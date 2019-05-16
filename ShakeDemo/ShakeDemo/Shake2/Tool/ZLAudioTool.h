//
//  ZLAudioTool.h
//  ShakeDemo
//
//  Created by 张丽 on 2019/5/16.
//  Copyright © 2019 ZL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLAudioTool : NSObject

/**
 *  播放音乐
 *
 *  @param filename 音乐的文件名
 */
+ (void)playMusic:(NSString *)filename;

@end

NS_ASSUME_NONNULL_END
