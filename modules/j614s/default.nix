# MacBook Pro 14" M4 Pro (J614s, T6040): everything from the boot chain up,
# in this repo, built from this flake's inputs (aura, u-boot, linux):
#
#   ./boot.nix       aura Stage 1 + Stage 2, U-Boot, extlinux, the SSD layout
#   ./hardware.nix   kernel (./kernel), command line, initrd, Apple firmware,
#                    console, debug-USB console
#   ./desktop.nix    Hyprland on the boot framebuffer (import separately)
#
# Build pieces on their own:
#   nix build .#nixosConfigurations.kyokasuigetsu.config.system.build.auraStage1
#   nix build .#nixosConfigurations.kyokasuigetsu.config.system.build.auraStage2
#   nix build .#nixosConfigurations.kyokasuigetsu.config.boot.kernelPackages.kernel
{
  imports = [
    ./hardware.nix
    ./boot.nix
  ];
}
