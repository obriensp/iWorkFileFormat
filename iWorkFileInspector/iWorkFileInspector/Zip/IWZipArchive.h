//
//  IWZipArchive.h
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IWZipArchive : NSObject

- (id)initWithURL:(NSURL *)fileURL;

@property(readonly) NSArray *entryNames;
- (NSData *)dataForEntryName:(NSString *)entryName;

@end
