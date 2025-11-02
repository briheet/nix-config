{ pkgs, ... }:

{

  home.packages = with pkgs; [
    helix
    starship
  ];
  
}
