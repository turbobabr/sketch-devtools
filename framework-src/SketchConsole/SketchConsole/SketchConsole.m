//
//  SketchConsole.m
//  SketchConsole
//
//  Created by Andrey on 21/08/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import "SketchConsole.h"
#import <objc/runtime.h>

#import "MMMarkdown.h"

#import <WebKit/WebKit.h>
#import "COSPreprocessorReplacement.h"
#import "SDTSwizzle.h"

#import "SDTModule.h"
#import "NSString+SketchDevTools.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"



@implementation NSView (SketchConsole)

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



@implementation SketchConsole

+(void)load {
    [self swizzleMSPluginMethods];
}

+(void)swizzleMSPluginMethods {
    static dispatch_once_t onceToken;
    
    
    dispatch_once(&onceToken, ^{
        
        [SDTSwizzle swizzleMethod:@selector(print:) withMethod:@selector(print:) sClass:[self class] pClass:NSClassFromString(@"MSPlugin") originalMethodPrefix:@"originalMSPlugin_"];
        
        /*
        Class selfClass = [self class];
        Class pluginClass = NSClassFromString(@"MSPlugin");
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        
        SEL originalSelector = @selector(print:);
        SEL swizzledSelector = @selector(print:);
        
        Method originalMethod = class_getInstanceMethod(pluginClass, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(selfClass, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(selfClass,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        
        // [SketchConsole printGlobal:[NSString stringWithFormat:@"MSPLUGIN - DID ADD METHOD: %d",didAddMethod]];
        
        
        if (didAddMethod) {
            class_replaceMethod(selfClass,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }

        class_addMethod(pluginClass,
                        NSSelectorFromString(@"MSPluginPrint"),
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
         */
        
    });
    
}

+(NSDictionary*)getExternalFiles:(NSURL*)scriptURL {

    // Консоль
    NSURL* pluginFolderURL=[scriptURL URLByDeletingLastPathComponent];
    return @{
             @"folder": pluginFolderURL,
             @"index": [pluginFolderURL URLByAppendingPathComponent:@"index.html"]
             };

    
    // Времяночка, чтобы попробовать отобразить плагины! :)
    /*
    NSURL* pluginFolderURL=[scriptURL URLByDeletingLastPathComponent];
    return @{
             @"folder": pluginFolderURL,
             @"index": [pluginFolderURL URLByAppendingPathComponent:@"plugins.html"]
             };
     */

}

+(NSView*)getCurrentContentView {
    NSDocumentController* controller=[NSDocumentController sharedDocumentController];
    NSDocument* doc=controller.currentDocument;
    if(doc==nil) return nil;
    
    return doc.windowForSheet.contentView;
}


+(SketchConsole*)sharedInstance {
    static dispatch_once_t once;
    static SketchConsole *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

@synthesize options = _options;  //Must do this

//Setter method
- (void) setOptions:(NSDictionary *)options {
    NSURL* fileURL=[[self.scriptURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"consoleOptions.json"];
    
    NSString* jsonOptions=[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:options options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    [jsonOptions writeToURL:fileURL atomically:false encoding:NSUTF8StringEncoding error:nil];
    
    _options = options;
}

//Getter method
- (NSDictionary*) options {
    
    NSURL* fileURL=[[self.scriptURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"consoleOptions.json"];
    
    if(_options==nil) {
        if([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
            NSString* jsonOptions=[NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:nil];
            _options=[NSJSONSerialization JSONObjectWithData:[jsonOptions dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        }
    }
    
    return _options;
}




+(BOOL)initConsole:(NSURL*)scriptURL {
    
    [SketchConsole sharedInstance].scriptURL=scriptURL;
    
    // Initialize Panel
    NSView* contentView=[self getCurrentContentView];
    if(contentView==nil) return false;
    
    int viewHeight=contentView.frame.size.height;
    int defaultConsoleHeight=[self defaultConsoleHeight];
    if(viewHeight/2<defaultConsoleHeight) defaultConsoleHeight=viewHeight/2;
    
    // Create WebView
    WebView* webView = [[WebView alloc] init];
    [webView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    webView.identifier=@"idConsoleWebView";
    
    // Create SplitView for substitution
    NSSplitView* splitView = [[NSSplitView alloc] initWithFrame:[contentView bounds]];
    splitView.autoresizingMask=NSViewWidthSizable | NSViewHeightSizable;
    splitView.identifier=@"idSketchDevToolsSplitter";
    
    
    NSSplitView* originalSplitView=contentView.subviews[0];
    
    [splitView addSubview:originalSplitView];
    [splitView addSubview:webView];
    
    [splitView adjustSubviews];
    
    // Replace default split view with the custom one.
    contentView.subviews=@[splitView];
    
    // Set position.
    [splitView setPosition:viewHeight-defaultConsoleHeight ofDividerAtIndex:0];
    
    
    // Expose script executer!
    id win = [webView windowScriptObject];
    [win setValue:[[SketchConsole alloc] init] forKey:@"SketchDevTools"];
    
    // Load web-page and initialize console.
    NSDictionary* files=[self getExternalFiles:scriptURL];
    NSString* indexPageContents=[NSString stringWithContentsOfFile:[files[@"index"] path] encoding:NSUTF8StringEncoding error:nil];
    [[webView mainFrame] loadHTMLString:indexPageContents baseURL:files[@"folder"]];
    
    return true;
}

+(BOOL)isConsoleInitialized {
    return ([self findWebView]==nil ? false : true);
}


+(id)persistentStorageGetValueForKey:(NSString*)key {
    NSDictionary* persistent = [[NSThread mainThread] threadDictionary];
    return persistent[key];
}

+(void)persistentStorageSetValue:(id)value forKey:(NSString*)key {
    NSDictionary* persistent = [[NSThread mainThread] threadDictionary];
    [persistent setValue:value forKey:key];
}

+(int)defaultConsoleHeight {
    
    int defaultValue=300;
    
    NSString* docObjectID=[self crrentDocumentObjectID];
    if(docObjectID==nil) return defaultValue;
    
    NSNumber* value=[self persistentStorageGetValueForKey:[NSString stringWithFormat:@"SketchDevTools-ConsoleHeight-%@",docObjectID]];
    if(value==nil) {
        return defaultValue;
    }
    
    return value.intValue;
}

+(void)saveDefaultConsoleHeight:(int)height {
    
    NSString* docObjectID=[self crrentDocumentObjectID];
    if(docObjectID==nil) return;
    
    [self persistentStorageSetValue:[NSNumber numberWithInt:height] forKey:[NSString stringWithFormat:@"SketchDevTools-ConsoleHeight-%@",docObjectID]];
    
}

+(void)ensureConsoleVisible {
    
    NSNumber* showConsoleOnError=[SketchConsole sharedInstance].options[@"showConsoleOnError"];
    if(![showConsoleOnError boolValue]) {
        return;
    }
    
    NSView* contentView=[SketchConsole getCurrentContentView];
    if(contentView==nil) return;
    
    int defaultConsoleHeight=[self defaultConsoleHeight];
    int viewHeight=contentView.frame.size.height;
    
    NSSplitView* splitView=(NSSplitView*)[[SketchConsole getCurrentContentView] subviewWithID:@"idSketchDevToolsSplitter"];
    if(splitView==nil) return;
    
    WebView* webView=[SketchConsole findWebView];
    if(webView==nil) return;
    
    if(webView.frame.size.height==0) {
        [splitView setPosition:viewHeight-defaultConsoleHeight ofDividerAtIndex:0];
    }
}

+(void)showHideConsole:(NSURL*)scriptURL {
    
    if(![self isConsoleInitialized]) {
        [self initConsole:scriptURL];
        return;
    }
    
    NSView* contentView=[self getCurrentContentView];
    if(contentView==nil) return;
    
    int defaultConsoleHeight=[self defaultConsoleHeight];
    int viewHeight=contentView.frame.size.height;
    
    NSSplitView* splitView=(NSSplitView*)[[self getCurrentContentView] subviewWithID:@"idSketchDevToolsSplitter"];
    if(splitView==nil) return;
    
    WebView* webView=[self findWebView];
    if(webView==nil) return;
    
    if(webView.frame.size.height==0) {
        
        [splitView setPosition:viewHeight-defaultConsoleHeight ofDividerAtIndex:0];
        
    } else {
        [self saveDefaultConsoleHeight:webView.frame.size.height];
        [splitView setPosition:viewHeight ofDividerAtIndex:0];
    }
}

-(void)hideConsole {
    NSView* contentView=[SketchConsole getCurrentContentView];
    if(contentView==nil) return;

    int viewHeight=contentView.frame.size.height;
    
    NSSplitView* splitView=(NSSplitView*)[[SketchConsole getCurrentContentView] subviewWithID:@"idSketchDevToolsSplitter"];
    if(splitView==nil) return;
    
    WebView* webView=[SketchConsole findWebView];
    if(webView==nil) return;
    
    [SketchConsole saveDefaultConsoleHeight:webView.frame.size.height];
    [splitView setPosition:viewHeight ofDividerAtIndex:0];
}


+(NSDictionary*)getLineInfo:(NSUInteger)lineNumber source:(NSString*)sourceScript withBaseURL:(NSURL*)base {
    
    SDTModule* root=[[SDTModule alloc] initWithScriptSource:sourceScript baseURL:base parent:nil startLine:0];
    SDTModule* module=[root findModuleByLineNumber:lineNumber];
    if(module) {
        
        // [SketchConsole printGlobal:[root treeAsDictionary]];
        
        return @{
                 @"line": [NSNumber numberWithInteger:[module relativeLineByAbsolute:lineNumber]],
                 @"module": module
                 };
    }
    
    
    
    return nil;
    
}



+(void)printGlobal:(id)s {
    
    if (![s isKindOfClass:[NSString class]]) {
        s = [s description];
    }
    
    
    NSString* logFilePath=@"/Users/andrey/Library/Application Support/com.bohemiancoding.sketch3/Plugins/AnnotationKit/temp/log.txt";
    
    NSString* log=[NSString stringWithContentsOfFile:logFilePath encoding:NSUTF8StringEncoding error:NULL];
    
    
    log=[log stringByAppendingString:@"\n"];
    log=[log stringByAppendingString:s];
    
    
    [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:[log dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

+(void)printGlobalEx:(id)s {
    
    if (![s isKindOfClass:[NSString class]]) {
        s = [s description];
    }
    
    
    NSString* logFilePath=@"/Users/andrey/Library/Application Support/com.bohemiancoding.sketch3/Plugins/AnnotationKit/temp/log.txt";
    
    [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:[s dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}


+(WebView*)findWebView {
    NSView* contentView=[self getCurrentContentView];
    if(contentView==nil) return nil;
    
    NSView* splitter=[contentView subviewWithID:@"idSketchDevToolsSplitter"];
    if(splitter) {
        return (WebView*)[splitter subviewWithID:@"idConsoleWebView"];
        
    } else {
        return nil;
    }
    
    return nil;
}

+(NSString*)crrentDocumentObjectID {
    NSDocumentController* controller=[NSDocumentController sharedDocumentController];
    NSDocument* doc=controller.currentDocument;
    
    if([doc respondsToSelector:NSSelectorFromString(@"documentData")]) {
        id docData=[doc performSelector:NSSelectorFromString(@"documentData")];
        if(docData) {
            if([docData respondsToSelector:NSSelectorFromString(@"objectID")]) {
                NSString* objectID=[docData performSelector:NSSelectorFromString(@"objectID")];
                return objectID;
            }
        }
    }
    
    return nil;
}

+(BOOL)isMochaError:(NSString*)s {
    
    NSDictionary* errors=@{
                           @"MethodArgumentsError": @[@"ObjC method ",@" requires ",@" but JavaScript passed "],
                           @"MethodNotFoundError": @[@"Unable to locate method ",@" of class "],
                           @"MethodParseEncodingError": @[@"Unable to parse method encoding for method ",@" of class "],
                           @"BlockArgumentsError": @[@"Block requires ",@", but JavaScript passed "],
                           @"FunctionNotFoundError": @[@"Unable to find function with name: "],
                           @"CFunctionArgumentsError": @[@"C function ",@" requires ",@", but JavaScript passed "]
                           };
    
    for (NSString* key in errors) {
        NSArray* error=[errors objectForKey:key];
        
        NSInteger passed=0;
        for(NSString* part in error) {
            if([s rangeOfString:part].location!=NSNotFound) {
                passed++;
            }
            
            if(passed==error.count) {
                return true;
            }
        }
        
    }
    
    return false;
}

+(BOOL)isError:(NSString*)s {
    
    NSInteger customErrorLocation=[s rangeOfString:@"Error: "].location;
    if(customErrorLocation!= NSNotFound && customErrorLocation==0) {
        return true;
    }
    
    if([s rangeOfString:@"ReferenceError: "].location != NSNotFound) {
        return true;
    }
    
    if([s rangeOfString:@"TypeError: "].location != NSNotFound) {
        return true;
    }
    
    if([s rangeOfString:@"SyntaxError: "].location != NSNotFound) {
        return true;
    }
    
    if([s rangeOfString:@"RangeError: "].location != NSNotFound) {
        return true;
    }
    
    if([s rangeOfString:@"EvalError: "].location != NSNotFound) {
        return true;
    }
    
    if([s rangeOfString:@"InternalError: "].location != NSNotFound) {
        return true;
    }
    
    if([s rangeOfString:@"URIError: "].location != NSNotFound) {
        return true;
    }
    
    return false;
}

-(void)print:(id)s {
    
    SketchConsole* shared=[SketchConsole sharedInstance];
    
    // Invoke original MSPlugin.print() method.
    if ([self respondsToSelector:NSSelectorFromString(@"originalMSPlugin_print")]) {
        [self performSelector:NSSelectorFromString(@"originalMSPlugin_print") withObject:s];
    } else {
        [SketchConsole printGlobal:@"Does not respond to selector!"];
    }
    
    
    // If logged value is an object we should convert it to a string.
    if (![s isKindOfClass:[NSString class]]) {
        // s = [s description];
        
        s = [[s description] sdt_escapeHTML];
    }
    
    WebView* webView =[SketchConsole findWebView];
    if(webView==nil) {
        // [SketchConsole printGlobal:@"ERROR: CAN'T FIND WEB VIEW!!!"];
        return;
    }
    
    NSString* pluginName=[self performSelector:NSSelectorFromString(@"name")];
    NSURL* pluginFileURL=[self performSelector:NSSelectorFromString(@"url")];
    NSURL* pluginsRootURL=[self performSelector:NSSelectorFromString(@"root")];
    
    
    // Process Mocha errors.
    if([SketchConsole isMochaError:s]) {
        NSArray *args = @[s,pluginName,[pluginFileURL path],[pluginsRootURL path]];
        
        [SketchConsole ensureConsoleVisible];
        
        id win = [webView windowScriptObject];
        [win callWebScriptMethod:@"addMochaErrorItem" withArguments:args];
        
        return;
    }
    
    // Process JavaScript standard errors.
    if([SketchConsole isError:s]) {
        
        NSArray* parts = [s componentsSeparatedByString:@"\n"];
        
        NSInteger (^findIntProperty)(NSString* propertyName) = ^NSInteger(NSString* propertyName) {
            NSInteger value=0;
            for (NSString* line in parts) {
                if([line rangeOfString:propertyName].location!=NSNotFound) {
                    value = [[line stringByReplacingOccurrencesOfString:propertyName withString:@""] integerValue];
                    return value;
                }
            }
            
            return 0;
        };
        
        NSString* (^findStringProperty)(NSString* propertyName) = ^NSString*(NSString* propertyName) {
            for (NSString* line in parts) {
                if([line rangeOfString:propertyName].location!=NSNotFound) {
                    return [line stringByReplacingOccurrencesOfString:propertyName withString:@""];
                }
            }
            return nil;
        };
        
        
        NSInteger lineNumber=findIntProperty(@"line: ");
        
        NSString* errorType=@"Unknown";
        NSString* errorMessage=@"Not Found";
        
        // Check for custom error generated by "throw Error()" code.
        NSInteger customErrorLocation=[s rangeOfString:@"Error: "].location;
        if(customErrorLocation!=NSNotFound && customErrorLocation==0) {
            errorType=@"CustomError";
            errorMessage=findStringProperty(@"Error: ");
        } else {
            // Standard JS errors.
            NSArray* errors=@[@"ReferenceError: ",@"TypeError: ",@"SyntaxError: ",@"RangeError: ",@"EvalError: ",@"InternalError: ",@"URIError: "];
            for (NSString* error in errors) {
                
                errorMessage=findStringProperty(error);
                if(errorMessage!=nil) {
                    errorType=[error stringByReplacingOccurrencesOfString:@": " withString:@""];
                    break;
                }
            }
        }
        
        
        NSString* script=[self performSelector:NSSelectorFromString(@"script")];
        NSString* processedScript=[self performSelector:NSSelectorFromString(@"processedScript")];
        // [SketchConsole printGlobalEx:processedScript];
    
        
        NSArray* lines=[processedScript componentsSeparatedByString:@"\n"];
        NSString* errorLineContents=lines[lineNumber-1];
        
        
        NSString* exceptionInfo=@"Not Defined!";
        
        NSDictionary* lineInfo=[SketchConsole getLineInfo:lineNumber source:script withBaseURL:pluginFileURL];
        // [SketchConsole printGlobal:[lineInfo description]];
        
        // Получаем актуальную строку с ошибкой.
        {
            NSURL* fileURL=[lineInfo[@"module"] url];
            
            // Если файл в котором возникла ошибка не является кастомным плагином, то мы берем строку
            // с ошибкой из актуального файла а не из скрипта.
            if([[fileURL path] rangeOfString:@"/Plugins/Untitled.sketchplugin"].location==NSNotFound) {
                NSString* fileContents=[NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:nil];
                NSArray* sourceFileLines=[fileContents componentsSeparatedByString:@"\n"];
                
                errorLineContents=sourceFileLines[[lineInfo[@"line"] integerValue]-1];
            } else {
                
                // В случае если ошибка возникла в кастомном скрипте, то мы берем строку кода с ошибкой
                // из скомпилированного скрипта предоставленного классом MSPlugin.
                NSArray* sourceFileLines=[processedScript componentsSeparatedByString:@"\n"];
                errorLineContents=sourceFileLines[[lineInfo[@"line"] integerValue]-1];
            }
            
            
        }
        
        if(lineInfo!=nil) {
            exceptionInfo = [NSString stringWithFormat:@"%@ : %@",[[lineInfo[@"module"] url] lastPathComponent],[lineInfo[@"line"] stringValue]];
        }
        
        NSArray *args = @[errorType,errorMessage,[[lineInfo[@"module"] url] path],[lineInfo[@"line"] stringValue],errorLineContents];

        [SketchConsole ensureConsoleVisible];
        
        id win = [webView windowScriptObject];
        [win callWebScriptMethod:@"addErrorItem" withArguments:args];
        
        // [SketchConsole printGlobal:@"THIS IS CALLED FROM ERROR HANDLER!"];
        
    } else {
        // NSArray *args = [NSArray arrayWithObjects:@"print",s,pluginName,[pluginFileURL path],[pluginsRootURL path],nil];
        NSArray *args = @[s,pluginName,[pluginFileURL path],[pluginsRootURL path]];
        
        id win = [webView windowScriptObject];
        [win callWebScriptMethod:@"addPrintItem" withArguments:args];
        
        // [SketchConsole printGlobal:@"THIS IS CALLED FROM PRINT HANDLER!"];
        
    }
    
    
    
    // Scroll to the bottom.
    // [webView scrollToEndOfDocument:self];
}

-(void)execScript:(NSString*)script {
    
    id plugin = [NSClassFromString(@"MSPlugin") alloc];
    
    plugin = [plugin performSelector:NSSelectorFromString(@"initWithScript:name:") withObject:script withObject:@"My Script"];
    [plugin performSelector:NSSelectorFromString(@"processScript")];
    [plugin performSelector:NSSelectorFromString(@"run")];
    
}

- (void)coscript:(id)coscript hadError:(NSString*)error onLineNumber:(NSInteger)lineNumber atSourceURL:(id)url {
    // [self print:error];
}

+(void)clearConsole {
    
    WebView* webView =[SketchConsole findWebView];
    if(webView==nil) {
        // [SketchConsole printGlobal:@"ERROR: CAN'T FIND WEB VIEW!!!"];
        return;
    }
    
    if(webView) {
        id win = [webView windowScriptObject];
        NSArray *args = @[];
        [win callWebScriptMethod:@"clearConsole" withArguments:args];
    }
}

-(void)openURL:(NSString*)url {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

-(NSString*)getConsoleOptions {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[SketchConsole sharedInstance].options options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
}

-(void)setConsoleOptions:(NSString*)options {
    [SketchConsole sharedInstance].options=[NSJSONSerialization JSONObjectWithData:[options dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
}

+ (NSString *) webScriptNameForSelector:(SEL)sel
{
    NSString* name=@"";
    
    if (sel == @selector(execScript:))
        name = @"execScript";
    
    if (sel == @selector(hideConsole))
        name = @"hideConsole";
    
    if (sel == @selector(getLineInfo:source:withBaseURL:))
        name = @"getLineInfo";
    
    if (sel == @selector(openURL:))
        name = @"openURL";
    
    if (sel == @selector(getConsoleOptions))
        name = @"getConsoleOptions";
    
    if (sel == @selector(setConsoleOptions:))
        name = @"setConsoleOptions";
    
    if (sel == @selector(showCustomScriptWindow:))
        name = @"showCustomScriptWindow";
    
    
    
    return name;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel
{
    if (sel == @selector(execScript:)) return NO;
    if (sel == @selector(hideConsole)) return NO;
    if (sel == @selector(getLineInfo:source:withBaseURL:)) return NO;
    if (sel == @selector(openURL:)) return NO;
    if (sel == @selector(getConsoleOptions)) return NO;
    if (sel == @selector(setConsoleOptions:)) return NO;
    if (sel == @selector(showCustomScriptWindow:)) return NO;
    
    return YES;
}


-(void)showCustomScriptWindow:(NSInteger)lineNumber {
    // Отображаем диалог с кастомным скриптом и получаем на него ссылку.
    NSWindowController* sheet=objc_msgSend(NSClassFromString(@"MSRunCustomScriptSheet"),NSSelectorFromString(@"runForWindow:"),[[NSApplication sharedApplication] mainWindow]);
    
    NSTextView* (^findScriptTextView)(void) = ^NSTextView*(void) {
        
        NSView* logView=objc_msgSend(sheet,NSSelectorFromString(@"logField"));
        
        NSArray* views=[(NSView*)sheet.window.contentView subviews];
        for (NSView* view in views) {
            if([view.className isEqualToString:@"NSSplitView"]) {
                
                for (NSScrollView* splitSubView in view.subviews) {
                    NSView* documentView=splitSubView.documentView;
                    if([documentView.className isEqualToString:@"NSTextView"] && ![documentView.identifier isEqualToString:logView.identifier]) {
                        return (NSTextView*)documentView;
                    }
                }
            }
        }
        
        return nil;
    };

    NSTextView* textView=findScriptTextView();
    if(textView!=nil) {
        NSString* text=textView.textStorage.string;
        NSArray* lines=[text componentsSeparatedByString:@"\n"];
        
        NSInteger count=0;
        for(int i=0;i<lineNumber-1;i++) {
            count+=[(NSString*)lines[i] length]+1;
        }
        
        NSRange selectedrange=NSMakeRange(count, [lines[lineNumber-1] length]);
        [textView setSelectedRange:selectedrange];
        [textView scrollRangeToVisible:selectedrange];
    }
    
};

@end

#pragma clang diagnostic pop
