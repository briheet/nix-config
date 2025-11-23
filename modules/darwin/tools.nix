{ pkgs, ... }:

{

  home.packages = with pkgs; [
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
    oxker
    obsidian
  ];

  
}
