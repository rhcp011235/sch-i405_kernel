#!/bin/bash
#
# Build script for SCH-I405 Kernel
# Orig script taken from: https://github.com/imnuts/sch-i510_kernel/blob/gingerbread/build_kernel.sh and adapted for the SCH-I405 by rhcp011235@gmail.com
#
#

export DEVICE="strat"

# setup
export WORK=`pwd`
export DATE=$(date +%m%d)


# Declare TOOLCHAIN in the environment: TOOLCHAIN="/blah" sh build.sh
if [ -z "$TOOLCHAIN" ]; then
	export TOOLCHAIN=arm-eabi-
fi


# execution!
cd ..

# Ensure the initramfs exists for our device.
if [ -d "${DEVICE}_initramfs" ]; then
	cd "${DEVICE}_initramfs"

	# Move out the .git so we dont have a huge kernel and we dont boot :)
	if [ -d ".git" ]; then
		mv .git ../.git_ramfs
	fi

	# Build the kernel
	cd $WORK
	echo "***** Building for $DEVICE *****"

	# Use make mrproper to clean up the directory.
	make ARCH=arm CROSS_COMPILE="$TOOLCHAIN" mrproper 

	# Clean the update.zip area
	rm -f update/*.zip update/kernel_update/zImage

	# Move out the .git for the kenrel
	# Thanks Imnuts for the idea
	if [ -d ".git" ]; then
		mv .git ../.git_kernel
	fi

	make ARCH=arm CROSS_COMPILE="$TOOLCHAIN" stratosphere_defconfig 
	make ARCH=arm CROSS_COMPILE="$TOOLCHAIN" -j16 
	if [ $? != 0 ]; then
		echo -e "FAIL!\n\n"
		cd ..
		if [ -d ".git_ramfs" ]; then
			mv .git_ramfs "$DEVICE"_initramfs/.git
		fi

		if [ -d ".git_kernel" ]; then
			mv .git_kernel "$WORK"/.git
		fi

		exit 1
	else
		echo -e "Success!\n"
		rm -f "$WORK"/*log.txt
	fi

	# Build a recovery odin file
	cp arch/arm/boot/zImage recovery.bin
	tar -c recovery.bin > "${DATE}_${DEVICE}_recovery.tar"
	md5sum -t "${DATE}_${DEVICE}_recovery.tar" >> "${DATE}_${DEVICE}_recovery.tar"
	mv "${DATE}_${DEVICE}_recovery.tar" "${DATE}_${DEVICE}_recovery.tar.md5"
	rm recovery.bin

	# Make the CWM Zip
	cp arch/arm/boot/zImage update/kernel_update/zImage
	cd update
	zip -r -q ../"${DATE}_${DEVICE}.zip" .

	# Finish up
	cd ../../

	if [ -d ".git_ramfs" ]; then
		mv .git_ramfs "$DEVICE"_initramfs/.git
	fi

	if [ -d ".git_kernel" ]; then
		mv .git_kernel "$WORK"/.git
	fi

	cd $WORK
	echo -e "***** Successfully compiled for $DEVICE *****\n"
else
	echo "No initramfs found! Aborting."
	exit 1
fi
