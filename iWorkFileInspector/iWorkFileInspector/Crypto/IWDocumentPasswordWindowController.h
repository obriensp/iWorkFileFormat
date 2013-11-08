//
//  IWDocumentPasswordWindowController.h
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class IWKeychainItemDescriptor;


@interface IWDocumentPasswordWindowController : NSWindowController

+ (BOOL)retrievePasswordForKeychainItemDescriptor:(IWKeychainItemDescriptor *)descriptor validator:(BOOL(^)(NSString *password))validator;

@end
