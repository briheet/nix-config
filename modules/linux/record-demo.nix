# record-demo: screen recording for demos: H.264 MP4, 60 fps, at most
# 1200 px tall, no audio.
#
#   record-demo            the whole screen
#   record-demo region     a region dragged with the mouse (slurp)
#
# Ctrl+C stops and finishes the file in ~/Videos (demo-YYYYmmdd-HHMMSS.mp4).
# Encoding is on the CPU (libx264).
{ pkgs, ... }:
let
  record-demo = pkgs.writeShellApplication {
    name = "record-demo";
    runtimeInputs = with pkgs; [ wf-recorder slurp coreutils ];
    text = ''
      dir="$HOME/Videos"
      mkdir -p "$dir"
      out="$dir/demo-$(date +%Y%m%d-%H%M%S).mp4"

      geometry=()
      case "''${1:-}" in
        "") ;;
        region|-r)
          sel=$(slurp) || { echo "no region selected"; exit 1; }
          geometry=(-g "$sel")
          ;;
        *)
          echo "usage: record-demo [region]" >&2
          exit 2
          ;;
      esac

      echo "Recording to $out"
      echo "Press Ctrl+C to stop."

      # Ctrl+C goes to wf-recorder, which finishes the file; the script
      # carries on to report it.
      trap ':' INT
      # Colour: the screen is full-range RGB. Convert it to video (limited)
      # range with the BT.709 matrix and tag the file BT.709, so players
      # don't guess (untagged full range showed blacks as brown).
      wf-recorder "''${geometry[@]}" \
        -c libx264 -x yuv420p -r 60 \
        -F "scale=-2:'min(1200,ih)':out_range=tv:out_color_matrix=bt709,format=yuv420p" \
        -p preset=veryfast -p crf=20 \
        -p x264-params=colorprim=bt709:transfer=bt709:colormatrix=bt709:range=tv \
        -f "$out" || true
      trap - INT

      if [ -s "$out" ]; then
        echo
        echo "Saved: $out ($(du -h "$out" | cut -f1))"
      else
        echo "No recording was saved." >&2
        exit 1
      fi
    '';
  };
in
{
  home.packages = [ record-demo ];
}
