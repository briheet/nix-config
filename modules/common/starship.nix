{pkgs, ...}: {
  home.packages = with pkgs; [
    nerd-fonts.iosevka
  ];

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;

    settings = {
      "$schema" = "https://starship.rs/config-schema.json";
      add_newline = false;
      # palette = "nord";
      palette = "catppuccin_mocha";
      continuation_prompt = "[∙](overlay1) ";

      format = builtins.concatStringsSep "" [
        "[╭─](overlay1)"
        "$username"
        "$hostname"
        "[ in ](overlay1)"
        "$directory"
        "$git_branch"
        "$git_commit"
        "$git_status"
        "$git_state"
        "$nix_shell"
        "$line_break"
        "[╰─](overlay1)"
        "$character"
      ];
      right_format = "$status$cmd_duration";

      # Nord (previous palette):
      # palettes.nord = {
      # nord0 = "#2e3440";
      # nord1 = "#3b4252";
      # nord2 = "#434c5e";
      # nord3 = "#4c566a";
      # nord4 = "#d8dee9";
      # nord5 = "#e5e9f0";
      # nord6 = "#eceff4";
      # nord7 = "#8fbcbb";
      # nord8 = "#88c0d0";
      # nord9 = "#81a1c1";
      # nord10 = "#5e81ac";
      # nord11 = "#bf616a";
      # nord12 = "#d08770";
      # nord13 = "#ebcb8b";
      # nord14 = "#a3be8c";
      # nord15 = "#b48ead";
      # };

      # Official Catppuccin Mocha palette
      # https://github.com/catppuccin/starship
      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };

      username = {
        show_always = true;
        format = "[$user]($style)";
        style_user = "bold mauve";
        style_root = "bold red";
      };

      hostname = {
        ssh_only = false;
        format = "[@$hostname]($style)";
        style = "bold mauve";
        trim_at = ".";
      };

      directory = {
        format = "[$path]($style)[$read_only]($read_only_style) ";
        style = "bold blue";
        read_only = " ";
        read_only_style = "bold red";
        truncation_length = 4;
        truncate_to_repo = false;
      };

      git_branch = {
        format = "[on](overlay1) [$symbol$branch]($style) ";
        symbol = " ";
        style = "bold green";
        truncation_length = 32;
        truncation_symbol = "…";
      };

      git_commit = {
        only_detached = true;
        format = "[at](overlay1) [$hash$tag]($style) ";
        style = "bold sapphire";
        tag_disabled = false;
        tag_symbol = "  ";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        style = "bold yellow";
        conflicted = "=";
        ahead = "⇡";
        behind = "⇣";
        diverged = "⇕";
        untracked = "?";
        stashed = "≡";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "✘";
      };

      git_state = {
        format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
        style = "bold peach";
      };

      nix_shell = {
        format = "[via](overlay1) [$symbol$name]($style) ";
        symbol = " ";
        style = "bold lavender";
      };

      status = {
        disabled = false;
        format = "[$symbol$status]($style) ";
        symbol = "✘ ";
        style = "bold red";
      };

      cmd_duration = {
        min_time = 2000;
        format = "[took](overlay1) [$duration]($style)";
        style = "bold yellow";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
        vimcmd_replace_one_symbol = "[❮](bold lavender)";
        vimcmd_replace_symbol = "[❮](bold lavender)";
        vimcmd_visual_symbol = "[❮](bold yellow)";
      };
    };
  };
}
