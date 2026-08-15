{ ... }:

{
  imports = [
    ../../modules/linux/helix.nix
    ../../modules/linux/nushell.nix
    ../../modules/linux/tmux.nix
  ];

  home = {
    username = "briheet";
    homeDirectory = "/home/briheet";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
