{
  description = "Flake for minimal macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs;
        [ vim
      	  neovim
	        git
	        htop
	        tmux
	        starship
	        fish
          fastfetch
	        go
          golangci-lint
          rustc
          cargo
	        nodejs
          bun
          prettierd
          docker
          docker-compose
          lazygit
          postgresql
          pnpm
          go-task
          pkg-config
          vips
          ripgrep
          ranger
          tree
          protobuf
          air
          uutils-findutils
          glib
          graphviz
          vscode
          ffmpeg
          clang
          btop
          libiconv
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Allow unfree
      nixpkgs.config.allowUnfree = true;

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;
   	  programs.zsh.enable = true;

    	environment.variables = {
    	PATH = "${pkgs.kitty}/Applications:${pkgs.kitty}/bin:$PATH";
    	};

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # Hostname change
      networking.hostName = "makima";

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#makima
    darwinConfigurations."makima" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
