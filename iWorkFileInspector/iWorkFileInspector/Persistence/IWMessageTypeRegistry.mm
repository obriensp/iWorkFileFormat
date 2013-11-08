//
//  IWMessageTypeRegistry.mm
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import "IWMessageTypeRegistry.h"

#import "KNArchives.pb.h"
#import "KNCommandArchives.pb.h"
#import "TNArchives.pb.h"
#import "TNCommandArchives.pb.h"
#import "TPArchives.pb.h"
#import "TPCommandArchives.pb.h"
#import "TSAArchives.pb.h"
#import "TSCEArchives.pb.h"
#import "TSCH3DArchives.pb.h"
#import "TSCHArchives.Common.pb.h"
#import "TSCHArchives.GEN.pb.h"
#import "TSCHArchives.pb.h"
#import "TSCHCommandArchives.pb.h"
#import "TSCHPreUFFArchives.pb.h"
#import "TSDArchives.pb.h"
#import "TSDCommandArchives.pb.h"
#import "TSKArchives.pb.h"
#import "TSPArchiveMessages.pb.h"
#import "TSPDatabaseMessages.pb.h"
#import "TSPMessages.pb.h"
#import "TSSArchives.pb.h"
#import "TSTArchives.pb.h"
#import "TSTCommandArchives.pb.h"
#import "TSTStylePropertyArchiving.pb.h"
#import "TSWPArchives.pb.h"
#import "TSWPCommandArchives.pb.h"

#import <map>


@implementation IWMessageTypeRegistry
{
	std::map<uint32, const google::protobuf::Message *> _messageTypeToPrototypeMap;
}

+ (IWMessageTypeRegistry *)registryForUTI:(NSString *)UTI
{
	static NSCache *cache = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cache = [[NSCache alloc] init];
	});
	
	IWMessageTypeRegistry *registry = [cache objectForKey:UTI];
	if (registry == nil) {
		registry = [[IWMessageTypeRegistry alloc] initWithUTI:UTI];
		[cache setObject:registry forKey:UTI];
	}
	
	return registry;
}

- (id)init
{
	self = [super init];
	if (self == nil) {
		return nil;
	}
	
	[self registerCommonPersistenceMessages];
	
	return self;
}

- (id)initWithUTI:(NSString *)UTI
{
	self = [self init];
	if (self == nil) {
		return nil;
	}
	
	if ([UTI isEqualToString:@"com.apple.iwork.keynote.key"]) {
		[self registerKeynotePersistenceMessages];
	} else if ([UTI isEqualToString:@"com.apple.iwork.pages.pages"]) {
		[self registerPagesPersistenceMessages];
	} else if ([UTI isEqualToString:@"com.apple.iwork.numbers.numbers"]) {
		[self registerNumbersPersistenceMessages];
	}
	
	return self;
}

- (const google::protobuf::Message *)messagePrototypeForMessageType:(uint32)messageType
{
	return _messageTypeToPrototypeMap[messageType];
}

#pragma mark -

- (void)registerCommonPersistenceMessages
{
	_messageTypeToPrototypeMap[200] = new TSK::DocumentArchive();
	_messageTypeToPrototypeMap[201] = new TSK::CommandHistory();
	_messageTypeToPrototypeMap[202] = new TSK::CommandGroupArchive();
	_messageTypeToPrototypeMap[203] = new TSK::CommandContainerArchive();
	_messageTypeToPrototypeMap[204] = new TSK::ReplaceAllCommandArchive();
	_messageTypeToPrototypeMap[205] = new TSK::TreeNode();
	_messageTypeToPrototypeMap[206] = new TSK::ProgressiveCommandGroupArchive();
	_messageTypeToPrototypeMap[208] = new TSK::CommandSelectionBehaviorHistoryArchive();
	_messageTypeToPrototypeMap[209] = new TSK::UndoRedoStateCommandSelectionBehaviorArchive();
	_messageTypeToPrototypeMap[210] = new TSK::ViewStateArchive();
	_messageTypeToPrototypeMap[211] = new TSK::DocumentSupportArchive();
	_messageTypeToPrototypeMap[212] = new TSK::AnnotationAuthorArchive();
	_messageTypeToPrototypeMap[213] = new TSK::AnnotationAuthorStorageArchive();
	_messageTypeToPrototypeMap[214] = new TSK::AddAnnotationAuthorCommandArchive();
	_messageTypeToPrototypeMap[215] = new TSK::SetAnnotationAuthorColorCommandArchive();
	_messageTypeToPrototypeMap[400] = new TSS::StyleArchive();
	_messageTypeToPrototypeMap[401] = new TSS::StylesheetArchive();
	_messageTypeToPrototypeMap[402] = new TSS::ThemeArchive();
	_messageTypeToPrototypeMap[410] = new TSS::ApplyThemeCommandArchive();
	_messageTypeToPrototypeMap[411] = new TSS::ApplyThemeChildCommandArchive();
	_messageTypeToPrototypeMap[412] = new TSS::StyleUpdatePropertyMapCommandArchive();
	_messageTypeToPrototypeMap[413] = new TSS::ThemeReplacePresetCommandArchive();
	_messageTypeToPrototypeMap[414] = new TSS::ThemeAddStylePresetCommandArchive();
	_messageTypeToPrototypeMap[415] = new TSS::ThemeRemoveStylePresetCommandArchive();
	_messageTypeToPrototypeMap[416] = new TSS::ThemeReplaceColorPresetCommandArchive();
	_messageTypeToPrototypeMap[417] = new TSS::ThemeMovePresetCommandArchive();
	_messageTypeToPrototypeMap[418] = new TSS::ThemeReplaceStylePresetCommandArchive();
	_messageTypeToPrototypeMap[600] = new TSA::DocumentArchive();
	_messageTypeToPrototypeMap[601] = new TSA::FunctionBrowserStateArchive();
	_messageTypeToPrototypeMap[602] = new TSA::PropagatePresetCommandArchive();
	_messageTypeToPrototypeMap[2001] = new TSWP::StorageArchive();
	_messageTypeToPrototypeMap[2002] = new TSWP::SelectionArchive();
	_messageTypeToPrototypeMap[2003] = new TSWP::DrawableAttachmentArchive();
	_messageTypeToPrototypeMap[2004] = new TSWP::TextualAttachmentArchive();
	_messageTypeToPrototypeMap[2005] = new TSWP::StorageArchive();
	_messageTypeToPrototypeMap[2006] = new TSWP::UIGraphicalAttachment();
	_messageTypeToPrototypeMap[2007] = new TSWP::TextualAttachmentArchive();
	_messageTypeToPrototypeMap[2008] = new TSWP::FootnoteReferenceAttachmentArchive();
	_messageTypeToPrototypeMap[2009] = new TSWP::TextualAttachmentArchive();
	_messageTypeToPrototypeMap[2010] = new TSWP::TSWPTOCPageNumberAttachmentArchive();
	_messageTypeToPrototypeMap[2011] = new TSWP::ShapeInfoArchive();
	_messageTypeToPrototypeMap[2013] = new TSWP::HighlightArchive();
	_messageTypeToPrototypeMap[2014] = new TSWP::CommentInfoArchive();
	_messageTypeToPrototypeMap[2021] = new TSWP::CharacterStyleArchive();
	_messageTypeToPrototypeMap[2022] = new TSWP::ParagraphStyleArchive();
	_messageTypeToPrototypeMap[2023] = new TSWP::ListStyleArchive();
	_messageTypeToPrototypeMap[2024] = new TSWP::ColumnStyleArchive();
	_messageTypeToPrototypeMap[2025] = new TSWP::ShapeStyleArchive();
	_messageTypeToPrototypeMap[2026] = new TSWP::TOCEntryStyleArchive();
	_messageTypeToPrototypeMap[2031] = new TSWP::PlaceholderSmartFieldArchive();
	_messageTypeToPrototypeMap[2032] = new TSWP::HyperlinkFieldArchive();
	_messageTypeToPrototypeMap[2033] = new TSWP::FilenameSmartFieldArchive();
	_messageTypeToPrototypeMap[2034] = new TSWP::DateTimeSmartFieldArchive();
	_messageTypeToPrototypeMap[2035] = new TSWP::BookmarkFieldArchive();
	_messageTypeToPrototypeMap[2036] = new TSWP::MergeSmartFieldArchive();
	_messageTypeToPrototypeMap[2037] = new TSWP::CitationRecordArchive();
	_messageTypeToPrototypeMap[2038] = new TSWP::CitationSmartFieldArchive();
	_messageTypeToPrototypeMap[2039] = new TSWP::UnsupportedHyperlinkFieldArchive();
	_messageTypeToPrototypeMap[2040] = new TSWP::BibliographySmartFieldArchive();
	_messageTypeToPrototypeMap[2041] = new TSWP::TOCSmartFieldArchive();
	_messageTypeToPrototypeMap[2042] = new TSWP::RubyFieldArchive();
	_messageTypeToPrototypeMap[2043] = new TSWP::NumberAttachmentArchive();
	_messageTypeToPrototypeMap[2050] = new TSWP::TextStylePresetArchive();
	_messageTypeToPrototypeMap[2051] = new TSWP::TOCSettingsArchive();
	_messageTypeToPrototypeMap[2052] = new TSWP::TOCEntryInstanceArchive();
	_messageTypeToPrototypeMap[2060] = new TSWP::ChangeArchive();
	_messageTypeToPrototypeMap[2061] = new TSK::DeprecatedChangeAuthorArchive();
	_messageTypeToPrototypeMap[2062] = new TSWP::ChangeSessionArchive();
	_messageTypeToPrototypeMap[2101] = new TSWP::TextCommandArchive();
	_messageTypeToPrototypeMap[2102] = new TSWP::InsertAttachmentCommandArchive();
	_messageTypeToPrototypeMap[2104] = new TSWP::ReplaceAllTextCommandArchive();
	_messageTypeToPrototypeMap[2105] = new TSWP::FormatTextCommandArchive();
	_messageTypeToPrototypeMap[2107] = new TSWP::ApplyPlaceholderTextCommandArchive();
	_messageTypeToPrototypeMap[2108] = new TSWP::ApplyHighlightTextCommandArchive();
	_messageTypeToPrototypeMap[2113] = new TSWP::CreateHyperlinkCommandArchive();
	_messageTypeToPrototypeMap[2114] = new TSWP::RemoveHyperlinkCommandArchive();
	_messageTypeToPrototypeMap[2115] = new TSWP::ModifyHyperlinkCommandArchive();
	_messageTypeToPrototypeMap[2116] = new TSWP::ApplyRubyTextCommandArchive();
	_messageTypeToPrototypeMap[2117] = new TSWP::RemoveRubyTextCommandArchive();
	_messageTypeToPrototypeMap[2118] = new TSWP::ModifyRubyTextCommandArchive();
	_messageTypeToPrototypeMap[2119] = new TSWP::UpdateDateTimeFieldCommandArchive();
	_messageTypeToPrototypeMap[2120] = new TSWP::ModifyTOCSettingsBaseCommandArchive();
	_messageTypeToPrototypeMap[2121] = new TSWP::ModifyTOCSettingsForTOCInfoCommandArchive();
	_messageTypeToPrototypeMap[2122] = new TSWP::ModifyTOCSettingsPresetForThemeCommandArchive();
	_messageTypeToPrototypeMap[2206] = new TSWP::AnchorAttachmentCommandArchive();
	_messageTypeToPrototypeMap[2207] = new TSWP::TextApplyThemeCommandArchive();
	_messageTypeToPrototypeMap[2231] = new TSWP::ShapeApplyPresetCommandArchive();
	_messageTypeToPrototypeMap[2232] = new TSWP::ShapePasteStyleCommandArchive();
	_messageTypeToPrototypeMap[2240] = new TSWP::TOCInfoArchive();
	_messageTypeToPrototypeMap[2241] = new TSWP::TOCAttachmentArchive();
	_messageTypeToPrototypeMap[2242] = new TSWP::TOCLayoutHintArchive();
	_messageTypeToPrototypeMap[2400] = new TSWP::StyleBaseCommandArchive();
	_messageTypeToPrototypeMap[2401] = new TSWP::StyleCreateCommandArchive();
	_messageTypeToPrototypeMap[2402] = new TSWP::StyleRenameCommandArchive();
	_messageTypeToPrototypeMap[2403] = new TSWP::StyleUpdateCommandArchive();
	_messageTypeToPrototypeMap[2404] = new TSWP::StyleDeleteCommandArchive();
	_messageTypeToPrototypeMap[2405] = new TSWP::StyleReorderCommandArchive();
	_messageTypeToPrototypeMap[2406] = new TSWP::StyleUpdatePropertyMapCommandArchive();
	_messageTypeToPrototypeMap[3002] = new TSD::DrawableArchive();
	_messageTypeToPrototypeMap[3003] = new TSD::ContainerArchive();
	_messageTypeToPrototypeMap[3004] = new TSD::ShapeArchive();
	_messageTypeToPrototypeMap[3005] = new TSD::ImageArchive();
	_messageTypeToPrototypeMap[3006] = new TSD::MaskArchive();
	_messageTypeToPrototypeMap[3007] = new TSD::MovieArchive();
	_messageTypeToPrototypeMap[3008] = new TSD::GroupArchive();
	_messageTypeToPrototypeMap[3009] = new TSD::ConnectionLineArchive();
	_messageTypeToPrototypeMap[3015] = new TSD::ShapeStyleArchive();
	_messageTypeToPrototypeMap[3016] = new TSD::MediaStyleArchive();
	_messageTypeToPrototypeMap[3020] = new TSD::DrawablesCommandGroupArchive();
	_messageTypeToPrototypeMap[3021] = new TSD::InfoGeometryCommandArchive();
	_messageTypeToPrototypeMap[3022] = new TSD::DrawablePathSourceCommandArchive();
	_messageTypeToPrototypeMap[3023] = new TSD::ShapePathSourceFlipCommandArchive();
	_messageTypeToPrototypeMap[3024] = new TSD::ImageMaskCommandArchive();
	_messageTypeToPrototypeMap[3025] = new TSD::ImageMediaCommandArchive();
	_messageTypeToPrototypeMap[3026] = new TSD::ImageReplaceCommandArchive();
	_messageTypeToPrototypeMap[3027] = new TSD::MediaOriginalSizeCommandArchive();
	_messageTypeToPrototypeMap[3028] = new TSD::ShapeStyleSetValueCommandArchive();
	_messageTypeToPrototypeMap[3030] = new TSD::MediaStyleSetValueCommandArchive();
	_messageTypeToPrototypeMap[3031] = new TSD::ShapeApplyPresetCommandArchive();
	_messageTypeToPrototypeMap[3032] = new TSD::MediaApplyPresetCommandArchive();
	_messageTypeToPrototypeMap[3033] = new TSD::DrawableApplyThemeCommandArchive();
	_messageTypeToPrototypeMap[3034] = new TSD::MovieSetValueCommandArchive();
	_messageTypeToPrototypeMap[3035] = new TSD::ShapeSetLineEndCommandArchive();
	_messageTypeToPrototypeMap[3036] = new TSD::ExteriorTextWrapCommandArchive();
	_messageTypeToPrototypeMap[3037] = new TSD::MediaFlagsCommandArchive();
	_messageTypeToPrototypeMap[3038] = new TSD::GroupDrawablesCommandArchive();
	_messageTypeToPrototypeMap[3039] = new TSD::UngroupGroupCommandArchive();
	_messageTypeToPrototypeMap[3040] = new TSD::DrawableHyperlinkCommandArchive();
	_messageTypeToPrototypeMap[3041] = new TSD::ConnectionLineConnectCommandArchive();
	_messageTypeToPrototypeMap[3042] = new TSD::InstantAlphaCommandArchive();
	_messageTypeToPrototypeMap[3043] = new TSD::DrawableLockCommandArchive();
	_messageTypeToPrototypeMap[3045] = new TSD::CanvasSelectionArchive();
	_messageTypeToPrototypeMap[3046] = new TSD::CommandSelectionBehaviorArchive();
	_messageTypeToPrototypeMap[3047] = new TSD::GuideStorageArchive();
	_messageTypeToPrototypeMap[3048] = new TSD::StyledInfoSetStyleCommandArchive();
	_messageTypeToPrototypeMap[3049] = new TSD::DrawableInfoCommentCommandArchive();
	_messageTypeToPrototypeMap[3050] = new TSD::GuideCommandArchive();
	_messageTypeToPrototypeMap[3051] = new TSD::DrawableAspectRatioLockedCommandArchive();
	_messageTypeToPrototypeMap[3052] = new TSD::ContainerRemoveChildrenCommandArchive();
	_messageTypeToPrototypeMap[3053] = new TSD::ContainerInsertChildrenCommandArchive();
	_messageTypeToPrototypeMap[3054] = new TSD::ContainerReorderChildrenCommandArchive();
	_messageTypeToPrototypeMap[3055] = new TSD::ImageAdjustmentsCommandArchive();
	_messageTypeToPrototypeMap[3056] = new TSD::CommentStorageArchive();
	_messageTypeToPrototypeMap[3057] = new TSD::ThemeReplaceFillPresetCommandArchive();
	_messageTypeToPrototypeMap[3058] = new TSD::DrawableAccessibilityDescriptionCommandArchive();
	_messageTypeToPrototypeMap[3059] = new TSD::PasteStyleCommandArchive();
	_messageTypeToPrototypeMap[3060] = new TSD::CommentStorageApplyCommandArchive();
	_messageTypeToPrototypeMap[4000] = new TSCE::CalculationEngineArchive();
	_messageTypeToPrototypeMap[4001] = new TSCE::FormulaRewriteCommandArchive();
	_messageTypeToPrototypeMap[4002] = new TSCE::TrackedReferencesRewriteCommandArchive();
	_messageTypeToPrototypeMap[4003] = new TSCE::NamedReferenceManagerArchive();
	_messageTypeToPrototypeMap[4004] = new TSCE::ReferenceTrackerArchive();
	_messageTypeToPrototypeMap[4005] = new TSCE::TrackedReferenceArchive();
	_messageTypeToPrototypeMap[5000] = new TSCH::PreUFF::ChartInfoArchive();
	_messageTypeToPrototypeMap[5002] = new TSCH::PreUFF::ChartGridArchive();
	_messageTypeToPrototypeMap[5004] = new TSCH::ChartMediatorArchive();
	_messageTypeToPrototypeMap[5010] = new TSCH::PreUFF::ChartStyleArchive();
	_messageTypeToPrototypeMap[5011] = new TSCH::PreUFF::ChartSeriesStyleArchive();
	_messageTypeToPrototypeMap[5012] = new TSCH::PreUFF::ChartAxisStyleArchive();
	_messageTypeToPrototypeMap[5013] = new TSCH::PreUFF::LegendStyleArchive();
	_messageTypeToPrototypeMap[5014] = new TSCH::PreUFF::ChartNonStyleArchive();
	_messageTypeToPrototypeMap[5015] = new TSCH::PreUFF::ChartSeriesNonStyleArchive();
	_messageTypeToPrototypeMap[5016] = new TSCH::PreUFF::ChartAxisNonStyleArchive();
	_messageTypeToPrototypeMap[5017] = new TSCH::PreUFF::LegendNonStyleArchive();
	_messageTypeToPrototypeMap[5020] = new TSCH::ChartStylePreset();
	_messageTypeToPrototypeMap[5021] = new TSCH::ChartDrawableArchive();
	_messageTypeToPrototypeMap[5022] = new TSCH::ChartStyleArchive();
	_messageTypeToPrototypeMap[5023] = new TSCH::ChartNonStyleArchive();
	_messageTypeToPrototypeMap[5024] = new TSCH::LegendStyleArchive();
	_messageTypeToPrototypeMap[5025] = new TSCH::LegendNonStyleArchive();
	_messageTypeToPrototypeMap[5026] = new TSCH::ChartAxisStyleArchive();
	_messageTypeToPrototypeMap[5027] = new TSCH::ChartAxisNonStyleArchive();
	_messageTypeToPrototypeMap[5028] = new TSCH::ChartSeriesStyleArchive();
	_messageTypeToPrototypeMap[5029] = new TSCH::ChartSeriesNonStyleArchive();
	_messageTypeToPrototypeMap[5103] = new TSCH::CommandSetChartTypeArchive();
	_messageTypeToPrototypeMap[5104] = new TSCH::CommandSetSeriesNameArchive();
	_messageTypeToPrototypeMap[5105] = new TSCH::CommandSetCategoryNameArchive();
	_messageTypeToPrototypeMap[5107] = new TSCH::CommandSetScatterFormatArchive();
	_messageTypeToPrototypeMap[5108] = new TSCH::CommandSetLegendFrameArchive();
	_messageTypeToPrototypeMap[5109] = new TSCH::CommandSetGridValueArchive();
	_messageTypeToPrototypeMap[5110] = new TSCH::CommandSetGridDirectionArchive();
	_messageTypeToPrototypeMap[5113] = new TSCH::SynchronousCommandArchive();
	_messageTypeToPrototypeMap[5114] = new TSCH::CommandReplaceAllArchive();
	_messageTypeToPrototypeMap[5115] = new TSCH::CommandAddGridRowsArchive();
	_messageTypeToPrototypeMap[5116] = new TSCH::CommandAddGridColumnsArchive();
	_messageTypeToPrototypeMap[5117] = new TSCH::CommandSetPreviewLocArchive();
	_messageTypeToPrototypeMap[5118] = new TSCH::CommandMoveGridRowsArchive();
	_messageTypeToPrototypeMap[5119] = new TSCH::CommandMoveGridColumnsArchive();
	_messageTypeToPrototypeMap[5120] = new TSCH::CommandDeleteGridRowsArchive();
	_messageTypeToPrototypeMap[5121] = new TSCH::CommandDeleteGridColumnsArchive();
	_messageTypeToPrototypeMap[5122] = new TSCH::CommandSetPieWedgeExplosion();
	_messageTypeToPrototypeMap[5123] = new TSCH::CommandStyleSwapArchive();
	_messageTypeToPrototypeMap[5124] = new TSCH::CommandChartApplyTheme();
	_messageTypeToPrototypeMap[5125] = new TSCH::CommandChartApplyPreset();
	_messageTypeToPrototypeMap[5126] = new TSCH::ChartCommandArchive();
	_messageTypeToPrototypeMap[5127] = new TSCH::CommandReplaceGridValuesArchive();
	_messageTypeToPrototypeMap[5129] = new TSCH::StylePasteboardDataArchive();
	_messageTypeToPrototypeMap[5130] = new TSCH::CommandSetMultiDataSetIndexArchive();
	_messageTypeToPrototypeMap[5131] = new TSCH::CommandReplaceThemePresetArchive();
	_messageTypeToPrototypeMap[5132] = new TSCH::CommandInvalidateWPCaches();
	_messageTypeToPrototypeMap[6000] = new TST::TableInfoArchive();
	_messageTypeToPrototypeMap[6001] = new TST::TableModelArchive();
	_messageTypeToPrototypeMap[6002] = new TST::Tile();
	_messageTypeToPrototypeMap[6003] = new TST::TableStyleArchive();
	_messageTypeToPrototypeMap[6004] = new TST::CellStyleArchive();
	_messageTypeToPrototypeMap[6005] = new TST::TableDataList();
	_messageTypeToPrototypeMap[6006] = new TST::HeaderStorageBucket();
	_messageTypeToPrototypeMap[6007] = new TST::WPTableInfoArchive();
	_messageTypeToPrototypeMap[6008] = new TST::TableStylePresetArchive();
	_messageTypeToPrototypeMap[6009] = new TST::TableStrokePresetArchive();
	_messageTypeToPrototypeMap[6010] = new TST::ConditionalStyleSetArchive();
	_messageTypeToPrototypeMap[6100] = new TST::TableCommandArchive();
	_messageTypeToPrototypeMap[6101] = new TST::CommandDeleteCellsArchive();
	_messageTypeToPrototypeMap[6102] = new TST::CommandInsertColumnsOrRowsArchive();
	_messageTypeToPrototypeMap[6103] = new TST::CommandRemoveColumnsOrRowsArchive();
	_messageTypeToPrototypeMap[6104] = new TST::CommandResizeColumnOrRowArchive();
	_messageTypeToPrototypeMap[6105] = new TST::CommandSetCellArchive();
	_messageTypeToPrototypeMap[6106] = new TST::CommandSetNumberOfHeadersOrFootersArchive();
	_messageTypeToPrototypeMap[6107] = new TST::CommandSetTableNameArchive();
	_messageTypeToPrototypeMap[6108] = new TST::CommandStyleCellsArchive();
	_messageTypeToPrototypeMap[6109] = new TST::CommandFillCellsArchive();
	_messageTypeToPrototypeMap[6110] = new TST::CommandReplaceAllTextArchive();
	_messageTypeToPrototypeMap[6111] = new TST::CommandChangeFreezeHeaderStateArchive();
	_messageTypeToPrototypeMap[6112] = new TST::CommandReplaceTextArchive();
	_messageTypeToPrototypeMap[6113] = new TST::CommandPasteArchive();
	_messageTypeToPrototypeMap[6114] = new TST::CommandSetTableNameEnabledArchive();
	_messageTypeToPrototypeMap[6115] = new TST::CommandMoveRowsArchive();
	_messageTypeToPrototypeMap[6116] = new TST::CommandMoveColumnsArchive();
	_messageTypeToPrototypeMap[6117] = new TST::CommandApplyTableStylePresetArchive();
	_messageTypeToPrototypeMap[6118] = new TST::CommandApplyStrokePresetArchive();
	_messageTypeToPrototypeMap[6119] = new TST::CommandSetExplicitFormatArchive();
	_messageTypeToPrototypeMap[6120] = new TST::CommandSetRepeatingHeaderEnabledArchive();
	_messageTypeToPrototypeMap[6121] = new TST::CommandApplyThemeToTableArchive();
	_messageTypeToPrototypeMap[6122] = new TST::CommandApplyThemeChildForTableArchive();
	_messageTypeToPrototypeMap[6123] = new TST::CommandSortArchive();
	_messageTypeToPrototypeMap[6124] = new TST::CommandToggleTextPropertyArchive();
	_messageTypeToPrototypeMap[6125] = new TST::CommandStyleTableArchive();
	_messageTypeToPrototypeMap[6126] = new TST::CommandSetNumberOfDecimalPlacesArchive();
	_messageTypeToPrototypeMap[6127] = new TST::CommandSetShowThousandsSeparatorArchive();
	_messageTypeToPrototypeMap[6128] = new TST::CommandSetNegativeNumberStyleArchive();
	_messageTypeToPrototypeMap[6129] = new TST::CommandSetFractionAccuracyArchive();
	_messageTypeToPrototypeMap[6130] = new TST::CommandSetSingleNumberFormatParameterArchive();
	_messageTypeToPrototypeMap[6131] = new TST::CommandSetCurrencyCodeArchive();
	_messageTypeToPrototypeMap[6132] = new TST::CommandSetUseAccountingStyleArchive();
	_messageTypeToPrototypeMap[6134] = new TST::CommandRewriteFormulasForSortArchive();
	_messageTypeToPrototypeMap[6135] = new TST::CommandRewriteFormulasForTectonicShiftArchive();
	_messageTypeToPrototypeMap[6136] = new TST::CommandSetTableFontNameArchive();
	_messageTypeToPrototypeMap[6137] = new TST::CommandSetTableFontSizeArchive();
	_messageTypeToPrototypeMap[6138] = new TST::CommandRewriteFormulasForMoveArchive();
	_messageTypeToPrototypeMap[6139] = new TST::CommandFixStylesInHeadersOrFootersArchive();
	_messageTypeToPrototypeMap[6141] = new TST::CommandResetFillPropertyToDefault();
	_messageTypeToPrototypeMap[6142] = new TST::CommandSetTableNameHeightArchive();
	_messageTypeToPrototypeMap[6143] = new TST::CommandMergeUnmergeArchive();
	_messageTypeToPrototypeMap[6144] = new TST::MergeRegionMapArchive();
	_messageTypeToPrototypeMap[6145] = new TST::CommandHideShowArchive();
	_messageTypeToPrototypeMap[6146] = new TST::CommandSetBaseArchive();
	_messageTypeToPrototypeMap[6147] = new TST::CommandSetBasePlacesArchive();
	_messageTypeToPrototypeMap[6148] = new TST::CommandSetBaseUseMinusSignArchive();
	_messageTypeToPrototypeMap[6179] = new TST::FormulaEqualsTokenAttachmentArchive();
	_messageTypeToPrototypeMap[6181] = new TST::TokenAttachmentArchive();
	_messageTypeToPrototypeMap[6182] = new TST::ExpressionNodeArchive();
	_messageTypeToPrototypeMap[6183] = new TST::BooleanNodeArchive();
	_messageTypeToPrototypeMap[6184] = new TST::NumberNodeArchive();
	_messageTypeToPrototypeMap[6185] = new TST::StringNodeArchive();
	_messageTypeToPrototypeMap[6186] = new TST::ArrayNodeArchive();
	_messageTypeToPrototypeMap[6187] = new TST::ListNodeArchive();
	_messageTypeToPrototypeMap[6188] = new TST::OperatorNodeArchive();
	_messageTypeToPrototypeMap[6189] = new TST::FunctionNodeArchive();
	_messageTypeToPrototypeMap[6190] = new TST::DateNodeArchive();
	_messageTypeToPrototypeMap[6191] = new TST::ReferenceNodeArchive();
	_messageTypeToPrototypeMap[6192] = new TST::DurationNodeArchive();
	_messageTypeToPrototypeMap[6193] = new TST::ArgumentPlaceholderNodeArchive();
	_messageTypeToPrototypeMap[6194] = new TST::PostfixOperatorNodeArchive();
	_messageTypeToPrototypeMap[6195] = new TST::PrefixOperatorNodeArchive();
	_messageTypeToPrototypeMap[6196] = new TST::FunctionEndNodeArchive();
	_messageTypeToPrototypeMap[6197] = new TST::EmptyExpressionNodeArchive();
	_messageTypeToPrototypeMap[6198] = new TST::LayoutHintArchive();
	_messageTypeToPrototypeMap[6199] = new TST::CompletionTokenAttachmentArchive();
	_messageTypeToPrototypeMap[6200] = new TST::FormulaEditingCommandGroupArchive();
	_messageTypeToPrototypeMap[6201] = new TST::TableDataList();
	_messageTypeToPrototypeMap[6202] = new TST::CommandCoerceMultipleCellsArchive();
	_messageTypeToPrototypeMap[6203] = new TST::CommandSetMultipleCellsCustomArchive();
	_messageTypeToPrototypeMap[6204] = new TST::HiddenStateFormulaOwnerArchive();
	_messageTypeToPrototypeMap[6205] = new TST::CommandSetAutomaticDurationUnitsArchive();
	_messageTypeToPrototypeMap[6206] = new TST::PopUpMenuModel();
	_messageTypeToPrototypeMap[6207] = new TST::CommandSetControlMinimumArchive();
	_messageTypeToPrototypeMap[6208] = new TST::CommandSetControlMaximumArchive();
	_messageTypeToPrototypeMap[6209] = new TST::CommandSetControlIncrementArchive();
	_messageTypeToPrototypeMap[6210] = new TST::CommandSetControlCellsDisplayNumberFormatArchive();
	_messageTypeToPrototypeMap[6211] = new TST::CommandSetMultipleCellsMultipleChoiceListArchive();
	_messageTypeToPrototypeMap[6212] = new TST::CommandSetMultipleChoiceListFormatForEditedItemArchive();
	_messageTypeToPrototypeMap[6213] = new TST::CommandSetMultipleChoiceListFormatForDeleteItemArchive();
	_messageTypeToPrototypeMap[6214] = new TST::CommandSetMultipleChoiceListFormatForReorderItemArchive();
	_messageTypeToPrototypeMap[6215] = new TST::CommandSetMultipleChoiceListFormatForInitialValueArchive();
	_messageTypeToPrototypeMap[6216] = new TST::CommandRewriteFormulasForCellMergeArchive();
	_messageTypeToPrototypeMap[6217] = new TST::TableInfoGeometryCommandArchive();
	_messageTypeToPrototypeMap[6218] = new TST::RichTextPayloadArchive();
	_messageTypeToPrototypeMap[6219] = new TST::EditingStateArchive();
	_messageTypeToPrototypeMap[6220] = new TST::FilterSetArchive();
	_messageTypeToPrototypeMap[6221] = new TST::CommandSetFiltersEnabledArchive();
	_messageTypeToPrototypeMap[6222] = new TST::CommandRewriteFilterFormulasForTectonicShiftArchive();
	_messageTypeToPrototypeMap[6223] = new TST::CommandRewriteFilterFormulasForSortArchive();
	_messageTypeToPrototypeMap[6224] = new TST::CommandRewriteFilterFormulasForTableResizeArchive();
	_messageTypeToPrototypeMap[6225] = new TST::CommandSetAutomaticFormatArchive();
	_messageTypeToPrototypeMap[6226] = new TST::CommandTextPreflightInsertCellArchive();
	_messageTypeToPrototypeMap[6227] = new TST::FormulaEditingCommandSelectionBehaviorArchive();
	_messageTypeToPrototypeMap[6228] = new TST::CommandDeleteCellContentsArchive();
	_messageTypeToPrototypeMap[6229] = new TST::CommandPostflightSetCellArchive();
	_messageTypeToPrototypeMap[6231] = new TST::CommandRewriteConditionalStylesForTectonicShiftArchive();
	_messageTypeToPrototypeMap[6232] = new TST::CommandRewriteConditionalStylesForSortArchive();
	_messageTypeToPrototypeMap[6233] = new TST::CommandRewriteConditionalStylesForRangeMoveArchive();
	_messageTypeToPrototypeMap[6234] = new TST::CommandRewriteConditionalStylesForCellMergeArchive();
	_messageTypeToPrototypeMap[6235] = new TST::IdentifierNodeArchive();
	_messageTypeToPrototypeMap[6236] = new TST::UndoRedoStateCommandSelectionBehaviorArchive();
	_messageTypeToPrototypeMap[6237] = new TST::CommandSetStyleApplyClearsAllFlagArchive();
	_messageTypeToPrototypeMap[6238] = new TST::CommandSetDateTimeFormatArchive();
	_messageTypeToPrototypeMap[6239] = new TST::TableCommandSelectionBehaviorArchive();
	_messageTypeToPrototypeMap[6240] = new TST::CommandAddQuickFilterRulesArchive();
	_messageTypeToPrototypeMap[6241] = new TST::CommandModifyFilterRuleArchive();
	_messageTypeToPrototypeMap[6242] = new TST::CommandDeleteFilterRulesArchive();
	_messageTypeToPrototypeMap[6244] = new TST::CommandApplyCellCommentArchive();
	_messageTypeToPrototypeMap[6245] = new TST::CommandApplyConditionalStyleSetArchive();
	_messageTypeToPrototypeMap[6246] = new TST::CommandSetFormulaTokenizationArchive();
	_messageTypeToPrototypeMap[6247] = new TST::TableStyleNetworkArchive();
	_messageTypeToPrototypeMap[6248] = new TST::CommandSetFilterEnabledArchive();
	_messageTypeToPrototypeMap[6249] = new TST::CommandSetFilterRuleEnabledArchive();
	_messageTypeToPrototypeMap[6250] = new TST::CommandSetFilterSetTypeArchive();
	_messageTypeToPrototypeMap[6251] = new TST::CommandSetStyleNetworkArchive();
	_messageTypeToPrototypeMap[6252] = new TST::CommandMutateCellsArchive();
	_messageTypeToPrototypeMap[6253] = new TST::DisableTableNameSelectionBehaviorArchive();
	_messageTypeToPrototypeMap[6254] = new TST::CommandDisableFilterRulesForColumnArchive();
	_messageTypeToPrototypeMap[6255] = new TST::CommandSetTextStyleArchive();
	_messageTypeToPrototypeMap[6256] = new TST::CommandNotifyForTransformingArchive();
	_messageTypeToPrototypeMap[11000] = new TSP::PasteboardObject();
	_messageTypeToPrototypeMap[11006] = new TSP::PackageMetadata();
	_messageTypeToPrototypeMap[11007] = new TSP::PasteboardMetadata();
	_messageTypeToPrototypeMap[11008] = new TSP::ObjectContainer();
}

- (void)registerKeynotePersistenceMessages
{
	_messageTypeToPrototypeMap[1] = new KN::DocumentArchive();
	_messageTypeToPrototypeMap[2] = new KN::ShowArchive();
	_messageTypeToPrototypeMap[3] = new KN::UIStateArchive();
	_messageTypeToPrototypeMap[4] = new KN::SlideNodeArchive();
	_messageTypeToPrototypeMap[5] = new KN::SlideArchive();
	_messageTypeToPrototypeMap[6] = new KN::SlideArchive();
	_messageTypeToPrototypeMap[7] = new KN::PlaceholderArchive();
	_messageTypeToPrototypeMap[8] = new KN::BuildArchive();
	_messageTypeToPrototypeMap[9] = new KN::SlideStyleArchive();
	_messageTypeToPrototypeMap[10] = new KN::ThemeArchive();
	_messageTypeToPrototypeMap[11] = new KN::PasteboardNativeStorageArchive();
	_messageTypeToPrototypeMap[12] = new KN::PlaceholderArchive();
	_messageTypeToPrototypeMap[14] = new TSWP::TextualAttachmentArchive();
	_messageTypeToPrototypeMap[15] = new KN::NoteArchive();
	_messageTypeToPrototypeMap[16] = new KN::RecordingArchive();
	_messageTypeToPrototypeMap[17] = new KN::RecordingEventTrackArchive();
	_messageTypeToPrototypeMap[18] = new KN::RecordingMovieTrackArchive();
	_messageTypeToPrototypeMap[19] = new KN::ClassicStylesheetRecordArchive();
	_messageTypeToPrototypeMap[20] = new KN::ClassicThemeRecordArchive();
	_messageTypeToPrototypeMap[21] = new KN::Soundtrack();
	_messageTypeToPrototypeMap[22] = new KN::SlideNumberAttachmentArchive();
	_messageTypeToPrototypeMap[23] = new KN::DesktopUILayoutArchive();
	_messageTypeToPrototypeMap[24] = new KN::CanvasSelectionArchive();
	_messageTypeToPrototypeMap[25] = new KN::SlideCollectionSelectionArchive();
	_messageTypeToPrototypeMap[100] = new KN::CommandBuildSetValueArchive();
	_messageTypeToPrototypeMap[101] = new KN::CommandShowInsertSlideArchive();
	_messageTypeToPrototypeMap[102] = new KN::CommandShowMoveSlideArchive();
	_messageTypeToPrototypeMap[103] = new KN::CommandShowRemoveSlideArchive();
	_messageTypeToPrototypeMap[104] = new KN::CommandSlideInsertDrawablesArchive();
	_messageTypeToPrototypeMap[105] = new KN::CommandSlideRemoveDrawableArchive();
	_messageTypeToPrototypeMap[106] = new KN::CommandSlideNodeSetPropertyArchive();
	_messageTypeToPrototypeMap[107] = new KN::CommandSlideInsertBuildArchive();
	_messageTypeToPrototypeMap[108] = new KN::CommandSlideMoveBuildWithoutMovingChunksArchive();
	_messageTypeToPrototypeMap[109] = new KN::CommandSlideRemoveBuildArchive();
	_messageTypeToPrototypeMap[110] = new KN::CommandSlideInsertBuildChunkArchive();
	_messageTypeToPrototypeMap[111] = new KN::CommandSlideMoveBuildChunkArchive();
	_messageTypeToPrototypeMap[112] = new KN::CommandSlideRemoveBuildChunkArchive();
	_messageTypeToPrototypeMap[113] = new KN::CommandSlideSetValueArchive();
	_messageTypeToPrototypeMap[114] = new KN::CommandTransitionSetValueArchive();
	_messageTypeToPrototypeMap[115] = new KN::UIStateCommandGroupArchive();
	_messageTypeToPrototypeMap[116] = new KN::CommandSlidePasteDrawablesArchive();
	_messageTypeToPrototypeMap[117] = new KN::CommandSlideApplyThemeArchive();
	_messageTypeToPrototypeMap[118] = new KN::CommandSlideMoveDrawableZOrderArchive();
	_messageTypeToPrototypeMap[119] = new KN::CommandChangeMasterSlideArchive();
	_messageTypeToPrototypeMap[123] = new KN::CommandShowSetSlideNumberVisibilityArchive();
	_messageTypeToPrototypeMap[124] = new KN::CommandShowSetValueArchive();
	_messageTypeToPrototypeMap[128] = new KN::CommandShowMarkOutOfSyncRecordingArchive();
	_messageTypeToPrototypeMap[129] = new KN::CommandShowRemoveRecordingArchive();
	_messageTypeToPrototypeMap[130] = new KN::CommandShowReplaceRecordingArchive();
	_messageTypeToPrototypeMap[131] = new KN::CommandShowSetSoundtrack();
	_messageTypeToPrototypeMap[132] = new KN::CommandSoundtrackSetValue();
	_messageTypeToPrototypeMap[133] = new KN::CommandMasterRescaleArchive();
	_messageTypeToPrototypeMap[134] = new KN::CommandMoveMastersArchive();
	_messageTypeToPrototypeMap[135] = new KN::CommandInsertMasterArchive();
	_messageTypeToPrototypeMap[136] = new KN::CommandSlideSetStyleArchive();
	_messageTypeToPrototypeMap[137] = new KN::CommandSlideSetPlaceholdersForTagsArchive();
	_messageTypeToPrototypeMap[138] = new KN::CommandBuildChunkSetValueArchive();
	_messageTypeToPrototypeMap[139] = new KN::CommandSlideMoveBuildChunksArchive();
	_messageTypeToPrototypeMap[140] = new KN::CommandRemoveMasterArchive();
	_messageTypeToPrototypeMap[141] = new KN::CommandRenameMasterArchive();
	_messageTypeToPrototypeMap[142] = new KN::CommandMasterSetThumbnailTextArchive();
	_messageTypeToPrototypeMap[143] = new KN::CommandShowChangeThemeArchive();
	_messageTypeToPrototypeMap[144] = new KN::CommandSlidePrimitiveSetMasterArchive();
	_messageTypeToPrototypeMap[145] = new KN::CommandMasterSetBodyStylesArchive();
	_messageTypeToPrototypeMap[146] = new KN::CommandSlideReapplyMasterArchive();
	_messageTypeToPrototypeMap[147] = new KN::SlideCollectionCommandSelectionBehaviorArchive();
	_messageTypeToPrototypeMap[148] = new KN::ChartInfoGeometryCommandArchive();
	_messageTypeToPrototypeMap[10011] = new TSWP::SectionPlaceholderArchive();
}

- (void)registerPagesPersistenceMessages
{
	_messageTypeToPrototypeMap[7] = new TP::PlaceholderArchive();
	_messageTypeToPrototypeMap[10000] = new TP::DocumentArchive();
	_messageTypeToPrototypeMap[10001] = new TP::ThemeArchive();
	_messageTypeToPrototypeMap[10010] = new TP::FloatingDrawablesArchive();
	_messageTypeToPrototypeMap[10011] = new TP::SectionArchive();
	_messageTypeToPrototypeMap[10012] = new TP::SettingsArchive();
	_messageTypeToPrototypeMap[10015] = new TP::DrawablesZOrderArchive();
	_messageTypeToPrototypeMap[10101] = new TP::InsertDrawablesCommandArchive();
	_messageTypeToPrototypeMap[10102] = new TP::RemoveDrawablesCommandArchive();
	_messageTypeToPrototypeMap[10108] = new TP::PasteAnchoredDrawablesCommandArchive();
	_messageTypeToPrototypeMap[10109] = new TP::PasteDrawablesCommandArchive();
	_messageTypeToPrototypeMap[10110] = new TP::MoveDrawablesAttachedCommandArchive();
	_messageTypeToPrototypeMap[10111] = new TP::MoveDrawablesFloatingCommandArchive();
	_messageTypeToPrototypeMap[10112] = new TP::MoveInlineDrawableAnchoredCommandArchive();
	_messageTypeToPrototypeMap[10113] = new TP::InsertFootnoteCommandArchive();
	_messageTypeToPrototypeMap[10114] = new TP::ChangeFootnoteFormatCommandArchive();
	_messageTypeToPrototypeMap[10115] = new TP::ChangeFootnoteKindCommandArchive();
	_messageTypeToPrototypeMap[10116] = new TP::ChangeFootnoteNumberingCommandArchive();
	_messageTypeToPrototypeMap[10117] = new TP::ToggleBodyLayoutDirectionCommandArchive();
	_messageTypeToPrototypeMap[10118] = new TP::ChangeFootnoteSpacingCommandArchive();
	_messageTypeToPrototypeMap[10119] = new TP::MoveAnchoredDrawableInlineCommandArchive();
	_messageTypeToPrototypeMap[10120] = new TP::ChangeSectionMarginsCommandArchive();
	_messageTypeToPrototypeMap[10121] = new TP::ChangeDocumentPrinterOptionsCommandArchive();
	_messageTypeToPrototypeMap[10125] = new TP::InsertMasterDrawablesCommandArchive();
	_messageTypeToPrototypeMap[10126] = new TP::RemoveMasterDrawablesCommandArchive();
	_messageTypeToPrototypeMap[10127] = new TP::PasteMasterDrawablesCommandArchive();
	_messageTypeToPrototypeMap[10128] = new TP::NudgeDrawablesCommandArchive();
	_messageTypeToPrototypeMap[10130] = new TP::MoveDrawablesPageIndexCommandArchive();
	_messageTypeToPrototypeMap[10131] = new TP::LayoutStateArchive();
	_messageTypeToPrototypeMap[10132] = new TP::CanvasSelectionArchive();
	_messageTypeToPrototypeMap[10133] = new TP::ViewStateArchive();
	_messageTypeToPrototypeMap[10134] = new TP::ChangeHeaderFooterVisibilityCommandArchive();
	_messageTypeToPrototypeMap[10140] = new TP::MoveMasterDrawableZOrderCommandArchive();
	_messageTypeToPrototypeMap[10141] = new TP::SwapDrawableZOrderCommandArchive();
	_messageTypeToPrototypeMap[10142] = new TP::RemoveAnchoredDrawableCommandArchive();
	_messageTypeToPrototypeMap[10143] = new TP::PageMasterArchive();
	_messageTypeToPrototypeMap[10147] = new TP::UIStateArchive();
	_messageTypeToPrototypeMap[10148] = new TP::ChangeCTVisibilityCommandArchive();
	_messageTypeToPrototypeMap[10149] = new TP::TrackChangesCommandArchive();
	_messageTypeToPrototypeMap[10150] = new TP::DocumentHyphenationCommandArchive();
	_messageTypeToPrototypeMap[10151] = new TP::DocumentLigaturesCommandArchive();
	_messageTypeToPrototypeMap[10152] = new TP::InsertSectionBreakCommandArchive();
	_messageTypeToPrototypeMap[10153] = new TP::DeleteSectionCommandArchive();
	_messageTypeToPrototypeMap[10154] = new TP::ReplaceSectionCommandArchive();
	_messageTypeToPrototypeMap[10155] = new TP::ChangeSectionPropertyCommandArchive();
	_messageTypeToPrototypeMap[10156] = new TP::DocumentHasBodyCommandArchive();
	_messageTypeToPrototypeMap[10157] = new TP::PauseChangeTrackingCommandArchive();
}

- (void)registerNumbersPersistenceMessages
{
	_messageTypeToPrototypeMap[1] = new TN::DocumentArchive();
	_messageTypeToPrototypeMap[2] = new TN::SheetArchive();
	_messageTypeToPrototypeMap[3] = new TN::FormBasedSheetArchive();
	_messageTypeToPrototypeMap[7] = new TN::PlaceholderArchive();
	_messageTypeToPrototypeMap[10011] = new TSWP::SectionPlaceholderArchive();
	_messageTypeToPrototypeMap[12002] = new TN::CommandSheetInsertDrawablesArchive();
	_messageTypeToPrototypeMap[12003] = new TN::CommandDocumentInsertSheetArchive();
	_messageTypeToPrototypeMap[12004] = new TN::CommandDocumentRemoveSheetArchive();
	_messageTypeToPrototypeMap[12005] = new TN::CommandSetSheetNameArchive();
	_messageTypeToPrototypeMap[12006] = new TN::ChartMediatorArchive();
	_messageTypeToPrototypeMap[12007] = new TN::CommandPasteDrawablesArchive();
	_messageTypeToPrototypeMap[12008] = new TN::CommandDocumentReorderSheetArchive();
	_messageTypeToPrototypeMap[12009] = new TN::ThemeArchive();
	_messageTypeToPrototypeMap[12010] = new TN::CommandPasteSheetArchive();
	_messageTypeToPrototypeMap[12011] = new TN::CommandReorderSidebarItemChildrenAchive();
	_messageTypeToPrototypeMap[12012] = new TN::CommandSheetRemoveDrawablesArchive();
	_messageTypeToPrototypeMap[12013] = new TN::CommandSheetMoveDrawableZOrderArchive();
	_messageTypeToPrototypeMap[12014] = new TN::CommandChartMediatorSetEditingState();
	_messageTypeToPrototypeMap[12015] = new TN::CommandFormChooseTargetTableArchive();
	_messageTypeToPrototypeMap[12016] = new TN::CommandChartMediatorUpdateForEntityDelete();
	_messageTypeToPrototypeMap[12017] = new TN::CommandSetPageOrientationArchive();
	_messageTypeToPrototypeMap[12018] = new TN::CommandSetContentScaleArchive();
	_messageTypeToPrototypeMap[12019] = new TN::CommandSetShowPageNumbersValueArchive();
	_messageTypeToPrototypeMap[12021] = new TN::CommandSetAutofitValueArchive();
	_messageTypeToPrototypeMap[12024] = new TN::UndoRedoStateArchive();
	_messageTypeToPrototypeMap[12025] = new TN::CommandDocumentReplaceLastSheetArchive();
	_messageTypeToPrototypeMap[12026] = new TN::UIStateArchive();
	_messageTypeToPrototypeMap[12027] = new TN::ChartCommandSelectionBehaviorArchive();
	_messageTypeToPrototypeMap[12028] = new TN::SheetSelectionArchive();
	_messageTypeToPrototypeMap[12029] = new TN::SheetCommandSelectionBehaviorArchive();
	_messageTypeToPrototypeMap[12030] = new TN::CommandSetDocumentPrinterOptions();
}

@end
