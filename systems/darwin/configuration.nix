# Macos level configuration.

{ pkgs, lib, ... }:
{
  # Unfree packages (Vscode, obsidian)
  nixpkgs.config.allowUnfree = true;

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

  # Networking
  networking = {
    applicationFirewall = {
      enable = true;
      enableStealthMode = true;
      allowSigned = true;
      allowSignedApp = true;
    };
    computerName = "Briheet's MacBook Pro";
    hostName = "makima";
  };

  system.stateVersion = 6;

  # Enable experimental Nix features
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Users
  users.users.briheet = {
    name = "briheet";
    home = "/Users/briheet";
  };

  programs.fish.enable = true;

}
