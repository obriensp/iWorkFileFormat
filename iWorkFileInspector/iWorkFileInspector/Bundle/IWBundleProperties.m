//
//  IWBundleProperties.m
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import "IWBundleProperties.h"


@implementation IWBundleProperties

- (instancetype)initWithURL:(NSURL *)fileURL
{
	self = [super init];
	if (self == nil) {
		return nil;
	}
	
	NSDictionary *plist = [NSDictionary dictionaryWithContentsOfURL:fileURL];
	if (plist == nil) {
		return nil;
	}
	
	NSString *documentUUIDString = plist[@"documentUUID"];
	if ([documentUUIDString isKindOfClass:[NSString class]]) {
		_documentUUID = [[NSUUID alloc] initWithUUIDString:documentUUIDString];
	}
	
	NSString *versionUUIDString = plist[@"versionUUID"];
	if ([versionUUIDString isKindOfClass:[NSString class]]) {
		_versionUUID = [[NSUUID alloc] initWithUUIDString:versionUUIDString];
	}
	
	return self;
}

@end
