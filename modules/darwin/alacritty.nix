{ pkgs, ... }:
{

  home.packages = [ pkgs.alacritty.terminfo ];

  programs.alacritty = {
    enable = true;
    theme = "gruvbox_material_medium_dark";

    settings = {
      env = {
        TERM = "xterm-256color";
        TERM_PROGRAM = "Alacritty";
        SHELL = "${pkgs.fish}/bin/fish";
      };

      window = {
        opacity = 1.0;
        blur = false;
        decorations = "Full";
      };

      terminal = {
        shell = "${pkgs.fish}/bin/fish";
      };

    };
  };

}
