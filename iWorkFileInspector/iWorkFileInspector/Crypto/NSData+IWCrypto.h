//
//  NSData+IWCrypto.h
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (IWCrypto)

// Decrypts data in .iwa encrypted format.
- (NSData *)decryptUsingIWAKey:(NSData *)keyData;

@end
