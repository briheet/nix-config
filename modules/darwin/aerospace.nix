{ pkgs, ... }:
{

  programs.aerospace = {
    enable = false;
    launchd.enable = true;
  };

}
