# MacBook Pro 14" M4 Pro (J614s) running NixOS from its SSD.
#
# The hardware, the SSD layout and the m1n1/U-Boot boot chain come from
# github:briheet/nixos-m4pro (nixosModules.default), the Hyprland desktop
# from its nixosModules.desktop. Everything here is this machine's own policy.
#
# On the Mac:
#   sudo nixos-rebuild switch --flake github:briheet/nix-config/m4pro#m4pro
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
  };

  networking.hostName = "m4pro";
  time.timeZone = "Asia/Kolkata";

  # Installed as 26.05 by nixos-m4pro; keep it.
  system.stateVersion = "26.05";

  # Super+Return in the Hyprland session (home.nix manages hyprland.lua).
  desktop.j614s.terminal = "ghostty";

  environment.shells = [ pkgs.nushell ];

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
