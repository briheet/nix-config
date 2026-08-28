{ pkgs, ... }:
{

  programs.sketchybar = {
    enable = true;
    config = ''
      # === COLORS ===
      CLR_BG=0x00000000          # Transparent bar background
      CLR_COMP_BG=0xff1d2021     # Compartment background (Gruvbox dark)
      CLR_COMP_BORDER=0xff3c3836 # Compartment border (Gruvbox gray)
      CLR_FG=0xffebdbb2          # Foreground (Gruvbox light text)

      # === PADDING CONSTANTS ===
      BAR_PADDING=8
      ITEM_PADDING=6
      ICON_PADDING=2
      LABEL_PADDING=2
      COMP_PADDING=6

      PLUGIN_DIR="$CONFIG_DIR/plugins"

      # === BAR ===
      sketchybar --bar position=top height=34 blur_radius=0 color="$CLR_BG" padding_left="$BAR_PADDING" padding_right="$BAR_PADDING"

      # === Aerospace ===
      # sketchybar --add event aerospace_workspace_change
      # LABELS=("" "" "" "󱙺" "" "" "" "󰎇" "󰖣")
      # LEFT_SPACE_ITEMS=()
      # INDEX=0
      #
      # for sid in $(aerospace list-workspaces --all); do
      #   label="''${LABELS[$INDEX]:-}"
      #   item="space.$sid"
      #   LEFT_SPACE_ITEMS+=("$item")
      #
      #   sketchybar --add item "$item" left \
      #     --subscribe "$item" aerospace_workspace_change \
      #     --set "$item" \
      #       background.color=0xff000000 \
      #       background.corner_radius=5 \
      #       background.height=20 \
      #       background.drawing=off \
      #       label="$label" \
      #       icon.padding_left="$ICON_PADDING" \
      #       icon.padding_right="$ICON_PADDING" \
      #       label.padding_left="$LABEL_PADDING" \
      #       label.padding_right="$LABEL_PADDING" \
      #       click_script="aerospace workspace $sid" \
      #       script="$PLUGIN_DIR/aerospace.sh $sid"
      #
      #   ((INDEX++))
      # done

      # === DEFAULTS ===
      sketchybar --default \
        padding_left="$ITEM_PADDING" \
        padding_right="$ITEM_PADDING" \
        icon.font="VictorMono Nerd Font:Regular:12.0" \
        label.font="VictorMono Nerd Font:Regular:14.0" \
        icon.color="$CLR_FG" \
        label.color="$CLR_FG" \
        icon.padding_left="$ICON_PADDING" \
        icon.padding_right="$ICON_PADDING" \
        label.padding_left="$LABEL_PADDING" \
        label.padding_right="$LABEL_PADDING"

      # === FRONT APP ===
      sketchybar --add item front_app left \
        --set front_app \
          script="$PLUGIN_DIR/front_app.sh" \
          label.y_offset=1 \
          label.padding_right="$COMP_PADDING" \
        --subscribe front_app front_app_switched

      # === RIGHT SIDE ITEMS ===
      sketchybar --add item clock right \
        --set clock update_freq=10 icon= script="$PLUGIN_DIR/clock.sh" label.padding_right="$COMP_PADDING"

      sketchybar --add item volume right \
        --set volume script="$PLUGIN_DIR/volume.sh" \
        --subscribe volume volume_change

      sketchybar --add item battery right \
        --set battery update_freq=120 script="$PLUGIN_DIR/battery.sh" \
        --subscribe battery system_woke power_source_change

      sketchybar --add item net right \
        --set net update_freq=120 icon= script="$PLUGIN_DIR/wifi.sh"

      # === ITEM GROUPS ===
      LEFT_ITEMS=(front_app)
      RIGHT_ITEMS=(clock volume battery net)

      # === COMPARTMENTS ===
      sketchybar --add bracket left_compartment "''${LEFT_ITEMS[@]}" \
        --set left_compartment \
          background.color="$CLR_COMP_BG" \
          background.corner_radius=8 \
          background.height=26 \
          background.border_color="$CLR_COMP_BORDER" \
          background.border_width=1 \
          background.drawing=on

      sketchybar --add bracket right_compartment "''${RIGHT_ITEMS[@]}" \
        --set right_compartment \
          background.color="$CLR_COMP_BG" \
          background.corner_radius=8 \
          background.height=26 \
          background.border_color="$CLR_COMP_BORDER" \
          background.border_width=1 \
          background.padding_left=0 \
          background.drawing=on

      # === FINALIZE ===
      sketchybar --update
    '';
  };

  # Plugin scripts
  xdg.configFile = {
    "sketchybar/plugins/aerospace.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
          sketchybar --set "$NAME" background.drawing=on
        else
          sketchybar --set "$NAME" background.drawing=off
        fi
      '';
    };

    "sketchybar/plugins/battery.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
        CHARGING="$(pmset -g batt | grep 'AC Power')"

        if [ "$PERCENTAGE" = "" ]; then
          exit 0
        fi

        case "''${PERCENTAGE}" in
          9[0-9]|100) ICON=""
          ;;
          [6-8][0-9]) ICON=""
          ;;
          [3-5][0-9]) ICON=""
          ;;
          [1-2][0-9]) ICON=""
          ;;
          *) ICON=""
        esac

        if [ "$CHARGING" != "" ]; then
          ICON=""
        fi

        sketchybar --set "$NAME" icon="$ICON" label="''${PERCENTAGE}%"
      '';
    };

    "sketchybar/plugins/clock.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        sketchybar --set "$NAME" label="$(date '+%A, %d %b, %I:%M %p')"
      '';
    };

    "sketchybar/plugins/front_app.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        if [ "$SENDER" = "front_app_switched" ]; then
          sketchybar --set "$NAME" label="$INFO"
        fi
      '';
    };

    "sketchybar/plugins/volume.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        if [ "$SENDER" = "volume_change" ]; then
          VOLUME="$INFO"

          case "$VOLUME" in
            [6-9][0-9]|100) ICON="󰕾"
            ;;
            [3-5][0-9]) ICON="󰖀"
            ;;
            [1-9]|[1-2][0-9]) ICON="󰕿"
            ;;
            *) ICON="󰖁"
          esac

          sketchybar --set "$NAME" icon="$ICON" label="$VOLUME%"
        fi
      '';
    };

    "sketchybar/plugins/wifi.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        wifi_name=$(networksetup -listpreferredwirelessnetworks en0 | sed -n '2 p' | tr -d '\t')

        if [ -z "$wifi_name" ]; then
          wifi_name="Offline"
        fi

        sketchybar --set "$NAME" label="$wifi_name"
      '';
    };
  };

}
