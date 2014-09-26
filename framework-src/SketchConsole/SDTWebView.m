//
//  SDTWebView.m
//  SketchConsole
//
//  Created by Andrey on 14/09/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import "SDTWebView.h"
#import "NSLogger.h"

@implementation SDTWebView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        /*
        id eventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask handler:^(NSEvent * mouseEvent) {
            NSView* subView= [self hitTest: [mouseEvent locationInWindow]];
            if(subView) {
                NSLog(@"Mouse moved: %@", NSStringFromPoint([mouseEvent locationInWindow]));
                NSLog(@"Мы сюда попадаем!!!");
                [subView mouseMoved:mouseEvent];
            }
            
        }];
         */
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
