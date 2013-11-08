//
//  NSData+IWCrypto.m
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import "NSData+IWCrypto.h"

#import <CommonCrypto/CommonCrypto.h>


@implementation NSData (IWCrypto)

- (NSData *)decryptUsingIWAKey:(NSData *)key
{
	// Data is encrypted as AES128 with PKCS7 padding.
	// The first 16 bytes are the IV and the last 20 bytes are garbage.
	// The first 16 byte of the *decrypted* data are discarded.
	if (self.length < 36) {
		return nil;
	}
	
	const uint8_t *bytes = self.bytes;
	NSUInteger length = self.length;
	
	const uint8_t *iv = bytes;
	const uint8_t *encryptedBytes = bytes + 16;
	size_t encryptedLength = length - 36;
	
	CCCryptorRef cryptor = NULL;
	OSStatus status = CCCryptorCreate(kCCDecrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
									  key.bytes, key.length, iv, &cryptor);
	if (status != errSecSuccess) {
		printf("%s: Failed to create cryptor: %d\n", __PRETTY_FUNCTION__, status);
		return nil;
	}
	
	// Get an estimate of the decrypted length.
	size_t decryptedLength = CCCryptorGetOutputLength(cryptor, encryptedLength, true);
	NSMutableData *decryptedData = [NSMutableData dataWithLength:decryptedLength];
	uint8_t *decryptedBytes = (uint8_t *)decryptedData.mutableBytes;
	
	// Start the decryption.
	size_t bytesWritten = 0;
	status = CCCryptorUpdate(cryptor, encryptedBytes, encryptedLength, decryptedBytes, decryptedLength, &bytesWritten);
	if (status != errSecSuccess) {
		printf("%s: Failed to update cryptor: %d\n", __PRETTY_FUNCTION__, status);
		CCCryptorRelease(cryptor);
		return nil;
	}
	
	// Find out how much space we need to finalize the decryption and expand the output buffer if necessary.
	size_t extraLength = CCCryptorGetOutputLength(cryptor, 0, true);
	if (bytesWritten + extraLength > decryptedLength) {
		[decryptedData setLength:bytesWritten + extraLength];
		decryptedBytes = (uint8_t *)decryptedData.mutableBytes;
	}
	
	// Finalize decryption.
	size_t extraBytesWritten = 0;
	status = CCCryptorFinal(cryptor, decryptedBytes + bytesWritten, extraLength, &extraBytesWritten);
	if (status != errSecSuccess) {
		printf("%s: Failed to update cryptor: %d\n", __PRETTY_FUNCTION__, status);
		CCCryptorRelease(cryptor);
		return nil;
	}
	
	// Discard the first 16 bytes of the decrypted data.
	if (bytesWritten + extraBytesWritten < 16) {
		return nil;
	}
	
	return [decryptedData subdataWithRange:NSMakeRange(16, bytesWritten + extraBytesWritten - 16)];
}

@end
