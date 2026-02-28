{ pkgs, ... }:
{

  home.packages = with pkgs; [
    (nerd-fonts.victor-mono)
    brave
    ngrok
    gh
    claude-code
    telegram-desktop
    vscode
    vim
    git
    nodejs
    docker
    docker-compose
    lazygit
    ripgrep
    ranger
    tree
    go-task
    uutils-findutils
    glib
    graphviz
    vscode
    ffmpeg
    btop
    subversion
    clippy
    lldb
    obsidian
    pnpm
    hyperfine
    direnv
  ];

}
