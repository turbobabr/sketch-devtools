//
//  SketchConsole.h
//  SketchConsole
//
//  Created by Andrey on 21/08/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDTModule;

@interface SketchConsole : NSObject


+(void)load;

+(void)printGlobal:(id)s;
+(void)printGlobalEx:(id)s;

-(void)print:(id)s;
-(void)coscript:(id)coscript hadError:(NSString*)error onLineNumber:(NSInteger)lineNumber atSourceURL:(id)url;

-(void)execScript:(NSString*)script;


+ (NSString *) webScriptNameForSelector:(SEL)sel;
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel;

+(void)clearConsole;

@property (nonatomic) NSDictionary* options;
@property (nonatomic) NSURL* scriptURL;

@property BOOL isNewSession;
@property SDTModule* cachedScriptRoot;

+(SketchConsole*)sharedInstance;


@end

