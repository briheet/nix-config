{ pkgs, ... }:
{
  programs.fish = {

    enable = true;

    interactiveShellInit = ''
      # Syntax highlighting
      set -g fish_color_normal d4be98
      set -g fish_color_command a9b665
      set -g fish_color_keyword ea6962
      set -g fish_color_quote d8a657
      set -g fish_color_redirection 7daea3
      set -g fish_color_end e78a4e
      set -g fish_color_error ea6962
      set -g fish_color_param d4be98
      set -g fish_color_comment 928374
      set -g fish_color_selection --background=45403d
      set -g fish_color_operator e78a4e
      set -g fish_color_escape 89b482
      set -g fish_color_autosuggestion 928374
      set -g fish_color_valid_path --underline
      set -g fish_color_cancel ea6962
      set -g fish_color_search_match --background=45403d d8a657
      set -g fish_color_cwd d8a657
      set -g fish_color_host 7daea3
      set -g fish_color_user a9b665
      set -g fish_color_status ea6962
      set -g fish_color_match 89b482
      set -g fish_color_history_current --bold

      # Pager colors
      set -g fish_pager_color_progress 928374
      set -g fish_pager_color_prefix a9b665
      set -g fish_pager_color_completion d4be98
      set -g fish_pager_color_description 928374
      set -g fish_pager_color_selected_background --background=45403d
    '';

    shellAliases = {
      ff = "fastfetch";
    };

    functions.fish_prompt = ''
      set_color e78a4e
      echo -n "❯ "
      set_color normal
    '';
  };

  # Add bass plugin to source bash scripts
  home.packages = with pkgs; [
    fishPlugins.bass
  ];
}
