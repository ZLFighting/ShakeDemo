//
//  UIAlertController+Color.h
//  ShakeDemo
//
//  Created by zl on 2018/5/31.
//  Copyright © 2018年 zl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Color)

/* 统一按钮样式 不写系统默认的蓝色 */
@property (nonatomic,strong) UIColor *tintColor;

/* 标题的颜色 */
@property (nonatomic,strong) UIColor *titleColor;

/* 信息的颜色 */
@property (nonatomic,strong) UIColor *messageColor;

@end

@interface UIAlertAction (Color)

/* 按钮title字体颜色 */
@property (nonatomic,strong) UIColor *textColor;

@end
