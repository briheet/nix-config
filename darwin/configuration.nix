# Macos level configuration.

{ pkgs, ... }:

{
  networking.hostName = "makima";

  services.nix-daemon.enable = true;

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
}
