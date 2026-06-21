{ pkgs, ... }:
{

  home.packages = [ pkgs.alacritty.terminfo ];

  programs.alacritty = {
    enable = true;
    theme = "ayu_mirage";
    # theme = "solarized_osaka";

    settings = {
      env = {
        TERM = "xterm-256color";
        TERM_PROGRAM = "Alacritty";
        # SHELL = "${pkgs.fish}/bin/fish";
        SHELL = "${pkgs.nushell}/bin/nu";
      };

      window = {
        opacity = 0.8;
        blur = false;
        decorations = "None";
      };

      terminal = {
        shell = "${pkgs.nushell}/bin/nu";
      };

    };
  };

}
