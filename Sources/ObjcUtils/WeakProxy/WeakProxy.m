//
//  WeakProxy.m
//  ObjcUtils
//
//  Created by Vasily Zaytsev on 24.08.2021.
//

#import "WeakProxy.h"

NS_ASSUME_NONNULL_BEGIN

@implementation WeakProxy

+ (instancetype)create {
    return [self alloc];
}

- (BOOL)respondsToSelector:(SEL)selector {
    return [_object respondsToSelector:selector];
}

- (nullable NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [_object methodSignatureForSelector:selector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _object;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:_object];
}

@end

NS_ASSUME_NONNULL_END
