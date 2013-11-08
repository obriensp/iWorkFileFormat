//
//  IWDocumentMessage.h
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <google/protobuf/message.h>


@interface IWDocumentMessage : NSObject

- (id)initWithMessage:(const google::protobuf::Message *)message identifier:(uint64_t)identifier;

@property(readonly) uint64_t identifier;

@property(readonly) NSString *typeName;
@property(readonly) NSString *contents;

@end
