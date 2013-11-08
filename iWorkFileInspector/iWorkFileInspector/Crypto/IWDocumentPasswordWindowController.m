//
//  IWDocumentPasswordWindowController.m
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import "IWDocumentPasswordWindowController.h"

#import "IWBadgedImageView.h"
#import "IWKeychainUtils.h"
#import "IWWindowShakeAnimation.h"


@implementation IWDocumentPasswordWindowController
{
	IWKeychainItemDescriptor *_keychainItemDescriptor;
	BOOL (^_passwordValidator)(NSString *);
	
	IBOutlet IWBadgedImageView *_appIconView;
	IBOutlet NSTextField *_documentPasswordPromptField;
	IBOutlet NSTextField *_passwordField;
	IBOutlet NSButton *_saveInKeychainButton;
}

+ (BOOL)retrievePasswordForKeychainItemDescriptor:(IWKeychainItemDescriptor *)descriptor validator:(BOOL(^)(NSString *password))validator
{
	// We can't do very much if we don't have a validator.
	if (validator == nil) {
		return NO;
	}
	
	// Check the keychain first.
	NSString *password = [IWKeychainUtils passwordForDescriptor:descriptor error:NULL];
	if (password != nil && validator(password)) {
		return YES;
	}
	
	// Create a window and run it modally.
	IWDocumentPasswordWindowController *passwordWindowController = [[IWDocumentPasswordWindowController alloc] initWithKeychainItemDescriptor:descriptor validator:validator];
	
	return [passwordWindowController runModal];
}

- (id)initWithKeychainItemDescriptor:(IWKeychainItemDescriptor *)descriptor validator:(BOOL(^)(NSString *password))validator
{
	self = [super initWithWindowNibName:@"IWDocumentPasswordWindowController"];
	if (self == nil) {
		return nil;
	}
	
	_keychainItemDescriptor = descriptor;
	_passwordValidator = validator;
	
	return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
	
	_appIconView.image = [NSImage imageNamed:@"IWLockIcon"];
	_appIconView.badgeImage = [NSImage imageNamed:NSImageNameApplicationIcon];
	
	_documentPasswordPromptField.stringValue = [NSString stringWithFormat:@"Enter the password for this document: \u201C%@\u201D", _keychainItemDescriptor.label];
}

#pragma mark - OK + Cancel

- (IBAction)enterPassword:(id)sender
{
	if (!_passwordValidator(_passwordField.stringValue)) {
		IWWindowShakeAnimation *animation = [[IWWindowShakeAnimation alloc] initWithWindow:self.window];
		[animation startAnimation];
		return;
	}
	
	if (_saveInKeychainButton.state == NSOnState) {
		[IWKeychainUtils setPassword:_passwordField.stringValue forDescriptor:_keychainItemDescriptor error:NULL];
	}
	
	[self dismissWindowWithCode:NSModalResponseOK];
}

- (IBAction)cancelPassword:(id)sender
{
	[self dismissWindowWithCode:NSModalResponseCancel];
}

#pragma mark - Modal Window

- (BOOL)runModal
{
	return [NSApp runModalForWindow:self.window] == NSModalResponseOK;
}

- (void)dismissWindowWithCode:(NSInteger)returnCode
{
	[self.window orderOut:nil];
	[NSApp stopModalWithCode:returnCode];
}

@end
