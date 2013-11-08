#!/bin/sh

# To remove intermediates, run:
#   ./clean.sh 
# To remove all build products, run:
#   ./clean.sh --all

###
# Set up the enviroment
###
source common.sh

###
# Remove build directories
###
rm -rf "$IWFI_BUILD_DIR"

if [[ $* == *--all* ]]
	then
		rm -rf "$IWFI_PRODUCT_DIR"
fi

rm -rf snappy-$IWFI_SNAPPY_VERSION
rm -rf protobuf-$IWFI_PROTOBUF_VERSION
