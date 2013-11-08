#iWork '13 File Format

## <a name="overview"/>Overview
The iWork '13 format is a [bundle](https://developer.apple.com/library/mac/documentation/corefoundation/conceptual/cfbundles/DocumentPackages/DocumentPackages.html)-based format built on top of several open source projects. This document describes the physical layout of files contained in these bundles and the algorithms involved, but does not attempt to describe the nature of the represented object graph.

## <a name="bundle"/>Bundle

The organization of an iWork document bundle is fairly straightforward. Media such as images and videos are stored in the `Data` subdirectory, serialized objects are stored in [Index.zip](#index-zip), some light metadata is stored in the `Metadata` subdirectory, and a few preview images are stored in the top level of the bundle.

	Photo Essay.key/
		Data/
			143917994_2881x1992-small.jpg
			143918632_1620x1622-small.jpg
			154121867_2447x1632-small.jpg
			154146989_2880x1920-small.jpg
			...
		Index.zip
		Metadata/
			BuildVersionHistory.plist
			DocumentIdentifier
			Properties.plist
		preview-micro.jpg
		preview-web.jpg
		preview.jpg

## <a name="index-zip" />Index.zip
A document's objects are organized into groups called Components. Each Component is serialized into the [IWA](#iwa) format and stored in Index.zip.

	Index/
		AnnotationAuthorStorage.iwa
		CalculationEngine.iwa
		Document.iwa
		DocumentStylesheet.iwa
		MasterSlide-1.iwa
		MasterSlide-10.iwa
		MasterSlide-11.iwa
		...

Curiously, the zip implementation iWork uses for this file is extremely limited. It does not support any form of compression or extensions like Zip64. Simply expanding Index.zip and then recreating it with a standard zip utility will result in a document that iWork refuses to open.

The iWork '13 applications contain a separate, more complete zip implementation used for reading and writing iWork '09 documents (which are bundles that have been zipped in their entirety), so I believe the choice to forgo compression for Index.zip is intentional.

One possibility is that Index.zip is used to prevent the syncronization issues that would occur if reading and writing a document involved accessing many small files. Saving a document might involve writing out several Components, so instead of coordinating writes to the various individual .iwa files, only the Index.zip must be locked. Since the .iwa files are inherently compressed (see [Snappy Compression](#snappy-compression)), the zip implementation used for Index.zip could be designed to be minimial and efficient.

## <a name="iwa"/>IWA

Components are serialized into .iwa (iWork Archive) files, a custom format consisting of a [Protobuf](#protobuf) stream wrapped in a [Snappy](#snappy-compression) stream.

### <a name="snappy-compression"/>Snappy Compression
[Snappy](https://code.google.com/p/snappy/) is a compression format created by Google aimed at providing decent compression ratios at high speeds. IWA files are stored in Snappy's [framing format](https://code.google.com/p/snappy/source/browse/trunk/framing_format.txt), though they do not adhere rigorously to the spec. In particular, they do not include the required Stream Identifier chunk, and compressed chunks do not include a CRC-32C checksum.

The stream is composed of contiguous chunks prefixed by a 4 byte header. The first byte indicates the chunk type, which in practice is always 0 for iWork, indicating a Snappy compressed chunk. The next three bytes are interpreted as a 24-bit little-endian integer indicating the length of the chunk. The 4 byte header is not included in the chunk length.

### <a name="protobuf"/>Protobuf
The uncompresed IWA contains the Component's objects, serialized consecutively in a [Protobuf](https://code.google.com/p/protobuf/) stream. Each object begins with a [varint](https://developers.google.com/protocol-buffers/docs/encoding#varints) representing the length of the [ArchiveInfo](#archiveinfo) message, followed by the `ArchiveInfo` message itself. The `ArchiveInfo` includes a variable number of [MessageInfo](#messageinfo) messages describing the encoded [Payloads](#payload) that follow, though in practice iWork files seem to only have one payload message per `ArchiveInfo`.

	Object 0	varint archiveInfoLength
				ArchiveInfo archiveInfo
				(payload)
				
	Object 1	varint archiveInfoLength
				ArchiveInfo archiveInfo
				(payload)
				
				...
					
	Object n	varint archiveInfoLength
				ArchiveInfo archiveInfo
				(payload)

### <a name="archiveinfo" />ArchiveInfo

The `ArchiveInfo` message contains the object's `identifier` (unique across the document), as well as information about the encoded messages (see [MessageInfo](#messageinfo)).

	message ArchiveInfo {
	  optional uint64 identifier = 1;
	  repeated MessageInfo message_infos = 2;
	}

### <a name="messageinfo" />MessageInfo

The `MessageInfo` message describes the encoded payload that follows the `ArchiveInfo`. The `type` field indicates how the payload should be decoded (see [TSPRegistry](#tspregistry)), the `version` field indicates what format version was used to encode (currently 1.0.5), and the `length` field specifies how much data follows. The `field_infos` field would allow for deep introspection into the format of the payload, but it is absent from all archives I have inspected. It's possible that it is meant for backwards compatibility when new fields are introduced. The `object_references` and `data_references` fields are for bookkeeping/cross-referencing.

	message MessageInfo {
	  required uint32 type = 1;
	  repeated uint32 version = 2 [packed = true];
	  required uint32 length = 3;
	  repeated FieldInfo field_infos = 4;
	  repeated uint64 object_references = 5 [packed = true];
	  repeated uint64 data_references = 6 [packed = true];
	}

### <a name="payload"/>Payload
The format of the payload is determined by the `type` field of the associated `MessageInfo` message. The iWork applications manually map these integer values to their respective Protobuf message types, and the mappings vary slightly between Keynote, Pages and Numbers. This information can be recovered by inspecting the [TSPRegistry](#tspregistry) class at runtime.

Because Protobuf is not a self-describing format, applications attempting to understand the payloads must know a great deal about the data types and hierarchy of the objects serialized by iWork. Fortunately, all of this information can be recovered from the iWork binaries using [proto-dump](https://github.com/obriensp/proto-dump).

A full dump of the Protobuf messages can be found [here](../iWorkFileInspector/iWorkFileInspector/Messages/Proto/).

### <a name="tspregistry" />TSPRegistry
The mapping between an object's `MessageInfo.type` and its respective Protobuf message type must by extracted from the iWork applications at runtime. Attaching to Keynote via a debugger and inspecting `[TSPRegistry sharedRegistry]` shows:

	<TSPRegistry 0x102daf560 
	 _messageTypeToPrototypeMap = {
		148 -> 0x102f24680 KN.ChartInfoGeometryCommandArchive
		147 -> 0x102f24650 KN.SlideCollectionCommandSelectionBehaviorArchive
		146 -> 0x102f24560 KN.CommandSlideReapplyMasterArchive
		145 -> 0x102f24420 KN.CommandMasterSetBodyStylesArchive
		...

A full list of the type mappings can be found [here](../iWorkFileInspector/iWorkFileInspector/Persistence/MessageTypes/).

## <a name="encryption"/>Encryption
If the document is locked with a password, nearly all files in the bundle are encrypted using [AES128](http://en.wikipedia.org/wiki/Advanced_Encryption_Standard) encryption with [PKCS7](http://en.wikipedia.org/wiki/Padding_\(cryptography\)#PKCS7) padding. For a full description of the encryption format, see [iWork Encrypted Stream](iWork Encrypted Stream.md).