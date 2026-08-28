{ pkgs, inputs, ... }:
{

  imports = [
    inputs.disko.nixosModules.disko
    ../hetzner/configuration.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };

    users.briheet = import ./home.nix;
  };

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.hostName = "zangetsu";
  time.timeZone = "Asia/Kolkata";

  programs.nushell.enable = true;

  services.openssh = {
    enable = true;
    openFirewall = true;

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  users.users.briheet = {
    isNormalUser = true;
    description = "Briheet";
    extraGroups = [ "wheel" ];
    shell = pkgs.nushell;

    openssh.authorizedKeys.keyFiles = [
      ../hetzner/secrets.txt
    ];
  };
}
