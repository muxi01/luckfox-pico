#!/bin/bash

FAT_IMAGE="./kernel.fat"
KNL_IMAGE="arch/arm/boot/zImage"
DTB_IMAGE="arch/arm/boot/dts/rv1108-hover2-rc.dtb"

TARGET_IMG="$1"
MODULES_LIB=./modules-lib


function do_make()
{
	threads=`sed -n "N;/processor/p" /proc/cpuinfo|wc -l`
	if [ "${TARGET_IMG}x" = "x" ] ; then
		echo "make kernel "
		rm -rf ${KNL_IMAGE}
		make zImage --jobs=$((${threads} - 4))
	elif [ "${TARGET_IMG}x" = "modulesx" ] ; then
		echo "make modules"
		make modules --jobs=$((${threads} - 4))
	else
		echo "make dtbs"
		make dtbs --jobs=$((${threads} - 4))
	fi
}


function rm_modules()
{
	echo "remove all ko modules"

	rm -rf ${MODULES_LIB}/*

	files=$(find ./ -name *.ko)
	for f in $files ; do
		rm -rf $f 
	done
}

function update_modules()
{
	echo "update all ko modules"

	modules=$1
	sudo mkdir -p ${modules}
	files=$(find ./ -name *.ko)
	for f in $files ; do
		fpath=$(dirname $f)
		IFS='/' read -ra parts <<< "$fpath"
		fname=${parts[-1]}
		floader="${modules}/${fname}"
		[ ! -e ${floader} ] && sudo mkdir  -p ${floader}
		sudo cp -rf $f  ${floader}/
	done

	sudo tree -L 4  $modules
}


function make_fatfs()
{
	# ls -hl arch/arm/boot/uImage | awk '{print $5}'
	sudo mkdir kernel_tmp
	sudo dd if=/dev/zero of=${FAT_IMAGE} bs=1M count=50
	sudo mkfs.fat ${FAT_IMAGE}
	sudo mount   ${FAT_IMAGE}  ./kernel_tmp
	sudo cp -rf  ${KNL_IMAGE}  ./kernel_tmp/uImage.img
	sudo cp -rf  ${DTB_IMAGE}  ./kernel_tmp/uImage.dtb
	update_modules 					./kernel_tmp/modules
	sudo umount ./kernel_tmp
	sudo rm -rf  ./kernel_tmp
}


function update_images()
{
	echo "update kernel.fat uImage.dtb modules.tar uImage.img"
	[ -d ${OUTPUT} ] || mkdir -p ${OUTPUT}
	cp -rf 	${KNL_IMAGE} 		${OUTPUT}/uImage.img
	cp -rf  ${DTB_IMAGE}  		${OUTPUT}/uImage.dtb
	cp -rf 	${FAT_IMAGE} 		${OUTPUT}/
	cp -rf  ${MODULES_LIB}.tar  ${OUTPUT}/
}



do_make
make_fatfs
update_images
echo "$(date)"
