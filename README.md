============= new_kernel.sh For Gentoo Linux Users =============

This program automates installing a specific kernel from gentoo-sources.  If you don't want to use a gentoo-sources kernel, then this script is not what you need.

The program will do the following:

=========================================

- downloads a gentoo-sources kernel based on the first argument
- automatically runs 'dispatch-conf' to add the necessary zz-autounmask entry, if needed (you still need to press 'u' manually)
- links the new kernel to the /usr/src/linux directory
- runs 'make olddefconfig' to use your previously defined .config with all your custom kernel modifications for the new kernel.
- runs 'make modules_prepare' to prepare the kernel modules.
- runs 'make -j<2nd arg number>' with your choice of CPU threads to use, passed in by the second argument.  This compiles your new kernel.
- runs 'emerge @modules-rebuild' to rebuild any external kernel modules.
- runs 'make modules_install' to install all your kernel modules.
- runs 'make install' to install the new kernel.  This will create your boot entry too, if you have your install-kernel flags set correctly.  For systems using GRUB and dracut, the following package.use/install-kernel entry should suffice: sys-kernel/installkernel dracut grub

=========================================
