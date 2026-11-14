# Hyprland's config on NixOS hosts with modules/j614s/desktop.nix.
# Hyprland itself, greetd and the apps come from the NixOS side.
{ ... }:
{
  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;
}
