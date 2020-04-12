#!/bin/bash

set -e
set -x

TARGET=avr
source $(dirname $0)/build-common.sh

BINUTILS_VER="2.34"
BINUTILS="binutils-$BINUTILS_VER"
BINUTILS_ARCH="$BINUTILS.tar.xz"
BINUTILS_URL="https://ftpmirror.gnu.org/binutils/$BINUTILS_ARCH"
BINUTILS_CONFIG="--target=$TARGET \
    --enable-languages=c,c++ \
    --disable-nls"

GCC_VER="9.3.0"
GCC="gcc-$GCC_VER"
GCC_ARCH="$GCC.tar.xz"
GCC_URL="https://ftpmirror.gnu.org/gcc/$GCC/$GCC_ARCH"
GCC_CONFIG="--target=$TARGET \
    --enable-languages=c,c++ \
    --disable-nls \
    --disable-libada \
    --disable-libssp \
    --with-dwarf2 \
    --disable-shared \
    --enable-static"

AVRLIBC_VER="2.0.0"
AVRLIBC="avr-libc-$AVRLIBC_VER"
AVRLIBC_ARCH="$AVRLIBC.tar.bz2"
AVRLIBC_URL="http://download.savannah.gnu.org/releases/avr-libc/$AVRLIBC_ARCH"
AVRLIBC_CONFIG="--host=avr"

GDB_VER="9.1"
GDB="gdb-$GDB_VER"
GDB_ARCH="$GDB.tar.xz"
GDB_URL="https://ftp.mirrorservice.org/sites/sourceware.org/pub/gdb/releases/$GDB_ARCH"
GDB_CONFIG="--target=$TARGET \
    --with-python=yes \
    --disable-nls"

build_binutils ()
{
    configure $BINUTILS $BINUTILS_CONFIG
    build_and_install $BINUTILS
}

build_gcc ()
{
    pushd $SRC_DIR/$GCC
    ./contrib/download_prerequisites
    popd
    configure $GCC $GCC_CONFIG
    build_and_install $GCC
}

build_avrlibc ()
{
    local PATH="$INSTALL_DIR/bin:$PATH"
    configure $AVRLIBC $AVRLIBC_CONFIG
    build_and_install $AVRLIBC
}

build_gdb ()
{
    configure $GDB $GDB_CONFIG
    build_and_install $GDB
}

recreate_dir "$ARCH_DIR"
recreate_dir "$BUILD_DIR"
recreate_dir "$SRC_DIR"
recreate_dir "$INSTALL_DIR"

download "$BINUTILS_URL" "$BINUTILS_ARCH"
download "$GCC_URL" "$GCC_ARCH"
download "$AVRLIBC_URL" "$AVRLIBC_ARCH"
download "$GDB_URL" "$GDB_ARCH"

build_binutils
build_gcc
build_avrlibc
build_gdb

strip_binaries
strip_target_objects
package_toolchain
