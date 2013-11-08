//
//  IWZipArchive.m
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import "IWZipArchive.h"


extern uint32_t crc32(uint32_t crc, const void *buf, size_t size);


#pragma mark Central Directory File Header

typedef struct {
	uint32_t signature;
	uint16_t creatorVersion;
	uint16_t extractorVersion;
	uint16_t bitfield;
	uint16_t compressionMethod;
	uint16_t modificationTime;
	uint16_t modificationDate;
	uint32_t crc;
	
	uint32_t compressedSize;
	uint32_t uncompressedSize;
	uint16_t nameLength;
	uint16_t extraFieldLength;
	uint16_t commentLength;
	
	uint16_t diskNumber;
	uint16_t internalFileAttributes;
	uint32_t externalFileAttributes;
	
	uint32_t localFileHeaderOffset;
} __attribute__((packed)) ZipCentralDirectoryFileHeader;


const uint32_t ZipCentralDirectoryFileHeaderSignature = 0x02014b50;

static void SwapZipCentralDirectoryFileHeader(ZipCentralDirectoryFileHeader *header)
{
	header->signature = NSSwapInt(header->signature);
	header->creatorVersion = NSSwapShort(header->creatorVersion);
	header->extractorVersion = NSSwapShort(header->extractorVersion);
	header->bitfield = NSSwapShort(header->bitfield);
	header->compressionMethod = NSSwapShort(header->compressionMethod);
	header->modificationTime = NSSwapShort(header->modificationTime);
	header->modificationDate = NSSwapShort(header->modificationDate);
	header->crc = NSSwapInt(header->crc);
	header->compressedSize = NSSwapInt(header->compressedSize);
	header->uncompressedSize = NSSwapInt(header->uncompressedSize);
	header->nameLength = NSSwapShort(header->nameLength);
	header->extraFieldLength = NSSwapShort(header->extraFieldLength);
	header->commentLength = NSSwapShort(header->commentLength);
	header->diskNumber = NSSwapShort(header->diskNumber);
	header->internalFileAttributes = NSSwapShort(header->internalFileAttributes);
	header->externalFileAttributes = NSSwapInt(header->externalFileAttributes);
	header->localFileHeaderOffset = NSSwapInt(header->localFileHeaderOffset);
}

#pragma mark - Local File Header

typedef struct {
	uint32_t signature;
	uint16_t extractorVersion;
	uint16_t bitfield;
	uint16_t compressionMethod;
	uint16_t modificationTime;
	uint16_t modificationDate;
	uint32_t crc;
	uint32_t compressedSize;
	uint32_t uncompressedSize;
	uint16_t nameLength;
	uint16_t extraFieldLength;
} __attribute__((packed)) ZipLocalFileHeader;

const uint32_t ZipLocalFileHeaderSignature = 0x04034b50;

static void SwapZipLocalFileHeader(ZipLocalFileHeader *header)
{
	header->signature = NSSwapInt(header->signature);
	header->extractorVersion = NSSwapShort(header->extractorVersion);
	header->bitfield = NSSwapShort(header->bitfield);
	header->compressionMethod = NSSwapShort(header->compressionMethod);
	header->modificationTime = NSSwapShort(header->modificationTime);
	header->modificationDate = NSSwapShort(header->modificationDate);
	header->crc = NSSwapInt(header->crc);
	header->compressedSize = NSSwapInt(header->compressedSize);
	header->uncompressedSize = NSSwapInt(header->uncompressedSize);
	header->nameLength = NSSwapShort(header->nameLength);
	header->extraFieldLength = NSSwapShort(header->extraFieldLength);
}

#pragma mark - End of Central Directory Record

typedef struct {
	uint32_t signature;
	uint16_t currentDiskNumber;
	uint16_t centralDirectoryDiskNumber;
	uint16_t onDiskCentralDirectoryRecordCount;
	uint16_t centralDirectoryRecordCount;
	uint32_t sizeOfCentralDirectory;
	uint32_t offsetOfcentralDirectory;
	uint16_t commentLength;
} __attribute__((packed)) ZipEndOfCentralDirectoryRecord;

const uint32_t ZipEndOfCentralDirectoryRecordSignature = 0x06054b50;

static inline void SwapZipEndOfCentralDirectoryRecord(ZipEndOfCentralDirectoryRecord *record)
{
	record->signature = NSSwapInt(record->signature);
	record->currentDiskNumber = NSSwapShort(record->currentDiskNumber);
	record->centralDirectoryDiskNumber = NSSwapShort(record->centralDirectoryDiskNumber);
	record->onDiskCentralDirectoryRecordCount = NSSwapShort(record->onDiskCentralDirectoryRecordCount);
	record->centralDirectoryRecordCount = NSSwapShort(record->centralDirectoryRecordCount);
	record->sizeOfCentralDirectory = NSSwapInt(record->sizeOfCentralDirectory);
	record->offsetOfcentralDirectory = NSSwapInt(record->offsetOfcentralDirectory);
	record->commentLength = NSSwapShort(record->commentLength);
}


#pragma mark - IWZipArchive


@implementation IWZipArchive
{
	NSData *_archiveData;
	NSUInteger _archiveLength;
	NSMutableDictionary *_entries;
}

- (id)initWithURL:(NSURL *)fileURL
{
	self = [super init];
	if (self == nil) {
		return nil;
	}
	
	_archiveData = [[NSData alloc] initWithContentsOfURL:fileURL];
	if (_archiveData == nil) {
		return nil;
	}
	
	_archiveLength = _archiveData.length;
	if (_archiveLength < sizeof(ZipEndOfCentralDirectoryRecord)) {
		return nil;
	}
	
	if (![self readEntries]) {
		return nil;
	}
	
	return self;
}

- (BOOL)readEntries
{
	_entries = [[NSMutableDictionary alloc] init];
	
	ZipEndOfCentralDirectoryRecord endOfCentralDirectoryRecord;
	[_archiveData getBytes:&endOfCentralDirectoryRecord range:NSMakeRange(_archiveLength - sizeof(endOfCentralDirectoryRecord), sizeof(endOfCentralDirectoryRecord))];
	
	if (CFByteOrderGetCurrent() != CFByteOrderLittleEndian) {
		SwapZipEndOfCentralDirectoryRecord(&endOfCentralDirectoryRecord);
	}
	
	if (endOfCentralDirectoryRecord.signature != ZipEndOfCentralDirectoryRecordSignature) {
		return NO;
	}
	
	if (endOfCentralDirectoryRecord.currentDiskNumber != 0 || endOfCentralDirectoryRecord.centralDirectoryDiskNumber != 0) {
		return NO;
	}
	
	NSRange centralDirectoryRange = NSMakeRange(endOfCentralDirectoryRecord.offsetOfcentralDirectory, endOfCentralDirectoryRecord.sizeOfCentralDirectory);
	if (NSMaxRange(centralDirectoryRange) > _archiveLength) {
		return NO;
	}

	return [self readEntriesFromData:[_archiveData subdataWithRange:centralDirectoryRange] count:endOfCentralDirectoryRecord.centralDirectoryRecordCount];
}

- (BOOL)readEntriesFromData:(NSData *)data count:(NSUInteger)count
{
	NSUInteger offset = 0;
	NSUInteger length = data.length;
	
	for (NSUInteger i = 0; i < count; i++) {
		ZipCentralDirectoryFileHeader header;
		if (offset + sizeof(header) > length) {
			NSLog(@"Not enough room for the header");
			return NO;
		}
		
		[data getBytes:&header range:NSMakeRange(offset, sizeof(header))];
		offset += sizeof(header);
		if (CFByteOrderGetCurrent() != CFByteOrderLittleEndian) {
			SwapZipCentralDirectoryFileHeader(&header);
		}
		
		if (header.signature != ZipCentralDirectoryFileHeaderSignature) {
			NSLog(@"Invalid signature[%ld]: 0x%x", i, header.signature);
			return NO;
		}
		
		NSUInteger combinedTrailerLength = (NSUInteger)header.nameLength + header.extraFieldLength + header.commentLength;
		if (offset + combinedTrailerLength > length) {
			NSLog(@"Not enough room: %ld", combinedTrailerLength);
			return NO;
		}
		
		NSData *nameData = [data subdataWithRange:NSMakeRange(offset, header.nameLength)];
		NSString *name = [[NSString alloc] initWithData:nameData encoding:NSASCIIStringEncoding];
		if (![self readEntryAtOffset:header.localFileHeaderOffset name:name]) {
			return NO;
		}
		
		offset += combinedTrailerLength;
	}
	
	return YES;
}

- (BOOL)readEntryAtOffset:(NSUInteger)offset name:(NSString *)name
{
	ZipLocalFileHeader header;
	if (offset + sizeof(header) > _archiveLength) {
		return NO;
	}
	
	[_archiveData getBytes:&header range:NSMakeRange(offset, sizeof(header))];
	if (CFByteOrderGetCurrent() != CFByteOrderLittleEndian) {
		SwapZipLocalFileHeader(&header);
	}
	
	if (header.signature != ZipLocalFileHeaderSignature) {
		return NO;
	}
	
	if (header.compressionMethod != 0) {
		return NO;
	}
	
	NSRange dataRange = NSMakeRange(offset + sizeof(header) + header.nameLength + header.extraFieldLength, header.uncompressedSize);
	if (NSMaxRange(dataRange) > _archiveLength) {
		return NO;
	}
	
	NSData *data = [_archiveData subdataWithRange:dataRange];
	uint32_t crc = crc32(0, data.bytes, data.length);
	if (crc != header.crc) {
		printf("%s: CRC32 Mismatch! 0x%08x vs 0x%08x", __PRETTY_FUNCTION__, crc, header.crc);
		return NO;
	}
	
	_entries[name] = data;
	
	return YES;
}

#pragma mark -

- (NSArray *)entryNames
{
	return _entries.allKeys;
}

- (NSData *)dataForEntryName:(NSString *)name
{
	return _entries[name];
}

@end
