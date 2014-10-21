//
//  SDTSwizzle.h
//  SketchConsole
//
//  Created by Andrey on 27/08/14.
//  Copyright (c) 2014 Andrey Shakhmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDTSwizzle : NSObject
+(BOOL)swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ sClass:(Class)sClass pClass:(Class)pClass originalMethodPrefix:(NSString*)prefix;

+(BOOL)swizzleClassMethod:(SEL)origSel_ withMethod:(SEL)altSel_ sClass:(Class)sClass pClass:(Class)pClass originalMethodPrefix:(NSString*)prefix;


@end
