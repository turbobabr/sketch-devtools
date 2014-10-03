//
//  SketchConsole.m
//  SketchConsole
//
//  Created by Andrey on 21/08/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import "SketchConsole.h"
#import <objc/runtime.h>

#import <WebKit/WebKit.h>
#import "SDTSwizzle.h"

#import "SDTModule.h"
#import "NSString+SketchDevTools.h"
#import "NSView+SketchDevTools.h"

#import "SKDProtocolHandler.h"
#import "NSLogger.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"



@implementation SketchConsole

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // [SDTSwizzle swizzleMethod:@selector(scriptWithExpandedImports:path:) withMethod:@selector(scriptWithExpandedImports:path:) sClass:[self class] pClass:NSClassFromString(@"MSPlugin") originalMethodPrefix:@"originalMSPlugin_"];
        
        // Перехват всех ошибок.
        // COScript.printException:
        [SDTSwizzle swizzleMethod:@selector(printException:) withMethod:@selector(printException:) sClass:[self class] pClass:NSClassFromString(@"COScript") originalMethodPrefix:@"originalCOScript_"];
        
        // MSPlugin.run();
        [SDTSwizzle swizzleMethod:@selector(run) withMethod:@selector(run) sClass:[self class] pClass:NSClassFromString(@"MSPlugin") originalMethodPrefix:@"originalMSPlugin_"];
        
        // COScript.executeString:baseURL:
        [SDTSwizzle swizzleMethod:@selector(executeString:baseURL:) withMethod:@selector(executeString:baseURL:) sClass:[self class] pClass:NSClassFromString(@"COScript") originalMethodPrefix:@"originalCOScript_"];
        
        // Shortcuts Experiment!
        [SDTSwizzle swizzleMethod:@selector(keyDown:) withMethod:@selector(keyDown:) sClass:[self class] pClass:NSClassFromString(@"MSContentDrawView") originalMethodPrefix:@"originalMSContentDrawView_"];
        
        
        // From COSPreprocessorReplacement.
        [SDTSwizzle swizzleClassMethod:@selector(preprocessForObjCStrings:) withMethod:@selector(preprocessForObjCStrings:) sClass:self pClass:NSClassFromString(@"COSPreprocessor") originalMethodPrefix:@"originalCOSPreprocessor_"];
        
    });
}

// It works like a charm! :(
- (void)keyDown:(NSEvent*)event; {
    
    NSDictionary* mutableKeycodesD=
    @{
      @"11" : @"b", // B - Toggle border
      @"3"  : @"f",  // F - Toggle fill
      @"9"  : @"v",  // V - Vector tool
      @"35" : @"p", // P - Pencil tool
      @"17" : @"t", // T - Text tool
      @"0"  : @"a",  // A - Artoboard tool
      @"1"  : @"s",  // S - Slice tool
      @"37" : @"l", // L - Line tool
      @"15" : @"r", // R - Rectangle tool
      @"31" : @"o", // O - Oval tool
      @"32" : @"u"  // U - Rounded Rect tool
      };
    
    NSString* preferredCharacter=[mutableKeycodesD valueForKey:[[NSNumber numberWithUnsignedShort:event.keyCode] stringValue]];
    if(preferredCharacter!=nil && !event.isARepeat && event.characters.length==1 && /*[NSEvent modifierFlags]==0 &&*/ ![preferredCharacter isEqualToString:[event.characters lowercaseString]]) {
        event=[NSEvent keyEventWithType:event.type location:event.locationInWindow modifierFlags:event.modifierFlags timestamp:event.timestamp windowNumber:event.windowNumber context:event.context characters:preferredCharacter charactersIgnoringModifiers:preferredCharacter isARepeat:event.isARepeat keyCode:event.keyCode];
    }
    
    SEL sel=NSSelectorFromString(@"originalMSContentDrawView_keyDown");
    if([self respondsToSelector:sel]) {
        [self performSelector:sel withObject:event];
    }
};


- (id)executeString:(NSString*)str baseURL:(NSURL*)base {
    
    // Vandalize Print Statement! :)
    if(true) {
        Ivar nameIVar = class_getInstanceVariable([self class], "_mochaRuntime");
        id mocha = object_getIvar(self, nameIVar);
        
        [mocha setNilValueForKey:@"print"];
        [mocha setNilValueForKey:@"log"];
        
        
        NSString* printScript=[[NSString alloc] initWithContentsOfFile:@"/Users/andrey/Library/Application Support/com.bohemiancoding.sketch3/Plugins/sketch-devtools/client-src/runtime/printVandalizer.js" encoding:NSUTF8StringEncoding error:nil];
        
        
        id newScript=[mocha performSelector:NSSelectorFromString(@"evalString:") withObject:printScript];
        
        
        [self performSelector:NSSelectorFromString(@"pushObject:withName:") withObject:newScript withObject:@"print"];
        [self performSelector:NSSelectorFromString(@"pushObject:withName:") withObject:newScript withObject:@"log"];
    }
    
    // Extend runtime with Console! :)
    if(false) {
        Ivar nameIVar = class_getInstanceVariable([self class], "_mochaRuntime");
        id mocha = object_getIvar(self, nameIVar);
        
        /*
        [mocha setNilValueForKey:@"print"];
        [mocha setNilValueForKey:@"log"];
         */
        
        NSString* printScript=[[NSString alloc] initWithContentsOfFile:@"/Users/andrey/Library/Application Support/com.bohemiancoding.sketch3/Plugins/Playground/libs/console.js" encoding:NSUTF8StringEncoding error:nil];
        
        printScript = objc_msgSend(NSClassFromString(@"COSPreprocessor"),NSSelectorFromString(@"preprocessForObjCStrings:"),printScript);
        printScript = objc_msgSend(NSClassFromString(@"COSPreprocessor"),NSSelectorFromString(@"preprocessForObjCMessagesToJS:"),printScript);
        
        
        id newScript=[mocha performSelector:NSSelectorFromString(@"evalString:") withObject:printScript];
        
        // [self performSelector:NSSelectorFromString(@"pushObject:withName:") withObject:newScript withObject:@"console"];
    }
    
    if ([self respondsToSelector:NSSelectorFromString(@"originalCOScript_executeString:baseURL:")]) {
        return [self performSelector:NSSelectorFromString(@"originalCOScript_executeString:baseURL:") withObject:str withObject:base];
    } else {
//         [SketchConsole printGlobal:@"originalCOScript_executeString:baseURL: Does not respond to selector!"];
    }

    
    return nil;
}

// Экспериментальная перегрузка для автоматической подгрузки модулей для каждого исполняемого плагина.
+(NSString*)processPackageImports:(NSString*)script path:(NSURL*)url {
    
    script=[script stringByReplacingOccurrencesOfString:@"#import 'underscore'" withString:@"#import 'modules/underscore.js'"];
    script=[script stringByReplacingOccurrencesOfString:@"#import 'console'" withString:@"#import 'modules/console.js'"];
    script=[script stringByReplacingOccurrencesOfString:@"#import 'sketch-query'" withString:@"#import 'modules/sketch-query.js'"];
    
    
    // Ignore source file replacement in case of custom script.
    if([url.lastPathComponent isEqualToString:@"Untitled.sketchplugin"]) {
        return script;
    }
    
    // Replace source file with the new imports.
    [script writeToFile:[url path] atomically:true encoding:NSUTF8StringEncoding error:nil];
    
    return script;
};

// Подмененный метод 'run' класса MSPlugin.
// Мы используем его для получения информации о сессии, а так же для получения время исполнения скрипта.
- (id)run {
    NSLog(@"begin: MSPlugin - run");
    NSDate *start = [NSDate date];
    
    // Кэшируем данные связанные с сессией.
    NSString* script=[self valueForKey:@"script"];
    NSURL* baseURL=[self valueForKey:@"url"];
    NSURL* root=[self valueForKey:@"root"];
    
    // Кэшируем дерево импортов для последующего использования при ошибках или логировании.
    SketchConsole* shared=[SketchConsole sharedInstance];
    shared.isNewSession=true;
    if(shared.isNewSession) {
        
        SDTModule* module=[[SDTModule alloc] initWithScriptSource:script baseURL:baseURL parent:nil startLine:0];
        shared.cachedScriptRoot=module;
        
        shared.isNewSession=false;
    }
    
    // Очищаем консоль в случае если пользователь включил очистку консоли при каждом запуске.
    if([(NSNumber*)shared.options[@"clearConsoleBeforeLaunch"] boolValue]) {
        [SketchConsole clearConsole];
    }
    
    // Вызываем оригинальный метод MSPlugin run.
    id result=[self performSelector:NSSelectorFromString(@"originalMSPlugin_run")];
    
    // Добавляем информацию о сессии имя плагина, таймстэмп и время исполнения.
    if([(NSNumber*)shared.options[@"showSessionInfo"] boolValue]) {
        
        // Получаем время исполнения всего скрипта (похоже что надо переносить в другой метод!).
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:start];
        
        // Добавляем элемент сессии.
        [SketchConsole callJSFunction:@"addSessionItem" withArguments:@[[baseURL lastPathComponent],@(interval)]];
    }
    
    // Обновляем консоль.
    [SketchConsole callJSFunction:@"refreshConsoleList" withArguments:@[]];
    
    
    NSLog(@"end: MSPlugin - run");
    
    return result;
}

- (id)scriptWithExpandedImports:(id)script path:(id)basePath {
    
    NSLog(@"begin: MSPlugin - scriptWithExpandedImports:path:");
    
    // Invoke original MSPlugin scriptWithExpandedImports:path: method.
    if ([self respondsToSelector:NSSelectorFromString(@"originalMSPlugin_scriptWithExpandedImports:path:")]) {
        script=[SketchConsole processPackageImports:script path:basePath];
        script = [self performSelector:NSSelectorFromString(@"originalMSPlugin_scriptWithExpandedImports:path") withObject:script withObject:basePath];
        
        NSLog(@"end: MSPlugin - scriptWithExpandedImports:path:");
        
        return script;
    } else {
//        [SketchConsole printGlobal:@"MSPlugin.scriptWithExpandedImports: Does not respond to selector!"];
    }
    
    return @"function noScriptToday(){}";
}

+(NSDictionary*)getExternalFiles:(NSURL*)scriptURL {

    // Консоль
    NSURL* pluginFolderURL=[scriptURL URLByDeletingLastPathComponent];
    return @{
             @"folder": pluginFolderURL,
             @"index": [pluginFolderURL URLByAppendingPathComponent:@"index.html"]
             };
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

+(void)callJSFunction:(NSString*)name withArguments:(NSArray*)args {
    WebView* webView =[self findWebView];
    if(webView!=nil) {
        [[webView windowScriptObject] callWebScriptMethod:name withArguments:args];
    }
}

+(void)customPrint:(id)s {
    if(s==nil) {
        s=@"(null)";
    }
    
    // If logged value is an object we should convert it to a string.
    if (![s isKindOfClass:[NSString class]]) {
        s = [[s description] sdt_escapeHTML];
    }
    
    [self callJSFunction:@"addCustomPrintItem" withArguments:@[s]];
}

+(void)extendedPrint:(id)s info:(NSDictionary*)info sourceScript:(NSString*)script {

    if(s==nil) {
        s=@"(null)";
    }
    
    // If logged value is an object we should convert it to a string.
    if (![s isKindOfClass:[NSString class]]) {
        s = [[s description] sdt_escapeHTML];
    }
    
    SketchConsole* shared=[self sharedInstance];
    if(shared.cachedScriptRoot!=nil) {
        
        SDTModule* module=[shared.cachedScriptRoot findModuleByLineNumber:[(NSNumber*)info[@"line"] integerValue]];
        NSInteger line=[module relativeLineByAbsolute:[(NSNumber*)info[@"line"] integerValue]];
        
        // Print it! :)
        [self callJSFunction:@"addPrintItemEx" withArguments:@[s,[module.url path],@(line)]];
    }
};

// Перехваченный метод из класса MSPlugin, который отвечает за отображение JS и Mocha ошибок.
- (void)printException:(NSException*)e {
    
    // Invoke original COScript.printException() method.
    if(false) {
        if ([self respondsToSelector:NSSelectorFromString(@"originalCOScript_printException")]) {
            [self performSelector:NSSelectorFromString(@"originalCOScript_printException") withObject:e];
        } else {
//            [SketchConsole printGlobal:@"COScript.printException: Does not respond to selector!"];
        }
    }
    
    // Check for JS errors.
    if([e.name isEqualToString:@"MOJavaScriptException"]) {
    
        NSString* errorType=@"JSUnknownError";
        NSString* message=@"";
        NSDictionary* errors=
        @{
          @"ReferenceError: " : @"JSReferenceError",
          @"TypeError: " : @"JSTypeError",
          @"SyntaxError: " : @"JSSyntaxError",
          @"RangeError: " : @"JSRangeError",
          @"EvalError: " : @"JSEvalError",
          @"InternalError: " : @"JSInternalError",
          @"URIError: " : @"JSURIError",
          @"Error: " : @"JSCustomError"
          };

        // Выявляем тип ошибки, а так же получаем сообщение ошибки.
        for (NSString* key in errors) {
            if([e.reason rangeOfString:key].location==0) {
                errorType=errors[key];
                message=[e.reason stringByReplacingOccurrencesOfString:key withString:@""];
                break;
            }
        }
        
        SketchConsole* shared=[SketchConsole sharedInstance];
        if(shared.cachedScriptRoot) {
            
            // Обработка стэка вызовов.
            NSArray* stack=[e.userInfo[@"stack"] componentsSeparatedByString:@"\n"];
            LogMessage(@"printException - STACK",0,	@"%@",stack);
            
            NSMutableArray* callStack = [NSMutableArray arrayWithArray:@[]];
            
            for(NSString* call in stack) {
                NSArray* components=[call componentsSeparatedByString:@"@"];
                
                NSString* fn=(components.count>1) ? components[0] : @"closure";
                components=[components[components.count-1] componentsSeparatedByString:@":"];
                
                NSString* filePath=components[0];
                NSUInteger line=[components[1] integerValue];
                NSUInteger column=[components[2] integerValue];
                SDTModule* module=[shared.cachedScriptRoot findModuleByLineNumber:line];
                if(module) {
                    NSUInteger relativeLineNumer=[module relativeLineByAbsolute:line];
                    NSString* sourceCodeLine=[module sourceCodeForLine:relativeLineNumer];
                    
                    NSLog(@"Stack Call: %@: %@:%ld:%ld",fn,[module.url lastPathComponent],relativeLineNumer,column);
                    
                    NSDictionary* call=@{
                                        @"fn": fn,
                                        @"filePath" : [module.url path],
                                        @"line": @(line),
                                        @"column": @(column)
                                        };
                    
                    [callStack addObject:call];
                }
            }
            
            NSString* callStackObj=[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:callStack options:0 error:nil] encoding:NSUTF8StringEncoding];
            
            // Ищем модуль по глобальной строке в которой произошла ошибка и обрабатывает эту ошибку.
            NSUInteger lineNumber=[(NSNumber*)e.userInfo[@"line"] integerValue];
            
            SDTModule* module=[shared.cachedScriptRoot findModuleByLineNumber:lineNumber];
            if(module) {
                NSUInteger relativeLineNumer=[module relativeLineByAbsolute:lineNumber];
                NSString* sourceCodeLine=[module sourceCodeForLine:relativeLineNumer];
                
                // Добавляем и отображаем ошибку на стороне WebKit'a.
                // callAddErrorJSFunction(@"addErrorItem",@[errorType,message,[module.url path],@(relativeLineNumer),sourceCodeLine,callStackObj]);
                [SketchConsole callJSFunction:@"addErrorItem" withArguments:@[errorType,message,[module.url path],@(relativeLineNumer),sourceCodeLine,callStackObj]];
            } else {
                NSLog(@"Error: Can't find source module!");
            }
            
        } else {
            NSLog(@"Error: Root module is not found!");
        }
        
        return;
    }
    
    // Check for Mocha runtime error.
    if([e.name isEqualToString:@"MORuntimeException"]) {
        // callAddErrorJSFunction(@"addMochaErrorItem",@[e.reason,@"/no/path/plg.sketchplugin",@"/no/path"]);
        [SketchConsole callJSFunction:@"addMochaErrorItem" withArguments:@[e.reason,@"/no/path/plg.sketchplugin",@"/no/path"]];
    }
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

+(void)printGlobalEx:(id)s {

    
    if (![s isKindOfClass:[NSString class]]) {
        s = [s description];
    }
    
    
    NSString* logFilePath=@"/Users/andrey/Library/Application Support/com.bohemiancoding.sketch3/Plugins/sketch-devtools/logs/framework_dump.js";
    
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

+(void)clearConsole {
    [self callJSFunction:@"clearConsole" withArguments:@[]];
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
    
    if (sel == @selector(hideConsole))
        name = @"hideConsole";
    
    if (sel == @selector(openURL:))
        name = @"openURL";
    
    if (sel == @selector(getConsoleOptions))
        name = @"getConsoleOptions";
    
    if (sel == @selector(setConsoleOptions:))
        name = @"setConsoleOptions";
    
    if (sel == @selector(showCustomScriptWindow:))
        name = @"showCustomScriptWindow";
    if (sel == @selector(openFile:withIDE:atLine:))
        name = @"openFileWithIDE";
    
    return name;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel
{
    if (sel == @selector(hideConsole)) return NO;
    if (sel == @selector(openURL:)) return NO;
    if (sel == @selector(getConsoleOptions)) return NO;
    if (sel == @selector(setConsoleOptions:)) return NO;
    if (sel == @selector(showCustomScriptWindow:)) return NO;
    if (sel == @selector(openFile:withIDE:atLine:)) return NO;
    
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

-(BOOL)openFile:(NSString*)filePath withIDE:(NSString*)ide atLine:(NSInteger)line {
    return [SKDProtocolHandler openFile:filePath withIDE:ide atLine:line];
}

+(id)testObject:(id)object {
    return [object description];
}

+(id)getPropertyData:(Class)objectClass accessorKey:(NSString*)accessorKey {
    
    objc_property_t prop = class_getProperty(objectClass, [accessorKey UTF8String]);
    
    NSString* getter=@"";
    NSString* setter=@"";
    
    char *setterName = property_copyAttributeValue(prop, "S");
    if (setterName == NULL) {
        setter=accessorKey;
    } else {
        setter = [NSString stringWithUTF8String:setterName];
    }
    
    char *getterName = property_copyAttributeValue(prop, "G");
    if (getterName == NULL) {
        getter = accessorKey;
    } else {
        getter = [NSString stringWithUTF8String:getterName];
    }
    
    return @{
             @"setter" : setter,
             @"getter" : getter
             };
};


+ (NSString*)preprocessForObjCStrings:(NSString*)sourceString {
    NSMutableString *buffer = [NSMutableString string];
    
    id tokenizer  = objc_msgSend(NSClassFromString(@"TDTokenizer"),NSSelectorFromString(@"tokenizerWithString:"),sourceString);
    objc_msgSend(objc_msgSend(tokenizer,NSSelectorFromString(@"whitespaceState")),NSSelectorFromString(@"setReportsWhitespaceTokens:"),YES);
    objc_msgSend(objc_msgSend(tokenizer,NSSelectorFromString(@"commentState")),NSSelectorFromString(@"setReportsCommentTokens:"),YES);
    
    id eof = objc_msgSend(NSClassFromString(@"TDToken"),NSSelectorFromString(@"EOFToken"));
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
                [buffer appendString:nastyComment];
            }
            
        } else if (objc_msgSend(tok,NSSelectorFromString(@"isSymbol")) && [[tok stringValue] isEqualToString:@"@"]) {
            
            nextToken = objc_msgSend(tokenizer,NSSelectorFromString(@"nextToken"));
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

@end



#pragma clang diagnostic pop










