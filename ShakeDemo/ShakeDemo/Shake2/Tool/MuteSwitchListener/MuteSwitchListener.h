//
//  MuteSwitchListener.h
//  DrawLotsTool
//
//  Created by JSB-ZengJieWu on 2019/3/05.
//  Copyright © 2018年 JSB-ZengJieWu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^MuteSwitchListenerBlock)(BOOL silent);

NS_ASSUME_NONNULL_BEGIN

@interface MuteSwitchListener : NSObject

@property (nonatomic,readonly) BOOL isMute;

@property (nonatomic,copy) MuteSwitchListenerBlock muteListenerBlock;

@property (nonatomic, assign) BOOL shouldBreak;

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
