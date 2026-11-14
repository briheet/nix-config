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

    # MacBook Pro M4 Pro (J614s) boot chain and kernel, all aurora-silicon's,
    # built by modules/j614s. `nix flake update aura` (or u-boot, linux)
    # follows upstream; our patches in modules/j614s apply on top.
    aura = {
      url = "github:aurora-silicon/aura";
      flake = false;
    };
    u-boot = {
      url = "github:aurora-silicon/u-boot/aurora-wip";
      flake = false;
    };
    linux = {
      url = "github:aurora-silicon/linux/integration/aurora";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
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
        kyokasuigetsu = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/kyokasuigetsu/default.nix
          ];
        };

        # NixOS from RAM that installs kyokasuigetsu onto the J614s's SSD
        # from git (modules/j614s/installer.nix); booted from the ESP by U-Boot.
        kyokasuigetsu-installer = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./modules/j614s/installer.nix
            {
              hardware.j614s.boot.espPartuuid =
                self.nixosConfigurations.kyokasuigetsu.config.hardware.j614s.boot.espPartuuid;
            }
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

      # A new ESP for the J614s, to copy onto the FAT partition macOS made:
      # aura Stage 2 and Stage 1 (with its recoveryOS enroll script), and an
      # extlinux menu whose only entry is the installer.
      packages.aarch64-linux.j614s-esp =
        let
          pkgs = nixpkgs.legacyPackages.aarch64-linux;
          host = self.nixosConfigurations.kyokasuigetsu.config.system.build;
          inst = self.nixosConfigurations.kyokasuigetsu-installer.config.system.build;
        in
        pkgs.runCommand "j614s-esp" { } ''
          mkdir -p $out/extlinux $out/installer
          cp -r ${host.auraEsp}/. $out/
          chmod -R u+w $out
          cp ${inst.kernel}/Image $out/installer/Image
          cp ${inst.netbootRamdisk}/initrd $out/installer/initrd
          cat > $out/extlinux/extlinux.conf <<EOF
          DEFAULT installer
          TIMEOUT 30
          MENU TITLE j614s installer
          LABEL installer
            MENU LABEL NixOS installer (kyokasuigetsu)
            LINUX ../installer/Image
            INITRD ../installer/initrd
            APPEND init=${inst.toplevel}/init $(cat ${inst.toplevel}/kernel-params)
          EOF
          du -sh $out/installer/*
        '';

      # Put other configs here for other systems
    };
}
