#!/bin/bash

RED=$(echo -en '\001\033[00;31m\002')
YELLOW=$(echo -en '\001\033[00;33m\002')
RESTORE=$(echo -en '\001\033[0m\002')

check_complete() {
    arg1=$1
    if [[ $? -eq 0 ]]; then
        echo "${YELLOW}$arg1 completed successfully.${RESTORE}"
    else
        echo "${RED}$arg1 failed.  Exiting program...${RESTORE}"
        exit 1
    fi
}

			## MAIN ##

if [ -z "$1" ]; then
    echo "${RED}Please provide the kernel version as an argument."
    exit 1
fi

arg1=$1

# Install gentoo-sources for the given version
sudo emerge gentoo-sources:"${arg1}" --autounmask --autounmask-write
check_complete "emerge gentoo-sources"

sudo dispatch-conf
check_complete "dispatch-conf"

sudo emerge gentoo-sources:"${arg1}" --autounmask --autounmask-write
check_complete "emerge gentoo-sources (second time)"

# Link kernel source
sudo ln -sf /usr/src/linux-"${arg1}"-gentoo /usr/src/linux
check_complete "Linking kernel source"

cd /usr/src/linux
check_complete "Change directory to /usr/src/linux"

# Build and install the kernel
sudo make olddefconfig
check_complete "make olddefconfig"

sudo make modules_prepare
check_complete "make modules_prepare"

sudo make -j16
check_complete "make (compilation)"

sudo emerge @module-rebuild
check_complete "module-rebuild"

sudo make modules_install
check_complete "make modules_install"

sudo make install
check_complete "make install"

