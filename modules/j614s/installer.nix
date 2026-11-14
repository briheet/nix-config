# NixOS from RAM on the J614s, which installs a system onto the SSD from git.
#
# It boots the way an installed system does: aura Stage 2, U-Boot loading
# EFI/BOOT/BOOTAA64.EFI from the ESP, GRUB (a standalone one whose only entry
# is this image), then nixos-aurora's kernel, the same store path an installed
# kyokasuigetsu uses. Its Stage 2 is the bring-up one (pkgs/bringup-stage2.nix):
# Aurora's, with the debug UART in the device tree, so the whole boot can be
# watched and driven over debug USB (kis channel 1; root is logged in on
# ttyDC0).
#
#   nmtui           join Wi-Fi first
#   j614s-install [FLAKE]
#                   create `nixos` (ext4) in the largest free block after the
#                   ESP and nixos-install FLAKE (default
#                   github:briheet/nix-config#kyokasuigetsu), which writes
#                   GRUB and Aurora's Stage 2 over this installer's. Asks
#                   before writing anything.
#
# Log in on the screen as root (no password, this image only), on the debug
# UART, or over SSH with the keys in hosts/hetzner/secrets.txt.
{ config, lib, pkgs, modulesPath, inputs, ... }:

let
  espPartuuid = config.hardware.j614s.boot.espPartuuid;

  install = pkgs.writeShellApplication {
    name = "j614s-install";
    runtimeInputs = with pkgs; [ gptfdisk e2fsprogs util-linux coreutils gnugrep systemd config.system.build.nixos-install config.nix.package ];
    text = ''
      disk=/dev/nvme0n1
      esp=/dev/disk/by-partuuid/${espPartuuid}
      root=/dev/disk/by-label/nixos
      flake=''${1:-github:briheet/nix-config#kyokasuigetsu}
      die() { echo "j614s-install: $*" >&2; exit 1; }

      [ -b "$disk" ] || die "$disk not found"
      nix --extra-experimental-features "nix-command flakes" flake metadata "''${flake%%#*}" >/dev/null ||
        die "cannot fetch ''${flake%%#*}; join Wi-Fi with nmtui first"
      [ -e "$esp" ] || die "no partition with PARTUUID ${espPartuuid} (the ESP)"
      [ "$(blkid -o value -s TYPE "$esp")" = vfat ] || die "$esp is not FAT"
      espnum=$(cat "/sys/class/block/$(basename "$(readlink -f "$esp")")/partition")

      sgdisk -p "$disk"
      if [ -e "$root" ]; then
        echo "A filesystem labelled nixos exists already: installing into it, not formatting."
      else
        ss=$(blockdev --getss "$disk")
        first=$(sgdisk -a $((1048576 / ss)) -F "$disk")
        last=$(sgdisk -E "$disk")
        [ $(( (last - first + 1) * ss )) -ge $((32 * 1024 * 1024 * 1024)) ] ||
          die "largest free block is $(( (last - first + 1) * ss / 1048576 )) MiB"
        espend=$(sgdisk -i "$espnum" "$disk" | grep '^Last sector' | grep -Eo '[0-9]+' | head -n 1)
        [ "$first" -gt "$espend" ] || die "the free block does not follow the ESP"
        echo
        echo "Will: create 'nixos' ext4 in sectors $first-$last ($(( (last - first + 1) * ss / 1073741824 )) GiB);"
        echo "      nixos-install --flake $flake"
        read -r -p "Type yes to go on: " ok
        [ "$ok" = yes ] || die "stopped; nothing written"
        sgdisk -b /root/gpt-before.bin "$disk" >/dev/null
        sgdisk -n "0:$first:$last" -t 0:8300 -c 0:nixos "$disk"
        sgdisk -v "$disk" | grep -q "No problems found" || die "sgdisk -v reports problems"
        partprobe "$disk" || blockdev --rereadpt "$disk" || true
        udevadm settle
        part=/dev/disk/by-partlabel/nixos
        [ -e "$part" ] || die "the nixos partition did not appear"
        mkfs.ext4 -q -L nixos "$part"
        udevadm settle
      fi

      mkdir -p /mnt
      mountpoint -q /mnt && die "/mnt is already mounted"
      mount "$root" /mnt
      mkdir -p /mnt/boot
      mount -o fmask=0077,dmask=0077 "$esp" /mnt/boot
      trap 'umount -R /mnt' EXIT
      nixos-install --flake "$flake" --no-root-passwd --no-channel-copy
      echo
      echo "Installed $flake. Set your password: nixos-enter --root /mnt -c 'passwd briheet'"
      echo "Then reboot."
    '';
  };
in
{
  imports = [
    (modulesPath + "/installer/netboot/netboot.nix")
    (modulesPath + "/profiles/minimal.nix")
    inputs.nixos-aurora.inputs.apple-silicon.nixosModules.default
    ./hardware.nix
  ];

  options.hardware.j614s.boot.espPartuuid = lib.mkOption { type = lib.types.str; };

  config = {
    nixpkgs.hostPlatform = "aarch64-linux";
    nixpkgs.overlays = [
      inputs.nixos-aurora.inputs.apple-silicon.overlays.default
      inputs.nixos-aurora.overlays.default
    ];
    nixpkgs.config.allowUnfree = true;
    # Aurora's installer would have put this Mac's firmware on the ESP;
    # ./hardware.nix has it in the store instead.
    hardware.asahi.extractPeripheralFirmware = false;

    system.stateVersion = "26.05";
    networking.hostName = "j614s-installer";
    networking.networkmanager.enable = true;
    # The kernel's squashfs has zlib and xz, not zstd.
    netboot.squashfsCompression = "xz -Xdict-size 100%";

    # Every kernel message, on the screen and on the debug UART.
    boot.consoleLogLevel = lib.mkForce 7;
    boot.kernelParams = [ "earlycon" "console=tty0" "console=ttyDC0" ];

    users.users.root.hashedPassword = lib.mkForce "";
    services.getty.autologinUser = "root";
    systemd.services."serial-getty@ttyDC0" = {
      wantedBy = [ "getty.target" ];
      overrideStrategy = "asDropin";
      serviceConfig.ExecStart = [
        ""
        "${pkgs.util-linux}/bin/agetty --login-program ${config.services.getty.loginProgram} --autologin root --noclear --keep-baud %I 115200,38400,9600 $TERM"
      ];
    };
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    users.users.root.openssh.authorizedKeys.keyFiles = [ ../../hosts/hetzner/secrets.txt ];

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      extra-substituters = [ "https://aurorasilicon.org/nixos-aurora/cache" ];
      extra-trusted-public-keys = [ "aurora-nixos-1:ZxmPNEWsrzgXai+W+dlTE8cachb1xaatfXKK8X8go14=" ];
    };
    environment.systemPackages = [ install pkgs.git ];
  };
}
