# nixos-aurora's display driver (appledrm.ko, drivers/gpu/drm/apple) built on
# its own, out of tree, against the running kernel's build output, with
# ../display-patches/*.patch applied. Installed under updates/, which depmod
# prefers over the in-tree copy, so the kernel stays nixos-aurora's cached one
# and a patch change rebuilds only this (as ./aurora-gpu.nix does for the GPU).
{ lib, stdenv, gnutar, kernel, patches ? [ ] }:

let
  release = kernel.modDirVersion;
  build = "${kernel.dev}/lib/modules/${release}/build";
  # The kernel's own make flags (toolchain, LLVM=1, ARCH), minus the ones
  # that point at its in-tree build directory.
  flags = lib.filter (f: !(lib.hasPrefix "O=" f) && !(lib.hasPrefix "--eval" f)) kernel.makeFlags;
in
stdenv.mkDerivation {
  pname = "aurora-display";
  version = "${kernel.version}-${toString (builtins.length patches)}p";

  src = kernel.src;
  nativeBuildInputs = kernel.moduleBuildDependencies ++ kernel.nativeBuildInputs ++ [ gnutar ];

  unpackPhase = ''
    mkdir -p src
    tar -xzf $src -C src --strip-components=1 --wildcards '*/drivers/gpu/drm/apple/*'
    cd src
  '';
  inherit patches;

  makeFlags = flags ++ [
    "-C" build
    "M=$(PWD)/drivers/gpu/drm/apple"
    "INSTALL_MOD_PATH=$(out)"
    "INSTALL_MOD_DIR=updates"
    "INSTALL_MOD_STRIP=1"
    "DEPMOD=true"
    # nixos-aurora's signing key stays in its build, and the kernel does not
    # require signed modules (no MODULE_SIG_FORCE): install it unsigned.
    "CONFIG_MODULE_SIG_ALL="
  ];
  buildFlags = [ "modules" ];
  installTargets = [ "modules_install" ];
  enableParallelBuilding = true;
  dontPatchELF = true;

  meta.platforms = [ "aarch64-linux" ];
}
