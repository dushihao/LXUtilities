//
//  UIViewController+LXExtension.m
//
//  Created by 从今以后 on 15/10/13.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "UIViewController+LXExtension.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIViewController (LXExtension)

#pragma mark - 各种条栏 -

- (nullable UITabBar *)lx_tabBar
{
    return self.tabBarController.tabBar;
}

- (nullable UIToolbar *)lx_toolBar
{
	return self.navigationController.toolbar;
}

- (nullable UINavigationBar *)lx_navigationBar
{
    return self.navigationController.navigationBar;
}

#pragma mark - 实例化方法 -

+ (instancetype)lx_instantiateWithStoryboardName:(NSString *)storyboardName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *viewController = [storyboard instantiateInitialViewController];
    NSAssert(viewController, @"%@ 故事版中未指定初始视图控制器", storyboardName);
    return viewController;
}

+ (instancetype)lx_instantiateWithStoryboardName:(NSString *)storyboardName
                                      identifier:(nullable NSString *)identifier
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];

    if (identifier) {
        return [storyboard instantiateViewControllerWithIdentifier:identifier];
    }

    identifier = NSStringFromClass(self);
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    NSAssert(viewController, @"%@ 故事版中的 %@ 视图控制器未指定标识符", storyboardName, identifier);
    return viewController;
}

@end

NS_ASSUME_NONNULL_END
