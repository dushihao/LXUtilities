//
//  UIApplication+LXExtension.h
//
//  Created by 从今以后 on 16/2/1.
//  Copyright © 2016年 从今以后. All rights reserved.
//

@import UIKit;
@class AppDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (LXExtension)

/// `sharedApplication` 的代理。
+ (AppDelegate<UIApplicationDelegate> *)lx_delegate;

/// 打开各种系统设置
+ (BOOL)lx_openPrefsWithString:(NSString *)aString;

@end

NS_ASSUME_NONNULL_END
