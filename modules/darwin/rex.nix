# Rex (superlogical.com/rex): /Applications/Rex.app kept current from its Sparkle
# appcast, plus ~/.config/rex/init.lua.
#
# `rex-update` installs the newest appcast build if it is newer than the installed
# one; a running Rex is quit and reopened. Run it by hand; it is kept out of
# activation so `darwin-rebuild switch` does not wait on the network.
{ config, pkgs, lib, ... }:

let
  rex-update = pkgs.writeShellApplication {
    name = "rex-update";
    runtimeInputs = [ pkgs.curl pkgs.libxml2 ];
    # Syntax check only: the default shellcheck makes every evaluation pull in
    # the Haskell package set (~10% of `darwin-rebuild` eval time).
    checkPhase = ''${pkgs.stdenv.shellDryRun} "$target"'';
    text = ''
      app=/Applications/Rex.app
      # The feed URL stays out of this repo: take it from the installed app.
      feed=$(/usr/bin/defaults read "$app/Contents/Info" SUFeedURL 2>/dev/null) \
        || { echo "Rex is not installed; install it once by hand" >&2; exit 1; }
      team=AG92C3PT77 # Superlogical's Developer ID

      tmp=$(mktemp -d)
      trap '/usr/bin/hdiutil detach -quiet "$tmp/mnt" 2>/dev/null || true; rm -rf "$tmp"' EXIT

      curl -fsSL "$feed" -o "$tmp/feed.xml"
      xpath() { xmllint --xpath "$1" "$tmp/feed.xml"; }
      latest=$(xpath '//item/*[local-name()="version"]/text()' | sort -n | tail -1)
      url=$(xpath "string(//item[*[local-name()='version']='$latest']/enclosure/@url)")
      installed=$(/usr/bin/defaults read "$app/Contents/Info" CFBundleVersion 2>/dev/null || echo 0)

      if (( installed >= latest )); then echo "Rex $installed is current"; exit 0; fi

      running=false; /usr/bin/pgrep -qx Rex && running=true
      if $running && [[ ''${1:-} == --no-restart ]]; then
        echo "Rex $latest available (installed $installed); quit Rex and run rex-update"; exit 0
      fi

      echo "Installing Rex $latest (installed $installed)"
      curl -fL --progress-bar "$url" -o "$tmp/Rex.dmg"
      /usr/bin/hdiutil attach -quiet -nobrowse -readonly -mountpoint "$tmp/mnt" "$tmp/Rex.dmg"
      /usr/bin/ditto "$tmp/mnt/Rex.app" "$tmp/Rex.app"

      /usr/sbin/spctl --assess --type execute "$tmp/Rex.app"
      [[ $(/usr/bin/codesign -dv "$tmp/Rex.app" 2>&1) == *$'\n'"TeamIdentifier=$team"$'\n'* ]] \
        || { echo "Rex.app is not signed by $team" >&2; exit 1; }

      if $running; then
        /usr/bin/osascript -e 'quit app id "com.superlogical.rex"'
        while /usr/bin/pgrep -qx Rex; do sleep 1; done
      fi
      rm -rf "$app"
      /usr/bin/ditto "$tmp/Rex.app" "$app"
      if $running; then /usr/bin/open "$app"; fi
    '';
  };
in
{
  home.packages = [ rex-update ];

  # Rex starts the account's login shell (/bin/zsh) unless this is set
  # (Settings > Terminal > Startup Command). Same as Ghostty's `command`.
  targets.darwin.defaults."com.superlogical.rex"."Workspace.terminalStartupCommand" =
    lib.getExe config.programs.nushell.package;

  xdg.configFile."rex/init.lua" = {
    source = ./rex/init.lua;
    # The app ships its CLI here; reload only if a server is already up.
    onChange = ''
      rex="$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"
      [ -x "$rex" ] && "$rex" --autostart=false config reload || true
    '';
  };
}
