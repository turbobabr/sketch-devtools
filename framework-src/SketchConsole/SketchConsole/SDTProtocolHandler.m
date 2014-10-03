//
//  SKDProtocolHandler.m
//  SketchConsole
//
//  Created by Andrey on 06/09/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import "SDTProtocolHandler.h"

@implementation SDTProtocolHandler

+(BOOL)openFile:(NSString*)filePath withIDE:(NSString*)ide atLine:(NSInteger)line {
    
    ide=[ide lowercaseString];
    
    NSDictionary* factory=
    @{
      @"sublime": @{
              @"launchPath": @"/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl",
              @"arguments": @[[NSString stringWithFormat:@"%@:%ld",filePath,line]]
              },
      @"textmate": @{
              @"launchPath": @"/Applications/TextMate.app/Contents/Resources/mate",
              @"arguments": @[filePath,@"-l",[NSString stringWithFormat:@"%ld",line]]
              },
      @"atom": @{
              @"launchPath": @"/Applications/Atom.app/Contents/MacOS/Atom",
              @"arguments": @[[NSString stringWithFormat:@"%@:%ld",filePath,line]]
              },
      @"xcode": @{
              @"launchPath": @"/usr/bin/xed",
              @"arguments": @[@"--line",[NSString stringWithFormat:@"%ld",line],filePath]
              },
      @"webstorm": @{
              @"launchPath": @"/Applications/WebStorm.app/Contents/MacOS/webide",
              @"arguments": @[@"--line",[NSString stringWithFormat:@"%ld",line],filePath],
              @"postProcessingScript": @"tell application \"WebStorm\" to activate"
              },
      @"appcode": @{
              @"launchPath": @"/Applications/AppCode.app/Contents/MacOS/appcode",
              @"arguments": @[@"--line",[NSString stringWithFormat:@"%ld",line],filePath],
              @"postProcessingScript": @"tell application \"AppCode\" to activate"
              },
      @"macvim": @{
              @"launchPath": @"/Applications/MacVim.app/Contents/MacOS/Vim",
              @"arguments": @[filePath,@"-g",[NSString stringWithFormat:@"+%ld",line]]
              },
      };
    
    if([factory objectForKey:ide]) {
        
        NSDictionary* launchOptions=factory[ide];
        
        [NSTask launchedTaskWithLaunchPath:launchOptions[@"launchPath"] arguments:launchOptions[@"arguments"]];
        if([launchOptions objectForKey:@"postProcessingScript"]) {
            NSAppleScript* script = [[NSAppleScript alloc] initWithSource:launchOptions[@"postProcessingScript"]];
            [script executeAndReturnError:nil];
        }
        
        return true;
        
    }
    
    return false;
}

@end
