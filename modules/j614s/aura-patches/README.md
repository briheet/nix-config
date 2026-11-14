# aura patches

Applied in name order to nixos-aurora's aura (`patch -p1` against its source
tree) for Stage 2 (and the Stage 1 written to the ESP) by ../boot.nix. A change
here rebuilds aura and Stage 2; it takes effect at the next boot, Stage 1 only
once enrolled again from recoveryOS.

- 0001: T6040 under macOS 27.2: accept the GPU firmware's third segment
  (__DATA_SHARED_RO), reserve and publish it; name each refusal in the log.
