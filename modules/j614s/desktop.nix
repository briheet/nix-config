# The desktop on the installed system: Hyprland, rendered by the GPU, shown
# by the display coprocessor (DCP) at 3024x1964, 120 Hz, scale 2.
#
# The GPU (aurora.ko with ./gpu-patches) and the DCP (appledrm.ko with
# ./display-patches) both run on the macOS 27.2 firmware. The GRUB entry
# "simpledrm" (./hardware.nix) leaves the panel on the boot framebuffer
# instead; for that path, /etc/drirc below pairs simpledrm with the GPU as
# Mesa pairs Apple's display driver with it (kmsro, "apple").
# Hyprland config: ~/.config/hypr/hyprland.lua (home-manager or your own).
#
# Log in on the screen (greetd/tuigreet); it starts Hyprland.
{ lib, pkgs, inputs, ... }:

{
  config = {
    programs.hyprland.enable = true;
    # nixos-aurora's Mesa (its default here), with the GPU driver.
    hardware.graphics.enable = true;
    # GBM and EGL on simpledrm, which has no render node of its own, would
    # otherwise get kms_swrast: softpipe, since nixos-aurora's Mesa has no
    # llvmpipe, and every frame lagged (2026-11-15). Mesa's loader takes a
    # device's driver from driconf ("loader", by kernel driver): give
    # simpledrm the kmsro pairing Apple's display driver uses, so it renders
    # on the GPU and scans out through simpledrm. The GPU's own render node
    # keeps its driver.
    environment.etc."drirc".text = ''
      <?xml version="1.0" standalone="yes"?>
      <driconf>
        <device driver="loader" kernel_driver="simpledrm">
          <application name="Default">
            <option name="dri_driver" value="apple" />
          </application>
        </device>
      </driconf>
    '';

    # aquamarine (Hyprland's backend) finds no EGL device for simpledrm, which
    # has no render node, and retries on every commit. Its unmerged PR #406
    # falls back to the GBM platform, which the drirc above sends to the GPU.
    nixpkgs.overlays = [
      (final: prev: {
        aquamarine = prev.aquamarine.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            ./aquamarine/patches/0001-drm-fall-back-to-the-GBM-platform.patch
          ];
        });
      })
    ];
    # foot's default font, readable at scale 2 (override in ~/.config/foot).
    environment.etc."xdg/foot/foot.ini".text = ''
      [main]
      font=monospace:size=13
    '';

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd start-hyprland";
        user = "greeter";
      };
    };

    environment.systemPackages = with pkgs; [
      foot
      fuzzel
      # No firefox yet: nixos-aurora patches it and no cache has that build,
      # and compiling it in the RAM installer runs out of room (2026-11-15).
      brightnessctl
      pavucontrol
    ];

    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      font-awesome
      dejavu_fonts
    ];
  };
}
