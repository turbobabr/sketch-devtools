//
//  SDTModule.m
//  PluginParser
//
//  Created by Andrey on 27/08/14.
//  Copyright (c) 2014 Andrey Shakhmin. All rights reserved.
//
#import <objc/runtime.h>
#import "SDTModule.h"
#import "NSString+SketchDevTools.h"

#import "NSLogger.h"
#import "SketchConsole.h"

/*
 #import "TDTokenizer.h"
 #import "TDToken.h"
 #import "TDWhitespaceState.h"
 #import "TDCommentState.h"
 */

// God knows how it works.. will add comments later. :)

@implementation SDTModule {
    
}

-(instancetype)init {
    
    self.imports=[NSMutableArray array];
    self.url=[[NSURL alloc] init];
    
    return self;
}

-(instancetype)initWithScriptURL:(NSURL*)url parent:(SDTModule*)parent startLine:(NSInteger)startLine {
    
    self.imports=[NSMutableArray array];
    self.url=url;
    self.parent=parent;
    self.line=startLine;
    
    NSString* source=[NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];;
    [self parseImports:source withBaseURL:url];
    
    return self;
}

-(instancetype)initWithScriptSource:(NSString*)source baseURL:(NSURL*)base parent:(SDTModule*)parent startLine:(NSInteger)startLine {
    
    self.imports=[NSMutableArray array];
    self.url=base;
    self.parent=parent;
    self.line=startLine;
    
    [self parseImports:source withBaseURL:base];
    
    return self;
}

-(instancetype)initWithScriptSource:(NSString*)source baseURL:(NSURL*)base parent:(SDTModule*)parent startLine:(NSInteger)startLine url:(NSURL*)url {
    
    self.imports=[NSMutableArray array];
    self.url=url;
    self.parent=parent;
    self.line=startLine;
    
    [self parseImports:source withBaseURL:base];
    
    return self;
}


-(BOOL)containsLine:(NSInteger)line {
    
    NSInteger relativeLineNumber=line-self.line;
    if(relativeLineNumber<0) {
        return false;
    }
    
    for (SDTModule* subModule in self.imports) {
        if([subModule containsLine:relativeLineNumber]) {
            return true;
        }
    }
    
    return relativeLineNumber<=self.numberOfLines;
}

-(NSInteger)relativeLineByAbsolute:(NSInteger)absolute {
    
    
    NSInteger deltaImports=0;
    NSInteger importsCount=0;
    NSInteger deltaComments=0;
    NSInteger commentsCount=0;
    
    for (SDTModule* subModule in self.imports) {
        if(subModule.isBlockComment) {
            if(subModule.line<absolute) {
                deltaComments+=[subModule numberOfLines];
                commentsCount++;
                
            }
        } else {
            if(subModule.line<absolute) {
                deltaImports+=[subModule takesNumberOfLines];
                importsCount++;
            }
        }
    }
    
    return (absolute - self.line - deltaImports) + importsCount + 1  + (deltaComments-commentsCount);
}

-(SDTModule*)findModuleByLineNumber:(NSInteger)line {
    
    
    NSInteger relativeLineNumber=line-self.line;
    
    if(relativeLineNumber<0) {
        return nil;
    }
    
    for (SDTModule* subModule in self.imports) {
        
        if(!subModule.isBlockComment) {
            SDTModule* module=[subModule findModuleByLineNumber:line];
            if(module!=nil) {
                return module;
            }
            
        }
        
    }
    
    if(relativeLineNumber<self.numberOfLines) {
        return self;
    }
    
    return nil;
}

-(BOOL)hasImports {
    return [self.imports count]>0;
}

-(NSInteger)takesNumberOfLines {
    if(self.isBlockComment) return 1;
    
    NSInteger count=0;
    for (SDTModule* subModule in self.imports) {
        count+=[subModule takesNumberOfLines]-1;
    }
    
    return count+self.internalNumberOfLines;
    
}

-(NSString*)resolveModulePath:(NSString*)relativeFilePath basePath:(NSString*)baseFilePath {

    NSString* pluginsRoot=[(NSURL*)objc_msgSend(NSClassFromString(@"MSPlugin"),NSSelectorFromString(@"pluginsURL")) path];
    
    NSString* scriptRoot=[baseFilePath stringByDeletingLastPathComponent];
    NSMutableArray* route=[NSMutableArray arrayWithArray:[[scriptRoot stringByReplacingOccurrencesOfString:pluginsRoot withString:@""] componentsSeparatedByString:@"/"]];

    NSInteger count=route.count;
    for(int i=0;i<count;i++) {
        
        NSString* basePath=[pluginsRoot stringByAppendingString:[route componentsJoinedByString:@"/"]];
        NSString* resolvedPath=[relativeFilePath sdt_resolvePath:basePath];
        if([[NSFileManager defaultManager] fileExistsAtPath:resolvedPath]) {
            return resolvedPath;
            break;
        }
        
        [route removeLastObject];
    }
    
    return nil;
}

-(SDTModule*)parseImports:(NSString*)source withBaseURL:(NSURL*)base {
    
    self.source=source;
    
    self.internalNumberOfLines=[source sdt_numberOfLines];
    self.numberOfLines=[source sdt_numberOfLines];
    
    NSInteger commentLines=0;
    NSInteger commentsCount=0;
    
    // TDTokenizer *tokenizer  = [TDTokenizer tokenizerWithString:source];
    id tokenizer = objc_msgSend(NSClassFromString(@"TDTokenizer"),NSSelectorFromString(@"tokenizerWithString:"),source);
    
    // [[tokenizer whitespaceState] setReportsWhitespaceTokens:YES];
    objc_msgSend(objc_msgSend(tokenizer,NSSelectorFromString(@"whitespaceState")),NSSelectorFromString(@"setReportsWhitespaceTokens:"),YES);
    
    // [[tokenizer commentState] setReportsCommentTokens:YES];
    objc_msgSend(objc_msgSend(tokenizer,NSSelectorFromString(@"commentState")),NSSelectorFromString(@"setReportsCommentTokens:"),YES);
    
    
    
    // TDToken *eof = [TDToken EOFToken];
    id eof = objc_msgSend(NSClassFromString(@"TDToken"),NSSelectorFromString(@"EOFToken"));
    
    // TDToken *tok = nil;
    id tok = nil;
    
    if(self.parent!=nil) {
        
        NSInteger line=0;
        for (SDTModule* sibling in self.parent.imports) {
            if(!sibling.isBlockComment) {
                line+=[sibling takesNumberOfLines];
                line-=1;
            }
        }
        
        self.line+=line;
        self.line+=self.parent.line;
    } else {
        self.line=1;
    }
    
    BOOL lastWasAtSym = NO;
    NSMutableString *collector = [NSMutableString string];
    
    // while ((tok = [tokenizer nextToken]) != eof) {
    while ((tok = objc_msgSend(tokenizer,NSSelectorFromString(@"nextToken"))) != eof) {
        
        // is block comment.
        // if([tok isComment] && ([[tok stringValue] rangeOfString:@"/*"].location!=NSNotFound)) {
        if(objc_msgSend(tok,NSSelectorFromString(@"isComment")) && ([[tok stringValue] rangeOfString:@"/*"].location!=NSNotFound) && false) {
            
            NSInteger currentLine=[collector sdt_numberOfLines];
            
            commentLines+=[[tok stringValue] sdt_numberOfLines];
            commentsCount++;
            
            SDTModule* module=[[SDTModule alloc] init];
            module.url=[[NSURL alloc] initFileURLWithPath:@"/"];
            module.isBlockComment=true;
            module.line=0;
            
            
            {
                NSInteger line=0;
                for (SDTModule* sibling in self.imports) {
                    if(!sibling.isBlockComment) {
                        line+=[sibling takesNumberOfLines];
                        line-=1;
                        
                    }
                    
                }
                
                module.line+=line;
                module.line+=currentLine+1;
                module.line+=self.line;
            }
            
            
            module.internalLine=currentLine+1;
            module.internalNumberOfLines=[[tok stringValue] sdt_numberOfLines];
            module.numberOfLines=[[tok stringValue] sdt_numberOfLines];
            [self.imports addObject:module];
            
        } else {
            [collector appendString:[tok stringValue]];
        }
        
        // if ([tok isSymbol] && [[tok stringValue] isEqualToString:@"#"]) {
        if (objc_msgSend(tok,NSSelectorFromString(@"isSymbol")) && [[tok stringValue] isEqualToString:@"#"]) {
            lastWasAtSym = YES;
        }
        else {
            
            if (lastWasAtSym) {
                lastWasAtSym = NO;
                
                // if ([tok isWord] && [[tok stringValue] isEqualToString:@"import"]) {
                if (objc_msgSend(tok,NSSelectorFromString(@"isWord")) && [objc_msgSend(tok,NSSelectorFromString(@"stringValue")) isEqualToString:@"import"]) {
                    // OK, big assumptions here.  We're going to get some whitespace, adn then a quote, and then a newline.  And that's it.
                    
                    // [tokenizer nextToken]; // the space
                    objc_msgSend(tokenizer,NSSelectorFromString(@"nextToken"));
                    
                    // NSString *pathInQuotes = [[tokenizer nextToken] stringValue];
                    NSString *pathInQuotes = [objc_msgSend(tokenizer,NSSelectorFromString(@"nextToken")) stringValue];
                    
                    NSString *path = [pathInQuotes substringWithRange:NSMakeRange(1, [pathInQuotes length]-2)];
                    if (base) {
                        
                        NSInteger curLine=[collector sdt_numberOfLines];
                        
                        NSString* resolvedModulePath=[self resolveModulePath:path basePath:[base path]];
                        
                        if (resolvedModulePath) {
                            NSURL *importURL = [NSURL fileURLWithPath:resolvedModulePath];
                            
                            [SketchConsole reportValidImport:resolvedModulePath atFile:[self.url path] atLine:curLine];
                            
                            NSString* subScriptSource=[NSString stringWithContentsOfURL:importURL encoding:NSUTF8StringEncoding error:nil];
                            SDTModule* subModule=[[SDTModule alloc] initWithScriptSource:subScriptSource baseURL:base parent:self startLine:curLine-1 url:importURL];
                            // subModule.url=importURL;
                            [self.imports addObject:subModule];
                            
                        }
                        else {
                            // [buffer appendFormat:@"'Unable to import %@ becase %@'", path, [outErr localizedFailureReason]];
                            NSDictionary* importExceptionInfo =
                            @{
                              @"url": self.url,
                              @"line": @(curLine),
                              @"path": path
                            };
                            
                            [SketchConsole reportBrokenImport:importExceptionInfo];
                        }
                        
                        
                        //debug(@"importURL: '%@'", importURL);
                        
                    }
                    else {
                        // [buffer appendFormat:@"'Unable to import %@ becase we have no base url to import from'", path];
                    }
                    
                    // debug(@"[tok stringValue]: '%@'", path);
                    
                    
                    continue;
                }
                else {
                    // [buffer appendString:@"#"];
                    
                    
                }
                
            }
            
            /*
             [buffer appendString:[tok stringValue]];
             [tempBuffer appendString:[tok stringValue]];
             */
            
        }
        
    }
    
    // Block comments corretion.
    if(true) {
        self.internalNumberOfLines-=commentLines;
        self.internalNumberOfLines+=commentsCount;
    }
    
    self.numberOfLines=[self takesNumberOfLines];
    
    
    return self;
};



-(NSDictionary*)treeAsDictionary {
    
    NSMutableArray* subModules=[NSMutableArray array];
    for (SDTModule* subModule in self.imports) {
        [subModules addObject:[subModule treeAsDictionary]];
    }
    
    NSDictionary* dict=@{
                         @"isComment": [NSNumber numberWithBool:self.isBlockComment],
                         @"url": self.url,
                         @"line": [NSNumber numberWithInteger:self.line],
                         @"internalLine": [NSNumber numberWithInteger:self.internalLine],
                         @"numberOfLines": [NSNumber numberWithInteger:self.numberOfLines],
                         @"internalNumberOfLines": [NSNumber numberWithInteger:self.internalNumberOfLines],
                         @"imports": subModules
                         };
    
    return dict;
}

-(NSString*)description {
    
    NSDictionary* dict=@{
                         @"isComment": [NSNumber numberWithBool:self.isBlockComment],
                         @"url": self.url,
                         @"line": [NSNumber numberWithInteger:self.line],
                         @"internalLine": [NSNumber numberWithInteger:self.internalLine],
                         @"numberOfLines": [NSNumber numberWithInteger:self.numberOfLines],
                         };
    
    return [dict description];
}


-(NSString*)sourceCodeForLine:(NSInteger)line {
    
    // Decrement line number for 0...count base format.
    line-=1;
    
    NSArray* lines=[self.source componentsSeparatedByString:@"\n"];
    if(line<0 || line>lines.count) {
        return @"NONE";
    }
    
    return lines[line];
}

@end
