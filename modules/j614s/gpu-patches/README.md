# GPU driver patches

Applied in name order to nixos-aurora's GPU driver (drivers/gpu/drm/asahi,
paths relative to the kernel tree, `patch -p1`) by ../pkgs/aurora-gpu.nix,
which builds it out of tree as aurora.ko under updates/. A change here
rebuilds only the module: `nixos-rebuild switch`, then
`sudo rmmod aurora; sudo modprobe aurora` (or reboot).

Developed against the 27.2 decode in github:briheet/nixos-m4pro.
