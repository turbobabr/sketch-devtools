//
//  COSPreprocessorReplacement.h
//  SketchConsole
//
//  Created by Andrey on 26/08/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface COSPreprocessorReplacement : NSObject

+(void)load;

+ (NSString*)preprocessCode:(NSString*)sourceString withBaseURL:(NSURL*)base;

@end
