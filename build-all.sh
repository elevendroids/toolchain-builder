#!/bin/bash
set -e
set -x

BASE_DIR=$(dirname $0)
$BASE_DIR/build-avr-gcc.sh
$BASE_DIR/build-arm-none-eabi-gcc.sh
$BASE_DIR/build-msp430-gcc.sh
