//
//  IWBundle.h
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    IWBundleType2015,
    IWBundleType2013
} IWBundleType;


@class IWBundleProperties, IWPasswordVerifier;


@interface IWBundle : NSObject

- (instancetype)initWithURL:(NSURL *)fileURL decryptionKey:(NSData *)decryptionKey;

@property(readonly) NSArray *componentNames;
@property (assign, readonly) IWBundleType bundleType;

- (NSData *)dataForComponentName:(NSString *)componentName;

+ (BOOL)validBundleExistsAtURL:(NSURL *)fileURL;
+ (IWBundleProperties *)propertiesForBundleURL:(NSURL *)fileURL;
+ (IWPasswordVerifier *)passwordVerifierForBundleURL:(NSURL *)fileURL passwordHint:(NSString **)hintPtr;

@end
