#!/bin/bash

set -e
set -x

TARGET=arm-none-eabi
source $(dirname $0)/build-common.sh

SOURCES_VER="10.3-2021.10"
SOURCES="gcc-arm-none-eabi-$SOURCES_VER"
SOURCES_ARCH="$SOURCES-src.tar.bz2"
#SOURCES_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/$SOURCES_ARCH"
SOURCES_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/$SOURCES_VER/gcc-arm-none-eabi-$SOURCES_VER-src.tar.bz2"

build_toolchain ()
{
    pushd $SRC_DIR/$SOURCES
    # Override the release version
    export SRC_VERSION=${SOURCES_VER/*-/}
    echo "Building version ${SRC_VERSION}"
    ./install-sources.sh --skip_steps=mingw32
    ./build-prerequisites.sh --skip_steps=mingw32
    ./build-toolchain.sh --skip_steps=gdb-with-python,mingw32,howto,manual,package_sources,md5_checksum
    unset SRC_VERSION
    popd
}

recreate_dir "$ARCH_DIR"
recreate_dir "$SRC_DIR"

download "$SOURCES_URL" "$SOURCES_ARCH"
# Add support for overriding the release version
sed -i -e "s/RELEASEVER=\(.*\)/RELEASEVER=\$SRC_VERSION/" $SRC_DIR/$SOURCES/build-common.sh

build_toolchain

mkdir -p "$PACKAGE_DIR"
pushd "$SRC_DIR/$SOURCES/pkg"
mv *.tar.bz2 "$PACKAGE_DIR/"
popd
