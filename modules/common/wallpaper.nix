{ pkgs, ... }:

let
  wallpaperDir = "$HOME/Pictures/wallpapers";
  changeWallpaper = pkgs.writeShellScript "change-wallpaper" ''
    wallpaper=$(
      ${pkgs.findutils}/bin/find "${wallpaperDir}" -type f \
        | ${pkgs.coreutils}/bin/shuf -n 1
    )

    ${pkgs.desktoppr}/bin/desktoppr "$wallpaper"
  '';
in
{

  programs.desktoppr = {
    enable = true;
  };

  launchd.agents.wallpaper = {
    enable = true;

    config = {
      ProgramArguments = [
        "${changeWallpaper}"
      ];

      RunAtLoad = true;
      StartInterval = 1800;
    };
  };

}
