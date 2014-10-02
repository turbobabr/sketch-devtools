//
//  SDTSwizzle.m
//  SketchConsole
//
//  Created by Andrey on 27/08/14.
//  Copyright (c) 2014 Turbobabr. All rights reserved.
//

#import "SDTSwizzle.h"
#import <objc/runtime.h>

#import "SketchConsole.h"

@implementation SDTSwizzle

+(BOOL)swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ sClass:(Class)sClass pClass:(Class)pClass originalMethodPrefix:(NSString*)prefix {
    
    SEL originalSelector = origSel_;
    SEL swizzledSelector = altSel_;
    
    Method originalMethod = class_getInstanceMethod(pClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(sClass, swizzledSelector);
    
    class_addMethod(sClass,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
    
    NSString* methodName=[prefix stringByAppendingString:NSStringFromSelector(origSel_)];
    if([[methodName componentsSeparatedByString:@":"] count]<3) {
        methodName=[methodName stringByReplacingOccurrencesOfString:@":" withString:@""];
    }
    
    // [SketchConsole printGlobal: methodName];
    
    class_addMethod(pClass,
                    NSSelectorFromString(methodName),
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));

    return true;
}

+(BOOL)swizzleClassMethod:(SEL)origSel_ withMethod:(SEL)altSel_ sClass:(Class)sClass pClass:(Class)pClass originalMethodPrefix:(NSString*)prefix {
    
    return [self swizzleMethod:origSel_ withMethod:altSel_ sClass:object_getClass((id)sClass) pClass:object_getClass((id)pClass) originalMethodPrefix:prefix];
};

@end
