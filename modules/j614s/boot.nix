# The J614s boot chain, nixos-aurora's:
#
#   iBoot -> aura Stage 1 (raw, enrolled with kmutil --raw on Macintosh HD
#            from its recoveryOS, Kernel CTRR off; pkgs/aura-stage1.nix says
#            why not the padded Mach-O object)
#         -> m1n1/boot-ctxr.bin on the ESP: Aurora's aura Stage 2 + this
#            kernel's J614s device tree (with the debug UART) + Aurora's
#            U-Boot (pkgs/bringup-stage2.nix), written by every bootloader
#            install, the previous one kept as boot-ctxr.bin.prev
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
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.hardware.j614s.boot;
  # Aurora's aura with the NixOS snowflake as its built-in logo
  # (boot.m1n1CustomLogo, as nixos-aurora's own modules apply it).
  aura = pkgs.m1n1.override { customLogo = config.boot.m1n1CustomLogo; };
  stage1 = pkgs.callPackage ./pkgs/aura-stage1.nix { inherit aura; inherit (cfg) espPartuuid; };
  stage2 = pkgs.callPackage ./pkgs/bringup-stage2.nix {
    inherit aura;
    uBoot = pkgs.uboot-asahi;
    kernel = config.boot.kernelPackages.kernel;
    kernelCommit = (lib.importJSON "${inputs.nixos-aurora}/kernel/provenance.json").kernel_commit;
    # aura keeps iBoot's whole framebuffer, notch rows included.
    variables = lib.optionalString cfg.showNotch "chosen.asahi,show-notch=1\n";
  };

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
    showNotch = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Give the OS the whole 3024x1964 panel, the strip beside the notch
        included, instead of the 3024x1890 below it (aura's
        chosen.asahi,show-notch=1, from the next boot after a rebuild).
      '';
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
    system.build = { auraStage1 = stage1; auraStage2 = stage2; inherit installStage1; };

    # nixos-aurora's Stage 2 updater commits a trial only when every device
    # tree device has bound; on the J614s sound-jack stays deferred, so no
    # trial ever commits and every later bootloader install is refused (and
    # its guard reboots the trial) (2026-11-15). Stage 2 is written below.
    aurora.stage2.enable = false;

    # The NixOS logo on aura's screen instead of Aurora's: Stage 2 shows it
    # from the next bootloader install; Stage 1 once it is enrolled again.
    boot.m1n1CustomLogo = "${pkgs.nixos-icons}/share/icons/hicolor/256x256/apps/nix-snowflake.png";

    # The GRUB menu, shown for 3 seconds (Aurora hides it, 1 second).
    boot.loader.grub.timeoutStyle = "menu";
    boot.loader.timeout = 3;

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

    # After GRUB: this generation's Stage 2 (the one it replaces kept as
    # .prev, any Aurora trial dropped), and Stage 1 with its recoveryOS
    # enroll script.
    boot.loader.grub.extraInstallCommands = lib.mkAfter ''
      put() {
        if ! ${pkgs.diffutils}/bin/cmp -s "$1" "$2"; then
          ${pkgs.coreutils}/bin/install -D -m 644 "$1" "$2.new"
          ${pkgs.coreutils}/bin/sync -f "$2.new"
          ${pkgs.coreutils}/bin/mv "$2.new" "$2"
        fi
      }
      if [ -e ${esp}/m1n1/boot-ctxr.bin ] && ! ${pkgs.diffutils}/bin/cmp -s ${esp}/m1n1/boot-ctxr.bin ${stage2}/boot-ctxr.bin; then
        put ${esp}/m1n1/boot-ctxr.bin ${esp}/m1n1/boot-ctxr.bin.prev
      fi
      put ${stage2}/boot-ctxr.bin ${esp}/m1n1/boot-ctxr.bin
      ${pkgs.coreutils}/bin/rm -f ${esp}/aura-try ${esp}/m1n1/boot-ctxr.bin.next ${esp}/m1n1/boot-ctxr.bin.next.json
      for f in stage1.bin stage1.bin.md5 stage1.version enroll-stage1.sh; do
        put ${stage1}/$f ${esp}/aura/$f
      done
      put ${installStage1} ${esp}/aura/install-stage1.sh
      ${pkgs.coreutils}/bin/rm -f ${esp}/aura/stage1.macho ${esp}/aura/stage1.macho.md5
    '';
  };
}
