//
//  NSObject+Stage.m
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

#import "NSObject+Stage.h"

#import "objc/runtime.h"

@interface StageDeallocationBlock : NSObject
@property (nonatomic,copy) VoidBlock block;
@end

@implementation StageDeallocationBlock

- (instancetype)initWithBlock:(VoidBlock)block {
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (void)dealloc {
    self.block();
}

@end

@implementation NSObject (Stage)

- (void)stage_onDeallocExecuteBlock:(VoidBlock)block {
    if (!block) {
        return;
    }

    static void* kOnDeallocationBlocks = &kOnDeallocationBlocks;
    NSMutableArray* scheduledBlocks = objc_getAssociatedObject(self, kOnDeallocationBlocks) ?: [NSMutableArray new];
    [scheduledBlocks addObject:[[StageDeallocationBlock alloc] initWithBlock:block]];
    [self associateObject:scheduledBlocks key:kOnDeallocationBlocks policy:RetainNonatomic];
}

- (id)associatedObjectWithKey:(void *)key {
    return objc_getAssociatedObject(self, key);
}

- (void)associateObject:(id)object key:(void *)key policy:(StageAssociationPolicy)policy {
    objc_setAssociatedObject(self, key, object, (objc_AssociationPolicy)policy);
}

@end
