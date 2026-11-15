# MacBook Pro 14" M4 Pro (J614s) running NixOS from its SSD.
#
# The hardware and boot chain are nixos-aurora's (Aurora's standard NixOS for
# Apple silicon), set up for this Mac in ../../modules/j614s; the Hyprland
# desktop is modules/j614s/desktop.nix. Everything here is this machine's own
# policy.
#
# On the Mac:
#   sudo nixos-rebuild switch --flake github:briheet/nix-config#kyokasuigetsu
{ pkgs, inputs, ... }:
{
  imports = [
    ../../modules/j614s
    ../../modules/j614s/desktop.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };

    users.briheet = import ./home.nix;
  };

  # Also lets in the Apple firmware modules/j614s pins by hash.
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];
    # `nixpkgs` resolves to the nixpkgs this system was built from (the
    # system registry NixOS writes), without downloading the global
    # registry: `nix shell nixpkgs#...` works offline and stays pinned.
    flake-registry = "";
  };

  # No channels: NIX_PATH becomes nixpkgs=flake:nixpkgs, the same pin.
  nix.channel.enable = false;

  # Weekly: delete generations older than 14 days and what nothing uses,
  # then rewrite the boot menu so it lists only the generations that are
  # left. By hand: sudo systemctl start nix-gc
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  systemd.services.nix-gc.serviceConfig.ExecStartPost = [
    "/run/current-system/bin/switch-to-configuration boot"
  ];
  nix.optimise.automatic = true;

  networking.hostName = "kyokasuigetsu";
  time.timeZone = "Asia/Kolkata";

  # Installed as 26.05; keep it.
  system.stateVersion = "26.05";

  # The whole screen, up to the top edge beside the notch (3024x1964).
  hardware.j614s.boot.showNotch = true;

  # The ESP (NIXBOOT, 4 GB FAT32 after the 40 GB macOS container), made by
  # diskutil on 2026-11-15; aura Stage 1 loads Stage 2 from this PARTUUID.
  hardware.j614s.boot.espPartuuid = "f3b4fa28-5a11-4fc3-af48-9f64c2d5fb67";

  environment.shells = [ pkgs.nushell ];

  # Caps Lock is Escape on the text consoles and the login screen too
  # (Hyprland sets the same in modules/linux/hyprland.lua).
  services.xserver.xkb.options = "caps:escape";
  console.useXkbConfig = true;

  # sshd at boot with port 22 open (nixos-aurora keeps it off and closed).
  aurora.openssh.startAtBoot = true;
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # The password is set on the machine (passwd); none is in this repo.
  users.users.briheet = {
    isNormalUser = true;
    description = "Briheet";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"
    ];
    shell = pkgs.nushell;

    openssh.authorizedKeys.keyFiles = [
      ../hetzner/secrets.txt
    ];
  };
}
