# Standalone home-manager profile for the Ubuntu GPU box (no NixOS, no nix-darwin)
{ ... }: {
  imports = [
    ../../modules/common/nushell.nix
    ../../modules/common/starship.nix
    ../../modules/common/tools.nix
    ../../modules/common/lazygit.nix
    ../../modules/common/yazi.nix
    ../../modules/common/helix.nix
    ../../modules/common/tmux.nix
    ../../modules/common/zellij.nix
    ../../modules/darwin/zoxide.nix
  ];

  home = {
    username = "ubuntu";
    homeDirectory = "/home/ubuntu";
    stateVersion = "26.05";
  };

  # Non-NixOS Linux: sets XDG_DATA_DIRS etc. so nix-installed apps integrate with Ubuntu
  targets.genericLinux.enable = true;

  # `use flake` in project .envrc files; nushell.nix already has its own direnv hook
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableNushellIntegration = false;
  };

  # Login shell stays bash (it sources /etc/profile, so ssh commands, rsync and Zed's remote
  # server all get the nix PATH); interactive bash then hands off to nushell.
  programs.bash = {
    enable = true;
    # Zed's remote terminal inherits __ETC_PROFILE_NIX_SOURCED with a nix-less PATH, so force a re-source
    bashrcExtra = ''
      if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        unset __ETC_PROFILE_NIX_SOURCED
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi
    '';
    initExtra = ''
      if [ -z "$NO_NU" ] && command -v nu >/dev/null; then
        exec nu
      fi
    '';
  };

  # Load home.sessionVariables (genericLinux, direnv) into nushell
  programs.nushell.loadSessionVariables = true;

  programs.home-manager.enable = true;
}
