{config, ...}: {
  programs.nushell = {
    enable = true;
    extraEnv = ''
      $env.EDITOR = "hx"
      $env.VISUAL = "hx"
      $env.PATH = (
        $env.PATH
        | prepend "${config.home.homeDirectory}/.local/bin"
        | prepend "/etc/profiles/per-user/${config.home.username}/bin"
        | prepend "/run/current-system/sw/bin"
        | append "/usr/local/bin"
      )
    '';

    extraConfig = ''
      $env.config.buffer_editor = "hx"

      # Nord (previous theme):
      # let nord0 = "#2e3440"
      # let nord2 = "#434c5e"
      # let nord3 = "#4c566a"
      # let nord4 = "#d8dee9"
      # let nord6 = "#eceff4"
      # let nord7 = "#8fbcbb"
      # let nord8 = "#88c0d0"
      # let nord9 = "#81a1c1"
      # let nord10 = "#5e81ac"
      # let nord11 = "#bf616a"
      # let nord12 = "#d08770"
      # let nord13 = "#ebcb8b"
      # let nord14 = "#a3be8c"
      # let nord15 = "#b48ead"
      #
      # $env.config.color_config = {
      # foreground: $nord6
      # background: $nord0
      # cursor: $nord4
      #
      # shape_string: $nord14
      # shape_string_interpolation: { fg: $nord14 attr: b }
      # shape_raw_string: $nord14
      # shape_record: $nord6
      # shape_list: $nord6
      # shape_table: $nord6
      # shape_bool: { fg: $nord7 attr: b }
      # shape_int: { fg: $nord15 attr: b }
      # shape_float: { fg: $nord15 attr: b }
      # shape_range: { fg: $nord15 attr: b }
      # shape_binary: { fg: $nord15 attr: b }
      # shape_datetime: $nord12
      # shape_custom: $nord7
      # shape_nothing: { fg: $nord7 attr: b }
      # shape_literal: $nord6
      # shape_operator: $nord9
      # shape_filepath: $nord7
      # shape_directory: $nord7
      # shape_globpattern: { fg: $nord13 attr: b }
      # shape_glob_interpolation: { fg: $nord13 attr: b }
      # shape_garbage: { fg: $nord6 bg: $nord11 attr: b }
      # shape_variable: $nord4
      # shape_vardecl: { fg: $nord8 attr: b }
      # shape_matching_brackets: { fg: $nord8 attr: bu }
      # shape_pipe: { fg: $nord9 attr: b }
      # shape_internalcall: { fg: $nord8 attr: b }
      # shape_external: $nord8
      # shape_external_resolved: { fg: $nord8 attr: b }
      # shape_externalarg: $nord4
      # shape_match_pattern: $nord14
      # shape_block: $nord6
      # shape_signature: { fg: $nord8 attr: b }
      # shape_keyword: { fg: $nord9 attr: b }
      # shape_closure: { fg: $nord8 attr: b }
      # shape_redirection: { fg: $nord9 attr: b }
      # shape_flag: { fg: $nord9 attr: b }
      #
      # bool: $nord7
      # int: $nord15
      # string: $nord14
      # float: $nord15
      # glob: $nord13
      # closure: $nord8
      # binary: $nord4
      # binary_null_char: $nord3
      # binary_printable: $nord14
      # binary_whitespace: $nord7
      # binary_ascii_other: $nord9
      # binary_non_ascii: $nord13
      # custom: $nord7
      # nothing: $nord3
      # datetime: $nord12
      # filesize: $nord7
      # list: $nord6
      # record: $nord6
      # duration: $nord15
      # range: $nord15
      # semver: $nord7
      # semver-range: $nord7
      # cell-path: $nord4
      # block: $nord8
      #
      # hints: { fg: $nord3 attr: i }
      # search_result: { fg: $nord6 bg: $nord2 attr: b }
      # header: { fg: $nord8 attr: b }
      # separator: $nord3
      # row_index: { fg: $nord9 attr: b }
      # empty: $nord10
      # leading_trailing_space_bg: { attr: n }
      # banner_foreground: $nord6
      # banner_highlight1: $nord8
      # banner_highlight2: $nord15
      # }

      # Official Catppuccin Mocha theme
      # https://github.com/catppuccin/nushell (themes/catppuccin_mocha.nu)
      let theme = {
        rosewater: "#f5e0dc"
        flamingo: "#f2cdcd"
        pink: "#f5c2e7"
        mauve: "#cba6f7"
        red: "#f38ba8"
        maroon: "#eba0ac"
        peach: "#fab387"
        yellow: "#f9e2af"
        green: "#a6e3a1"
        teal: "#94e2d5"
        sky: "#89dceb"
        sapphire: "#74c7ec"
        blue: "#89b4fa"
        lavender: "#b4befe"
        text: "#cdd6f4"
        subtext1: "#bac2de"
        subtext0: "#a6adc8"
        overlay2: "#9399b2"
        overlay1: "#7f849c"
        overlay0: "#6c7086"
        surface2: "#585b70"
        surface1: "#45475a"
        surface0: "#313244"
        base: "#1e1e2e"
        mantle: "#181825"
        crust: "#11111b"
      }

      let scheme = {
        recognized_command: $theme.blue
        unrecognized_command: $theme.text
        constant: $theme.peach
        punctuation: $theme.overlay2
        operator: $theme.sky
        string: $theme.green
        virtual_text: $theme.surface2
        variable: { fg: $theme.flamingo attr: i }
        filepath: $theme.yellow
      }

      $env.config.color_config = {
        separator: { fg: $theme.surface2 attr: b }
        leading_trailing_space_bg: { fg: $theme.lavender attr: u }
        header: { fg: $theme.text attr: b }
        row_index: $scheme.virtual_text
        record: $theme.text
        list: $theme.text
        hints: $scheme.virtual_text
        search_result: { fg: $theme.base bg: $theme.yellow }
        shape_closure: $theme.teal
        closure: $theme.teal
        shape_flag: { fg: $theme.maroon attr: i }
        shape_matching_brackets: { attr: u }
        shape_garbage: $theme.red
        shape_keyword: $theme.mauve
        shape_match_pattern: $theme.green
        shape_signature: $theme.teal
        shape_table: $scheme.punctuation
        cell-path: $scheme.punctuation
        shape_list: $scheme.punctuation
        shape_record: $scheme.punctuation
        shape_vardecl: $scheme.variable
        shape_variable: $scheme.variable
        empty: { attr: n }
        filesize: {||
          if $in < 1kb {
            $theme.teal
          } else if $in < 10kb {
            $theme.green
          } else if $in < 100kb {
            $theme.yellow
          } else if $in < 10mb {
            $theme.peach
          } else if $in < 100mb {
            $theme.maroon
          } else if $in < 1gb {
            $theme.red
          } else {
            $theme.mauve
          }
        }
        duration: {||
          if $in < 1day {
            $theme.teal
          } else if $in < 1wk {
            $theme.green
          } else if $in < 4wk {
            $theme.yellow
          } else if $in < 12wk {
            $theme.peach
          } else if $in < 24wk {
            $theme.maroon
          } else if $in < 52wk {
            $theme.red
          } else {
            $theme.mauve
          }
        }
        datetime: {|| (date now) - $in |
          if $in < 1day {
            $theme.teal
          } else if $in < 1wk {
            $theme.green
          } else if $in < 4wk {
            $theme.yellow
          } else if $in < 12wk {
            $theme.peach
          } else if $in < 24wk {
            $theme.maroon
          } else if $in < 52wk {
            $theme.red
          } else {
            $theme.mauve
          }
        }
        shape_external: $scheme.unrecognized_command
        shape_internalcall: $scheme.recognized_command
        shape_external_resolved: $scheme.recognized_command
        shape_block: $scheme.recognized_command
        block: $scheme.recognized_command
        shape_custom: $theme.pink
        custom: $theme.pink
        background: $theme.base
        foreground: $theme.text
        cursor: { bg: $theme.rosewater fg: $theme.base }
        shape_range: $scheme.operator
        range: $scheme.operator
        shape_pipe: $scheme.operator
        shape_operator: $scheme.operator
        shape_redirection: $scheme.operator
        glob: $scheme.filepath
        shape_directory: $scheme.filepath
        shape_filepath: $scheme.filepath
        shape_glob_interpolation: $scheme.filepath
        shape_globpattern: $scheme.filepath
        shape_int: $scheme.constant
        int: $scheme.constant
        bool: $scheme.constant
        float: $scheme.constant
        nothing: $scheme.constant
        binary: $scheme.constant
        shape_nothing: $scheme.constant
        shape_bool: $scheme.constant
        shape_float: $scheme.constant
        shape_binary: $scheme.constant
        shape_datetime: $scheme.constant
        shape_literal: $scheme.constant
        string: $scheme.string
        shape_string: $scheme.string
        shape_string_interpolation: $theme.flamingo
        shape_raw_string: $scheme.string
        shape_externalarg: $scheme.string
      }

      $env.config.highlight_resolved_externals = true

      $env.config.explore = {
        status_bar_background: { fg: $theme.text, bg: $theme.mantle }
        command_bar_text: { fg: $theme.text }
        highlight: { fg: $theme.base, bg: $theme.yellow }
        status: {
          error: $theme.red
          warn: $theme.yellow
          info: $theme.blue
        }
        selected_cell: { bg: $theme.blue fg: $theme.base }
      }

      # Catppuccin Mocha. Nord (previous) values kept in comments.
      $env.LS_COLORS = (
        [
          "di=1;38;2;137;180;250"   # blue      (was 129;161;193)
          "ln=1;38;2;137;220;235"   # sky       (was 136;192;208)
          "so=38;2;245;194;231"     # pink      (was 180;142;173)
          "pi=38;2;148;226;213"     # teal      (was 143;188;187)
          "ex=1;38;2;166;227;161"   # green     (was 163;190;140)
          "bd=38;2;249;226;175"     # yellow    (was 235;203;139)
          "cd=38;2;249;226;175"     # yellow    (was 235;203;139)
          "or=1;38;2;243;139;168"   # red       (was 191;97;106)
          "mi=1;38;2;243;139;168"   # red       (was 191;97;106)
          "*.tar=38;2;250;179;135"  # peach     (was 208;135;112)
          "*.tgz=38;2;250;179;135"
          "*.zip=38;2;250;179;135"
          "*.gz=38;2;250;179;135"
          "*.bz2=38;2;250;179;135"
          "*.xz=38;2;250;179;135"
          "*.7z=38;2;250;179;135"
          "*.jpg=38;2;203;166;247"  # mauve     (was 180;142;173)
          "*.jpeg=38;2;203;166;247"
          "*.png=38;2;203;166;247"
          "*.gif=38;2;203;166;247"
          "*.svg=38;2;203;166;247"
          "*.mp3=38;2;235;160;172"  # maroon    (was 163;190;140)
          "*.flac=38;2;235;160;172"
          "*.wav=38;2;235;160;172"
        ]
        | str join ":"
      )

      $env.config = ($env.config | upsert hooks.env_change.PWD (
        ($env.config.hooks.env_change.PWD? | default [])
        | append {||
            if (which direnv | is-empty) {
              return
            }

            direnv export json | from json | default {} | load-env
          }
      ))

      $env.config.show_banner = false

      alias lz = lazygit
    '';
  };
}
