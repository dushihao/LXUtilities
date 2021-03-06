//
//  CALayer+LXExtension.m
//
//  Created by 从今以后 on 15/10/5.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "CALayer+LXExtension.h"

NS_ASSUME_NONNULL_BEGIN

@interface _LXAnimationDelegate : NSObject <CAAnimationDelegate> {
    void (^_completion)(BOOL finished);
}
@end
@implementation _LXAnimationDelegate

- (instancetype)initWithCompletion:(void (^)(BOOL finished))completion {
    self = [super init];
    if (self) {
        _completion = completion;
    }
    return self;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (_completion) {
        _completion(flag);
        _completion = nil;
    }
}

@end

@implementation CALayer (LXExtension)

#pragma mark size

- (void)setLx_size:(CGSize)lx_size {
    CGRect frame = self.frame;
    frame.size = lx_size;
    self.frame = frame;
}

- (CGSize)lx_size {
    return self.frame.size;
}

- (void)setLx_width:(CGFloat)lx_width {
    CGRect frame = self.frame;
    frame.size.width = lx_width;
    self.frame = frame;
}

- (CGFloat)lx_width {
    return self.frame.size.width;
}

- (void)setLx_height:(CGFloat)lx_height {
    CGRect frame = self.frame;
    frame.size.height = lx_height;
    self.frame = frame;
}

- (CGFloat)lx_height {
    return self.frame.size.height;
}

#pragma mark origin

- (void)setLx_origin:(CGPoint)lx_origin {
    CGRect frame = self.frame;
    frame.origin = lx_origin;
    self.frame = frame;
}

- (CGPoint)lx_origin {
    return self.frame.origin;
}

- (void)setLx_originX:(CGFloat)lx_originX {
    CGRect frame = self.frame;
    frame.origin.x = lx_originX;
    self.frame = frame;
}

- (CGFloat)lx_originX {
    return self.frame.origin.x;
}

- (void)setLx_originY:(CGFloat)lx_originY {
    CGRect frame = self.frame;
    frame.origin.y = lx_originY;
    self.frame = frame;
}

- (CGFloat)lx_originY {
    return self.frame.origin.y;
}

#pragma mark position

- (void)setLx_positionX:(CGFloat)lx_positionX {
    CGPoint position = self.position;
    position.x = lx_positionX;
    self.position = position;
}

- (CGFloat)lx_positionX {
    return self.position.x;
}

- (void)setLx_positionY:(CGFloat)lx_positionY {
    CGPoint position = self.position;
    position.y = lx_positionY;
    self.position = position;
}

- (CGFloat)lx_positionY {
    return self.position.y;
}

#pragma mark - 动画

- (void)lx_addAnimation:(CAAnimation *)anim
                 forKey:(nullable NSString *)key
             completion:(void (^)(BOOL finished))completion {
    if (completion) {
        anim.delegate = [[_LXAnimationDelegate alloc] initWithCompletion:completion];
    }

    [self addAnimation:anim forKey:key];
}

- (void)setLx_paused:(BOOL)lx_paused {
	if (lx_paused == self.lx_isPaused) {
		return;
	}

    if (lx_paused) {
		CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
		self.speed = 0.0;
		self.timeOffset = pausedTime;
    } else {
		CFTimeInterval pausedTime = self.timeOffset;
		self.speed = 1.0;
		self.timeOffset = 0.0;
		self.beginTime = 0.0;
		CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
		self.beginTime = timeSincePause;
    }
}

- (BOOL)lx_isPaused {
    return self.speed == 0.0;
}

@end

NS_ASSUME_NONNULL_END
