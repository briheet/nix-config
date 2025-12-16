# Macos level configuration.

{ pkgs, lib, ... }:

{
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

  programs.fish.enable = true;
  programs.fish.shellInit = ''
    __nixos_path_fix
  '';

  environment.etc."fish/nixos-env-preinit.fish".text = lib.mkMerge [
    (lib.mkBefore ''
      set -g __nixos_path_original $PATH
    '')
    (lib.mkAfter ''
      function __nixos_path_fix -d "fix PATH value"
        set -l result (string replace '$HOME' "$HOME" $__nixos_path_original)
        for elt in $PATH
          if not contains -- $elt $result
            set -a result $elt
          end
        end
        set -g PATH $result
      end
    '')
  ];

}
