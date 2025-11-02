{ pkgs, ... }:

{

  imports = [
    ../modules/darwin/kitty.nix
    ../modules/darwin/tools.nix
  ];

  home.username = "briheet";
  home.homeDirectory = "/Users/briheet";
  home.stateVersion = "25.05";
  
}
