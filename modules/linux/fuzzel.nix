# fuzzel, the launcher (Super+D). Apps that run in a terminal (Terminal=true:
# Helix, ...) open in Ghostty; without `terminal` fuzzel used $TERMINAL,
# which nothing sets, and silently launched nothing.
{ ... }:
{
  programs.fuzzel = {
    enable = true;
    settings.main.terminal = "ghostty -e";
  };
}
