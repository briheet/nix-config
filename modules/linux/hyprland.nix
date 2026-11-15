# Hyprland's config on NixOS hosts with modules/j614s/desktop.nix.
# Hyprland itself, greetd and the apps come from the NixOS side.
{ pkgs, ... }:
{
  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;

  # The wallpaper: hyprpaper, as a user service of the graphical session,
  # with NixOS's nineish dark grey from nixpkgs. hyprpaper 0.8 takes a
  # `wallpaper` block per output; eDP-1 is the internal panel.
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      ipc = true;
      wallpaper = {
        monitor = "eDP-1";
        path = "${pkgs.nixos-artwork.wallpapers.simple-dark-gray.gnomeFilePath}";
        fit_mode = "cover";
      };
    };
  };
}
