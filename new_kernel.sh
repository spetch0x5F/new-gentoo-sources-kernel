#!/bin/bash

RED=$(echo -en '\001\033[00;31m\002')
YELLOW=$(echo -en '\001\033[00;33m\002')
RESTORE=$(echo -en '\001\033[0m\002')

        ##### FUNCTIONS #####

intro_blurb() {
echo ""
echo "${YELLOW}"
echo "============= new_kernel.sh For Gentoo Linux Users ============="
echo ""
echo "This program automates installing a specific kernel from gentoo-sources.  If you don't want to use a gentoo-sources kernel, then this script is not what you need."
echo ""
echo "The program will do the following:"
echo ""
echo "========================================="
echo ""
echo "- downloads a gentoo-sources kernel based on the first argument"
echo "- automatically runs 'dispatch-conf' to add the necessary zz-autounmask entry, if needed (you still need to press 'u' manually)"
echo "- links the new kernel to the /usr/src/linux directory"
echo "- runs 'make olddefconfig' to use your previously defined .config with all your custom kernel modifications for the new kernel."
echo "- runs 'make modules_prepare' to prepare the kernel modules."
echo "- runs 'make -j<2nd arg number>' with your choice of CPU threads to use, passed in by the second argument.  This compiles your new kernel."
echo "- runs 'emerge @modules-rebuild' to rebuild any external kernel modules."
echo "- runs 'make modules_install' to install all your kernel modules."
echo "- runs 'make install' to install the new kernel.  This will create your boot entry too, if you have your install-kernel flags set correctly.  For systems using GRUB and dracut, the following package.use/install-kernel entry should suffice: sys-kernel/installkernel dracut grub"
echo ""
echo "========================================="
echo "${RESTORE}"
echo ""

}

check_complete() {
    arg1=$1
    if [[ $? -eq 0 ]]; then
        echo "${YELLOW}$arg1 completed successfully.${RESTORE}"
        echo ""
    else
        echo "${RED}$arg1 failed.  Exiting program...${RESTORE}"
        echo ""
        exit 1
    fi
}

install_the_kernel() {

# Install gentoo-sources for the given version
sudo emerge gentoo-sources:"${arg1}" --autounmask --autounmask-write


sudo dispatch-conf
echo ""

sudo emerge gentoo-sources:"${arg1}" --autounmask --autounmask-write
echo ""

# Link kernel source
sudo ln -sf /usr/src/linux-"${arg1}"-gentoo /usr/src/linux
check_complete "Kernel source linkage"

cd /usr/src/linux
check_complete "directory change to /usr/src/linux"

# Build and install the kernel
sudo make olddefconfig
check_complete "make olddefconfig"

sudo make modules_prepare
check_complete "make modules_prepare"

sudo make -j"${arg2}"
check_complete "make (compilation)"

notify-send -w "Please enter your password again to finish installing the kernel."
sudo emerge @module-rebuild
check_complete "module-rebuild"

sudo make modules_install
check_complete "make modules_install"

sudo make install
check_complete "make install"

}



			##### MAIN #####

check_args() {

if [ -z "$1" ]; then
    echo "" 
    echo "${RED}Please provide the kernel version as the first argument."
    echo ""
    echo "${YELLOW}Like this, for kernel 6.12.9 with 4 CPU threads being specified to compile it:"
    echo ""
    echo "     ./new_kernel.sh 6.12.9 4"
    echo "${RESTORE}"
    echo ""
    exit 1
fi

arg1=$1

if [ -z "$2" ]; then
    echo "" 
    echo "${RED}Please provide the number of CPU threads to use as the 2nd argument."
    echo ""
    echo "${YELLOW}Like this, for -j4 with kernel 6.12.9:"
    echo ""
    echo "     ./new_kernel.sh 6.12.9 4"
    echo "${RESTORE}"
    echo ""
    exit 1
fi

arg2=$2

}

# RUN INSTALL
intro_blurb
check_args $1 $2
install_the_kernel


