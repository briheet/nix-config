# Macos level configuration.

{ pkgs, lib, ... }:
{

  # Unfree packages (Vscode, obsidian)
  nixpkgs.config.allowUnfree = true;
  # users.users.briheet.shell = pkgs.fish;

  # System docs
  documentation = {
    enable = true;
    doc.enable = false;
    info.enable = false;
    man.enable = true;
  };

  # Environment
  environment = {
    shells = [ pkgs.fish ];
  };

  networking.hostName = "makima";
  system.stateVersion = 6;

  # Enable experimental Nix features
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.briheet = {
    name = "briheet";
    home = "/Users/briheet";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
    users.briheet = import ./home.nix;
  };

  programs.fish = {
    enable = true;
  };

}
