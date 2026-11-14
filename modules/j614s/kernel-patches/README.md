# Kernel patches for the J614s

Applied in name order on top of nixos-aurora's kernel (its source, config and
build; `boot.kernelPatches`, which the Apple Silicon module passes to
nixos-aurora's `linux-asahi`). Any patch here means the kernel is built locally
instead of coming from Aurora's cache; on the M4 Pro itself that is the fast
path (`nixos-rebuild` builds natively).

Patches are developed and tested in github:briheet/nixos-m4pro (decoding,
logs, the dev tree workflow) and land here once they work.
