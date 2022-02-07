#!/bin/bash
set -e
set -x

if which apt; then # Debian, Ubuntu
    apt update -y
    apt upgrade -y
    apt install -y \
        autoconf \
        bison \
        build-essential \
        flex \
        gawk \
        git \
        libexpat-dev \
        libgmp-dev \
        libz-dev \
        texinfo \
        wget

elif which dnf; then # Fedora, CentOS, AlmaLinux, Rocky Linux etc.
    dnf update -y --refresh
    # CentOS-based distros require PowerTools repo to be enabled for some of the packages
    if [ -e /etc/centos-release ]; then
        dnf -y install dnf-plugins-core
        dnf config-manager --set-enabled powertools
        dnf update -y
    fi
    dnf install -y \
        autoconf \
        bison \
        bzip2 \
        expat-devel \
        flex \
        gcc \
        gcc-c++ \
        git \
        gmp-devel \
        make \
        patch \
        tar \
        texinfo \
        wget \
        zlib-devel

elif which pacman; then # Arch Linux
    pacman -Syu --noconfirm
    pacman -Sy --needed --noconfirm \
        autoconf \
        base-devel \
        bison \
        flex \
        git \
        texinfo \
        wget

else
        echo "Unsupported package manager!"
        exit 1
fi

