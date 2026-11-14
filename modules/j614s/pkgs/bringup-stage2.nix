# A Stage 2 for bringing the J614s up (the installer's ESP): nixos-aurora's
# aura, U-Boot and kernel device tree, with one addition to the tree: the
# debug UART (../dts/j614s-debug-uart.dtsi, appended to the board's tree), so U-Boot's console, earlycon
# and ttyDC0 reach a host over debug USB. Composed by aura's own
# compose_stage2.py, as boot-ctxr-j614s.bin is.
#
# Only the installer boots it. An installed system's Stage 2 is nixos-aurora's
# own (modules/installed.nix writes it on every bootloader install), built
# from the unpatched kernel, which stays the cached one.
{ runCommand, python3, dtc, gcc, gzip, gnutar, aura, uBoot, kernel, kernelCommit }:

runCommand "j614s-bringup-stage2" { nativeBuildInputs = [ python3 dtc gcc gzip gnutar ]; } ''
  # The J614s tree with the debug UART, built as the kernel builds its dtbs.
  mkdir tree
  tar -xzf ${kernel.src} -C tree --strip-components=1 --wildcards \
    '*/arch/arm64/boot/dts/*' '*/include/dt-bindings/*' '*/scripts/dtc/include-prefixes/*'
  chmod -R u+w tree
  cat ${../dts/j614s-debug-uart.dtsi} >> tree/arch/arm64/boot/dts/apple/t6040-j614s.dts
  cpp -nostdinc -undef -D__DTS__ -x assembler-with-cpp \
    -I tree/include -I tree/arch/arm64/boot/dts -I tree/scripts/dtc/include-prefixes \
    tree/arch/arm64/boot/dts/apple/t6040-j614s.dts > j614s.dts
  dtc -q -I dts -O dtb -o t6040-j614s.dtb j614s.dts

  uboot=${uBoot}/u-boot-nodtb.bin
  if [ ! -e $uboot ]; then gunzip -c ${uBoot}/u-boot-nodtb.bin.gz > u-boot-nodtb.bin; uboot=u-boot-nodtb.bin; fi

  mkdir aura-src
  tar -xzf ${aura.src} -C aura-src --strip-components=1 --wildcards '*/tools/*'
  python3 aura-src/tools/compose_stage2.py \
    --aura ${aura}/lib/m1n1/m1n1.bin \
    --kernel-commit ${kernelCommit} \
    --dtb t6040-j614s.dtb \
    --uboot $uboot \
    --output boot-ctxr.bin
  mkdir -p $out
  cp boot-ctxr.bin* t6040-j614s.dtb $out/
''
