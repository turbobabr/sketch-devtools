//
//  NSString+SketchDevTools.h
//  SketchConsole
//
//  Created by Andrey on 03/09/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SketchDevTools)

-(NSInteger)sdt_numberOfLines;
- (NSString *)sdt_escapeHTML;

+ (NSString *)sdt_escapeHTML:(NSString*)str;

@end
