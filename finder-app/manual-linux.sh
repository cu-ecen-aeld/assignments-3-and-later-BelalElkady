#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-
CROSS_TOOLCHAIN_PATH=~/system-programming/assignments-BelalElkady/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}
    # TODO: Add your kernel build steps here
     make mrproper CROSS_COMPILE=${CROSS_COMPILE} ARCH=${ARCH}
    make defconfig CROSS_COMPILE=${CROSS_COMPILE} ARCH=${ARCH} -j4 all dtbs
fi

echo "Adding the Image in outdir"
cp ${OUTDIR}/linux-stable/arch/arm64/boot/Image ${OUTDIR}

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir rootfs
cd rootfs
mkdir -p home bin boot dev etc lib lib64 proc root sbin media sys tmp var usr etc/init.d usr/bin usr/sbin usr/lib

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
   make distclean



else
    cd busybox
fi

# TODO: Make and install busybox
make  ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
make CONFIG_PREFIX=/tmp/aeld/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

echo "Library dependencies"
${CROSS_COMPILE}readelf -a busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
cp ${CROSS_TOOLCHAIN_PATH}/libc/lib/ld-linux-aarch64.so.1 /tmp/aeld/rootfs/lib 
cp ${CROSS_TOOLCHAIN_PATH}/libc/lib64/libm.so.6 /tmp/aeld/rootfs/lib 
cp ${CROSS_TOOLCHAIN_PATH}/libc/lib64/libresolv.so.2 /tmp/aeld/rootfs/lib 
cp ${CROSS_TOOLCHAIN_PATH}/libc/lib64/libc.so.6 /tmp/aeld/rootfs/lib 

cp ${CROSS_TOOLCHAIN_PATH}/libc/lib/ld-linux-aarch64.so.1 /tmp/aeld/rootfs/lib64 
cp ${CROSS_TOOLCHAIN_PATH}/libc/lib64/libm.so.6 /tmp/aeld/rootfs/lib64 
cp ${CROSS_TOOLCHAIN_PATH}/libc/lib64/libresolv.so.2 /tmp/aeld/rootfs/lib64 
cp ${CROSS_TOOLCHAIN_PATH}/libc/lib64/libc.so.6 /tmp/aeld/rootfs/lib64
# TODO: Make device nodes
cd ../rootfs/dev
sudo mknod -m 666 null c 1 3
sudo mknod -m 666 console c 5 1
# TODO: Clean and build the writer utility
cd /home/belal/system-programming/assignments-BelalElkady/finder-app/
make clean
make all CROSS_COMPILE=${CROSS_COMPILE}
# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cp -r * ${OUTDIR}/rootfs/home
# TODO: Chown the root directory
sudo chown -R belal ${OUTDIR}/rootfs
# TODO: Create initramfs.cpio.gz
cd ${OUTDIR}/rootfs
find . | cpio -ov -H newc --owner root:root| gzip -f > ${OUTDIR}/initramfs.cpio.gz

#gzip -f initramfs.cpio