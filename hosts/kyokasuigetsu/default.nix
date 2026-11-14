# MacBook Pro 14" M4 Pro (J614s) running NixOS from its SSD.
#
# The hardware, the SSD layout and the m1n1/U-Boot boot chain come from
# github:briheet/nixos-m4pro (nixosModules.default), the Hyprland desktop
# from its nixosModules.desktop. Everything here is this machine's own policy.
#
# On the Mac:
#   sudo nixos-rebuild switch --flake github:briheet/nix-config#kyokasuigetsu
{ pkgs, inputs, ... }:
{
  imports = [
    inputs.nixos-m4pro.nixosModules.default
    inputs.nixos-m4pro.nixosModules.desktop
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };

    users.briheet = import ./home.nix;
  };

  # Also lets in the Apple firmware nixos-m4pro pins by hash.
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

  # Installed as 26.05 by nixos-m4pro; keep it.
  system.stateVersion = "26.05";

  environment.shells = [ pkgs.nushell ];

  # Caps Lock is Escape on the text consoles and the login screen too
  # (Hyprland sets the same in modules/linux/hyprland.lua).
  services.xserver.xkb.options = "caps:escape";
  console.useXkbConfig = true;

  services.openssh = {
    enable = true;
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
