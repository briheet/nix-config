# Hyprland's config on NixOS hosts with nixos-m4pro's desktop module.
# Hyprland itself, greetd and the apps come from the NixOS side.
{ ... }:
{
  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;
}
