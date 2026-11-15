# Ghostty on Linux, built from source (settings in modules/common/ghostty.nix).
#
# One process for every window: a new window opens in the running instance
# instead of starting Ghostty (GTK, fonts, renderer) again, which took
# 90-250 ms per window on the M4 Pro (2026-11-15 frame trace). Hyprland starts
# the instance at login without a window (modules/linux/hyprland.lua), and it
# stays running after its last window closes.
{ pkgs, ... }:
{
  programs.ghostty.package = pkgs.ghostty;
  programs.ghostty.settings = {
    gtk-single-instance = true;
    quit-after-last-window-closed = false;
    # See-through background (Hyprland composites it on the GPU).
    background-opacity = 0.85;
  };
}
