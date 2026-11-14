# A Stage 2 for bringing the J614s up (the installer's ESP): nixos-aurora's
# aura, U-Boot and kernel device tree, with one addition to the tree: the
# debug UART (../dts/j614s-debug-uart.patch), so U-Boot's console, earlycon
# and ttyDC0 reach a host over debug USB. Composed by aura's own
# compose_stage2.py, as boot-ctxr-j614s.bin is.
#
# Only the installer boots it. An installed system's Stage 2 is nixos-aurora's
# own (modules/installed.nix writes it on every bootloader install), built
# from the unpatched kernel, which stays the cached one.
{ runCommand, srcOnly, python3, dtc, gcc, gzip, aura, uBoot, kernel, kernelCommit }:

let
  kernelSrc = srcOnly kernel;
in
runCommand "j614s-bringup-stage2" { nativeBuildInputs = [ python3 dtc gcc gzip ]; } ''
  # The J614s tree with the debug UART, built as the kernel builds its dtbs.
  mkdir tree
  cp -r --no-preserve=mode ${kernelSrc}/arch ${kernelSrc}/include ${kernelSrc}/scripts tree/
  (cd tree && patch -p1 < ${../dts/j614s-debug-uart.patch})
  cpp -nostdinc -undef -D__DTS__ -x assembler-with-cpp \
    -I tree/include -I tree/arch/arm64/boot/dts -I tree/scripts/dtc/include-prefixes \
    tree/arch/arm64/boot/dts/apple/t6040-j614s.dts > j614s.dts
  dtc -q -I dts -O dtb -o t6040-j614s.dtb j614s.dts

  uboot=${uBoot}/u-boot-nodtb.bin
  if [ ! -e $uboot ]; then gunzip -c ${uBoot}/u-boot-nodtb.bin.gz > u-boot-nodtb.bin; uboot=u-boot-nodtb.bin; fi

  python3 ${aura.src}/tools/compose_stage2.py \
    --aura ${aura}/lib/m1n1/m1n1.bin \
    --kernel-commit ${kernelCommit} \
    --dtb t6040-j614s.dtb \
    --uboot $uboot \
    --output boot-ctxr.bin
  mkdir -p $out
  cp boot-ctxr.bin* t6040-j614s.dtb $out/
''
