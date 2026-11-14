# The J614s boot chain, all aurora-silicon's (aura, aurora U-Boot, aurora
# kernel), built from nix-config's own flake inputs:
#
#   iBoot -> aura Stage 1 (padded Mach-O boot object, enrolled with kmutil
#            on Macintosh HD from its recoveryOS)
#         -> m1n1/boot-ctxr.bin on the ESP: aura Stage 2 + t6040-j614s.dtb
#            + U-Boot (rewritten with every generation, since the DTB is the
#            generation's kernel's)
#         -> U-Boot's extlinux menu -> the generation's kernel, which runs
#            in aura's CTXR execute window
#
# Stage 1 changes only from recoveryOS (kmutil, with the owner's password).
# Each switch also writes the Stage 1 this generation would use to the ESP,
# with a script that enrolls it, and `aura-status` says when the Stage 1 that
# booted is not that one.
#
# On the ESP:
#   m1n1/boot-ctxr.bin        Stage 2, what Stage 1 loads
#   m1n1/boot-ctxr.bin.prev   the Stage 2 it replaced (copy back from recoveryOS)
#   aura/stage1.macho.gz      Stage 1 for this generation, .md5 of the unpacked
#                             object, stage1.version its tag
#   aura/enroll-stage1.sh     aura's enroll script
#   aura/install-stage1.sh    unpacks stage1.macho and runs it (recoveryOS)
#   aura-proxy                (touch it) Stage 1 waits for a host on USB: the
#                             aura proxy, for tethered work
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.hardware.j614s.boot;
  extlinux = config.boot.loader.generic-extlinux-compatible;
  kernel = config.boot.kernelPackages.kernel;

  aura = pkgs.callPackage ./pkgs/aura.nix { src = inputs.aura; };
  uBoot = pkgs.callPackage ./pkgs/u-boot.nix { src = inputs.u-boot; };
  stage1 = pkgs.callPackage ./pkgs/aura-stage1.nix { inherit aura; inherit (cfg) espPartuuid; };
  stage2 = pkgs.callPackage ./pkgs/aura-stage2.nix {
    inherit aura kernel uBoot;
    kernelRev = inputs.linux.rev;
  };
  stage1Version = aura.versionTag;

  installStage1 = pkgs.writeText "install-stage1.sh" ''
    #!/bin/bash
    # Enrolls aura Stage 1 from this ESP as the boot object of a macOS volume
    # (Macintosh HD by default). In recoveryOS (shut down, hold the power
    # button until "Loading startup options", Options), Terminal:
    #
    #   diskutil mount disk0s4                         (the ESP)
    #   bash /Volumes/NIXBOOT/aura/install-stage1.sh   [VOLUME [enroll options]]
    #
    # VOLUME defaults to ${cfg.stage1Volume}. Further options go to aura's
    # enroll-stage1.sh (--check runs every check and stops; --keep FILE MD5
    # names a rollback image; the default is --no-rollback).
    set -e
    dir=$(cd "$(dirname "$0")" && pwd)
    volume="''${1:-${cfg.stage1Volume}}"
    [ $# -gt 0 ] && shift
    [ $# -gt 0 ] || set -- --no-rollback

    echo "aura Stage 1 $(cat "$dir/stage1.version") for $volume"
    echo "Unpacking the padded boot object (about 150 MB) next to it..."
    gunzip -c "$dir/stage1.macho.gz" > "$dir/stage1.macho"
    trap 'rm -f "$dir/stage1.macho"' EXIT
    bash "$dir/enroll-stage1.sh" --compress "$@" "$volume" "$dir/stage1.macho" "$(cat "$dir/stage1.macho.md5")"
  '';

  status = pkgs.writeShellApplication {
    name = "aura-status";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      chosen=/proc/device-tree/chosen
      prop() { if [ -r "$chosen/$1" ]; then tr -d '\0' < "$chosen/$1"; else echo "unknown"; fi; }
      esp() { if [ -r "/boot/aura/$1" ]; then cat "/boot/aura/$1"; else echo "none"; fi; }
      running=$(prop asahi,m1n1-stage1-version)
      onesp=$(esp stage1.version)

      if [ "''${1:-}" = "--record" ]; then
        if [ "$running" != "$onesp" ] && [ "$onesp" != "none" ]; then
          echo "aura Stage 1: booted $running, this generation's is $onesp."
          echo "  To update it, in recoveryOS Terminal: bash /Volumes/NIXBOOT/aura/install-stage1.sh"
        fi
        exit 0
      fi

      echo "iBoot               $(prop asahi,iboot1-version) / $(prop asahi,iboot2-version)"
      echo "aura Stage 1        booted $running, on the ESP $onesp"
      echo "aura Stage 2        booted $(prop asahi,m1n1-stage2-version)"
      echo "CTXR window         $(if [ -e "$chosen/aurora,ctxr-exec-window" ]; then echo present; else echo absent; fi)"
      echo "U-Boot              booted $(prop u-boot,version)"
      echo "kernel              booted $(uname -r)"
      echo "proxy on next boot  $(if [ -e /boot/aura-proxy ]; then echo yes; else echo no; fi)"
    '';
  };
in
{
  options.hardware.j614s.boot = {
    espPartuuid = lib.mkOption {
      type = lib.types.str;
      default = "c1689edb-3947-4ed4-ba55-696ead4f2833";
      description = "PARTUUID of the ESP (nixos-boot); Stage 1 loads Stage 2 from it.";
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
    system.build = {
      auraStage1 = stage1;
      auraStage2 = stage2;
      inherit aura uBoot;
      # What the boot loader install puts on the ESP besides extlinux, as a
      # tree: for seeding a new ESP from macOS (flake package j614s-esp).
      auraEsp = pkgs.runCommand "j614s-aura-esp" { } ''
        install -Dm644 ${stage2}/boot-ctxr.bin $out/m1n1/boot-ctxr.bin
        install -Dm644 ${stage1}/stage1.macho.gz $out/aura/stage1.macho.gz
        install -Dm644 ${stage1}/stage1.macho.md5 $out/aura/stage1.macho.md5
        install -Dm644 ${stage1}/enroll-stage1.sh $out/aura/enroll-stage1.sh
        install -Dm644 ${installStage1} $out/aura/install-stage1.sh
        echo ${stage1Version} > $out/aura/stage1.version
      '';
    };

    fileSystems."/" = {
      device = "/dev/disk/by-partlabel/nixos";
      fsType = "ext4";
    };
    fileSystems."/boot" = {
      device = "/dev/disk/by-partlabel/nixos-boot";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;
    # Each generation's kernel and initrd (about 40 MB) go on the 512 MiB ESP,
    # beside Stage 1 (a few MB gzipped).
    boot.loader.generic-extlinux-compatible.configurationLimit = lib.mkDefault 6;
    # Linux gets the device tree aura filled in (memory, CPUs, framebuffer,
    # carveouts, the CTXR window), which U-Boot passes on.
    boot.loader.generic-extlinux-compatible.useGenerationDeviceTree = false;
    hardware.deviceTree.name = "apple/t6040-j614s.dtb";

    environment.systemPackages = [ status ];

    systemd.services.aura-status = {
      description = "Say when the aura Stage 1 that booted is not this generation's";
      wantedBy = [ "multi-user.target" ];
      unitConfig.RequiresMountsFor = "/boot";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${status}/bin/aura-status --record";
      };
    };

    # The extlinux installer, then Stage 2 and Stage 1: each file written
    # beside the old one and renamed over it, so a failed copy leaves the
    # previous file whole.
    system.build.installBootLoader = lib.mkForce (
      pkgs.writeShellScript "install-extlinux-aura" ''
        set -eu
        export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.diffutils ]}:$PATH
        ${extlinux.populateCmd} -d /boot -c "$@"

        put() { # put SRC DEST: replace DEST only if it differs
          if ! cmp -s "$1" "$2"; then
            install -D -m 644 "$1" "$2.new"
            sync -f "$2.new"
            mv "$2.new" "$2"
          fi
        }

        if [ -e /boot/m1n1/boot-ctxr.bin ] && ! cmp -s /boot/m1n1/boot-ctxr.bin ${stage2}/boot-ctxr.bin; then
          put /boot/m1n1/boot-ctxr.bin /boot/m1n1/boot-ctxr.bin.prev
        fi
        put ${stage2}/boot-ctxr.bin /boot/m1n1/boot-ctxr.bin

        put ${stage1}/stage1.macho.gz /boot/aura/stage1.macho.gz
        put ${stage1}/stage1.macho.md5 /boot/aura/stage1.macho.md5
        put ${stage1}/enroll-stage1.sh /boot/aura/enroll-stage1.sh
        put ${installStage1} /boot/aura/install-stage1.sh
        echo ${stage1Version} > /boot/aura/stage1.version
        ${status}/bin/aura-status --record
      ''
    );
  };
}
