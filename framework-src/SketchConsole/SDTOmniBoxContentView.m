//
//  SDTOmniBoxContentView.m
//  SketchConsole
//
//  Created by Andrey on 15/09/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import "SDTOmniBoxContentView.h"

@implementation SDTOmniBoxContentView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Clear the drawing rect.
    [[NSColor clearColor] set];
    NSRectFill([self frame]);
    // A boolean tracks the previous shape of the window. If the shape changes, it's necessary for the
    // window to recalculate its shape and shadow.
    BOOL shouldDisplayWindow = NO;
    // If the window transparency is > 0.7, draw the circle, otherwise, draw the pentagon.
    
    [[NSColor whiteColor] set];
    // [NSBezierPath fillRect:dirtyRect];
    NSBezierPath* path=[NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:4 yRadius:3];
    [path fill];
    
    /*
    if ([[self window] alphaValue] > 0.7) {
        shouldDisplayWindow = (showingPentagon == YES);
        showingPentagon = NO;
        [circleImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    } else {
        shouldDisplayWindow = (showingPentagon == NO);
        showingPentagon = YES;
        [pentagonImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
     */
    
    // Reset the window shape and shadow.
    if (shouldDisplayWindow) {
        [[self window] display];
        [[self window] setHasShadow:NO];
        [[self window] setHasShadow:YES];
    }

}

@end
