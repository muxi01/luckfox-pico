#!/bin/bash
rkdeveloptool.bin db RV1108_usb_boot_V1.26.bin && sleep 1
rkdeveloptool.bin wl 0x400 uboot-fake-kernel.img  && sleep 1
rkdeveloptool.bin rd

# rkdeveloptool.bin db rv110x_loader_v1.12.126.bin && sleep 1
# rkdeveloptool.bin ul rv110x_loader_v1.12.126.bin && sleep 1
# rkdeveloptool.bin wl 0x2000 u-boot.img && sleep 1
# rkdeveloptool.bin rd 0

# rkdeveloptool.bin db rv110x_loader_v1.12.126.bin && sleep 1
# rkdeveloptool.bin wl 0x40 idblock.bin && sleep 1
# rkdeveloptool.bin wl 0x2000 uboot.img && sleep 1
# rkdeveloptool.bin rd 0