# This deals with home manager modules between command and darwin specific configs
{ ... }:
{
  imports = [
    ../../modules/common/nushell.nix
    ../../modules/common/tools.nix
    ../../modules/common/helix.nix
    ../../modules/common/aerospace.nix
    ../../modules/common/wallpaper.nix
    ../../modules/common/sketchybar.nix
    ../../modules/common/ghostty.nix
  ];

  home.username = "briheet";
  home.homeDirectory = "/Users/briheet";
  home.stateVersion = "25.05";
}
