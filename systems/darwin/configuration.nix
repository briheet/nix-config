# Macos level configuration.

{ pkgs, inputs, ... }:
{
  # Unfree packages (obsidian)
  nixpkgs.config.allowUnfree = true;

  # Package bundle .app
  environment.systemPackages =
    with pkgs;
    [
      kitty
      iina
      discord
      obsidian
      alacritty
    ]
    ++ [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
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
    shells = [ pkgs.nushell ];
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
      # _HIHideMenuBar = true;
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
