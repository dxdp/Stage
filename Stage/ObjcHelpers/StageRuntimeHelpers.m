//
//  StageRuntimeHelpers.m
//  Stage
//
//  Copyright © 2016 David Parton
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies
//  or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
//  AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "StageRuntimeHelpers.h"
#import "NSObject+Stage.h"
#import "objc/runtime.h"
#import <dlfcn.h>

@implementation StageRuntimeHelpers

// TODO: Inject view factory definitions
+ (UIView *)makeViewWithClass:(Class)cls {
    NSAssert([cls isSubclassOfClass:[UIView class]], @"Must be subclass of UIView");
    return [[cls alloc] initWithFrame:CGRectZero];
}

+ (void)loadReveal {
#if DEBUG
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if TARGET_IPHONE_SIMULATOR
        (void)dlopen("/Applications/Reveal.app/Contents/SharedSupport/iOS-Libraries/libReveal.dylib", 0x2);
#else
        (void)dlopen([(NSString*)[(NSBundle*)[NSBundle mainBundle] pathForResource:@"libReveal" ofType:@"dylib"] cStringUsingEncoding:0x4], 0x2);
#endif
        (void)[(NSNotificationCenter*)[NSNotificationCenter defaultCenter] postNotificationName:@"IBARevealRequestStart" object:nil];
    });
#endif
}

@end
