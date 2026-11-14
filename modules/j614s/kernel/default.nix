# The J614s kernel: aurora-silicon/linux integration/aurora (the `linux`
# input of nix-config's flake, `nix flake update linux` follows it), plus
# ./patches (only what aurora lacks), built with aurora's patched bindgen.
#
# Config: ./m4pro-nixos.full.config, generated from arm64 defconfig,
# aurora's arch/arm64/configs/asahi.config, then ./m4pro-min.config and
# ./m4pro-nixos.config (ours win: storage, keyboard, console and Wi-Fi built
# in, so the initrd needs no modules). It has CONFIG_ARM64_CTXR_EXECMEM,
# which aura's confined boot (stage 1 padded for the execute window) needs.
{ lib, callPackage, linuxManualConfig, src, ... }:

let
  # The version from the source's own Makefile, so an update needs no edit.
  makefile = builtins.readFile (src + "/Makefile");
  field = name: lib.head (lib.concatMap
    (line: if builtins.match "${name} = ([0-9]+)" line == null then [ ] else builtins.match "${name} = ([0-9]+)" line)
    (lib.splitString "\n" makefile));
  kernelVersion = "${field "VERSION"}.${field "PATCHLEVEL"}.${field "SUBLEVEL"}";
  patchDir = ./patches;
  # aurora's patched bindgen; Kbuild picks it up from this path in the
  # source tree (aurora's Makefile, aurora_bindgen).
  bindgen = callPackage ../pkgs/aurora-bindgen.nix { inherit src; };
  patches = lib.sort lib.lessThan
    (lib.filter (lib.hasSuffix ".patch") (builtins.attrNames (builtins.readDir patchDir)));
in
(linuxManualConfig {
  version = "${kernelVersion}-m4pro-nixos";
  modDirVersion = "${kernelVersion}-m4pro-nixos";
  src = src.outPath or src;
  kernelPatches = map (name: { inherit name; patch = patchDir + "/${name}"; }) patches;
  configfile = ./m4pro-nixos.full.config;
  allowImportFromDerivation = true;
}).overrideAttrs (old: {
  postPatch = (old.postPatch or "") + ''
    mkdir -p tools/aurora-bindgen/build/bin
    ln -s ${bindgen}/bin/bindgen tools/aurora-bindgen/build/bin/bindgen
  '';
})
