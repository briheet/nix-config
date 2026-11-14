# Ghostty on macOS: the prebuilt app (settings in modules/common/ghostty.nix).
{ pkgs, ... }:
{
  programs.ghostty.package = pkgs.ghostty-bin;
}
