#!/bin/bash -e
BUILD_START=$(date +"%s")

# Colours
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
DIVIDER="$blue***********************************************$nocol"

# Kernel details
KERNEL_NAME="ts"
VERSION="Kernel"
DATE=$(date +"%d-%m-%Y-%I-%M")
FINAL_ZIP=$KERNEL_NAME-$VERSION-$DATE.zip
DEFCONFIG=nokia_defconfig

# Dirs and Files
BASE_DIR=`pwd`/../
KERNEL_DIR=$BASE_DIR/Ts.kernel_sdm660
ANYKERNEL_DIR=$BASE_DIR/AnyKernel3
KERNEL_IMG=$BASE_DIR/output/arch/arm64/boot/Image.gz-dtb
UPLOAD_DIR=$BASE_DIR/output

# Export Environment Variables
export PATH="$BASE_DIR/proton-clang/bin:$PATH"
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
export USE_CCACHE=1
export CCACHE_EXEC=$(command -v cccache)

# Make defconfig
function make_defconfig()  {
	echo -e " "
	make $DEFCONFIG CC=clang O=$BASE_DIR/output/
}

# Make newdefconfig
function make_newdefconfig()  {
	echo -e " "
	make savedefconfig CC=clang O=$BASE_DIR/output/
	mv $BASE_DIR/output/defconfig $BASE_DIR/new_defconfig
}

# Open Menuconfig
function make_menuconfig()  {
	echo -e " "
	make menuconfig CC=clang O=$BASE_DIR/output/
}

# Clear CCACHE
function clear_ccache  {
	echo -e " "
	ccache -Cz
}

# Menu
function menu()  {
	clear
	echo -e "$yellow Que hacer?"
	echo -e ""
	echo -e "1: Make defconfig and open menuconfig"
	echo -e "2: Make new_defconfig after menuconfig"
	echo -e "3: Clear ccache and reset stats"
	echo -e "5: Exit script"
	echo -e ""
	echo -e "Awaiting User Input: $red"
	read choice
	
	case $choice in
	 	1) echo -e $DIVIDER
		   echo -e "$cyan        Opening Menuconfig                          "
		   echo -e $DIVIDER
	 	   make_defconfig
	 	   make_menuconfig
	 	   menu
	 	   ;;
	 	2) echo -e $DIVIDER
		   echo -e "$cyan        Generating Defconfig                        "
		   echo -e $DIVIDER
	 	   make_newdefconfig
	 	   menu
	 	   ;;
	 	3) echo -e $DIVIDER
		   echo -e "$cyan    Clearing CCACHE                            "
		   echo -e $DIVIDER
	 	   clear_ccache
	 	   menu
	 	   ;;
	 	5) echo -e "$red Exiting"
	 	   clear
	 	   ;; 
	 	   
	 esac
	
}

menu
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "Script execution completed after $((DIFF/60)) minute(s) and $((DIFF % 60)) seconds"
