//
//  IWPasswordVerifier.m
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import "IWPasswordVerifier.h"

#import <CommonCrypto/CommonCrypto.h>


typedef struct {
	uint16_t version;
	uint16_t format;
	uint32_t iterations;
	uint8_t salt[16];
	uint8_t iv[16];
	uint8_t data[64];
} __attribute__((packed)) IWPasswordVerifierData;


@implementation IWPasswordVerifier
{
	IWPasswordVerifierData _data;
}

- (id)initWithData:(NSData *)data
{
	self = [super init];
	if (self == nil) {
		return nil;
	}
	
	if (data.length != sizeof(_data)) {
		NSLog(@"%s: unrecognized format", __PRETTY_FUNCTION__);
		return nil;
	}
	
	[data getBytes:&_data];
	if (CFByteOrderGetCurrent() != CFByteOrderLittleEndian) {
		_data.version = NSSwapShort(_data.version);
		_data.format = NSSwapShort(_data.format);
		_data.iterations = NSSwapInt(_data.iterations);
	}
	
	if (_data.version != 2 || _data.format != 1) {
		NSLog(@"%s: Unsupported version or format: %d, %d", __PRETTY_FUNCTION__, _data.version, _data.format);
		return nil;
	}
	
	return self;
}

- (NSData *)_createKeyWithPassword:(NSString *)password
{
	if (password.length == 0) {
		return nil;
	}
	
	// The 16-byte key is created using standard PBKDF2+SHA1.
	uint8_t key[16];
	const char *cString = password.UTF8String;
	if (CCKeyDerivationPBKDF(kCCPBKDF2, cString, strlen(cString), _data.salt, sizeof(_data.salt),
							 kCCPRFHmacAlgSHA1, _data.iterations, key, sizeof(key)) != kCCSuccess) {
		return nil;
	}
	
	return [NSData dataWithBytes:key length:sizeof(key)];
}

- (BOOL)_verifyKeyData:(NSData *)data
{
	if (CC_SHA256_DIGEST_LENGTH != 32) {
		// Sanity check.
		return NO;
	}
	
	if (data.length != 16) {
		return NO;
	}
	
	// Use the key to decrypt the 64-byte block.
	uint8_t decrypted[64];
	size_t bytesDecrypted = 0;
	if (CCCrypt(kCCDecrypt, kCCAlgorithmAES128, 0, data.bytes, data.length,
			_data.iv, _data.data, sizeof(_data.data),
			decrypted, sizeof(decrypted), &bytesDecrypted) != kCCSuccess) {
		NSLog(@"%s: CCCrypt failed", __PRETTY_FUNCTION__);
		return NO;
	}
	
	if (bytesDecrypted != sizeof(decrypted)) {
		NSLog(@"%s: CCCrypt didn't produce enough data", __PRETTY_FUNCTION__);
		return NO;
	}
	
	// The last 32 bytes of the block should be equal to the SHA256 of the first 32 bytes.
	uint8_t hash[32];
	CC_SHA256_CTX ctx;
	CC_SHA256_Init(&ctx);
	CC_SHA256_Update(&ctx, decrypted, 32);
	CC_SHA256_Final(hash, &ctx);
	
	return memcmp(hash, &decrypted[32], 32) == 0;
}

- (NSData *)createKeyWithPassword:(NSString *)password
{
	NSData *keyData = [self _createKeyWithPassword:password];
	if (![self _verifyKeyData:keyData]) {
		return nil;
	}
	
	return keyData;
}

@end
