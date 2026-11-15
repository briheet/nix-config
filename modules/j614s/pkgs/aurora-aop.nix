# nixos-aurora's AOP driver (aop.ko, drivers/soc/apple/aop.rs: the always-on
# coprocessor behind the headphone jack, speakers, microphones and ambient
# light sensor) built on its own, out of tree, against the running kernel's
# build output, with ../aop-patches/*.patch applied. As ./aurora-gpu.nix:
# installed under updates/, so the kernel stays nixos-aurora's cached one.
# Only aop.ko is built: a one-line Kbuild replaces the directory's Makefile,
# so the other drivers in drivers/soc/apple stay the kernel's own.
{ lib, stdenv, gnutar, kernel, patches ? [ ] }:

let
  release = kernel.modDirVersion;
  build = "${kernel.dev}/lib/modules/${release}/build";
  flags = lib.filter (f: !(lib.hasPrefix "O=" f) && !(lib.hasPrefix "--eval" f)) kernel.makeFlags;
in
stdenv.mkDerivation {
  pname = "aurora-aop";
  version = "${kernel.version}-${toString (builtins.length patches)}p";

  src = kernel.src;
  nativeBuildInputs = kernel.moduleBuildDependencies ++ kernel.nativeBuildInputs ++ [ gnutar ];

  unpackPhase = ''
    mkdir -p src
    tar -xzf $src -C src --strip-components=1 --wildcards '*/drivers/soc/apple/aop*.rs'
    cd src
  '';
  inherit patches;
  postPatch = ''
    echo 'obj-m := aop.o' > drivers/soc/apple/Kbuild
  '';

  makeFlags = flags ++ [
    "-C" build
    "M=$(PWD)/drivers/soc/apple"
    "INSTALL_MOD_PATH=$(out)"
    "INSTALL_MOD_DIR=updates"
    "INSTALL_MOD_STRIP=1"
    "DEPMOD=true"
    "CONFIG_MODULE_SIG_ALL="
  ];
  buildFlags = [ "modules" ];
  installTargets = [ "modules_install" ];
  enableParallelBuilding = true;
  dontPatchELF = true;

  meta.platforms = [ "aarch64-linux" ];
}
