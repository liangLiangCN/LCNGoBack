//
//  UINavigationController+LCNGoBack.h
//  右滑返回上一级
//
//  Created by 梁川楠 on 16/8/11.
//  Copyright © 2016年 liangLiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (LCNGoBack)

/**
 *  自定义全屏拖拽返回手势
 */
@property (nonatomic,strong,readonly) UIPanGestureRecognizer *lcn_popGestureRecognizer;

@end
