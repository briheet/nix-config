{ pkgs, ... }:

{

  home.packages = with pkgs; [
    kitty
  ];

  programs.kitty = {
    enable = true;
    # themeFile = "Solarized_Dark_-_Patched";
    themeFile = "Everforest_Dark_Hard";

    font = {
      name = "Caskaydia Cove";
      size = 12;
    };

    keybindings = {
      "ctrl+shift+t" = "launch --cwd=current --type=tab";
      "ctrl+q" = "close_window";

      # Tab switching
      "alt+1" = "goto_tab 1";
      "alt+2" = "goto_tab 2";
      "alt+3" = "goto_tab 3";
      "alt+4" = "goto_tab 4";
      "alt+5" = "goto_tab 5";
      "alt+6" = "goto_tab 6";
      "alt+7" = "goto_tab 7";
      "alt+8" = "goto_tab 8";
      "alt+9" = "goto_tab 9";

      # Clipboard
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";

      # Scrolling
      "ctrl+shift+up" = "scroll_line_up";
      "ctrl+shift+k" = "scroll_line_up";
      "ctrl+shift+down" = "scroll_line_down";
      "ctrl+shift+j" = "scroll_line_down";
      "ctrl+shift+page_up" = "scroll_page_up";
      "ctrl+shift+page_down" = "scroll_page_down";
      "ctrl+shift+home" = "scroll_home";
      "ctrl+shift+end" = "scroll_end";

      # Tab movement
      "ctrl+shift+." = "move_tab_forward";
      "ctrl+shift+," = "move_tab_backward";

      # Tab title
      "ctrl+shift+alt+t" = "set_tab_title";
      "f3" = "set_tab_title";

      # Font size
      "ctrl+shift+equal" = "change_font_size all +1.0";
      "ctrl+shift+minus" = "change_font_size all -1.0";
      "ctrl+alt+equal" = "change_font_size all 0";

      # Path hints
      "ctrl+shift+p>f" = "kitten hints --type path --program -";
      "ctrl+shift+p>shift+f" = "kitten hints --type path";

      # Misc
      "ctrl+shift+f5" = "load_config_file";
      "ctrl+shift+f11" = "toggle_fullscreen";

      # Delete word
      "ctrl+backspace" = "send_text all \\x17";
    };

    settings = {
      background_opacity = 0.7;
      background_tint = 0.5;
      macos_traditional_fullscreen = true;

      background_blur = 32;

      # cursor_trail = "1";
      # cursor_trail_decay = "0.1 0.4";
      # cursor_trail_start_threshold = "2";
      cursor_blink_interval = 0;

      shell = "${pkgs.fish}/bin/fish";
    };

  };

}
