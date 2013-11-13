//
//  IWBundle.m
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import "IWBundle.h"

#import "IWBundleProperties.h"
#import "IWPasswordVerifier.h"
#import "IWZipArchive.h"
#import "NSData+IWCrypto.h"
#import "NSData+IWSnappy.h"


NSString * const IWBundleComponentZipFileName = @"Index.zip";
NSString * const IWBundleComponentBasePath = @"Index";
NSString * const IWBundleArchivePathExtension = @"iwa";
NSString * const IWBundleMetadataDirectoryName = @"Metadata";
NSString * const IWBundlePropertiesFileName = @"Properties.plist";
NSString * const IWBundlePasswordHintFileName = @".iwph";
NSString * const IWBundlePasswordVerifierFileName = @".iwpv2";


@implementation IWBundle
{
	IWZipArchive *_objectArchive;
	NSData *_decryptionKey;
}

- (instancetype)initWithURL:(NSURL *)fileURL decryptionKey:(NSData *)decryptionKey
{
	self = [super init];
	if (self == nil) {
		return nil;
	}
	
	_objectArchive = [[IWZipArchive alloc] initWithURL:[fileURL URLByAppendingPathComponent:IWBundleComponentZipFileName]];
	if (_objectArchive == nil) {
		return nil;
	}
	
	_decryptionKey = decryptionKey;
	
	return self;
}

- (NSArray *)componentNames
{
	NSMutableArray *componentNames = [NSMutableArray array];
	
	for (NSString *entryName in _objectArchive.entryNames) {
		if (![entryName.pathExtension isEqualToString:IWBundleArchivePathExtension]) {
			continue;
		}
		
		NSArray *pathComponents = entryName.pathComponents;
		if (pathComponents.count < 2 || ![pathComponents[0] isEqualToString:IWBundleComponentBasePath]) {
			continue;
		}
		
		// Strip off the leading "Index/" and the trailing ".iwa"
		NSString *path = [NSString pathWithComponents:[pathComponents subarrayWithRange:NSMakeRange(1, pathComponents.count - 1)]];
		[componentNames addObject:path.stringByDeletingPathExtension];
	}
	
	[componentNames sortUsingSelector:@selector(compare:)];
	
	return componentNames;
}

- (NSData *)dataForComponentName:(NSString *)componentName
{
	NSString *fileName = [componentName stringByAppendingPathExtension:IWBundleArchivePathExtension];
	NSString *path = [IWBundleComponentBasePath stringByAppendingPathComponent:fileName];
	NSData *data = [_objectArchive dataForEntryName:path];
	
	if (data == nil) {
		NSLog(@"Unable to get data from archive for component: %@, path: %@", componentName, path);
	}
	
	if (_decryptionKey != nil) {
		data = [data decryptUsingIWAKey:_decryptionKey];
	}
	
	return [data snappyIWADecompressedData];
}

#pragma mark -

+ (BOOL)validBundleExistsAtURL:(NSURL *)fileURL
{
	if (!fileURL.isFileURL) {
		return NO;
	}
	
	NSURL *componentArchiveURL = [fileURL URLByAppendingPathComponent:IWBundleComponentZipFileName];
	return [componentArchiveURL checkResourceIsReachableAndReturnError:NULL];
}

+ (IWBundleProperties *)propertiesForBundleURL:(NSURL *)fileURL
{
	NSURL *metadataURL = [fileURL URLByAppendingPathComponent:IWBundleMetadataDirectoryName isDirectory:YES];
	NSURL *propertiesURL = [metadataURL URLByAppendingPathComponent:IWBundlePropertiesFileName];
	return [[IWBundleProperties alloc] initWithURL:propertiesURL];
}

+ (IWPasswordVerifier *)passwordVerifierForBundleURL:(NSURL *)fileURL passwordHint:(NSString **)hintPtr
{
	if (hintPtr != nil) {
		NSData *passwordHintData = [NSData dataWithContentsOfURL:[fileURL URLByAppendingPathComponent:IWBundlePasswordHintFileName]];
		(*hintPtr) = passwordHintData == nil ? nil : [[NSString alloc] initWithData:passwordHintData encoding:NSUTF8StringEncoding];
	}
	
	NSData *passwordVerifierData = [NSData dataWithContentsOfURL:[fileURL URLByAppendingPathComponent:IWBundlePasswordVerifierFileName]];
	if (passwordVerifierData == nil) {
		return nil;
	}
	
	return [[IWPasswordVerifier alloc] initWithData:passwordVerifierData];
}

@end
