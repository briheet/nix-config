# Macos level configuration.

{ pkgs, lib, ... }:
{
  # Unfree packages (Vscode, obsidian)
  nixpkgs.config.allowUnfree = true;

  # Package bundle .app
  environment.systemPackages = with pkgs; [
    kitty
  ];

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

  # Global programs
  programs = {
    direnv.enable = true;
    fish.enable = true;
  };

  # Systems
  system = {
    primaryUser = "briheet";

    # Menu and system
    defaults.NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleMeasurementUnits = "Centimeters";
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      AppleShowScrollBars = "WhenScrolling";
      _HIHideMenuBar = false;
    };

    # Dock stuff
    defaults.dock.autohide = true;

    # Keyboard stuff
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };

  # Time
  time.timeZone = "Asia/Calcutta";
}
