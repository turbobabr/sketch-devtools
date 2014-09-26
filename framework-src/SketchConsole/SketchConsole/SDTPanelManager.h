//
//  SDTPanelManager.h
//  SketchConsole
//
//  Created by Andrey on 13/09/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDTFileWatcher;

@interface SDTPanelManager : NSObject


+(SDTPanelManager*)sharedInstance;

@property (strong) SDTFileWatcher* pageFileWatcher;

@end
