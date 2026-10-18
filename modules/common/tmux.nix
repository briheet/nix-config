{ pkgs, ... }:
{

  programs.tmux = {

    enable = true;
    clock24 = true;

    keyMode = "vi";
    mouse = true;
    prefix = "C-b";

    secureSocket = true;

    shell = "${pkgs.nushell}/bin/nu";
    terminal = "tmux-256color";

    extraConfig = ''
        set -g visual-activity off
        set -g visual-bell off
        set -g visual-silence off
        setw -g monitor-activity off
        set -g bell-action none

        # Status bar
        set -g status-position bottom

        #Mouse
        set -g mouse on

        # Plane
        set -g base-index 1
        set -g pane-base-index 1

        # Escape time
        set -sg escape-time 10

        # Catppuccin Mocha status bar (must run after the plugin is sourced;
        # home-manager appends programs.tmux.extraConfig after all plugins).
        set -g status-left-length 100
        set -g status-right-length 100
        set -g status-left ""
        set -g status-right "#{E:@catppuccin_status_application}"
        set -ag status-right "#{E:@catppuccin_status_session}"
        set -ag status-right "#{E:@catppuccin_status_host}"
      '';

    plugins = [
      # Nord (previous theme):
      # pkgs.tmuxPlugins.nord

      # https://github.com/catppuccin/tmux
      {
        plugin = pkgs.tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor 'mocha'
          set -g @catppuccin_window_status_style 'rounded'
          set -g @catppuccin_window_number_position 'right'
          set -g @catppuccin_window_text ' #W'
          set -g @catppuccin_window_current_text ' #W'
        '';
      }

      pkgs.tmuxPlugins.yank
    ];

  };

}
