//
//  UINavigationController+LCNGoBack.m
//  右滑返回上一级
//
//  Created by 梁川楠 on 16/8/11.
//  Copyright © 2016年 liangLiang. All rights reserved.
//

#import "UINavigationController+LCNGoBack.h"
#import <objc/runtime.h>

@interface LCNFullScreenPopGestureRecongizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic,weak) UINavigationController *navigationController;

@end

@implementation LCNFullScreenPopGestureRecongizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    
    // 判断是否是根控制器，如果是，取消手势
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }
    
    // 如果正在转场动画，取消手势
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    // 判断手指移动方向
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    if (translation.x <= 0) {
        return NO;
    }
    
    return YES;
}

@end

@implementation UINavigationController (LCNGoBack)

#pragma mark - 在此方法中, 交换系统的 pushViewController: animated: 方法 和自定义的 lcn_pushViewController: animated: 方法
+ (void)load {
    
    Method originalMethod = class_getInstanceMethod([self class], @selector(pushViewController:animated:));
    Method newMethod = class_getInstanceMethod([self class], @selector(lcn_pushViewController:animated:));
    
    // 交换方法
    method_exchangeImplementations(originalMethod, newMethod);
}

- (void)lcn_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // 首先判断手势有没有添加成功
    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.lcn_popGestureRecognizer]) {
        // 如果没有添加成功, 再添加
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.lcn_popGestureRecognizer];
        
        NSArray *targets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        
        id internalTarget = [targets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        
        self.lcn_popGestureRecognizer.delegate = [self lcn_fullScreenPopGestureRecongizerDelegate];
        
        [self.lcn_popGestureRecognizer addTarget:internalTarget action:internalAction];
        
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    // push 到目标控制器
    if (![self.viewControllers containsObject:viewController]) {
        [self lcn_pushViewController:viewController animated:YES];
    }
}

- (LCNFullScreenPopGestureRecongizerDelegate *)lcn_fullScreenPopGestureRecongizerDelegate {
    
    LCNFullScreenPopGestureRecongizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
    
    if (!delegate) {
        delegate = [[LCNFullScreenPopGestureRecongizerDelegate alloc] init];
        
        delegate.navigationController = self;
        
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return delegate;
}

#pragma mark - 实现get方法
- (UIPanGestureRecognizer *)lcn_popGestureRecognizer {
    UIPanGestureRecognizer *panGestureRecognizer = objc_getAssociatedObject(self, _cmd);
    
    if (panGestureRecognizer == nil) {
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        
        objc_setAssociatedObject(self, _cmd, panGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return panGestureRecognizer;
}

@end
