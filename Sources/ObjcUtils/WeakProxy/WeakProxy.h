//
//  WeakProxy.h
//  ObjcUtils
//
//  Created by Vasiliy Zaytsev on 24.08.2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeakProxy : NSProxy

@property (nonatomic, weak, nullable) NSObject* object;

+ (instancetype)create;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
