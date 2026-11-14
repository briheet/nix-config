# The J614s boot chain, nixos-aurora's:
#
#   iBoot -> aura Stage 1 (raw, enrolled with kmutil --raw on Macintosh HD
#            from its recoveryOS, Kernel CTRR off; pkgs/aura-stage1.nix says
#            why not the padded Mach-O object)
#         -> m1n1/boot-ctxr.bin on the ESP: aura Stage 2 + this kernel's
#            Apple device trees + U-Boot, which nixos-aurora's installed
#            module rewrites (as a trial, then committed) on every
#            bootloader install
#         -> U-Boot loads EFI/BOOT/BOOTAA64.EFI from the partition aura came
#            from -> GRUB -> the generation's kernel
#
# Stage 1 is the one part nixos-aurora never writes (its installer enrolls
# it). Here it is built from Aurora's aura package (pkgs/aura-stage1.nix) and
# every bootloader install puts it on the ESP with its enroll script; enroll
# it from recoveryOS:
#
#   bash /Volumes/NIXBOOT/aura/install-stage1.sh
#
# `aura-status` shows what booted. On the ESP:
#   aura/stage1.bin, .md5, stage1.version, enroll-stage1.sh, install-stage1.sh
#   aura-proxy   (touch it) Stage 1 waits for a host on USB: the aura proxy
{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.j614s.boot;
  aura = pkgs.m1n1;
  stage1 = pkgs.callPackage ./pkgs/aura-stage1.nix { inherit aura; inherit (cfg) espPartuuid; };

  installStage1 = pkgs.writeText "install-stage1.sh" ''
    #!/bin/bash
    # Enrolls aura Stage 1 from this ESP as the boot object of a macOS volume
    # (${cfg.stage1Volume} by default). In recoveryOS (shut down, hold the
    # power button until "Loading startup options", Options), Terminal:
    #
    #   bash /Volumes/NIXBOOT/aura/install-stage1.sh   [VOLUME [enroll options]]
    #
    # Startup Security Utility must allow Reduced Security for the volume
    # first. A raw Stage 1 needs Kernel CTRR off: if bputil reports it on,
    # this runs `bputil -nc` (it asks for the owner's password). Further
    # options go to aura's enroll-stage1.sh (--check runs every check and
    # stops; --keep FILE MD5 names a rollback image; the default is
    # --no-rollback). recoveryOS has no grep or cat: bash builtins and sed.
    set -e
    dir=$(cd "$(dirname "$0")" && pwd)
    volume="''${1:-${cfg.stage1Volume}}"
    [ $# -gt 0 ] && shift
    [ $# -gt 0 ] || set -- --no-rollback
    read -r version < "$dir/stage1.version"
    read -r md5 < "$dir/stage1.bin.md5"
    echo "aura Stage 1 $version (raw) for $volume"
    group=$(diskutil info "/Volumes/$volume" | sed -n 's/^ *APFS Volume Group: *//p')
    if [ -n "$group" ] && [ -n "$(bputil -d -v "$group" 2>&1 | sed -n '/Kernel CTRR Status: *Enabled/p')" ]; then
      echo "Kernel CTRR is on for $volume; turning it off (bputil -nc), which asks for your password."
      bputil -nc -v "$group"
    fi
    bash "$dir/enroll-stage1.sh" --raw "$@" "$volume" "$dir/stage1.bin" "$md5"
  '';

  esp = config.boot.loader.efi.efiSysMountPoint;
  status = pkgs.writeShellApplication {
    name = "aura-status";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      chosen=/proc/device-tree/chosen
      prop() { if [ -r "$chosen/$1" ]; then tr -d '\0' < "$chosen/$1"; else echo "unknown"; fi; }
      echo "iBoot               $(prop asahi,iboot1-version) / $(prop asahi,iboot2-version)"
      echo "aura Stage 1        booted $(prop asahi,m1n1-stage1-version), on the ESP $(cat ${esp}/aura/stage1.version 2>/dev/null || echo none)"
      echo "aura Stage 2        booted $(prop asahi,m1n1-stage2-version)"
      echo "CTXR window         $(if [ -e "$chosen/aurora,ctxr-exec-window" ]; then echo present; else echo absent; fi)"
      echo "kernel              booted $(uname -r)"
      echo "proxy on next boot  $(if [ -e ${esp}/aura-proxy ]; then echo yes; else echo no; fi)"
    '';
  };
in
{
  options.hardware.j614s.boot = {
    espPartuuid = lib.mkOption {
      type = lib.types.str;
      description = "PARTUUID of the ESP; aura Stage 1 loads Stage 2 from it.";
    };
    stage1Volume = lib.mkOption {
      type = lib.types.str;
      default = "Macintosh HD";
      description = ''
        The macOS volume whose boot policy holds Stage 1. On this Mac it is
        Macintosh HD itself (an empty macOS kept for its paired recoveryOS):
        selecting it at startup boots aura, and Full Security in Startup
        Security Utility boots macOS again.
      '';
    };
  };

  config = {
    system.build = { auraStage1 = stage1; inherit installStage1; };

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    fileSystems.${esp} = {
      device = "/dev/disk/by-partuuid/${cfg.espPartuuid}";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
    # Kernels and initrds of every generation GRUB lists go on the 4 GB ESP.
    boot.loader.grub.configurationLimit = lib.mkDefault 8;

    environment.systemPackages = [ status ];

    # After GRUB and Aurora's Stage 2: this generation's Stage 1 and its
    # recoveryOS enroll script.
    boot.loader.grub.extraInstallCommands = lib.mkAfter ''
      put() {
        if ! ${pkgs.diffutils}/bin/cmp -s "$1" "$2"; then
          ${pkgs.coreutils}/bin/install -D -m 644 "$1" "$2.new"
          ${pkgs.coreutils}/bin/sync -f "$2.new"
          ${pkgs.coreutils}/bin/mv "$2.new" "$2"
        fi
      }
      for f in stage1.bin stage1.bin.md5 stage1.version enroll-stage1.sh; do
        put ${stage1}/$f ${esp}/aura/$f
      done
      put ${installStage1} ${esp}/aura/install-stage1.sh
      rm -f ${esp}/aura/stage1.macho ${esp}/aura/stage1.macho.md5
    '';
  };
}
