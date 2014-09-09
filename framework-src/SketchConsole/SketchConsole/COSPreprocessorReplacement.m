//
//  COSPreprocessorReplacement.m
//  SketchConsole
//
//  Created by Andrey on 26/08/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import <objc/runtime.h>
#import "COSPreprocessorReplacement.h"
#import "SketchConsole.h"
#import "SDTSwizzle.h"
#import "NSString+SketchDevTools.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"



@implementation COSPreprocessorReplacement

+(void)load {
    
    // [SketchConsole printGlobal:@"COSPreprocessorReplacement:load!"];

    [self swizzle_processCode];
    // [self swizzle_processImports];
}

+(void)swizzle_processCode {
    static dispatch_once_t COPreprocessorOnceToken;
    dispatch_once(&COPreprocessorOnceToken, ^{
        
        [SDTSwizzle swizzleClassMethod:@selector(preprocessCode:withBaseURL:) withMethod:@selector(preprocessCode:withBaseURL:) sClass:self pClass:NSClassFromString(@"COSPreprocessor") originalMethodPrefix:@"originalCOSPreprocessor_"];
        
        
        [SDTSwizzle swizzleClassMethod:@selector(preprocessForObjCStrings:) withMethod:@selector(preprocessForObjCStrings:) sClass:self pClass:NSClassFromString(@"COSPreprocessor") originalMethodPrefix:@"originalCOSPreprocessor_"];
        
        /*
        Class selfClass = object_getClass((id)self);
        Class pluginClass = object_getClass((id)NSClassFromString(@"COSPreprocessor"));
        
        SEL originalSelector = @selector(preprocessCode:withBaseURL:);
        SEL swizzledSelector = @selector(preprocessCode:withBaseURL:);
        
        Method originalMethod = class_getClassMethod(pluginClass, originalSelector);
        Method swizzledMethod = class_getClassMethod(selfClass, swizzledSelector);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
        class_addMethod(pluginClass,
                        NSSelectorFromString(@"originalPreprocessCode:withBaseURL:"),
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
         */
        
    });

}

+(void)swizzle_processImports {
    static dispatch_once_t COPreprocessorOnceToken;
    dispatch_once(&COPreprocessorOnceToken, ^{
        
        Class selfClass = object_getClass((id)self);
        Class pluginClass = object_getClass((id)NSClassFromString(@"COSPreprocessor"));
        
        SEL originalSelector = @selector(processImports:withBaseURL:);
        SEL swizzledSelector = @selector(processImports:withBaseURL:);
        
        Method originalMethod = class_getClassMethod(pluginClass, originalSelector);
        Method swizzledMethod = class_getClassMethod(selfClass, swizzledSelector);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
        class_addMethod(pluginClass,
                        NSSelectorFromString(@"originalProcessImports:withBaseURL:"),
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
    });
    
}


+ (NSString*)preprocessForObjCStrings:(NSString*)sourceString {
    NSMutableString *buffer = [NSMutableString string];
    // TDTokenizer *tokenizer  = [TDTokenizer tokenizerWithString:sourceString];
    
    id tokenizer  = objc_msgSend(NSClassFromString(@"TDTokenizer"),NSSelectorFromString(@"tokenizerWithString:"),sourceString);
    
    /*
    tokenizer.whitespaceState.reportsWhitespaceTokens = YES;
    tokenizer.commentState.reportsCommentTokens = NO;
     */
    
    // [[tokenizer whitespaceState] setReportsWhitespaceTokens:YES];
    objc_msgSend(objc_msgSend(tokenizer,NSSelectorFromString(@"whitespaceState")),NSSelectorFromString(@"setReportsWhitespaceTokens:"),YES);
    
    // [[tokenizer commentState] setReportsCommentTokens:YES];
    objc_msgSend(objc_msgSend(tokenizer,NSSelectorFromString(@"commentState")),NSSelectorFromString(@"setReportsCommentTokens:"),YES);

    // TDToken *eof = [TDToken EOFToken];
    id eof = objc_msgSend(NSClassFromString(@"TDToken"),NSSelectorFromString(@"EOFToken"));
    //TDToken *tok                    = nil;
    id tok = nil;
    id nextToken = nil;
    
    while ((tok = objc_msgSend(tokenizer,NSSelectorFromString(@"nextToken"))) != eof) {
        
        if (objc_msgSend(tok,NSSelectorFromString(@"isComment"))) {
            
            if([[tok stringValue] rangeOfString:@"/*"].location!=NSNotFound) {
                
                NSInteger numLines=[[tok stringValue] sdt_numberOfLines];
                NSMutableString* nastyComment=[NSMutableString string];
                for(int i=0;i<numLines;i++) {
                    
                    [nastyComment appendString:(i<numLines-1) ? @"// I will never ever remove block comments! (c) Gus Mueller :)\n" : @"// I will never ever remove block comments! (c) Gus Mueller :)"];
                }
                
                
                // [SketchConsole printGlobal:[tok stringValue]];
                
                
                [buffer appendString:nastyComment];
            } else {
                
                // nextToken = objc_msgSend(tokenizer,NSSelectorFromString(@"nextToken"));
                // [buffer appendString:@"\n"];
            }
            
        } else if (objc_msgSend(tok,NSSelectorFromString(@"isSymbol")) && [[tok stringValue] isEqualToString:@"@"]) {
            
            // woo, it's special objc stuff.
            
            nextToken = objc_msgSend(tokenizer,NSSelectorFromString(@"nextToken"));
            //if (nextToken.quotedString) {
            if(objc_msgSend(nextToken,NSSelectorFromString(@"quotedString"))) {
                [buffer appendFormat:@"[NSString stringWithString:%@]", [nextToken stringValue]];
            }
            else {
                [buffer appendString:[tok stringValue]];
                [buffer appendString:[nextToken stringValue]];
            }
        }
        else {
            [buffer appendString:[tok stringValue]];
        }
    }
    
    return buffer;
}


+ (NSString*)preprocessCode:(NSString*)sourceString withBaseURL:(NSURL*)base {

/*
    [SketchConsole printGlobal:@"INITIAL:"];
    [SketchConsole printGlobal:@"==========================================================================================="];
    [SketchConsole printGlobal:sourceString];
    [SketchConsole printGlobal:@" "];
    [SketchConsole printGlobal:@" "];
    

    sourceString = objc_msgSend(NSClassFromString(@"COSPreprocessor"),NSSelectorFromString(@"preprocessForObjCStrings:"),sourceString);
    [SketchConsole printGlobal:@"AFTER: preprocessForObjCStrings"];
    [SketchConsole printGlobal:@"==========================================================================================="];
    [SketchConsole printGlobal:sourceString];
    [SketchConsole printGlobal:@" "];
    [SketchConsole printGlobal:@" "];


    
    sourceString = objc_msgSend(NSClassFromString(@"COSPreprocessor"),NSSelectorFromString(@"preprocessForObjCMessagesToJS:"),sourceString);
    [SketchConsole printGlobal:@"AFTER: preprocessForObjCMessagesToJS"];
    [SketchConsole printGlobal:@"==========================================================================================="];
    [SketchConsole printGlobal:sourceString];
    [SketchConsole printGlobal:@" "];
    [SketchConsole printGlobal:@" "];
    
    
    
//    sourceString = [self processImports:sourceString withBaseURL:(NSURL*)base];
//    sourceString = [self processMultilineStrings:sourceString];
//    sourceString = [self preprocessForObjCStrings:sourceString];
//    sourceString = [self preprocessForObjCMessagesToJS:sourceString];
     
    
   //  "<MOMethodDescription: 0x60000063aa40 : selector=preprocessForObjCStrings:, typeEncoding=@24@0:8@16>",
   //  "<MOMethodDescription: 0x60000063aa80 : selector=preprocessForObjCMessagesToJS:, typeEncoding=@24@0:8@16>"
    

    
    return sourceString;
 */

    
    
    NSString* code=@"print('THE CODE IS EMPTY!');";
    /*
    [SketchConsole printGlobal:@"А ТУТ МЕНЯ УЖЕ ПОКОЛЕЧИЛИ!!! :("];
    [SketchConsole printGlobal:sourceString];
     */
    
    // Indicate that we are running a new session.
    SketchConsole* console=[SketchConsole sharedInstance];
    console.isNewSession=true;
    
    
    // Invoke original method.
    if ([self respondsToSelector:NSSelectorFromString(@"originalCOSPreprocessor_preprocessCode:withBaseURL:")]) {
        code=[self performSelector:NSSelectorFromString(@"originalCOSPreprocessor_preprocessCode:withBaseURL:") withObject:sourceString withObject:base];
    }
    
    // Очистка консоли перед запуском каждого плагина.
    if([(NSNumber*)[SketchConsole sharedInstance].options[@"clearConsoleBeforeLaunch"] boolValue]) {
        [SketchConsole clearConsole];
    }
    
    /*
    [SketchConsole printGlobal:@"ИЛИ ТУТ ПОКАЛЕЧИЛИ????????!!! :("];
    [SketchConsole printGlobal:code];
     */
    
    [SketchConsole printGlobalEx:code];
    
    // [SketchConsole printGlobalEx:sourceString];
    
    return code;
}

/*
+ (NSString*)processImports:(NSString*)sourceString withBaseURL:(NSURL*)base {
    
    NSString* code=@"// THIS IS THE BEGINNING!\n";
    
    // Invoke original method.
    if ([self respondsToSelector:NSSelectorFromString(@"originalProcessImports:withBaseURL:")]) {
        code=[self performSelector:NSSelectorFromString(@"originalProcessImports:withBaseURL:") withObject:sourceString withObject:base];
    }
    
    return code;
}



+(NSString*)getLineInfo:(NSUInteger)lineNumber source:(NSString*)sourceScript withBaseURL:(NSURL*)base {
    return @"Unknown";
    
    NSUInteger index=1;
    
    NSArray* blocks=[self processImportsMap:sourceScript withBaseURL:base];
    for (NSDictionary* block in blocks) {
        
        NSUInteger numberOfLines=[block[@"numberOfLines"] integerValue];
        
        if(lineNumber>=index && lineNumber<index+numberOfLines) {
            // return block[@"url"];
            return [NSString stringWithFormat:@"%@ - %lu",block[@"url"],lineNumber-index+1];
        }
        
        index+=numberOfLines;
    }
 
    return @"NO INFO";
}
 */

/*
+ (NSMutableArray*)processImportsMap:(NSString*)sourceString withBaseURL:(NSURL*)base {
    
    NSMutableString *buffer = [NSMutableString string];
    
    NSMutableArray* sourceMap =[NSMutableArray array];

    
    // TDTokenizer *tokenizer  = [TDTokenizer tokenizerWithString:sourceString];
    id tokenizer = objc_msgSend(NSClassFromString(@"TDTokenizer"),NSSelectorFromString(@"tokenizerWithString:"),sourceString);
    
    // [[tokenizer whitespaceState] setReportsWhitespaceTokens:YES];
    objc_msgSend(objc_msgSend(tokenizer,NSSelectorFromString(@"whitespaceState")),NSSelectorFromString(@"setReportsWhitespaceTokens:"),YES);
    
    // [[tokenizer commentState] setReportsCommentTokens:YES];
    objc_msgSend(objc_msgSend(tokenizer,NSSelectorFromString(@"commentState")),NSSelectorFromString(@"setReportsCommentTokens:"),YES);
    
    
    // TDToken *eof = [TDToken EOFToken];
    id eof = objc_msgSend(NSClassFromString(@"TDToken"),NSSelectorFromString(@"EOFToken"));
    //TDToken *tok                    = nil;
    id tok = nil;
    
    BOOL lastWasAtSym = NO;
    
    
    NSMutableString *tempBuffer = [NSMutableString string];
    NSString* currentScript=@"base";
    
    
    // while ((tok = [tokenizer nextToken]) != eof) {
    while ((tok = objc_msgSend(tokenizer,NSSelectorFromString(@"nextToken"))) != eof) {
        
        // if ([tok isSymbol] && [[tok stringValue] isEqualToString:@"@"]) {
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
                    
                    NSString *pathInQuotes = [objc_msgSend(tokenizer,NSSelectorFromString(@"nextToken")) stringValue];
                    // [SketchConsole printGlobal:pathInQuotes];
                    

                    // NSString *pathInQuotes = objc_msgSend(objc_msgSend(tokenizer,NSSelectorFromString(@"nextToken")),NSSelectorFromString(@"stringValue"));

                    
                    NSString *path = [pathInQuotes substringWithRange:NSMakeRange(1, [pathInQuotes length]-2)];
                    
                    
                    
                    
                    
                    if (base) {
                        
                        NSURL *importURL = [[base URLByDeletingLastPathComponent] URLByAppendingPathComponent:path];
                        
                        NSError *outErr = nil;
                        NSString *s = [NSString stringWithContentsOfURL:importURL encoding:NSUTF8StringEncoding error:&outErr];
                        
                        if (s) {
                            // [buffer appendFormat:@"// imported from %@\n", [importURL path]];
                            
                            // Flush current block
                            if(![tempBuffer isEqualToString:@"\n"])
                            {
                                NSDictionary* fileSourceMap=@{
                                                              @"url" : currentScript,
                                                              @"numberOfLines": [NSNumber numberWithInteger:[tempBuffer sdt_numberOfLines]],
                                                              @"code": tempBuffer
                                                              };
                                
                                [sourceMap addObject:fileSourceMap];
                                tempBuffer=[NSMutableString string];
                                
                            } else {
                                tempBuffer=[NSMutableString string];
                            }

                            
                            
                            
                            NSDictionary* fileSourceMap=@{
                                                          @"url" : [importURL path],
                                                          @"numberOfLines": [NSNumber numberWithInteger:[s sdt_numberOfLines]]
                                                          };
                            
                            [sourceMap addObject:fileSourceMap];
                            
                            [buffer appendString:s];

                        }
                        else {
                            [buffer appendFormat:@"'Unable to import %@ becase %@'", path, [outErr localizedFailureReason]];
                        }
                        
                        
                        //debug(@"importURL: '%@'", importURL);
                        
                    }
                    else {
                        [buffer appendFormat:@"'Unable to import %@ becase we have no base url to import from'", path];
                    }
                    
                    // debug(@"[tok stringValue]: '%@'", path);
                    
                    
                    continue;
                }
                else {
                    [buffer appendString:@"#"];
                    
                    
                }
                
            }
            
            [buffer appendString:[tok stringValue]];
            [tempBuffer appendString:[tok stringValue]];
            
        }
        
    }
    
    // Flush current block
    {
        NSDictionary* fileSourceMap=@{
                                      @"url" : currentScript,
                                      @"numberOfLines": [NSNumber numberWithInteger:[tempBuffer sdt_numberOfLines]],
                                      @"code": tempBuffer
                                      };
        
        [sourceMap addObject:fileSourceMap];
        tempBuffer=[NSMutableString string];
        
    }
    
    // return buffer;
    return sourceMap;
    // return tempBuffer;
}
*/

@end

#pragma clang diagnostic pop
