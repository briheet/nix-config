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

    # MacBook Pro M4 Pro (J614s): nixos-aurora, Aurora's standard NixOS for
    # Apple silicon (kernel, U-Boot, aura, Stage 2 updates, its own nixpkgs
    # pin). Locked to a commit whose kernel, U-Boot and aura are in Aurora's
    # binary cache; kyokasuigetsu is built with its nixpkgs so they match.
    nixos-aurora.url = "github:aurora-silicon/nixos-aurora";
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

        # MacBook Pro M4 Pro (J614s), NixOS on its SSD, on nixos-aurora (its
        # nixpkgs, so Aurora's cached kernel, U-Boot and aura match)
        kyokasuigetsu = inputs.nixos-aurora.inputs.nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/kyokasuigetsu/default.nix
          ];
        };

        # NixOS from RAM that installs kyokasuigetsu onto the J614s's SSD
        # from git (modules/j614s/installer.nix); booted from the ESP.
        kyokasuigetsu-installer = inputs.nixos-aurora.inputs.nixpkgs.lib.nixosSystem {
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

      # What goes on the J614s's ESP for the first install, copied onto the
      # FAT partition macOS made:
      #   EFI/BOOT/BOOTAA64.EFI  a standalone GRUB whose only entry is the
      #                          installer (U-Boot loads it from the ESP)
      #   installer/             its kernel (Aurora's) and initrd
      #   m1n1/boot-ctxr.bin     the bring-up Stage 2 (debug UART)
      #   aura/                  Stage 1 and its recoveryOS enroll script
      # nixos-install replaces GRUB and Stage 2 with the installed system's.
      packages.aarch64-linux.j614s-esp =
        let
          host = self.nixosConfigurations.kyokasuigetsu;
          inst = self.nixosConfigurations.kyokasuigetsu-installer;
          pkgs = inst.pkgs;
          kernel = inst.config.boot.kernelPackages.kernel;
          stage2 = pkgs.callPackage ./modules/j614s/pkgs/bringup-stage2.nix {
            aura = pkgs.m1n1;
            uBoot = pkgs.uboot-asahi;
            inherit kernel;
            kernelCommit =
              (builtins.fromJSON (builtins.readFile "${inputs.nixos-aurora}/kernel/provenance.json"))
              .kernel_commit;
          };
          stage1 = host.config.system.build.auraStage1;
          grubCfg = pkgs.writeText "grub.cfg" ''
            set timeout=3
            search --no-floppy --file --set=root /installer/Image
            menuentry "NixOS installer (kyokasuigetsu)" {
              linux /installer/Image init=${inst.config.system.build.toplevel}/init ${toString inst.config.boot.kernelParams}
              initrd /installer/initrd
            }
          '';
        in
        pkgs.runCommand "j614s-esp" { nativeBuildInputs = [ pkgs.grub2_efi ]; } ''
          mkdir -p $out/EFI/BOOT $out/installer $out/m1n1 $out/aura
          grub-mkstandalone -O arm64-efi -o $out/EFI/BOOT/BOOTAA64.EFI \
            --modules="part_gpt fat search search_fs_file linux normal configfile echo" \
            "boot/grub/grub.cfg=${grubCfg}"
          cp ${kernel}/Image $out/installer/Image
          cp ${inst.config.system.build.netbootRamdisk}/initrd $out/installer/initrd
          cp ${stage2}/boot-ctxr.bin $out/m1n1/boot-ctxr.bin
          for f in stage1.bin stage1.bin.md5 stage1.version enroll-stage1.sh; do
            cp ${stage1}/$f $out/aura/$f
          done
          cp ${host.config.system.build.installStage1} $out/aura/install-stage1.sh
          du -sh $out/*/*
        '';

      # Put other configs here for other systems
    };
}
