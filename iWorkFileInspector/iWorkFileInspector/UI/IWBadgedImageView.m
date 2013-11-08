//
//  IWBadgedImageView.m
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import "IWBadgedImageView.h"

#import <QuartzCore/QuartzCore.h>


const CGFloat kIWBadgeImageViewBadgeWidth = 32.0;
const CGFloat kIWBadgeImageViewBadgeHeight = 32.0;


@implementation IWBadgedImageView
{
	CALayer *_badgeLayer;
}

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self == nil) {
		return nil;
	}
	
	[self setWantsLayer:YES];
	
	_badgeLayer = [CALayer layer];
	[[self layer] addSublayer:_badgeLayer];
	
	return self;
}

- (void)setImage:(NSImage *)image
{
	_image = image;
	self.layer.contents = image;
}

- (void)setBadgeImage:(NSImage *)badgeImage
{
	_badgeImage = badgeImage;
	
	// Setting the contents directly will cause CALayer to use the largest rep, rather than the 32px or 32px@2x, so grab a CGImage.
	// TODO: Refetch the CGImage when the backing scale factor changes?
	CGRect imageRect = CGRectMake(0, 0, kIWBadgeImageViewBadgeWidth, kIWBadgeImageViewBadgeHeight);
	_badgeLayer.contents = (__bridge id)[badgeImage CGImageForProposedRect:&imageRect context:nil hints:nil];
	
	[self setNeedsDisplay:YES];
}

- (BOOL)wantsUpdateLayer
{
	return YES;
}

- (void)updateLayer
{
	[CATransaction begin];
	{
		[CATransaction setDisableActions:YES];
		
		CGRect bounds = self.layer.bounds;
		CGRect badgeFrame = bounds;
		badgeFrame.origin.x = CGRectGetMaxX(bounds) - kIWBadgeImageViewBadgeWidth - 2.0;
		badgeFrame.size = CGSizeMake(kIWBadgeImageViewBadgeWidth, kIWBadgeImageViewBadgeHeight);
		_badgeLayer.frame = badgeFrame;
	}
	[CATransaction commit];
}

@end
