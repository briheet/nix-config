{ pkgs, ... }:
{
  programs.fish = {

    enable = true;
    shellInit = ''
      set -g fish_color_host purple
      set -g fish_color_cwd purple
    '';

    functions.fish_prompt = ''
      # Username @ host in purple
      set_color brmagenta
      echo -n "$USER@$hostname "

      # Directory in blue
      set_color blue
      echo -n (prompt_pwd)

      # Prompt arrow in purple
      set_color brmagenta
      echo -n " > "

      # Reset
      set_color normal
    '';
  };

  # Add bass plugin to source bash scripts
  home.packages = with pkgs; [
    fishPlugins.bass
  ];
}
