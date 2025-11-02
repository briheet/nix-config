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
    uutils-findutils
    glib
    graphviz
    vscode
    ffmpeg
    btop
    subversion
    clippy
    lldb
  ];

  
}
