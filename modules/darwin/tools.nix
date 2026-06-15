{ pkgs, ... }:
{

  home.packages = with pkgs; [
    (nerd-fonts.victor-mono)
    delta
    protobuf
    delve
    bun
    cargo-flamegraph
    lld
    lldb
    yabai
    yazi
    gh
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
    obsidian
    pnpm
    hyperfine
    direnv
    uv
  ];

}
