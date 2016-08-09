//
//  StageSafeKVO.m
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

#import "StageSafeKVO.h"
#import "NSObject+Stage.h"

#import "objc/runtime.h"

static void* kSafeKvoLifetimeAssociation = &kSafeKvoLifetimeAssociation;

typedef id (^ArrayFlatMapBlock)(id object, NSInteger index);
@interface NSArray (Stage)
- (NSArray*)flatMap:(ArrayFlatMapBlock)mapper;
@end
@implementation NSArray (Stage)

- (NSArray *)flatMap:(ArrayFlatMapBlock)mapper {
    NSMutableArray* newArray = [[NSMutableArray alloc] initWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id newValue = mapper(obj, idx);
        if (newValue != nil) {
            [newArray addObject:newValue];
        }
    }];
    return newArray;
}

@end

@interface StageSafeKVO ()
@property (nonatomic,weak) id object;
@property (nonatomic,assign) id target;
@property (nonatomic,copy) StageSafeKVOBlock handler;
@property (nonatomic,copy) NSArray* keyPaths;
@end

@implementation StageSafeKVO

+ (instancetype)observer:(id)observer watchKey:(NSString *)keyPath inObject:(id)object withBlock:(StageSafeKVOBlock)block {
    return [self observer:observer watchKeys:@[keyPath] inObject:object withBlock:block];
}

+ (instancetype)observer:(id)observer watchKeys:(NSArray *)keyPaths inObject:(id)object withBlock:(StageSafeKVOBlock)block {

    keyPaths = [keyPaths flatMap:^id(id obj, NSInteger idx) {
        return [obj isKindOfClass:[NSString class]] && [obj length] > 0 ? obj : nil;
    }];

    if (!observer || !object || observer == object || !keyPaths.count || !block) {
        return nil;
    }

    StageSafeKVO* kvo = [StageSafeKVO new];
    kvo.keyPaths = keyPaths;
    kvo.handler = block;
    kvo.object = observer;
    kvo.target = object;
    [observer stage_onDeallocExecuteBlock:^{
        [kvo stopObserving];
    }];
    [object stage_onDeallocExecuteBlock:^{
        [kvo stopObserving];
    }];
    objc_setAssociatedObject(object, kSafeKvoLifetimeAssociation, kvo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(observer, kSafeKvoLifetimeAssociation, kvo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    for (NSString* keyPath in keyPaths) {
        [object addObserver:kvo forKeyPath:keyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return kvo;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.handler(object, keyPath, change);
}

- (void)stopObserving {
    if (!self.object || !self.target) return;
    id object = self.object, target = self.target;
    self.object = nil;
    self.target = nil;

    for (NSString* keyPath in self.keyPaths) {
        [target removeObserver:self forKeyPath:keyPath];
    }
    objc_setAssociatedObject(object, kSafeKvoLifetimeAssociation, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(target, kSafeKvoLifetimeAssociation, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end