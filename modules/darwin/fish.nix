{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    # Initialize home-manager environment
    loginShellInit = ''
      # Set up the home-manager session variables
      if test -e $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
        bass source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
      end
    '';
  };

  # Add bass plugin to source bash scripts
  home.packages = with pkgs; [
    fishPlugins.bass
  ];
}
