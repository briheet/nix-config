# aura Stage 1 for the J614s, as aurora-installer enrolls it on a T6040,
# from nixos-aurora's aura package (its raw Stage 1 and aura's own tools):
#
#   1. the raw Stage 1 with its config block filled (fill_stage1_config.py):
#      boot `stage2Path` from the ESP with this PARTUUID, no proxy window
#   2. wrapped as a Mach-O boot object without __TEXT_BOOT_EXEC (iBoot enters
#      it directly, no SPTM) and padded for the 128 MiB code-execute window
#      (macho_boot_object.py --execute-window). An unpadded Stage 1 arms only
#      ~5 MiB of CTXR_D and Stage 2 refuses to start the OS.
#
# The padding is ~146 MiB of zeros; FAT has no sparse files and recoveryOS
# has no gunzip, so the object goes on the ESP as is, as aura's
# docs/recovery-enroll.md lays it out, and is enrolled with aura's
# enroll-stage1.sh --compress.
{ runCommand, python3, aura, espPartuuid, stage2Path ? "m1n1/boot-ctxr.bin" }:

runCommand "aura-stage1-j614s" { nativeBuildInputs = [ python3 ]; } ''
  tools=${aura}/share/aura/tools
  python3 $tools/fill_stage1_config.py \
    --input ${aura}/share/aura/stage1/aura-raw.bin \
    --output stage1.bin \
    --esp-partuuid ${espPartuuid} \
    --stage2-path ${stage2Path}
  python3 $tools/macho_boot_object.py --execute-window stage1.bin stage1.macho
  mkdir -p $out
  md5sum stage1.macho | cut -d' ' -f1 > $out/stage1.macho.md5
  cp stage1.macho $out/stage1.macho
  cp stage1.bin $out/stage1-raw.bin
  cp $tools/enroll-stage1.sh $out/
  echo ${aura.version} > $out/stage1.version
''
