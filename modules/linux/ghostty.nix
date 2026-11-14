# Ghostty on Linux, built from source (settings in modules/common/ghostty.nix).
{ pkgs, ... }:
{
  programs.ghostty.package = pkgs.ghostty;
}
