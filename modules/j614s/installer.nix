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
    netboot.squashfsCompression = "xz -Xdict-size 100%";
    # netboot mounts the store image with threads=multi, which Aurora's
    # kernel (single-threaded squashfs, no CHOICE_DECOMP_BY_MOUNT) rejects
    # with EINVAL, so the initrd never got its /nix/store (2026-11-15).
    fileSystems."/nix/.ro-store".options = lib.mkForce [ "loop" ];
    # A failure in this image's initrd opens a root shell, not a locked one.
    boot.initrd.systemd.emergencyAccess = true;

    # Aurora's initrd module set (nixos-aurora modules/aurora.nix), not
    # NixOS's PC defaults, which this kernel doesn't build.
    boot.initrd.includeDefaultModules = false;
    boot.initrd.availableKernelModules = [
      "apple-mailbox" "apple_nvmem_spmi" "nvme_apple" "pinctrl-apple-gpio"
      "macsmc" "macsmc-power" "macsmc-input" "macsmc-hwmon" "macsmc-reboot"
      "i2c-pasemi-platform" "tps6598x" "sn201202x" "thunderbolt_apple" "apple-dart" "dwc3"
      "dwc3-of-simple" "xhci-pci" "pcie-apple" "gpio_macsmc" "phy-apple-atc"
      "nvmem_apple_efuses" "spi-apple" "spi-hid-apple" "spi-hid-apple-of"
      "rtc-macsmc" "spmi-apple-controller" "apple-dockchannel" "dockchannel-hid"
      "apple-rtkit-helper" "usb-storage" "xhci-plat-hcd" "usbhid" "hid_generic"
      "nvme" "uas" "sd_mod" "vfat" "ext4"
    ];
    # Macs have no TPM, and this kernel has no TPM drivers (as Aurora's).
    boot.initrd.systemd.tpm2.enable = false;
    # No sound in the installer (the Apple Silicon module's audio stack).
    hardware.asahi.setupAsahiSound = false;

    # Every kernel message, on the screen and on the debug UART.
    boot.consoleLogLevel = lib.mkForce 7;
    # aura drops stdout-path on a non-debug boot, so earlycon names the
    # UART (DockChannel channel 1's data window, ../dts/j614s-debug-uart.dtsi).
    boot.kernelParams = [ "earlycon=dockchannel,0x50883c000" "console=tty0" "console=ttyDC0" ];

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
