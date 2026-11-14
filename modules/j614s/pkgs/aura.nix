# aura, aurora-silicon's bootloader (their m1n1 fork), from the `aura` input.
# Built as nixos-aurora builds it (pkgs/aura.nix there): nixpkgs' m1n1
# derivation, clang and lld (with GCC the image outgrows the room aura-raw.ld
# leaves before the DCP log buffer), RELEASE=1 CHAINLOADING=1.
#
#   $out/stage1/aura.bin   Stage 1, raw; ../boot.nix fills its config block
#                          and wraps it as a padded Mach-O for kmutil
#   $out/stage2/aura.bin   the bare ESP Stage 2 (ESP_STAGE2=1), which
#                          ./aura-stage2.nix composes with DTB and U-Boot
#   $out/dev/aura.bin      plain build: the USB proxy, for tethered work
#   $out/tools/            aura's own fill/wrap/compose/enroll tools
#
# nixosLogo: the NixOS snowflake on the panel instead of the Aurora logo.
{ lib, m1n1, rustPlatform, llvmPackages, buildPackages, imagemagick, nixos-icons, src, nixosLogo ? true }:

let
  version = lib.fileContents (src + "/VERSION");
  flags = [ "USE_CLANG=1" "BUILTIN_LOGO=${if nixosLogo then "nixos" else "aurora"}" ]
    ++ lib.optionals nixosLogo [ "LOGO_DIR=data" ];
in
(m1n1.override { customLogo = null; }).overrideAttrs (old: {
  pname = "aura";
  version = "${version}-${src.shortRev or "dirty"}";
  src = src.outPath or src;

  # aura's version.sh reads git, which a source tarball does not have.
  env = (old.env or { }) // {
    AURA_VERSION_TAG = "${version}-g${src.shortRev or "dirty"}-nixos";
  };
  hardeningDisable = [ "all" ];
  # What aura reports as /chosen/asahi,m1n1-stage{1,2}-version.
  passthru = (old.passthru or { }) // { versionTag = "${version}-g${src.shortRev or "dirty"}-nixos"; };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = src + "/rust/Cargo.lock";
    outputHashes."fatfs-0.4.0" = "sha256-r1STNZupll2U5MppT0gNmEKDl9gevRTYZFOAVimtZxU=";
  };

  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
    llvmPackages.clang-unwrapped
    llvmPackages.lld
    llvmPackages.llvm
    buildPackages.python3
    imagemagick
  ];

  postPatch = ''
    patchShebangs version.sh tools
  '' + lib.optionalString nixosLogo ''
    for s in 48 128 256; do
      magick ${nixos-icons}/share/icons/hicolor/256x256/apps/nix-snowflake.png \
        -background black -alpha remove -alpha off -resize ''${s}x''${s} \
        -gravity center -extent ''${s}x''${s} -depth 8 rgba:data/nixos_$s.bin
      test "$(wc -c < data/nixos_$s.bin)" -eq $((s * s * 4))
    done
  '';

  # Three builds from one tree: Stage 1, Stage 2, the proxy.
  dontUseMakeBuild = true;
  buildPhase = ''
    runHook preBuild
    build() {
      out_dir=$1; shift
      make -j$NIX_BUILD_CORES ARCH= "$@" ${lib.escapeShellArgs flags}
      mkdir -p "$out_dir"
      cp build/aura.bin "$out_dir/"
      make clean
    }
    build stages/stage1 RELEASE=1 CHAINLOADING=1
    build stages/stage2 RELEASE=1 CHAINLOADING=1 ESP_STAGE2=1
    build stages/dev CHAINLOADING=1
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    for s in stage1 stage2 dev; do
      install -Dm644 stages/$s/aura.bin $out/$s/aura.bin
    done
    install -Dm755 -t $out/tools \
      tools/fill_stage1_config.py tools/macho_boot_object.py \
      tools/compose_stage2.py tools/recovery/enroll-stage1.sh
    install -Dm644 LICENSE -t $out/share/doc/aura/licenses/
    runHook postInstall
  '';

  doCheck = false; # Upstream m1n1's Python suite is not aura's.
})
