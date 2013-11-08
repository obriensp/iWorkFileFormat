#!/bin/sh

###
# Set up the enviroment
###
export ROOT=$PWD
export IWFI_BUILD_DIR=$ROOT/intermediate
export IWFI_PRODUCT_DIR=$ROOT/prebuilt

export IWFI_SNAPPY_VERSION=1.1.1
export IWFI_PROTOBUF_VERSION=2.5.0

# Exit if anything fails
set -e
