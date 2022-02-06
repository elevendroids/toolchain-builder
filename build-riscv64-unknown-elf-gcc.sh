#!/bin/bash

set -e
set -x

TARGET=riscv64-unknown-elf
source $(dirname $0)/build-common.sh

GCC_VER="2022.01.17"
GCC="riscv-gcc"
TOOLCHAIN="riscv-gnu-toolchain"
TOOLCHAIN_REPO_URL="https://github.com/riscv-collab/${TOOLCHAIN}.git"
TOOLCHAIN_CONFIG="--enable-multilib"

GDB_CONFIG="--with-python=no"

download_sources ()
{
    local TOOLCHAIN_DIR=$SRC_DIR/$TOOLCHAIN
    git clone --depth 1 --branch $GCC_VER $TOOLCHAIN_REPO_URL $TOOLCHAIN_DIR
    pushd $TOOLCHAIN_DIR
    git submodule update --init --recommend-shallow riscv-{binutils,gcc,gdb,newlib}
    popd
    GCC_VER=$(<$TOOLCHAIN_DIR/$GCC/gcc/BASE-VER)
}

build_toolchain ()
{
    pushd $BUILD_DIR/$TOOLCHAIN
    make $MAKEFLAGS GDB_TARGET_FLAGS_EXTRA=$GDB_CONFIG
    popd
}

recreate_dir "$BUILD_DIR"
recreate_dir "$SRC_DIR"
recreate_dir "$INSTALL_DIR"
download_sources

configure $TOOLCHAIN $TOOLCHAIN_CONFIG
build_toolchain

strip_binaries
strip_target_objects
package_toolchain

