# Hyprland's config on NixOS hosts with modules/j614s/desktop.nix.
# Hyprland itself, greetd and the apps come from the NixOS side.
{ pkgs, ... }:
let
  wallpaper = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
in
{
  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;

  # The wallpaper: hyprpaper (Hyprland's own), started by hyprland.lua, with
  # NixOS's nineish dark grey from nixpkgs. hyprpaper 0.8 syntax: a
  # `wallpaper` block per output; eDP-1 is the internal panel.
  home.packages = [ pkgs.hyprpaper ];
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    splash = false
    ipc = true

    wallpaper {
      monitor = eDP-1
      path = ${wallpaper}
      fit_mode = cover
    }
  '';
}
