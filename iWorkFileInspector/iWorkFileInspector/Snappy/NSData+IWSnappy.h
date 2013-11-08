//
//  NSData+IWSnappy.h
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (IWSnappy)

// Uses raw snappy decompression
- (NSData *)snappyDecompressedData;

// For data in .iwa format, where delimited chunks are snappy compressed with a 4 byte header.
- (NSData *)snappyIWADecompressedData;

@end
