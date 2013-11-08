//
//  IWBundleProperties.h
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IWBundleProperties : NSObject

- (instancetype)initWithURL:(NSURL *)fileURL;

@property(readonly, nonatomic) NSUUID *documentUUID;
@property(readonly, nonatomic) NSUUID *versionUUID;

@end
