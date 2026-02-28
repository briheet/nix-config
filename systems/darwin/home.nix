{ inputs, pkgs, ... }:
{

  imports = [
    ../../modules/darwin/kitty.nix
    ../../modules/darwin/fish.nix
    ../../modules/darwin/tools.nix
    ../../modules/darwin/helix.nix
    ../../modules/darwin/alacritty.nix
    ../../modules/darwin/sketchybar.nix
    ../../modules/darwin/zen-browser.nix
    ../../modules/darwin/tmux.nix
  ];

  home.username = "briheet";
  home.homeDirectory = "/Users/briheet";
  home.stateVersion = "25.05";
}
