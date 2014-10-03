//
//  SKDProtocolHandler.h
//  SketchConsole
//
//  Created by Andrey on 06/09/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDTProtocolHandler : NSObject

+(BOOL)openFile:(NSString*)filePath withIDE:(NSString*)ide atLine:(NSInteger)line;

@end
