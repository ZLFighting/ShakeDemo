//
//  Shake2ViewController.m
//  ShakeDemo
//
//  Created by 张丽 on 2019/5/16.
//  Copyright © 2019 ZL. All rights reserved.
//

#import "Shake2ViewController.h"
#import "ZLAudioTool.h"
#import "MuteSwitchListener.h"
#import "UIAlertController+Color.h"

/** 颜色 */
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define MUteSwitchKey @"MuteSwitch"

/** 屏幕宽*/
#define HScreenW [UIScreen mainScreen].bounds.size.width
/** 屏幕高*/
#define HScreenH [UIScreen mainScreen].bounds.size.height


@interface Shake2ViewController () <CAAnimationDelegate>

@property (nonatomic, strong) UIButton *musicBtn;

@property(nonatomic, strong) UIImageView *bgView;

// 背景图
@property (nonatomic, strong) UIImageView *shakeImageView;

@property (nonatomic, strong) UILabel *tipsLabel;

@end

@implementation Shake2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.bgView addSubview:self.shakeImageView];
    [self.bgView addSubview:self.tipsLabel];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.musicBtn];
}

#pragma mark - Getter


- (UIButton *)musicBtn {
    
    if (!_musicBtn) {
        _musicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _musicBtn.imageEdgeInsets = UIEdgeInsetsMake(0,0,0,-25);
        [_musicBtn addTarget:self action:@selector(clickMusicBtn:) forControlEvents:UIControlEventTouchUpInside];
        _musicBtn.imageEdgeInsets = UIEdgeInsetsMake(0,0,0,-25);
        [_musicBtn setImage:[UIImage imageNamed:@"icon_music_on"] forState:UIControlStateNormal];
        [_musicBtn setImage:[UIImage imageNamed:@"icon_music_off"] forState:UIControlStateSelected];
        _musicBtn.selected = ![[[NSUserDefaults standardUserDefaults] objectForKey:MUteSwitchKey] boolValue];
    }
    return _musicBtn;
}

#pragma mark - Btn Click Events
- (void)clickMusicBtn:(UIButton *)sender {
    
    if ([MuteSwitchListener shareInstance].isMute) {
        // 静音按钮打开状态
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请关闭静音按钮" preferredStyle:UIAlertControllerStyleAlert];
        alert.titleColor = UIColorFromRGB(0x333333);
        alert.messageColor = UIColorFromRGB(0x555555);
        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        if([[[NSUserDefaults standardUserDefaults] objectForKey:MUteSwitchKey] boolValue]){
            [ZLAudioTool playMusic:@"click.mp3"];
        }
        sender.selected = !sender.selected;
        if (sender.selected) {
            [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:MUteSwitchKey];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:MUteSwitchKey];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - 执行摇一摇动画
- (void)startShakeAnimation {
    
    [self.shakeImageView.layer removeAnimationForKey:@"shake"];
    CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //设置抖动幅度
    shake.fromValue = [NSNumber numberWithFloat:-0.4];
    shake.toValue = [NSNumber numberWithFloat:+0.4];
    shake.duration = 0.17;
    shake.delegate = self;
    shake.autoreverses = YES;
    //是否重复
    shake.repeatCount = 3;
    [self.shakeImageView.layer addAnimation:shake forKey:@"shake"];
}


#pragma mark - CAAnimationDelegated动画之行结束回调
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:MUteSwitchKey] boolValue]){
        [ZLAudioTool playMusic:@"result.mp3"];
    }
    // TODO:
    NSInteger i = arc4random() % 100;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%ld号签", (long)i] message:[NSString stringWithFormat:@"%ld号内容", (long)i] preferredStyle:UIAlertControllerStyleAlert];
    alertController.titleColor = UIColorFromRGB(0x333333);
    alertController.messageColor = UIColorFromRGB(0x555555);
    [alertController addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 实现相应的响应者方法
/** 开始摇一摇 */
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motionBegan");

    if([[[NSUserDefaults standardUserDefaults] objectForKey:MUteSwitchKey] boolValue]){
        [ZLAudioTool playMusic:@"shake.mp3"];
    }
    [self startShakeAnimation];
}

/** 摇一摇结束（需要在这里处理结束后的代码） */
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motionEnded");
}

/** 摇一摇取消（被中断，比如突然来电） */
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motionCancelled");
}


#pragma mark - 懒加载

- (UIImageView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shakeBg"]];
        _bgView.frame = CGRectMake(0, 0, HScreenW, HScreenH);
        _bgView.contentMode = UIViewContentModeScaleAspectFill;
        _bgView.userInteractionEnabled = YES;
        [self.view addSubview:_bgView];
    }
    return _bgView;
}


- (UIImageView *)shakeImageView {
    if (!_shakeImageView) {
        _shakeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(HScreenW/4, (HScreenH-HScreenW/2-40)/2, HScreenW/2, HScreenW/2)];
        _shakeImageView.image = [UIImage imageNamed:@"shake"];
        _shakeImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _shakeImageView;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.shakeImageView.frame)+35, HScreenW, 18)];
        _tipsLabel.font = [UIFont systemFontOfSize:18.f];
        _tipsLabel.textColor = UIColorFromRGB(0xf3382a); // UIColorFromRGB(0x666666);
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipsLabel;
}

@end

