//
//  IWKeychainUtils.m
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import "IWKeychainUtils.h"


@implementation IWKeychainItemDescriptor
@end


@implementation IWKeychainUtils

+ (NSString *)passwordForDescriptor:(IWKeychainItemDescriptor *)descriptor error:(NSError **)errorPtr
{
	NSDictionary *query = @{
		(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
		(__bridge id)kSecAttrGeneric: descriptor.genericItem,
		(__bridge id)kSecReturnData: @(YES),
		(__bridge id)kSecReturnAttributes: @(YES),
	};

	CFTypeRef keychainCFType = NULL;
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &keychainCFType);
	if (status != errSecSuccess) {
		if (errorPtr != NULL) {
			(*errorPtr) = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
		}
		
		return NO;
	}
	
	NSDictionary *keychainItem = (__bridge_transfer NSDictionary *)keychainCFType;
	NSData *passwordData = keychainItem[(__bridge id)kSecValueData];
	return [[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];
}

+ (BOOL)setPassword:(NSString *)password forDescriptor:(IWKeychainItemDescriptor *)descriptor error:(NSError **)errorPtr
{
	NSString *service = descriptor.service;
	NSData *genericItem = descriptor.genericItem;
	
	if (password == nil || genericItem == nil || service == nil) {
		return NO;
	}
	
	// If there's already a password for this descriptor, remove it first.
	if ([self passwordForDescriptor:descriptor error:NULL] != nil) {
		if (![self removePasswordForDescriptor:descriptor error:errorPtr]) {
			return NO;
		}
	}
	
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	attributes[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
	attributes[(__bridge id)kSecAttrGeneric] = genericItem;
	attributes[(__bridge id)kSecValueData] = [password dataUsingEncoding:NSUTF8StringEncoding];
	attributes[(__bridge id)kSecAttrService] = service;
	
	NSString *description = descriptor.itemDescription;
	if (description != nil) {
		attributes[(__bridge id)kSecAttrDescription] = description;
	}
	
	NSString *label = descriptor.label;
	if (label != nil) {
		attributes[(__bridge id)kSecAttrLabel] = label;
	}
	
	OSStatus status = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
	if (status != errSecSuccess) {
		if (errorPtr != NULL) {
			(*errorPtr) = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
		}
		
		return NO;
	}
	
	return YES;
}

+ (BOOL)removePasswordForDescriptor:(IWKeychainItemDescriptor *)descriptor error:(NSError **)errorPtr
{
	NSData *genericItem = descriptor.genericItem;
	if (genericItem == nil) {
		return NO;
	}
	
	NSDictionary *query = @{
		(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
		(__bridge id)kSecAttrGeneric: genericItem
	};
	
	OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
	if (status == errSecSuccess) {
		return YES;
	}
	
	if (errorPtr != NULL) {
		(*errorPtr) = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
	}
	
	return NO;
}

@end
