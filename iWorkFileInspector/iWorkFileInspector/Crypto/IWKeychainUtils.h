//
//  IWKeychainUtils.h
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IWKeychainItemDescriptor : NSObject

// Optional. Maps to kSecAttrLabel.
@property(copy) NSString *label;

// Optional. Maps to kSecAttrDescription.
// Named 'itemDescription' instead of 'description' to avoid a conflict with -[NSObject description].
@property(copy) NSString *itemDescription;

// Required. Maps to kSecAttrService.
@property(copy) NSString *service;

// Required. Maps to kSecAttrGeneric.
@property(copy) NSData *genericItem;

@end


@interface IWKeychainUtils : NSObject

+ (NSString *)passwordForDescriptor:(IWKeychainItemDescriptor *)descriptor error:(NSError **)errorPtr;
+ (BOOL)setPassword:(NSString *)password forDescriptor:(IWKeychainItemDescriptor *)descriptor error:(NSError **)errorPtr;
+ (BOOL)removePasswordForDescriptor:(IWKeychainItemDescriptor *)descriptor error:(NSError **)errorPtr;

@end
