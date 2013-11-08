//
//  IWWindowShakeAnimation.m
//  iWork File Inspector
//
//  Copyright (c) 2013 Sean Patrick O'Brien. All rights reserved.
//

#import "IWWindowShakeAnimation.h"


@implementation IWWindowShakeAnimation
{
	NSWindow *_window;
	CGPoint _originalOrigin;
}

- (id)initWithWindow:(NSWindow *)window
{
	self = [super initWithDuration:0.4 animationCurve:NSAnimationEaseInOut];
	if (self == nil) {
		return nil;
	}
	
	_window = window;
	[self setAnimationBlockingMode:NSAnimationNonblockingThreaded];
	
	return self;
}

- (void)startAnimation
{
	_originalOrigin = _window.frame.origin;
	[super startAnimation];
}

// Simulates private NSAnimationCurve = 4, damped sin wave centered at 0.5
- (float)myCurrentValue
{
	float x = self.currentProgress;
	float multiplier = x >= 0.5 ? exp(x * -0.8) : 1.0;
	return (1 + sin(x * M_PI * 6.0) * multiplier) * 0.5;
}

- (void)setCurrentProgress:(NSAnimationProgress)progress
{
	[super setCurrentProgress:progress];

	CGPoint origin = _originalOrigin;
	origin.x += (self.myCurrentValue * 2.0 - 1.0) * 14.0;
	
	[_window setFrameOrigin:origin];
}

@end
