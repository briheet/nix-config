{ pkgs, ... }:
let
  # Official Catppuccin Mocha flavor from the Yazi flavor collection.
  # https://github.com/yazi-rs/flavors
  catppuccin-mocha-flavor =
    let
      src = pkgs.fetchFromGitHub {
        owner = "yazi-rs";
        repo = "flavors";
        rev = "20b47bfd78880c2674899597fd26bc01b21ff48c";
        hash = "sha256-NGnfrQdsnQITKCZ0oh6DCxeCR2ozJoPAZetsi3ghHAI=";
      };
    in
    "${src}/catppuccin-mocha.yazi";
in
{
  programs.yazi = {
    enable = true;

    enableNushellIntegration = true;
    shellWrapperName = "y";

    extraPackages = [ pkgs.glow ];

    # Nord (previous theme):
    # flavors.nord = pkgs.yaziPlugins.nord;
    # theme.flavor = {
    #   dark = "nord";
    #   light = "nord";
    # };
    flavors.catppuccin-mocha = catppuccin-mocha-flavor;
    theme.flavor = {
      dark = "catppuccin-mocha";
      light = "catppuccin-mocha";
    };

    plugins = {
      piper = pkgs.yaziPlugins.piper;
      toggle-pane = pkgs.yaziPlugins.toggle-pane;
    };

    keymap.mgr.prepend_keymap = [
      {
        on = "T";
        run = "plugin toggle-pane max-preview";
        desc = "Maximize or restore preview";
      }
    ];

    settings = {
      # Parent directory, file list, preview: keep the file list narrow so previews get most of the window.
      mgr.ratio = [ 1 2 5 ];
      preview = {
        wrap = "yes";
        tab_size = 2;
      };

      # Keep the built-in code/media previewers; render Markdown with Glow.
      plugin.prepend_previewers = [
        {
          url = "*.md";
          run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'';
        }
      ];

      opener.edit = [
        {
          run = "hx %s";
          desc = "Helix";
          block = true;
          for = "unix";
        }
      ];
    };
  };
}
