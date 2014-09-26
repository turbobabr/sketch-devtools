//
//  SDTOmniBoxWindowController.m
//  SketchConsole
//
//  Created by Andrey on 14/09/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import "SDTOmniBoxWindowController.h"
#import <WebKit/WebKit.h>
#import "NSLogger.h"


@interface SDTOmniBoxWindowController ()

@end

@implementation SDTOmniBoxWindowController

+(SDTOmniBoxWindowController*)sharedInstance {
    static dispatch_once_t once;
    static SDTOmniBoxWindowController *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}


+(void)showOmniBox {
    [self sharedInstance].myself=[[SDTOmniBoxWindowController alloc] initWithWindowNibName:@"SDTOmniBoxWindow"];
    [[self sharedInstance].myself updateHeight];
    [[self sharedInstance].myself showWindow:[[NSApplication sharedApplication] mainWindow]];
    
    [[self sharedInstance].myself.window makeKeyAndOrderFront:nil];
    
    

    
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)controlTextDidChange:(NSNotification *)obj {
    NSString* searchTerm=self.searchBox.stringValue;
    
    
    [self updateHeight];
    
    id win = [self.webView windowScriptObject];
    [win callWebScriptMethod:@"filterEntries" withArguments:@[searchTerm]];
    
    
    
    /*
    args=@[[NSString stringWithFormat:@"Actual Line Number: %ld",line],@"Some Plugin",info[@"file"],info[@"file"]];
    [win callWebScriptMethod:@"addPrintItem" withArguments:args];
     */
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
    NSLog(@"%@",control);
    
    id win = [self.webView windowScriptObject];

    NSString* cmd=NSStringFromSelector(command);
    NSLog(cmd);
    if([cmd isEqualToString:@"moveUp:"]) {
        // NSLog(@"MOVE UP!");
        [win callWebScriptMethod:@"decrementSelection" withArguments:@[]];
        
        return true;
        
    } else if([cmd isEqualToString:@"moveDown:"]) {
        // NSLog(@"MOVE DOWN!");
        [win callWebScriptMethod:@"incrementSelection" withArguments:@[]];
        
        return true;
    } else if([cmd isEqualToString:@"complete:"]) {
        // NSLog(@"MOVE DOWN!");
        // [win callWebScriptMethod:@"incrementSelection" withArguments:@[]];
        
        [self close];
        
        return true;
    } else if([cmd isEqualToString:@"insertNewline:"]) {
        // NSLog(@"MOVE DOWN!");
        // [win callWebScriptMethod:@"incrementSelection" withArguments:@[]];
        
        [self close];
        
        return true;
    }
    
    return false;
}

-(void)updateHeight {
    
    int horzPadding=10;
    int topPadding=10;
    int bottomPadding=10;
    
    
    int max=10;
    int entryHeigh=53;
    
    int listHeight=entryHeigh*max;
    
    NSLog(@"%@",self.window);
    
    NSRect windowFrame = [self.window frame];
    windowFrame.size.height=listHeight;
    [self.window setFrame:windowFrame display:true];
    
    windowFrame = [self.webView frame];
    windowFrame.size.height=listHeight;
    [self.webView setFrame:windowFrame];

    // [self.window setFrame:windowFrame display:YES];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.searchBox becomeFirstResponder];
    
    self.searchBox.delegate=self;
    
    
    NSString* indexPageContents=[NSString stringWithContentsOfFile:@"/Users/andrey/Library/Application Support/com.bohemiancoding.sketch3/Plugins/Playground/omni-box/index.html" encoding:NSUTF8StringEncoding error:nil];
    
    NSString* ts=[NSString stringWithFormat:@"?ts=%f",[[NSDate date] timeIntervalSince1970]];
    indexPageContents = [indexPageContents stringByReplacingOccurrencesOfString:@"?ts=NO_CACHE" withString:ts];
    
    
    [[self.webView mainFrame] loadHTMLString:indexPageContents baseURL:[NSURL fileURLWithPath:@"/Users/andrey/Library/Application Support/com.bohemiancoding.sketch3/Plugins/Playground/omni-box"]];

    [self updateHeight];
    
    [self.window center];
    
    
}

- (IBAction)onButton:(id)sender {
    // [self.webView setFrame:NSMakeRect(0,0,100,500)];
    [self updateHeight];
}
@end
