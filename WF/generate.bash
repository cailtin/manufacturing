#!/bin/bash
# Generates bootloader and firmware images for manufacturing scripts
# Jacob Alexander - 2015

NAME_BOOTLOADER="WF_bootloader"
NAME_FIRMWARE="WF_firmware"
BOOTLOADER_BRANCH="master"
BOOTLOADER_REV="85586c574ac72a160593e7675aa9029d9b2a6713"
FIRMWARE_BRANCH="master"
FIRMWARE_REV="8c858e4483b61b0622e3663647a881d0a3150473"
KLL_BRANCH="master"
KLL_REV="b6cf0f13a88fef650f48270a1d1e20ccb1972d21"
CHIP="mk20dx256vlh7"
SCAN="WhiteFox"
BASEMAP="defaultMap"
DEFAULTMAP="stdFuncMap"
PARTIALMAPS="whitefox"


# Convenience debug/error checker
debug() {
	# Error occurred, stop
	if [ "$RETVAL" -ne "0" ]; then
		exit $RETVAL
	fi
}


# Find actual directory of this script and enter it
cd "$(realpath $(dirname "$0"))"

# Remove old .bin files
rm *.bin

# Make sure controller code is available and up to date
if [ ! -d ../controller ]; then
	cd ..
	git clone https://github.com/kiibohd/controller.git
	cd -
	cd ../controller
	git clone https://github.com/kiibohd/kll.git
	cd -
fi
cd ../controller

# Make sure repo is up to date
git checkout master
git pull


##############
# Bootloader #
##############

# Change to branch and revision
git checkout $BOOTLOADER_BRANCH
git checkout $BOOTLOADER_REV
cd -

# Create tmp directory (and make sure it's clean)
mkdir -p bootloader
cd bootloader
rm -rf *

# Generate the firmware
cmake ../../controller/Bootloader -DCHIP=$CHIP
make

# Prepare file
cp -f kiibohd_bootloader.bin ../${NAME_BOOTLOADER}.${BOOTLOADER_REV}.bin

# Revert to master branch
cd -
cd ../controller
git checkout master
cd -


############
# Firmware #
############

# Select kll version
cd ../controller/kll
git checkout master
git pull
git checkout $KLL_BRANCH
git checkout $KLL_REV
cd -

# Change to branch and revision
cd ../controller
git checkout $FIRMWARE_BRANCH
git checkout $FIRMWARE_REV
cd -

# Create tmp directory (and make sure it's clean)
mkdir -p firmware
cd firmware
rm -rf *

# Generate the firmware
cmake ../../controller -DCHIP=$CHIP -DScanModule=$SCAN -DBaseMap="$BASEMAP" -DDefaultMap="$DEFAULTMAP" -DPartialMaps="$PARTIALMAPS"
make

# Prepare file
cp -f kiibohd.dfu.bin ../${NAME_FIRMWARE}.${FIRMWARE_REV}.dfu.bin

# Revert to master branch
cd ..
cd ../controller
git checkout master
cd -
cd ../controller/kll
git checkout master
cd -

