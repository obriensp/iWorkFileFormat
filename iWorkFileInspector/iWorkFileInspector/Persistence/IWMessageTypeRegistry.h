//
//  IWMessageTypeRegistry.h
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <google/protobuf/message.h>


@interface IWMessageTypeRegistry : NSObject

+ (IWMessageTypeRegistry *)registryForUTI:(NSString *)UTI;

- (const google::protobuf::Message *)messagePrototypeForMessageType:(uint32)messageType;

@end
