{ pkgs, ... }:
{

  home.packages = with pkgs; [
    (nerd-fonts.victor-mono)
    delta
    protobuf
    delve
    terraform
    bun
    cargo-flamegraph
    lld
    lldb
    yabai
    yazi
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
