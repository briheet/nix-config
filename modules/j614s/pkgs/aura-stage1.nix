# aura Stage 1 for the J614s, as aurora-installer enrolls it on a T6040:
#
#   1. the raw Stage 1 with its config block filled (aura's
#      fill_stage1_config.py): boot `stage2Path` from the ESP with this
#      PARTUUID, no proxy window
#   2. wrapped as a Mach-O boot object without __TEXT_BOOT_EXEC (so iBoot
#      enters it directly, no SPTM) and padded for the 128 MiB code-execute
#      window (macho_boot_object.py --execute-window). An unpadded Stage 1
#      arms only ~5 MiB of CTXR_D and Stage 2 refuses to start the OS.
#
# The padding is ~146 MiB of zeros, so the object is kept gzipped (the ESP
# is FAT, which has no sparse files). ../boot.nix puts it on the ESP with an
# enroll script for recoveryOS, which unpacks it and runs aura's
# enroll-stage1.sh with --compress.
{ runCommand, python3, aura, espPartuuid, stage2Path ? "m1n1/boot-ctxr.bin" }:

runCommand "aura-stage1-j614s" { nativeBuildInputs = [ python3 ]; } ''
  python3 ${aura}/tools/fill_stage1_config.py \
    --input ${aura}/stage1/aura.bin \
    --output stage1.bin \
    --esp-partuuid ${espPartuuid} \
    --stage2-path ${stage2Path}
  python3 ${aura}/tools/macho_boot_object.py --execute-window stage1.bin stage1.macho
  mkdir -p $out
  md5sum stage1.macho | cut -d' ' -f1 > $out/stage1.macho.md5
  gzip -9n < stage1.macho > $out/stage1.macho.gz
  cp stage1.bin $out/stage1-raw.bin
  cp ${aura}/tools/enroll-stage1.sh $out/
''
