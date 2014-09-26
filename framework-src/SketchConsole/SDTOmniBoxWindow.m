//
//  SDTOmniBoxWindow.m
//  SketchConsole
//
//  Created by Andrey on 15/09/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import "SDTOmniBoxWindow.h"
#import "SDTOmniBoxContentView.h"

#define WINDOW_FRAME_PADDING 10

@implementation SDTOmniBoxWindow

- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSUInteger)windowStyle
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)deferCreation
{
    // Using NSBorderlessWindowMask results in a window without a title bar.
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    if (self != nil) {
        // Start with no transparency for all drawing into the window
        [self setAlphaValue:1.0];
        // Turn off opacity so that the parts of the window that are not drawn into are transparent.
        [self setOpaque:NO];
    }
    return self;
}

- (BOOL)canBecomeKeyWindow {
    
    return YES;
}

@end
