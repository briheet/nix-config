# Display driver patches

Applied in name order to nixos-aurora's display driver (drivers/gpu/drm/apple,
paths relative to the kernel tree, `patch -p1`) by ../pkgs/aurora-display.nix,
which builds it out of tree as appledrm.ko under updates/. A change here
rebuilds only the module (`nixos-rebuild boot`, then reboot: the display
coprocessor is handed over by aura at boot).

- 0001-t6041-macos-27.2-dcp-firmware.patch: the M4 Pro's internal panel on
  the macOS 27.2 DCP firmware, through the firmware-27 interface. Needs
  ../aura-patches/0002 and 0003 (the 27.2 handoff, and aura enabling the
  display nodes, since the kernel's built-in gate accepts only 26.6.2).

Developed against github:briheet/nixos-m4pro docs/display/.
