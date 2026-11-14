# U-Boot for the J614s: aurora-silicon's fork (aurora-wip), which boots the
# M4 Pro (T6040) from its SSD with the dockchannel serial console and the MTP
# keyboard, and keeps Linux inside aura's CTXR execute window
# (aurora-silicon/u-boot#32). u-boot-nodtb.bin is gzipped as Asahi lays it
# out; aura's compose_stage2.py takes it raw (pkgs/aura-stage2.nix). aura
# passes it the kernel's device tree. ../u-boot/patches are our J614s fixes.
{ lib, buildUBoot, src }:

let
  source = src;
in

buildUBoot rec {
  # The u-boot flake input, locked in nix-config's flake.lock;
  # `nix flake update u-boot` follows upstream.
  version = "aurora-wip-${source.shortRev or "dirty"}";
  src = source.outPath or source;
  patches = lib.filesystem.listFilesRecursive ../u-boot/patches;
  defconfig = "apple_m1_defconfig";
  extraMeta.platforms = [ "aarch64-linux" ];
  filesToInstall = [ "u-boot-nodtb.bin.gz" ];
  extraConfig = ''
    CONFIG_IDENT_STRING=" ${version}"
    CONFIG_VIDEO_FONT_4X6=n
    CONFIG_VIDEO_FONT_8X16=n
    CONFIG_VIDEO_FONT_SUN12X22=n
    CONFIG_VIDEO_FONT_16X32=y
    CONFIG_CMD_BOOTMENU=y
    # aurora's quiet boot keeps U-Boot's text off the display while it boots
    # on its own, so the extlinux menu is invisible; on the J614s the MTP
    # keyboard also sends nothing then (2026-11-14: no key reports in an
    # autoboot menu, every key with quiet boot off). Show the menu instead.
    CONFIG_VIDEO_QUIET_BOOT=n
    CONFIG_FAT_WRITE=y
    # No stored environment: U-Boot always starts from its built-in one
    # (u-boot/patches/0003), and nothing looks for uboot.env on the ESP.
    CONFIG_ENV_IS_IN_FAT=n
    CONFIG_ENV_IS_NOWHERE=y
  '';
  postBuild = ''
    gzip -n u-boot-nodtb.bin
  '';
}
