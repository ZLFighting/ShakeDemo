//
//  ZLAudioTool.m
//  ShakeDemo
//
//  Created by 张丽 on 2019/5/16.
//  Copyright © 2019 ZL. All rights reserved.
//

#import "ZLAudioTool.h"
#import <AVFoundation/AVFoundation.h>

@implementation ZLAudioTool

/**
 *  播放音乐
 *
 *  @param filename 音乐的文件名
 */
+ (void)playMusic:(NSString *)filename {
    @try {
        NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
        SystemSoundID soundID = 0;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundID);
        AudioServicesPlaySystemSound(soundID);
    } @catch (NSException *exception) {
        NSLog(@"处理异常%@", exception);
    } @finally {
        NSLog(@"异常完成");
    }
    
}

@end
