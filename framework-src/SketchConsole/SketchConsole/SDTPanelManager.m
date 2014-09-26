//
//  SDTPanelManager.m
//  SketchConsole
//
//  Created by Andrey on 13/09/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import "SDTPanelManager.h"
#import "NSView+SketchDevTools.h"
#import <WebKit/WebKit.h>
#import "SDTFileWatcher.h"
#import "SketchConsole.h"
#import "NSLogger.h"

#import "SDTWebView.h"

@implementation SDTPanelManager

+(SDTPanelManager*)sharedInstance {
    static dispatch_once_t once;
    static SDTPanelManager *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}


+(void)initFileWatchers {
    
    SDTPanelManager* shared=[self sharedInstance];
    
    NSString* filePath=@"/Users/andrey/Library/Application Support/com.bohemiancoding.sketch3/Plugins/Playground/side-panel/plugins-directory.html";
    shared.pageFileWatcher = [SDTFileWatcher fileWatcherWithPath:filePath delegate:shared];
    
    [SketchConsole printGlobal:shared.pageFileWatcher];
    
}

- (void)fileWatcherDidRecieveFSEvent:(SDTFileWatcher*)fw {
    
    NSString *path = [fw path];
    
    [SketchConsole printGlobal:@"File Event: "];
    [SketchConsole printGlobal:path];
    [SketchConsole printGlobal:@" "];
    
    
    LogMessage(@"SDTPanelManager",0,@"Update file: %@",path);
    
    
    [SDTPanelManager reloadWebView];
    
    
    
    
    
    /*
    NSError *err = nil;
    NSString *src = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:path] encoding:NSUTF8StringEncoding error:&err];
    
    if (err) {
        NSBeep();
        NSLog(@"err: %@", err);
        return;
    }
    
    if (src) {
        [[[jsTextView textStorage] mutableString] setString:src];
    }
     */
}

+(NSSplitView*)wrapWithSplitView:(NSView*)contentView isVertical:(BOOL)isVertical {
    
    // Create SplitView for substitution
    NSSplitView* newSplitView = [[NSSplitView alloc] initWithFrame:[contentView bounds]];
    [newSplitView setVertical:isVertical];
    newSplitView.autoresizingMask=NSViewWidthSizable | NSViewHeightSizable;

    
    newSplitView.subviews=contentView.subviews;
    
    // Replace default split view with the custom one.
    contentView.subviews=@[newSplitView];

    return newSplitView;
};


+(void)reloadWebView {
    
    [SketchConsole printGlobal:@"RELOAD VIEW:"];
    NSLog(@"LOAD VIEW:");
    NSView* contentView=[self getCurrentDocumentContentView];
    if(contentView==nil) return;
    
    [SketchConsole printGlobal:@"CONTENT VIEW:"];
    [SketchConsole printGlobal:contentView.identifier];
    

    
    NSSplitView* splitView=contentView.subviews[0];
    [SketchConsole printGlobal:splitView.identifier];
    
    // WebView* webView=[(NSScrollView*)splitView.subviews[1] documentView];
    SDTWebView* webView=(SDTWebView*)splitView.subviews[2];
    [SketchConsole printGlobal:webView.identifier];
    
    [SketchConsole printGlobal:@"WEB VIEW:"];
    [SketchConsole printGlobal:webView];
    
    
    
    // Load web-page and initialize panel.
    NSString* indexPageContents=[NSString stringWithContentsOfFile:@"/Users/andrey/Library/Application Support/com.bohemiancoding.sketch3/Plugins/Playground/side-panel/plugins-directory.html" encoding:NSUTF8StringEncoding error:nil];
    
    NSString* ts=[NSString stringWithFormat:@"?ts=%f",[[NSDate date] timeIntervalSince1970]];
    indexPageContents = [indexPageContents stringByReplacingOccurrencesOfString:@"?ts=NO_CACHE" withString:ts];
    
    
    [[webView mainFrame] loadHTMLString:indexPageContents baseURL:[NSURL fileURLWithPath:@"/Users/andrey/Library/Application Support/com.bohemiancoding.sketch3/Plugins/Playground/side-panel"]];

    
    
};


- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame {
    
    [SketchConsole printGlobal:@"WEB VIEW: МЕНЯ ВЫЗЫВАЮТ???"];
    id win = [sender windowScriptObject];
    [win setValue:[[SDTPanelManager alloc] init] forKey:@"SDTPanelManager"];
}


+(BOOL)initPanels {
    
    [self initFileWatchers];
    
    
    NSView* contentView=[self getCurrentDocumentContentView];
    if(contentView==nil) return false;
    
    NSSplitView* splitView=contentView.subviews[0];
    
    NSArray* subviews=splitView.subviews;
    
    // Create WebView
    SDTWebView* webView = [[SDTWebView alloc] initWithFrame:NSMakeRect(0,0,300,100)];
    [webView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    webView.identifier=@"isPluginsView";
    
    
    // Load web-page and initialize panel.
    NSString* indexPageContents=[NSString stringWithContentsOfFile:@"/Users/andrey/Library/Application Support/com.bohemiancoding.sketch3/Plugins/Playground/side-panel/plugins-directory.html" encoding:NSUTF8StringEncoding error:nil];
    
    [webView setFrameLoadDelegate:[self sharedInstance]];
    
    /*
    id win = [webView windowScriptObject];
    [win setValue:[[SDTPanelManager alloc] init] forKey:@"SDTPanelManager"];
     */
    
    
    [[webView mainFrame] loadHTMLString:indexPageContents baseURL:[NSURL fileURLWithPath:@"/Users/andrey/Library/Application Support/com.bohemiancoding.sketch3/Plugins/Playground/side-panel"]];
    

    
    splitView.subviews=@[subviews[0],subviews[1],webView,subviews[2]];
    
    // [splitView makeFirstResponder:webView];
    [webView becomeFirstResponder];
    
    // [splitView setPosition:500 ofDividerAtIndex:0];
    
    
    return true;
    
    
    /*
    NSSplitView* splitView=[self wrapWithSplitView:contentView isVertical:true];
    
    // splitView.dividerStyle=NSSplitViewDividerStyleThin;
    // splitView.dividerStyle=NSSplitViewDividerStyleThick;
    splitView.dividerStyle=NSSplitViewDividerStylePaneSplitter;
    splitView.dividerThickness=10;
    
    NSButton* btn=[[NSButton alloc] init];
    [splitView addSubview:btn];
    [splitView adjustSubviews];
    
    [splitView setPosition:contentView.frame.size.width-100 ofDividerAtIndex:0];
    
    return true;
     */
    
    /*
    // Initialize Panel
    NSView* contentView=[self getCurrentDocumentContentView];
    if(contentView==nil) return false;
    
    int viewHeight=contentView.frame.size.height;
    int defaultConsoleHeight=300; // [self defaultConsoleHeight];
    if(viewHeight/2<defaultConsoleHeight) defaultConsoleHeight=viewHeight/2;
    
    // Create SplitView for substitution
    NSSplitView* splitView = [[NSSplitView alloc] initWithFrame:[contentView bounds]];
    splitView.autoresizingMask=NSViewWidthSizable | NSViewHeightSizable;
    splitView.identifier=@"idSketchDevToolsSplitter";
    
    
    NSSplitView* originalSplitView=contentView.subviews[0];
    [splitView addSubview:originalSplitView];
    
    NSButton* btn=[[NSButton alloc] init];
    [splitView addSubview:btn];
    [splitView adjustSubviews];
    
    // Replace default split view with the custom one.
    contentView.subviews=@[splitView];
    
    // Set position.
    [splitView setPosition:viewHeight-defaultConsoleHeight ofDividerAtIndex:0];
     */

    return true;
}


+(NSView*)bottomPanelView {
    return nil;
}

+(NSView*)rightPanelView {
    return nil;
}

+(NSView*)getCurrentDocumentContentView {
    
    /*
    NSDocumentController* controller=[NSDocumentController sharedDocumentController];
    NSDocument* doc=controller.currentDocument;
    if(doc==nil) return nil;
    
    return doc.windowForSheet.contentView;
     */
    
    id document=[(NSClassFromString(@"MSDocument")) performSelector:NSSelectorFromString(@"currentDocument")];
    
    NSWindow* window=[document valueForKey:@"documentWindow"];
    return window.contentView;
}

+ (NSString *) webScriptNameForSelector:(SEL)sel
{
    NSString* name=@"";
    
    if (sel == @selector(execScript:))
        name = @"execScript";
    
    if (sel == @selector(logMessage:))
        name = @"logMessage";
    
    return name;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel
{
    if (sel == @selector(execScript:)) return NO;
    if (sel == @selector(logMessage:)) return NO;
    
    return YES;
}

-(void)logMessage:(NSString*)message {
    LogMessage(@"JSLog",0,@"%@",message);
}

-(void)execScript:(NSString*)script {
    
    id plugin = [NSClassFromString(@"MSPlugin") alloc];
    
    plugin = [plugin performSelector:NSSelectorFromString(@"initWithScript:name:") withObject:script withObject:@"My Script"];
    [plugin performSelector:NSSelectorFromString(@"processScript")];
    [plugin performSelector:NSSelectorFromString(@"run")];
    
}



@end
