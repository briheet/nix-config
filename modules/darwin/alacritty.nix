{ pkgs, ... }:
{

  home.packages = [ pkgs.alacritty.terminfo ];

  programs.alacritty = {
    enable = true;
    theme = "deep_space";

    settings = {
      env = {
        TERM = "xterm-256color";
        TERM_PROGRAM = "Alacritty";
        SHELL = "${pkgs.fish}/bin/fish";
      };

      window = {
        opacity = 0.7;
        blur = true;
      };

      terminal = {
        shell = "${pkgs.fish}/bin/fish";
      };

    };
  };

}
