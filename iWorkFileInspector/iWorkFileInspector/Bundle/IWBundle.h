//
//  IWBundle.h
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import <Foundation/Foundation.h>


@class IWBundleProperties, IWPasswordVerifier;


@interface IWBundle : NSObject

- (instancetype)initWithURL:(NSURL *)fileURL decryptionKey:(NSData *)decryptionKey;

@property(readonly) NSArray *componentNames;

- (NSData *)dataForComponentName:(NSString *)componentName;

+ (BOOL)validBundleExistsAtURL:(NSURL *)fileURL;
+ (IWBundleProperties *)propertiesForBundleURL:(NSURL *)fileURL;
+ (IWPasswordVerifier *)passwordVerifierForBundleURL:(NSURL *)fileURL passwordHint:(NSString **)hintPtr;

@end
