{ inputs, pkgs, ... }:
{

  imports = [
    ../../modules/darwin/nushell.nix
    ../../modules/darwin/tools.nix
    ../../modules/darwin/helix.nix
    ../../modules/darwin/alacritty.nix
    ../../modules/darwin/sketchybar.nix
    ../../modules/darwin/tmux.nix
    ../../modules/darwin/emacs.nix
  ];

  home.username = "briheet";
  home.homeDirectory = "/Users/briheet";
  home.stateVersion = "25.05";
}
