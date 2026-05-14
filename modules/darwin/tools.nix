{ pkgs, ... }:
{

  home.packages = with pkgs; [
    (nerd-fonts.victor-mono)
    yabai
    gh
    telegram-desktop
    vim
    git
    nodejs
    docker
    docker-compose
    lazygit
    ripgrep
    ranger
    tree
    vscode
    btop
    subversion
    clippy
    lldb
    obsidian
    pnpm
    hyperfine
    direnv
    uv
  ];

}
