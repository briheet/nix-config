{ pkgs, ... }:
{

  home.packages = with pkgs; [
    (nerd-fonts.victor-mono)
    graphviz
    pkg-config
    hwloc
    ffmpeg
    delta
    protobuf
    delve
    bun
    cargo-flamegraph
    lld
    lldb
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
