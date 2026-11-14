# nushell on macOS: nix-darwin's and home manager's bin directories ahead of
# the system's, which macOS's login PATH does not put first.
{ config, lib, ... }:
{
  # After the shared env (modules/common/nushell.nix).
  programs.nushell.extraEnv = lib.mkAfter ''
    $env.PATH = (
      $env.PATH
      | prepend "${config.home.homeDirectory}/.local/bin"
      | prepend "/etc/profiles/per-user/${config.home.username}/bin"
      | prepend "/run/current-system/sw/bin"
      | append "/usr/local/bin"
    )
  '';
}
