//
//  IWDocument.mm
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import "IWDocument.h"

#import <google/protobuf/message.h>
#import <google/protobuf/io/coded_stream.h>
#import "IWBundle.h"
#import "IWBundleProperties.h"
#import "IWDocumentMessage.h"
#import "IWDocumentPasswordWindowController.h"
#import "IWKeychainUtils.h"
#import "IWMessageTypeRegistry.h"
#import "IWPasswordVerifier.h"
#import "TSPArchiveMessages.pb.h"


@implementation IWDocument
{
	IWBundle *_bundle;
	
	NSArray *_componentNames;
	NSDictionary *_documentMessagesByComponentName;
	
	IBOutlet NSWindow *_window;
	IBOutlet NSSplitView *_splitView;
	IBOutlet NSOutlineView *_outlineView;
	IBOutlet NSTextView *_textView;
	
	BOOL _shouldForceWindowKeyAndFront;
	BOOL _documentLoadingWasCancelled;
}

- (id)init
{
	self = [super init];
	if (self == nil) {
		return nil;
	}
	
	
	return self;
}

#pragma mark -

- (NSString *)windowNibName
{
	return @"IWDocument";
}

- (void)makeWindowControllers
{
	if (_documentLoadingWasCancelled) {
		[[NSDocumentController sharedDocumentController] removeDocument:self];
		return;
	}
	
	[super makeWindowControllers];
	
	[_splitView adjustSubviews];
}

- (void)showWindows
{
	[super showWindows];
	
	if (_shouldForceWindowKeyAndFront) {
		[_window makeKeyAndOrderFront:nil];
	}
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError
{
	if (!url.isFileURL) {
		return NO;
	}
	
	// Make sure it's an iWork '13 file. We don't support other iWork formats.
	if (![IWBundle validBundleExistsAtURL:url]) {
		return NO;
	}
	
	// If a password verifier is present, the document is encrypted.
	__block NSData *decryptionKey = nil;
	IWPasswordVerifier *passwordVerifier = [IWBundle passwordVerifierForBundleURL:url passwordHint:NULL];
	if (passwordVerifier != nil) {
		
		// Follow the keychain conventions used by iWork.
		IWBundleProperties *bundleProperties = [IWBundle propertiesForBundleURL:url];
		NSUUID *documentUUID = bundleProperties.documentUUID;
		
		IWKeychainItemDescriptor *keychainItemDescriptor = [[IWKeychainItemDescriptor alloc] init];
		keychainItemDescriptor.label = self.displayName;
		keychainItemDescriptor.itemDescription = @"iWork Document Password";
		keychainItemDescriptor.service = documentUUID.UUIDString;
		keychainItemDescriptor.genericItem = [documentUUID.UUIDString dataUsingEncoding:NSUTF8StringEncoding];
		
		// Try to retrieve the password.
		[IWDocumentPasswordWindowController retrievePasswordForKeychainItemDescriptor:keychainItemDescriptor validator:^BOOL(NSString *password) {
			decryptionKey = [passwordVerifier createKeyWithPassword:password];
			return decryptionKey != nil;
		}];
		
		if (decryptionKey == nil) {
			// The user explicitly cancelled opening the document, but if we return NO here, AppKit will show the standard error UI.
			// Return YES instead and we'll clean up and close the document in -makeWindowControllers
			_documentLoadingWasCancelled = YES;
			return YES;
		}
		
		// The password window steals focus, so we have to force the document window to the front when it opens.
		_shouldForceWindowKeyAndFront = YES;
	}
	
	// Construct the bundle.
	_bundle = [[IWBundle alloc] initWithURL:url decryptionKey:decryptionKey];
	if (_bundle == nil) {
		return NO;
	}
	
	// Grab the list of components.
	_componentNames = _bundle.componentNames;
	NSMutableDictionary *documentMessagesByComponentName = [NSMutableDictionary dictionary];
	IWMessageTypeRegistry *messageTypeRegistry = [IWMessageTypeRegistry registryForUTI:typeName];
	
	// Load the messages from each component.
	for (NSString *componentName in _componentNames) {
		NSArray *documentMessages = [self readDocumentMessagesForComponentName:componentName messageTypeRegistry:messageTypeRegistry];
		if (documentMessages == nil) {
			return NO;
		}
		
		documentMessagesByComponentName[componentName] = documentMessages;
	}
	
	_documentMessagesByComponentName = documentMessagesByComponentName;
	
	[_outlineView reloadData];
	
	return YES;
}

- (NSArray *)readDocumentMessagesForComponentName:(NSString *)name messageTypeRegistry:(IWMessageTypeRegistry *)messageTypeRegistry
{
	NSData *data = [_bundle dataForComponentName:name];
	if (data == nil) {
		NSLog(@"Failed to get component data");
		return nil;
	}
	
	NSMutableArray *messages = [NSMutableArray array];
	
	google::protobuf::io::CodedInputStream stream((const uint8_t *)data.bytes, (int)data.length);
	while (stream.BytesUntilLimit() > 0) {
		uint64 archiveInfoLength = 0;
		
		if (!stream.ReadVarint64(&archiveInfoLength)) {
			NSLog(@"Failed to read archive info length");
			NSLog(@"Data: %@", data);
			return nil;
		}
		
		TSP::ArchiveInfo archiveInfo;
		BOOL didReadArchiveInfo = NO;
		
		google::protobuf::io::CodedInputStream::Limit limit = stream.PushLimit((int)archiveInfoLength);
		{
			didReadArchiveInfo = archiveInfo.ParseFromCodedStream(&stream);
		}
		stream.PopLimit(limit);
		
		if (!didReadArchiveInfo) {
			printf("Failed to read archive info\n");
			return nil;
		}
		
		for (const TSP::MessageInfo &messageInfo : archiveInfo.message_infos()) {
			// Grab a message prototype from the registry.
			const google::protobuf::Message *messagePrototype = [messageTypeRegistry messagePrototypeForMessageType:messageInfo.type()];
			if (messagePrototype == nullptr) {
				printf("Unknown message type: %d\n", messageInfo.type());
				stream.Skip(messageInfo.length());
				continue;
			}
			
			google::protobuf::io::CodedInputStream::Limit limit = stream.PushLimit((int)messageInfo.length());
			{
				google::protobuf::Message *message = messagePrototype->New();
				if (!message->ParseFromCodedStream(&stream)) {
					delete message;
					return nil;
				}
				
				IWDocumentMessage *documentMessage = [[IWDocumentMessage alloc] initWithMessage:message identifier:archiveInfo.identifier()];
				if (documentMessage != nil) {
					[messages addObject:documentMessage];
				}
				
				delete message;
			}
			stream.PopLimit(limit);
		}
	}
	
	return messages;
}

#pragma mark -

- (NSArray *)arrayForChildrenOfOutlineViewItem:(id)item
{
	if (item == nil) {
		return _componentNames;
	}
	
	if ([item isKindOfClass:[NSString class]]) {
		return _documentMessagesByComponentName[item];
	}
	
	return nil;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	return [[self arrayForChildrenOfOutlineViewItem:item] count];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)anIndex ofItem:(id)item
{
	NSArray *children = [self arrayForChildrenOfOutlineViewItem:item];
	if (anIndex >= children.count) {
		return nil;
	}
	
	return children[anIndex];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return [self arrayForChildrenOfOutlineViewItem:item] != nil;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	if ([item isKindOfClass:[IWDocumentMessage class]]) {
		IWDocumentMessage *documentMessage = item;
		return [NSString stringWithFormat:@"%lld %@", documentMessage.identifier, documentMessage.typeName];
	}
	
	return item;
}

- (id)outlineView:(NSOutlineView *)outlineView itemForPersistentObject:(id)object
{
	if ([object isKindOfClass:[NSString class]]) {
		if (![_componentNames containsObject:object]) {
			return nil;
		}
		
		return object;
	}
	
	if ([object isKindOfClass:[NSArray class]] && [object count] == 3) {
		id firstMember = [object objectAtIndex:0];
		id secondMember = [object objectAtIndex:0];
		id thirdMember = [object objectAtIndex:0];
		
		if (![firstMember isKindOfClass:[NSString class]] || ![secondMember isKindOfClass:[NSNumber class]] ||
			![thirdMember isKindOfClass:[NSString class]]) {
			return nil;
		}
		
		NSArray *documentMessages = _documentMessagesByComponentName[firstMember];
		if (documentMessages == nil) {
			return nil;
		}
		
		uint64_t identifier = [secondMember unsignedLongLongValue];
		for (IWDocumentMessage *documentMessage in documentMessages) {
			if (documentMessage.identifier == identifier && [documentMessage.typeName isEqualToString:thirdMember]) {
				return documentMessage;
			}
		}
		
		return nil;
	}
	
	return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView persistentObjectForItem:(id)item
{
	if ([item isKindOfClass:[IWDocumentMessage class]]) {
		NSString *componentName = [outlineView parentForItem:item];
		if (componentName == nil) {
			return nil;
		}
		
		IWDocumentMessage *documentMessage = item;
		return @[ componentName, @(documentMessage.identifier), documentMessage.typeName ];
	}
	
	if ([item isKindOfClass:[NSString class]]) {
		return item;
	}
	
	return nil;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	NSInteger selectedRow = _outlineView.selectedRow;
	if (selectedRow < 0) {
		return;
	}
	
	id item = [_outlineView itemAtRow:selectedRow];
	if (![item isKindOfClass:[IWDocumentMessage class]]) {
		return;
	}
	
	NSFont *font = [NSFont userFixedPitchFontOfSize:13.0];
	NSDictionary *attributes = font == nil ? nil : @{ NSFontAttributeName: font };
	
	IWDocumentMessage *documentMessage = item;
	[_textView.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:documentMessage.contents attributes:attributes]];

	// I don't understand why this is necessary. By default, the text view autoresizes itself to be too wide, causing horizontal scrolling.
	// This happens even for a very small amount of text.
	CGRect frame = _textView.frame;
	frame.size.width = CGRectGetWidth(_textView.enclosingScrollView.contentView.frame);
	_textView.frame = frame;
}

#pragma mark -

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view
{
	// Don't resize the outline view
	return ![_outlineView isDescendantOf:view];
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex
{
	// Don't allow fractional positions, otherwise the subviews will draw on top of the divider, causing it to disappear.
	return floor(proposedPosition);
}

@end
