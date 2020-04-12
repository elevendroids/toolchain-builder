#!/bin/bash
set -e
set -x

BASE_DIR=$(dirname $0)
rm -rf "$BASE_DIR/work"
rm -rf "$BASE_DIR/pkg"
