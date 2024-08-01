#!/bin/bash

if [ "$1" = "" ] ; then
    ./make.sh 
fi

echo "update outputs to  ${RK3328_IMAGE}"
cp -rf parameter-gpt.txt  ${RK3328_IMAGE}
cp -rf rk3328_loader_*.bin  ${RK3328_IMAGE}
cp -rf uboot.img idbloader.img  pack_image.py trust.img ${RK3328_IMAGE}
