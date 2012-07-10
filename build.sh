#!/bin/bash
#
# Build script for SCH-I405 Kernel
# Orig script taken from: https://github.com/imnuts/sch-i510_kernel/blob/gingerbread/build_kernel.sh and adapted for the SCH-I405 by rhcp011235@gmail.com
#
#

# setup
WORK=`pwd`
DATE=$(date +%m%d)


# Edit This for your Toolchain Dir
TOOLCHAIN=/opt/toolchains/arm-2009q3/bin/arm-none-linux-gnueabi-


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
make ARCH=arm CROSS_COMPILE="$TOOLCHAIN" mrproper 

# Clean the update.zip area
rm -f update/*.zip update/kernel_update/zImage

# Move out the .git for the kenrel
# Thanks Imnuts for the idea
mv .git ../.git_kernel

make ARCH=arm CROSS_COMPILE="$TOOLCHAIN" stratosphere_defconfig 
make ARCH=arm CROSS_COMPILE="$TOOLCHAIN" -j16 
if [ $? != 0 ]; then
		echo -e "FAIL!\n\n"
		cd ..
		mv .git_ramfs "$DEVICE"_initramfs/.git
		mv .git_kernel "$WORK"/.git
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
mv .git_ramfs "$DEVICE"_initramfs/.git
mv .git_kernel "$WORK"/.git
cd $WORK
echo -e "***** Successfully compiled for $DEVICE *****\n"

