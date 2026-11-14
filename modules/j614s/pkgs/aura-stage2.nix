# aura's ESP Stage 2 for the J614s (what aurora ships as boot-ctxr-j614s.bin):
# the bare Stage 2 aura, the kernel's t6040-j614s.dtb and U-Boot, composed by
# aura's compose_stage2.py, which checks the DTB and refuses an aura that is
# not a Stage 2. Its JSON receipt (kernel revision, each part's offset, size
# and SHA-256) lands beside the image.
{ runCommand, python3, aura, kernel, uBoot, kernelRev }:

runCommand "aura-stage2-j614s" { nativeBuildInputs = [ python3 ]; } ''
  gunzip -c ${uBoot}/u-boot-nodtb.bin.gz > u-boot-nodtb.bin
  python3 ${aura}/tools/compose_stage2.py \
    --aura ${aura}/stage2/aura.bin \
    --kernel-commit ${kernelRev} \
    --dtb ${kernel}/dtbs/apple/t6040-j614s.dtb \
    --uboot u-boot-nodtb.bin \
    --output boot-ctxr.bin
  test "$(stat -c %s boot-ctxr.bin)" -le $((16 * 1024 * 1024))
  mkdir -p $out
  cp boot-ctxr.bin* $out/
''
