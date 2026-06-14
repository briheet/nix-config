{ pkgs, ... }:
{

  home.packages = [ pkgs.alacritty.terminfo ];

  programs.alacritty = {
    enable = true;
    # theme = "gruvbox_material_medium_dark";
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
        opacity = 0.9;
        blur = true;
        decorations = "Full";
      };

      terminal = {
        # shell = "${pkgs.fish}/bin/fish";
        shell = "${pkgs.nushell}/bin/nu";
      };

    };
  };

}
