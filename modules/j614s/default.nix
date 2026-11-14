# MacBook Pro 14" M4 Pro (J614s, T6040) on nixos-aurora, Aurora's standard
# NixOS for Apple silicon (the `nixos-aurora` input, a commit whose kernel,
# U-Boot and aura are in Aurora's binary cache): its kernel, initrd,
# firmware handling, U-Boot, aura and Stage 2 updates. A configuration using
# this must be built with nixos-aurora's nixpkgs (flake.nix) so those store
# paths match the cache.
#
#   ./boot.nix       SSD layout, aura Stage 1 on the ESP
#   ./hardware.nix   this Mac's Apple firmware, console font
#   ./desktop.nix    Hyprland (import separately); Aurora's desktop is off
#   ./installer.nix  a RAM installer for the first install (flake package
#                    j614s-esp)
{ inputs, ... }:

let
  aurora = inputs.nixos-aurora;
in
{
  imports = [
    aurora.inputs.apple-silicon.nixosModules.default
    aurora.nixosModules.default
    aurora.nixosModules.installed
    ./hardware.nix
    ./boot.nix
  ];

  nixpkgs.overlays = [
    aurora.inputs.apple-silicon.overlays.default
    aurora.overlays.default
  ];

  # No Aurora desktop or greeter: ./desktop.nix brings Hyprland.
  aurora.desktop = "minimal";
  # No Flatpak: software comes from Nix, and Aurora's Flatpak GL provider
  # (its GPU Mesa, inert here) held the greeter back 1.4 s at boot.
  aurora.flatpak.enable = false;
}
