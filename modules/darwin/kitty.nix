{ pkgs, ... }:

{

  home.packages = with pkgs; [
    kitty
  ];

  programs.kitty = {
    enable = true;
    themeFile = "Everforest_Dark_Hard";
  };

      
}
