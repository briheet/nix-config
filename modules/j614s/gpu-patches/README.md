# GPU driver patches

Applied in name order to nixos-aurora's GPU driver (drivers/gpu/drm/asahi,
paths relative to the kernel tree, `patch -p1`) by ../pkgs/aurora-gpu.nix,
which builds it out of tree as aurora.ko under updates/. A change here
rebuilds only the module: `nixos-rebuild switch`, then
`sudo rmmod aurora; sudo modprobe aurora` (or reboot).

- 0001-t6040-macos-27.2-gpu-firmware.patch: the M4 Pro (T6040) on the
  macOS 27.2 GPU firmware. Needs ../aura-patches/0001 (the firmware's third
  segment in the GPU handoff). Its header lists every change.

Developed against the 27.2 decode in github:briheet/nixos-m4pro
(docs/gpu/driver-27.2-diff.md; the probe history in driver-27.2-probes.md;
the test in tools/gpu-smoke). The patches of the bring-up itself, with its
firmware log and record dumps, are in this repository's history.
