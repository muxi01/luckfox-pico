#!/bin/bash

export ARCH=arm
export TOOLCHAIN="$(pwd)/../../../tools/linux/toolchain/arm-rockchip830-linux-uclibcgnueabihf/bin"
export PATH=${TOOLCHAIN}:${PATH}

export CROSS_COMPILE=arm-rockchip830-linux-uclibcgnueabihf-
export CROSS_COMPILE_ARM32="${TOOLCHAIN}/${CROSS_COMPILE}"

