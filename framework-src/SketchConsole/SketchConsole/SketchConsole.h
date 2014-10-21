//
//  SketchConsole.h
//  SketchConsole
//
//  Created by Andrey on 21/08/14.
//  Copyright (c) 2014 Andrey Shakhmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDTModule;
@class SDTFileWatcher;

@interface SketchConsole : NSObject


+(void)load;

+(void)clearConsole;

@property (nonatomic) NSDictionary* options;
@property (nonatomic) NSURL* scriptURL; // sketch-devtools/Console.sketchplugin

@property (nonatomic) NSMutableArray* brokenImports;
@property (nonatomic) NSMutableDictionary* validImports;


+(SketchConsole*)sharedInstance;
+(void)reportBrokenImport:(NSDictionary*)info;
+(void)reportValidImport:(NSString*)importFilePath atFile:(NSString*)filePath atLine:(NSInteger)line;


// Session
@property BOOL isNewSession;
@property SDTModule* cachedScriptRoot;

@property NSURL* sessionScriptURL;
@property BOOL finished;

// Internal
@property SDTFileWatcher* fileWatcher;


@property (weak,setter=setMyObjectName:,getter=getMyObjectName) NSString* objectName;

@end

