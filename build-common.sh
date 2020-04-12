#!/bin/bash

HOST="$(uname -m)"
JOBS=$(grep ^processor /proc/cpuinfo | wc -l)
MAKEFLAGS=-j$JOBS

ROOT_DIR=$(dirname $0)
PATCH_DIR=$ROOT_DIR/patches/$TARGET
PACKAGE_DIR=$ROOT_DIR/pkg
WORK_DIR=$ROOT_DIR/work/$TARGET-gcc

ARCH_DIR=$WORK_DIR/arch
SRC_DIR=$WORK_DIR/src
BUILD_DIR=$WORK_DIR/build
INSTALL_DIR=$WORK_DIR/install

download ()
{
    wget --content-disposition "$1" -O "$ARCH_DIR/$2"
    tar xf "$ARCH_DIR/$2" -C "$SRC_DIR"
}

patch_sources ()
{
    local PATCH_FILE=$PATCH_DIR/$1
    [[ -f "$PATCH_FILE" ]] || return 1

    pushd $SRC_DIR/$SOURCES
    patch -p0 -i $PATCH_FILE
    popd
}

configure ()
{
    local NAME=$1
    local SOURCE=$SRC_DIR/$NAME
    local BUILD=$BUILD_DIR/$NAME
    shift

    if [ ! -e $SOURCE/configure ] && [ -e $SOURCE/bootstrap ]; then
        cd $SOURCE
        ./bootstrap
    fi
    mkdir -p $BUILD
    pushd $BUILD
    $SOURCE/configure --prefix="$INSTALL_DIR" $@
    popd
}

build_and_install ()
{
    pushd $BUILD_DIR/$1
    shift
    make $MAKEFLAGS $@
    make install $@
    popd
}

strip_binaries ()
{
    set +e
    for subdir in bin/ $TARGET/bin/ lib/gcc/$TARGET/$GCC_VER/ libexec/gcc/$TARGET/$GCC_VER/; do
        [[ -d "$INSTALL_DIR/$subdir" ]] || continue
        binaries=$(find $INSTALL_DIR/$subdir -maxdepth 1 -name \* -perm /111 -and ! -type d)
        for binary in $binaries; do
            strip $binary
        done
    done
    set -e
}

strip_target_objects ()
{
    set +e
    local PATH="$INSTALL_DIR/bin:$PATH"
    for subdir in $TARGET/lib/ lib/gcc/$TARGET/ libexec/gcc/$TARGET/; do
        [[ -d "$INSTALL_DIR/$subdir" ]] || continue
        libs=$(find $INSTALL_DIR/$subdir -name \*.a -type f ! -path \*/plugin/\*)
        for lib in $libs; do
            $TARGET-objcopy --strip-debug $lib
        done
        objs=$(find $INSTALL_DIR/$subdir -name \*.o -type f ! -path \*/plugin/\*)
        for obj in $objs; do
            $TARGET-objcopy --strip-debug $obj
        done
    done
    set -e
}

package_toolchain ()
{
    local PACKAGE_NAME="$TARGET-gcc-$GCC_VER-$HOST-linux"
    mkdir -p "$PACKAGE_DIR"
    pushd "$PACKAGE_DIR"
    [[ ! -h "$PACKAGE_NAME" ]] || rm "$PACKAGE_NAME"
    ln -s "$INSTALL_DIR" "$PACKAGE_NAME"
    tar cjf "$PACKAGE_NAME.tar.bz2" \
        --owner=0 \
        --group=0 \
        --dereference \
        "$PACKAGE_NAME"
    rm "$PACKAGE_NAME"
    popd
}

recreate_dir ()
{
    [[ ! -d "$1" ]] || rm -rf "$1"
    mkdir -p "$1"
}
