//
//  NSObject+Stage.h
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

#import <Foundation/Foundation.h>

typedef void (^VoidBlock)(void);
typedef NS_ENUM(NSUInteger, StageAssociationPolicy) {
    Assign = 0,
    RetainNonatomic = 1,
    CopyNonatomic = 3,
    RetainAtomic = 01401,
    CopyAtomic = 01403
};

@interface NSObject (Stage)
- (void)stage_onDeallocExecuteBlock:(nonnull VoidBlock)block NS_SWIFT_NAME(onDeallocation(_:));
- (void)associateObject:(nullable id)object key:(nonnull void*)key policy:(StageAssociationPolicy)policy;
- (nullable id)associatedObjectWithKey:(nonnull void*)key NS_SWIFT_NAME(associatedObject(key:));
@end
