//
//  LXWeakWrapper.m
//
//  Created by 从今以后 on 16/1/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "LXWeakWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@implementation LXWeakWrapper

- (instancetype)initWithObject:(id)object
{
    self = [super init];
    if (self) {
        _object = object;
    }
    return self;
}

+ (instancetype)wrapperWithObject:(id)object
{
    return [[self alloc] initWithObject:object];
}

@end

NS_ASSUME_NONNULL_END
