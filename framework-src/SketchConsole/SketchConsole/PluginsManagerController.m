//
//  PluginsManagerController.m
//  SketchConsole
//
//  Created by Andrey on 05/09/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import "PluginsManagerController.h"

@interface PluginsManagerController ()
@property (weak) IBOutlet NSButton *showMeMoreButton;

@end

@implementation PluginsManagerController

- (id)init
{
    self = [super initWithWindowNibName:@"PluginsManager"];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (IBAction)showMeMore:(id)sender {
    [self.showMeMoreButton setTitle:@"MORE!"];
}

@end
