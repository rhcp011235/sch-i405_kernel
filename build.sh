#!/bin/bash

# setup
WORK=`pwd`
DATE=$(date +%m%d)


# Edit This for your Toolchain Dir
TOOLCHAIN=/opt/toolchains/2009q3-68/bin/arm-none-eabi-


# execution!
cd ..

# check for device we're building for
DEVICE="strat"
cd "$DEVICE"_initramfs

# Move out the .git so we dont have a huge kernel and we dont boot :)
mv .git ../.git_ramfs




# build the kernel
cd $WORK
echo "***** Building for $DEVICE *****"

# Make Clean and remove everything
make mrproper > /dev/null 2>&1

# Clean the update.zip area
rm -f update/*.zip update/kernel_update/zImage

# Move out the .git for the kenrel
# Thanks Imnuts for the idea
mv .git ../.git_kernel

make ARCH=arm CROSS_COMPILE="$TOOLCHAIN" "$DEVICE"_defconfig 1>/dev/null 2>"$WORK"/errlog.txt
make -j16 1>"$WORK"/stdlog.txt 2>>"$WORK"/errlog.txt

if [ $? != 0 ]; then
		echo -e "FAIL!\n\n"
		cd ..
		mv .git_ramfs "$DEVICE"_initramfs/
		mv .git_kernel "$WORK"
		exit 1
	else
		echo -e "Success!\n"
		rm -f "$WORK"/*log.txt
fi

# Build a recovery odin file
cp arch/arm/boot/zImage recovery.bin
tar -c recovery.bin > "$DATE"_"$DEVICE"_recovery.tar
md5sum -t "$DATE"_"$DEVICE"_recovery.tar >> "$DATE"_"$DEVICE"_recovery.tar
mv "$DATE"_"$DEVICE"_recovery.tar "$DATE"_"$DEVICE"_recovery.tar.md5
rm recovery.bin

# Make the CWM Zip
cp arch/arm/boot/zImage update/kernel_update/zImage
cd update
zip -r -q kernel_update.zip .
mv kernel_update.zip ../"$DATE"_"$DEVICE".zip

# Finish up
cd ../../
mv .git_ramfs "$DEVICE"_initramfs/
cd $WORK
echo -e "***** Successfully compiled for $DEVICE *****\n"

