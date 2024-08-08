#!/bin/bash

# rkdeveloptool.bin db ../rkbin/bin/rv1108/rv1108_usb_boot_v1.26.bin && sleep 1
# rkdeveloptool.bin wl 0x400 uboot-fake-kernel.img  && sleep 1
# rkdeveloptool.bin rd

rm -f f1.img 
cp -f ../rkbin/bin/rv1108/idblock-origin-0x7ffff.img  f1.img 
cat uboot-fake-kernel.img >> f1.img 
rkdeveloptool.bin db ../rkbin/bin/rv1108/rv1108_usb_boot_v1.26.bin && sleep 1
rkdeveloptool.bin wl 0 f1.img   && sleep 1
rkdeveloptool.bin rd

# rkdeveloptool.bin db rv110x_loader_v1.12.126.bin && sleep 1
# rkdeveloptool.bin ul rv110x_loader_v1.12.126.bin && sleep 1
# rkdeveloptool.bin wl 0x2000 u-boot.img && sleep 1
# rkdeveloptool.bin rd 0

# rkdeveloptool.bin db rv110x_loader_v1.12.126.bin && sleep 1
# rkdeveloptool.bin wl 0x40 idblock.bin && sleep 1
# rkdeveloptool.bin wl 0x2000 uboot.img && sleep 1
# rkdeveloptool.bin rd 0