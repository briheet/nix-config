# AOP driver patches

Applied in name order to nixos-aurora's AOP driver (drivers/soc/apple/aop.rs,
paths relative to the kernel tree, `patch -p1`) by ../pkgs/aurora-aop.nix,
which builds it out of tree as aop.ko under updates/. The AOP (always-on
coprocessor) carries the headphone jack, speakers, microphones and ambient
light sensor on the M4 Pro.

- 0001-aop-T6040-27.2-accept-EDATA-region.patch: accept the 27.2 firmware's
  __EDATA region, mapped inside its EC0p window, and pass its IOVA as the
  new ED0p boot argument (left 0, the firmware stalls before its mailbox).
  Needs ../aura-patches/0004, which keeps that mapping in the handoff.
- 0002-aop-debug-dump-state-on-failed-start.patch: debug, while the AOP is
  brought up on 27.2: on a failed start, log ("aopdbg") its ASC and mailbox
  state, boot arguments, log text and SRAM fault strings.
