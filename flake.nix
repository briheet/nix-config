{
  description = "Darwin Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:nix-darwin/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    cats.url = "github:briheet/cats";
    cats.inputs.nixpkgs.follows = "nixpkgs";
    cats.inputs.home-manager.follows = "home-manager";

    # Zen stuff
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.inputs.home-manager.follows = "home-manager";

    # llm latest via numtide
    llm-agents.url = "github:numtide/llm-agents.nix";

    # Disko stuff
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # MacBook Pro M4 Pro (J614s): hardware, boot chain and desktop modules
    nixos-m4pro.url = "github:briheet/nixos-m4pro/nixos-on-ssd";
    nixos-m4pro.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      darwin,
      ...
    }:
    {

      darwinConfigurations = {

        # invideo lappy
        goryutenmetsu = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.darwinModules.home-manager
            ./hosts/goryutenmetsu/default.nix
          ];
        };

        # personal lappy
        makima = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.darwinModules.home-manager
            ./hosts/makima/default.nix
          ];
        };
      };

      nixosConfigurations = {

        # zangetsu vm config
        zangetsu = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/zangetsu/default.nix
          ];
        };

        # MacBook Pro M4 Pro (J614s), NixOS on its SSD
        m4pro = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/m4pro/default.nix
          ];
        };

        # Temp: You can use this to install nixos on remote machines;
        vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            inputs.disko.nixosModules.disko
            ./hosts/hetzner/default.nix
          ];
        };
      };

      homeConfigurations = {

        # ubuntu gpu box: standalone home-manager on top of the stock image
        gpu = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./hosts/gpu/home.nix ];
        };
      };

      # Put other configs here for other systems
    };
}
