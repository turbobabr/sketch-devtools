//
//  NSView+SketchDevTools.m
//  SketchConsole
//
//  Created by Andrey on 06/09/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import "NSView+SketchDevTools.h"

@implementation NSView (SketchDevTools)

-(NSView*)subviewWithID:(NSString*)viewID {
    
    for(NSUInteger i=0;i<self.subviews.count;i++) {
        NSView* subView=(NSView*)self.subviews[i];
        // if(subView.identifier==viewID)
        if([subView.identifier isEqualToString:viewID])
        {
            return self.subviews[i];
        }
    }
    
    return nil;
}


@end
