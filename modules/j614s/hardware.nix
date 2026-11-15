# The J614s (MacBook Pro 14", M4 Pro) on top of nixos-aurora: what Aurora's
# modules don't already provide for this Mac.
#
# Aurora's kernel, initrd and peripheral handling come from its modules
# (./default.nix). Aurora's installer puts this Mac's Apple firmware on the
# ESP (vendorfw/firmware.cpio), which we don't have, so the trackpad, Wi-Fi
# and Bluetooth firmware come from the store instead (pkgs/j614s-firmware.nix,
# by hash); the kernel finds it on its normal firmware path.
{ config, lib, pkgs, ... }:

{
  hardware.firmware = [ (pkgs.callPackage ./pkgs/j614s-firmware.nix { }) ];

  # Our patches on top of nixos-aurora's kernel (./kernel-patches/*.patch, in
  # name order). None means Aurora's cached kernel is used as is.
  boot.kernelPatches = map (name: { inherit name; patch = ./kernel-patches + "/${name}"; })
    (lib.sort lib.lessThan (lib.filter (lib.hasSuffix ".patch")
      (builtins.attrNames (builtins.readDir ./kernel-patches))));
  # nixos-aurora's GPU and display drivers built on their own with
  # ./gpu-patches (pkgs/aurora-gpu.nix) and ./display-patches
  # (pkgs/aurora-display.nix), so driver work rebuilds only the module, not
  # the kernel.
  boot.extraModulePackages =
    let
      patchesIn = dir: map (name: dir + "/${name}")
        (lib.sort lib.lessThan (lib.filter (lib.hasSuffix ".patch")
          (builtins.attrNames (builtins.readDir dir))));
    in
    [
      (config.boot.kernelPackages.callPackage ./pkgs/aurora-gpu.nix {
        patches = patchesIn ./gpu-patches;
      })
      (config.boot.kernelPackages.callPackage ./pkgs/aurora-display.nix {
        patches = patchesIn ./display-patches;
      })
    ];
  # appledrm always loads: the GPU driver needs its symbols. It drives the
  # internal panel through the display coprocessor on the 27.2 firmware
  # (display-patches); the specialisation below is the fallback that leaves
  # the panel on the boot framebuffer (simpledrm): its own GRUB entry, which
  # `grub-reboot` can also pick for one boot (GRUB's default is the saved one).
  specialisation.simpledrm.configuration = {
    system.nixos.tags = [ "simpledrm" ];
    boot.kernelParams = [ "appledrm.t6041_fw27=0" ];
  };
  boot.loader.grub.default = "saved";

  # The keyboard and trackpad probe in the initrd.
  boot.initrd.extraFirmwarePaths = [ "apple/tpmtfw-j614s.bin" ];

  # nixos-aurora blacklists the Wi-Fi and Bluetooth drivers and loads them
  # from its firmware admission once the ESP's vendor firmware is in place;
  # with no vendorfw on this ESP they never loaded (2026-11-15). Load them
  # after Aurora's firmware step; the firmware is the store copy above.
  systemd.services.j614s-radios = {
    description = "Load the J614s Wi-Fi and Bluetooth drivers";
    wantedBy = [ "multi-user.target" ];
    after = [ "aurora-vendor-firmware.service" ];
    before = [ "NetworkManager.service" "bluetooth.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = [
        "${pkgs.kmod}/bin/modprobe brcmfmac"
        "-${pkgs.kmod}/bin/modprobe hci_bcm4377"
      ];
    };
  };

  # A large console font for the 3024x1890 panel (Terminus 32 px).
  console = {
    earlySetup = lib.mkDefault true;
    packages = [ pkgs.terminus_font ];
    font = lib.mkDefault "ter-v32n";
  };
}
