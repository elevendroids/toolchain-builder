#!/bin/bash

set -e
set -x

TARGET=msp430-elf
source $(dirname $0)/build-common.sh

MSP430_PATCHES="msp430-gcc-9.3.1.11-source-patches"
MSP430_PATCHES_ARCH="$MSP430_PATCHES.tar.bz2"
MSP430_PATCHES_URL="http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/9_3_1_2/export/$MSP430_PATCHES_ARCH"

BINUTILS_VER="2.34"
BINUTILS="binutils-$BINUTILS_VER"
BINUTILS_ARCH="$BINUTILS.tar.bz2"
BINUTILS_URL="https://ftp.mirrorservice.org/sites/ftp.gnu.org/gnu/binutils/$BINUTILS_ARCH"
BINUTILS_CONFIG="--target=$TARGET \
    --enable-languages=c,c++ \
    --disable-nls \
    --disable-sim \
    --disable-gdb \
    --disable-werror"

GCC_VER="9.3.0"
GCC="gcc-$GCC_VER"
GCC_ARCH="$GCC.tar.xz"
GCC_URL="https://ftp.mirrorservice.org/sites/ftp.gnu.org/gnu/gcc/$GCC/$GCC_ARCH"
GCC_CONFIG="--target=$TARGET \
    --libexecdir=$INSTALL_DIR/lib \
    --enable-languages=c,c++ \
    --disable-nls \
    --enable-target-optspace \
    --enable-newlib-nano-formatted-io"

NEWLIB_VER="2.4.0"
NEWLIB="newlib-$NEWLIB_VER"
NEWLIB_ARCH="$NEWLIB.tar.gz"
NEWLIB_URL="https://ftp.mirrorservice.org/sites/sourceware.org/pub/newlib/$NEWLIB_ARCH"
#NEWLIB_CONFIG="--target=$TARGET"

GDB_VER="9.1"
GDB="gdb-$GDB_VER"
GDB_ARCH="$GDB.tar.xz"
GDB_URL="https://ftp.mirrorservice.org/sites/sourceware.org/pub/gdb/releases/$GDB_ARCH"
GDB_CONFIG="--target=$TARGET \
    --enable-languages=c,c++ \
    --disable-nls \
    --disable-binutils \
    --disable-gas \
    --disable-ld \
    --disable-gprof \
    --disable-etc \
    --without-mpfr \
    --without-lzma \
    --with-python=no"

patch_sources ()
{
    local NAME=$1
    local PATCH=$2
    local SOURCE=$SRC_DIR/$NAME
    pushd $SOURCE
    patch -p0 -i $PATCH
    popd
}

build_binutils ()
{
    for patch_file in $SRC_DIR/$MSP430_PATCHES/binutils-*.patch; do
        patch_sources "$BINUTILS" "$patch_file"
    done
    configure $BINUTILS $BINUTILS_CONFIG
    build_and_install $BINUTILS
}

build_gcc ()
{
    local PATH="$INSTALL_DIR/bin:$PATH"
    for patch_file in $SRC_DIR/$MSP430_PATCHES/gcc-*.patch; do
        patch_sources "$GCC" "$patch_file"
    done
    for patch_file in $SRC_DIR/$MSP430_PATCHES/newlib-*.patch; do
        patch_sources "$NEWLIB" "$patch_file"
    done
    # GCC version is likely to change after patching.
    # Update it to properly handle stripping the binaries and package naming later
    GCC_VER=$(<$SRC_DIR/$GCC/gcc/BASE-VER)

    pushd $SRC_DIR/$GCC
    ./contrib/download_prerequisites
    popd
    for dir in libgloss newlib; do
        ln -fns $SRC_DIR/$NEWLIB/$dir $SRC_DIR/$GCC/$dir
    done
    configure $GCC $GCC_CONFIG
    build_and_install $GCC
}

build_gdb ()
{
    for patch_file in $SRC_DIR/$MSP430_PATCHES/gdb-*.patch; do
        patch_sources "$GDB" "$patch_file"
    done
    configure $GDB $GDB_CONFIG
    build_and_install $GDB
}

recreate_dir "$ARCH_DIR"
recreate_dir "$BUILD_DIR"
recreate_dir "$SRC_DIR"
recreate_dir "$INSTALL_DIR"

download "$MSP430_PATCHES_URL" "$MSP430_PATCHES_ARCH"
download "$BINUTILS_URL" "$BINUTILS_ARCH"
download "$GCC_URL" "$GCC_ARCH"
download "$NEWLIB_URL" "$NEWLIB_ARCH"
download "$GDB_URL" "$GDB_ARCH"

build_binutils
build_gcc
build_gdb

strip_binaries
strip_target_objects
package_toolchain
