# nushell on Linux: the PATH from the session is already right (on NixOS
# the setuid wrappers come first, which sudo needs); add only ~/.local/bin.
{ config, lib, ... }:
{
  # After the shared env (modules/common/nushell.nix).
  programs.nushell.extraEnv = lib.mkAfter ''
    $env.PATH = ($env.PATH | prepend "${config.home.homeDirectory}/.local/bin")
  '';
}
