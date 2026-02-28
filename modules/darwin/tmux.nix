{ pkgs, ... }:
{

  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    mouse = true;
    prefix = "C-b";
    secureSocket = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "xterm-256color";
  };

}
