//
//  IWPasswordVerifier.h
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IWPasswordVerifier : NSObject

- (id)initWithData:(NSData *)data;

- (NSData *)createKeyWithPassword:(NSString *)password;

@end
