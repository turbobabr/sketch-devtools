//
//  SDTOmniBoxWindowController.h
//  SketchConsole
//
//  Created by Andrey on 14/09/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WebView;
@interface SDTOmniBoxWindowController : NSWindowController <NSTextFieldDelegate>


+(SDTOmniBoxWindowController*)sharedInstance;
@property (strong) SDTOmniBoxWindowController* myself;
@property (weak) IBOutlet WebView *webView;

@property (weak) IBOutlet NSTextField *searchBox;

- (IBAction)onButton:(id)sender;

@end
