# record-demo: screen recording for demos: H.264 MP4, 60 fps, at most
# 1200 px tall, no audio.
#
#   record-demo            the whole screen
#   record-demo region     a region dragged with the mouse (slurp)
#
# Ctrl+C stops; the file lands in ~/Videos (demo-YYYYmmdd-HHMMSS.mp4).
#
# Colour: wf-recorder records the screen's RGB losslessly (libx264rgb), with
# no colour conversion. On Ctrl+C, ffmpeg converts it once to video range
# with the BT.709 matrix and tags the file BT.709, so every player shows the
# same colours (wf-recorder's own conversion left the file untagged full
# range, and blacks looked brown). The lossless file is deleted afterwards.
{ pkgs, ... }:
let
  record-demo = pkgs.writeShellApplication {
    name = "record-demo";
    runtimeInputs = with pkgs; [ wf-recorder slurp ffmpeg coreutils ];
    text = ''
      dir="$HOME/Videos"
      mkdir -p "$dir"
      stamp=$(date +%Y%m%d-%H%M%S)
      out="$dir/demo-$stamp.mp4"
      raw="$dir/.demo-$stamp-rgb.mkv"

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

      echo "Recording. Press Ctrl+C to stop."

      # Ctrl+C goes to wf-recorder, which finishes the file; the script
      # carries on to convert it.
      trap ':' INT
      wf-recorder "''${geometry[@]}" \
        -c libx264rgb -x bgr0 -r 60 \
        -p preset=ultrafast -p qp=0 \
        -f "$raw" || true
      trap - INT

      if [ ! -s "$raw" ]; then
        echo "No recording was saved." >&2
        rm -f "$raw"
        exit 1
      fi

      echo
      echo "Converting..."
      if ffmpeg -v error -stats -y -i "$raw" \
        -vf "scale=-2:'min(1200,ih)':out_range=tv:out_color_matrix=bt709,format=yuv420p" \
        -c:v libx264 -preset veryfast -crf 20 \
        -x264-params colorprim=bt709:transfer=bt709:colormatrix=bt709:range=tv \
        -movflags +faststart -an "$out"; then
        rm -f "$raw"
        echo "Saved: $out ($(du -h "$out" | cut -f1))"
      else
        echo "Conversion failed; the lossless recording is kept: $raw" >&2
        exit 1
      fi
    '';
  };
in
{
  home.packages = [ record-demo ];
}
