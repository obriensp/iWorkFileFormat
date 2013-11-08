#!/bin/sh

###
# Set up the enviroment
###
source common.sh

###
# Prepare build directories
###
rm -rf "$IWFI_BUILD_DIR"
rm -rf "$IWFI_PRODUCT_DIR"
mkdir "$IWFI_BUILD_DIR"
mkdir "$IWFI_PRODUCT_DIR"

###
# Clean up any existing sources and extract new ones
###
rm -rf snappy_$IWFI_SNAPPY_VERSION
rm -rf protobuf_$IWFI_PROTOBUF_VERSION
tar -xzf packages/snappy-$IWFI_SNAPPY_VERSION.tar.gz
tar -xzf packages/protobuf-$IWFI_PROTOBUF_VERSION.tar.gz

###
# Apply patches
###

###
# Build Snappy
###
cd "$ROOT/snappy-$IWFI_SNAPPY_VERSION"
./configure --prefix="$IWFI_BUILD_DIR"
make install

###
# Build Protobuf
###
cd "$ROOT/protobuf-$IWFI_PROTOBUF_VERSION"
./configure --prefix="$IWFI_BUILD_DIR"
make install

###
# Copy build products
###
mkdir $IWFI_PRODUCT_DIR/bin $IWFI_PRODUCT_DIR/include $IWFI_PRODUCT_DIR/lib
cp -r $IWFI_BUILD_DIR/bin/protoc $IWFI_PRODUCT_DIR/bin/protoc
cp -r $IWFI_BUILD_DIR/include/* $IWFI_PRODUCT_DIR/include/
for libname in libsnappy.a libprotobuf.a; do
	cp $IWFI_BUILD_DIR/lib/$libname $IWFI_PRODUCT_DIR/lib/$libname
done
