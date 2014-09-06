//
//  SDTModule.h
//  PluginParser
//
//  Created by Andrey on 27/08/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDTModule : NSObject



@property NSInteger line;
@property NSInteger internalLine;
@property NSInteger numberOfLines;
@property NSInteger internalNumberOfLines;
@property NSURL* url;

@property BOOL isBlockComment;

@property NSMutableArray* imports;
@property NSString* source;
@property SDTModule* parent;


-(BOOL)containsLine:(NSInteger)line;
-(SDTModule*)findModuleByLineNumber:(NSInteger)line;
-(BOOL)hasImports;


-(NSDictionary*)treeAsDictionary;


-(instancetype)initWithScriptURL:(NSURL*)url parent:(SDTModule*)parent startLine:(NSInteger)startLine;
-(instancetype)initWithScriptSource:(NSString*)source baseURL:(NSURL*)base parent:(SDTModule*)parent startLine:(NSInteger)startLine;

-(NSInteger)takesNumberOfLines;

-(NSInteger)relativeLineByAbsolute:(NSInteger)absolute;


@end
