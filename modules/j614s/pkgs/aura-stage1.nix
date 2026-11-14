# aura Stage 1 for the J614s: nixos-aurora's raw Stage 1 (aura-raw.bin) with
# its config block filled by aura's fill_stage1_config.py: boot `stage2Path`
# from the ESP with this PARTUUID, no proxy window.
#
# Raw, not the padded Mach-O boot object aurora-installer enrolls on M4
# Macs: that mode (CTXR windows) needs the stub macOS's iBoot to be 26.6.2's,
# and this Mac boots Stage 1 through Macintosh HD's 27.2 iBoot, under which
# aura started no secondary CPU and the kernel died after ExitBootServices
# (2026-11-15). A raw object with Kernel CTRR off (`bputil -nc`) arms no CTXR
# window, so aura and Linux run as on M1 to M3; this Mac ran Linux on all
# cores that way under the same iBoot. Enrolled from recoveryOS with aura's
# enroll-stage1.sh --raw (kmutil --raw --entry-point 2048
# --lowest-virtual-address 0). Stage 2 stays m1n1/boot-ctxr.bin, the file
# nixos-aurora updates on a T6040.
{ runCommand, python3, aura, espPartuuid, stage2Path ? "m1n1/boot-ctxr.bin" }:

runCommand "aura-stage1-j614s" { nativeBuildInputs = [ python3 ]; } ''
  tools=${aura}/share/aura/tools
  mkdir -p $out
  python3 $tools/fill_stage1_config.py \
    --input ${aura}/share/aura/stage1/aura-raw.bin \
    --output $out/stage1.bin \
    --esp-partuuid ${espPartuuid} \
    --stage2-path ${stage2Path}
  md5sum $out/stage1.bin | cut -d' ' -f1 > $out/stage1.bin.md5
  cp $tools/enroll-stage1.sh $out/
  echo ${aura.version} > $out/stage1.version
''
