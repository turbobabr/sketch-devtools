//
//  SDTFileWatcher.h
//  SketchConsole
//
//  Created by Andrey on 13/09/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDTFileWatcher : NSObject
{
    
    FSEventStreamRef streamRef;
}

@property (weak) id delegate;
@property (retain) NSString *path;

+ (id) fileWatcherWithPath:(NSString*)filePath delegate:(id)delegate;

@end


@interface NSObject (SDTFileWatcherDelegate)
- (void) fileWatcherDidRecieveFSEvent:(SDTFileWatcher*)fw;
@end


