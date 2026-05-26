{ config, pkgs, ... }:
{

  home.packages = with pkgs; [
    nerd-fonts.iosevka
  ];

  programs.nushell = {
    enable = true;
    extraEnv = ''
      $env.PATH = (
        $env.PATH
        | prepend "/etc/profiles/per-user/${config.home.username}/bin"
        | prepend "/run/current-system/sw/bin"
      )
    '';

    extraConfig = ''
      $env.config = ($env.config | upsert hooks.env_change.PWD (
        ($env.config.hooks.env_change.PWD? | default [])
        | append {||
            if (which direnv | is-empty) {
              return
            }

            direnv export json | from json | default {} | load-env
          }
      ))

      def --env y [...args] {
        let tmp = (mktemp -t "yazi-cwd.XXXXXX")
        ^yazi ...$args --cwd-file $tmp

        let cwd = (open $tmp)

        if $cwd != $env.PWD and ($cwd | path exists) {
          cd $cwd
        }

        rm -fp $tmp
      }
    '';
  };
}
