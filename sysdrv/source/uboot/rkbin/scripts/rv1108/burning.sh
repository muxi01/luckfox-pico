#!/bin/bash
rkdeveloptool.bin db RV1108_usb_boot_V1.26.bin && sleep 1
rkdeveloptool.bin wl 0 Firmware.img  && sleep 1
rkdeveloptool.bin rd