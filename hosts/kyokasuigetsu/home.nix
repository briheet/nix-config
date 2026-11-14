# Home manager on the M4 Pro (NixOS): the shared modules that work on Linux,
# and the Hyprland config.
{ ... }:
{
  imports = [
    ../../modules/common/nushell.nix
    ../../modules/common/starship.nix
    ../../modules/common/tools.nix
    ../../modules/common/lazygit.nix
    ../../modules/common/yazi.nix
    ../../modules/common/helix.nix
    ../../modules/common/tmux.nix
    ../../modules/common/ghostty.nix
    ../../modules/common/zellij.nix
    ../../modules/darwin/zoxide.nix
    ../../modules/linux/hyprland.nix
  ];

  home = {
    username = "briheet";
    homeDirectory = "/home/briheet";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
