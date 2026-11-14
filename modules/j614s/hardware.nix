# The J614s (MacBook Pro 14", M4 Pro) on top of nixos-aurora: what Aurora's
# modules don't already provide for this Mac.
#
# Aurora's kernel, initrd and peripheral handling come from its modules
# (./default.nix). Aurora's installer puts this Mac's Apple firmware on the
# ESP (vendorfw/firmware.cpio), which we don't have, so the trackpad, Wi-Fi
# and Bluetooth firmware come from the store instead (pkgs/j614s-firmware.nix,
# by hash); the kernel finds it on its normal firmware path.
{ lib, pkgs, ... }:

{
  hardware.firmware = [ (pkgs.callPackage ./pkgs/j614s-firmware.nix { }) ];
  # The keyboard and trackpad probe in the initrd.
  boot.initrd.extraFirmwarePaths = [ "apple/tpmtfw-j614s.bin" ];

  # A large console font for the 3024x1890 panel (Terminus 32 px).
  console = {
    earlySetup = lib.mkDefault true;
    packages = [ pkgs.terminus_font ];
    font = lib.mkDefault "ter-v32n";
  };
}
