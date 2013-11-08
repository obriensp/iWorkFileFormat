//
//  IWDocumentMessage.mm
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import "IWDocumentMessage.h"


@implementation IWDocumentMessage

- (id)initWithMessage:(const google::protobuf::Message *)message identifier:(uint64_t)identifier
{
	self = [super init];
	if (self == nil) {
		return nil;
	}
	
	_identifier = identifier;
	_typeName = [NSString stringWithUTF8String:message->GetTypeName().c_str()];
	_contents = [NSString stringWithUTF8String:message->DebugString().c_str()];
	
	return self;
}

@end
