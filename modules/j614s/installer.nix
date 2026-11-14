# NixOS from RAM on the J614s, which installs a system onto the SSD.
#
# U-Boot boots it from the ESP like any generation (extlinux entry
# "installer"): the netboot image, a small system in a squashfs inside the
# initrd. It carries only what has to be built once before the Mac runs
# Linux (aura, U-Boot, the kernel, the Apple firmware); the system itself is
# built on the Mac from git: `nixos-install --flake`, over Wi-Fi. The kernel
# and firmware it carries are the same store paths kyokasuigetsu uses, so
# nixos-install takes them from this image's store instead of rebuilding
# (the Apple firmware cannot be downloaded at all).
#
# The ESP comes from macOS (`diskutil apfs resizeContainer` with an MS-DOS
# partition after the container), so the PARTUUID aura Stage 1 loads from is
# whatever macOS gave it, set as hardware.j614s.boot.espPartuuid. The
# installer finds the ESP by that PARTUUID, then:
#
#   nmtui           join Wi-Fi first
#   j614s-install [FLAKE]
#                   label the ESP nixos-boot (type EF00), create `nixos`
#                   (ext4) in the largest free block after it, and
#                   nixos-install FLAKE (default
#                   github:briheet/nix-config#kyokasuigetsu). Asks before
#                   writing anything.
#
# Log in on the screen as root (no password, this image only), or over SSH
# with the keys in hosts/hetzner/secrets.txt.
{ config, lib, pkgs, modulesPath, ... }:

let
  espPartuuid = config.hardware.j614s.boot.espPartuuid;

  install = pkgs.writeShellApplication {
    name = "j614s-install";
    runtimeInputs = with pkgs; [ gptfdisk e2fsprogs util-linux coreutils gnugrep systemd config.system.build.nixos-install ];
    text = ''
      disk=/dev/nvme0n1
      esp=/dev/disk/by-partuuid/${espPartuuid}
      root=/dev/disk/by-partlabel/nixos
      flake=''${1:-github:briheet/nix-config#kyokasuigetsu}
      die() { echo "j614s-install: $*" >&2; exit 1; }

      [ -b "$disk" ] || die "$disk not found"
      nix --extra-experimental-features "nix-command flakes" flake metadata "''${flake%%#*}" >/dev/null ||
        die "cannot fetch ''${flake%%#*}; join Wi-Fi with nmtui first"
      [ -e "$esp" ] || die "no partition with PARTUUID ${espPartuuid} (the ESP macOS made)"
      [ "$(blkid -o value -s TYPE "$esp")" = vfat ] || die "$esp is not FAT"
      espnum=$(cat "/sys/class/block/$(basename "$(readlink -f "$esp")")/partition")

      sgdisk -p "$disk"
      if [ -e "$root" ]; then
        echo "A partition labelled nixos exists already: installing into it, not formatting."
      else
        ss=$(blockdev --getss "$disk")
        first=$(sgdisk -a $((1048576 / ss)) -F "$disk")
        last=$(sgdisk -E "$disk")
        [ $(( (last - first + 1) * ss )) -ge $((32 * 1024 * 1024 * 1024)) ] ||
          die "largest free block is $(( (last - first + 1) * ss / 1048576 )) MiB"
        espend=$(sgdisk -i "$espnum" "$disk" | grep '^Last sector' | grep -Eo '[0-9]+' | head -n 1)
        [ "$first" -gt "$espend" ] || die "the free block does not follow the ESP"
        echo
        echo "Will: label partition $espnum (ESP) nixos-boot, type EF00;"
        echo "      create 'nixos' ext4 in sectors $first-$last ($(( (last - first + 1) * ss / 1073741824 )) GiB);"
        echo "      nixos-install --flake $flake"
        read -r -p "Type yes to go on: " ok
        [ "$ok" = yes ] || die "stopped; nothing written"
        sgdisk -b /root/gpt-before.bin "$disk" >/dev/null
        sgdisk -c "$espnum:nixos-boot" -t "$espnum:ef00" \
               -n "0:$first:$last" -t 0:8300 -c 0:nixos "$disk"
        sgdisk -v "$disk" | grep -q "No problems found" || die "sgdisk -v reports problems"
        partprobe "$disk" || blockdev --rereadpt "$disk" || true
        udevadm settle
        [ -e "$root" ] || die "the nixos partition did not appear"
        mkfs.ext4 -q -L nixos "$root"
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
    ./hardware.nix
  ];

  options.hardware.j614s.boot.espPartuuid = lib.mkOption { type = lib.types.str; };

  config = {
    system.stateVersion = "26.05";
    networking.hostName = "j614s-installer";
    # The kernel's squashfs has zlib and xz, not zstd.
    netboot.squashfsCompression = "xz -Xdict-size 100%";

    users.users.root.hashedPassword = lib.mkForce "";
    services.getty.autologinUser = "root";
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    users.users.root.openssh.authorizedKeys.keyFiles = [ ../../hosts/hetzner/secrets.txt ];

    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    environment.systemPackages = [ install ];
  };
}
