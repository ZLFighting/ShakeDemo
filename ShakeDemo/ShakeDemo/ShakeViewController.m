//
//  ViewController.m
//  ShakeDemo
//
//  Created by ZL on 2017/3/28.
//  Copyright © 2017年 ZL. All rights reserved.
//

#import "ShakeViewController.h"
//添加
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "UIView+ZLExtension.h"


/**
 * 在模拟器中运行时，可以通过「Hardware」-「Shake Gesture」来测试「摇一摇」功能
 */

@interface ShakeViewController ()

@property (nonatomic, weak) UIImageView *bgImgView; // 背景图

@property (nonatomic, weak) UIImageView *imgUp; // 上半部图

@property (nonatomic, weak) UIImageView *imgDown; // 下半部图

@property (nonatomic, weak) UIActivityIndicatorView *aiLoad; // 菊花进度

@end

@implementation ShakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"摇一摇";
    
    [self setUpMainUI];
    
    return;
}

#pragma mark - 设置界面UI

- (void)setUpMainUI {
    
    CGFloat UI_View_Width = [UIScreen mainScreen].bounds.size.width;
    CGFloat UI_View_Height = [UIScreen mainScreen].bounds.size.height;

    // 背景图
    UIImageView *bgImgView = [[UIImageView alloc] init];
    bgImgView.frame = self.view.bounds;
    bgImgView.image = [UIImage imageNamed:@"shake_bg"];
    bgImgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgImgView];
    self.bgImgView = bgImgView;
    
    // 上半部分图
    UIImageView *imgUp = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UI_View_Width, UI_View_Height * 0.5)];
    imgUp.image = [UIImage imageNamed:@"shake_up"];
    imgUp.backgroundColor = [UIColor clearColor];
    [bgImgView addSubview:imgUp];
    self.imgUp = imgUp;
    
    // 下半部分图
    UIImageView *imgDown = [[UIImageView alloc] initWithFrame:CGRectMake(0, UI_View_Height * 0.5, UI_View_Width, UI_View_Height * 0.5)];
    imgDown.image = [UIImage imageNamed:@"shake_down"];
    imgDown.backgroundColor = [UIColor clearColor];
    [bgImgView addSubview:imgDown];
    self.imgDown = imgDown;
    
    // 菊花进度
    UIActivityIndicatorView *aiLoad = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    aiLoad.center = self.view.center;
    aiLoad.backgroundColor = [UIColor clearColor];
    [bgImgView addSubview:aiLoad];
    self.aiLoad = aiLoad;
}

- (BOOL)canBecomeFirstResponder {
    
    return YES;
}

#pragma mark - 摇一摇

/**
 *  摇动开始
 */
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    NSLog(@"开始摇了");
    
    // 菊花显示并开始转动
    self.aiLoad.hidden = NO;
    [self.aiLoad startAnimating];
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    CGFloat offset = self.bgImgView.height * 0.5;
    CGFloat duration = 0.4;
    
    [UIView animateWithDuration:duration animations:^{
        self.imgUp.y -= offset;
        self.imgDown.y += offset;
    }];
    
}

/**
 *  摇动结束
 */
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    NSLog(@"摇动结束");
    
    // 不是摇一摇事件则返回
    if (motion != UIEventSubtypeMotionShake) return;
    
    // 1.添加摇动动画
    CGFloat offset = self.bgImgView.height * 0.5;
    CGFloat duration = 0.4;
    [UIView animateWithDuration:duration animations:^{
        self.imgUp.y += offset;
        self.imgDown.y -= offset;
    }];
    
    // 2.设置播放音效
    SystemSoundID soundID;  // shake_sound_male.wav
    NSString *path = [[NSBundle mainBundle ] pathForResource:@"shake_sound_male" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
    // 添加摇动声音
    AudioServicesPlaySystemSound (soundID);
    
    // 3.设置震动
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    // 4.菊花暂停转动并隐藏
    [self.aiLoad stopAnimating];
    self.aiLoad.hidden = YES;
}

/**
 *  摇动取消（被中断，比如突然来电）
 */
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    NSLog(@"摇动取消");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
