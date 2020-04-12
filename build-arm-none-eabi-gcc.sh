#!/bin/bash

set -e
set -x

TARGET=arm-none-eabi
source $(dirname $0)/build-common.sh

SOURCES_VER="2019-q4-major"
SOURCES="gcc-arm-none-eabi-9-$SOURCES_VER"
SOURCES_ARCH="$SOURCES-src.tar.bz2"
SOURCES_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/$SOURCES_ARCH"

build_toolchain ()
{
    pushd $SRC_DIR/$SOURCES
    # Override the release version
    export RELEASEVER=$SOURCES_VER
    ./install-sources.sh --skip_steps=mingw32
    ./build-prerequisites.sh --skip_steps=mingw32
    ./build-toolchain.sh --skip_steps=mingw32,howto,manual,package_sources,md5_checksum
    unset RELEASEVER
    popd
}

recreate_dir "$ARCH_DIR"
recreate_dir "$SRC_DIR"

download "$SOURCES_URL" "$SOURCES_ARCH"
# Add support for overriding the release version
patch_sources "build-common.sh.patch"
build_toolchain

mkdir -p "$PACKAGE_DIR"
pushd "$SRC_DIR/$SOURCES/pkg"
mv *.tar.bz2 "$PACKAGE_DIR/"
popd
