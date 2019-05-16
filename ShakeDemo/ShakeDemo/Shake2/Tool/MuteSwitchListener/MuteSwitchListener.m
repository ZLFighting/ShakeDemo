//
//  MuteSwitchListener.m
//  DrawLotsTool
//
//  Created by JSB-ZengJieWu on 2019/3/05.
//  Copyright © 2018年 JSB-ZengJieWu. All rights reserved.
//

#import "MuteSwitchListener.h"
#import <AudioToolbox/AudioToolbox.h>

void MuteSwitchListenerNotificationCompletionProc(SystemSoundID  ssID,void* clientData);

@interface MuteSwitchListener()

@property (nonatomic, assign) NSTimeInterval interval;
@property (nonatomic, assign) SystemSoundID soundId;
@property (nonatomic, assign) BOOL isPaused;
@property (nonatomic, assign) BOOL isPlaying;

- (void)complete;

@end

void MuteSwitchListenerNotificationCompletionProc(SystemSoundID  ssID,void* clientData){
    MuteSwitchListener* detecotr = (__bridge MuteSwitchListener*)clientData;
    [detecotr complete];
}

@implementation MuteSwitchListener

- (void)dealloc{
    if (self.soundId != -1){
        AudioServicesRemoveSystemSoundCompletion(self.soundId);
        AudioServicesDisposeSystemSoundID(self.soundId);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init{
    if (self = [super init]){
        
        NSURL* url = [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"MuteSwitchListener" ofType:@"bundle"]] URLForResource:@"silence" withExtension:@"mp3"];
        if (AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &_soundId) == kAudioServicesNoError){
            UInt32 yes = 1;
            AudioServicesAddSystemSoundCompletion(self.soundId,
                                                  CFRunLoopGetMain(),
                                                  kCFRunLoopCommonModes,
                                                  MuteSwitchListenerNotificationCompletionProc,
                                                  (__bridge void *)(self));
            AudioServicesSetProperty(kAudioServicesPropertyIsUISound,
                                     sizeof(_soundId),
                                     &_soundId,
                                     sizeof(yes),
                                     &yes);
            [self performSelector:@selector(loopCheck) withObject:nil afterDelay:1];
        } else {
            self.soundId = -1;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willReturnToForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

+ (instancetype)shareInstance{
    static MuteSwitchListener* sShared = nil;
    if (!sShared)
        sShared = [MuteSwitchListener new];
    return sShared;
}

- (void)setMuteListenerBlock:(MuteSwitchListenerBlock)muteListenerBlock{
    _muteListenerBlock = muteListenerBlock;
}

- (void)scheduleCall{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(loopCheck) object:nil];
    [self performSelector:@selector(loopCheck) withObject:nil afterDelay:1];
}

- (void)complete{
    
    if (self.shouldBreak) {
        return;
    }
    
    self.isPlaying = NO;
    NSTimeInterval elapsed = [NSDate timeIntervalSinceReferenceDate] - self.interval;
    BOOL isMute = elapsed < 0.16; // Should have been 0.5 sec, but it seems to return much faster (0.3something)
    if (self.isMute != isMute) {
        _isMute = isMute;
        if (self.muteListenerBlock)
            self.muteListenerBlock(isMute);
    }
    [self scheduleCall];
}

- (void)loopCheck{
    if (!self.isPaused){
        self.interval = [NSDate timeIntervalSinceReferenceDate];
        self.isPlaying = YES;
        AudioServicesPlaySystemSound(self.soundId);
    }
}

- (void)didEnterBackground{
    self.isPaused = YES;
}

- (void)willReturnToForeground{
    self.isPaused = NO;
    if (!self.isPlaying){
        [self scheduleCall];
    }
}

- (void)setShouldBreak:(BOOL)shouldBreak
{
    _shouldBreak = shouldBreak;
    if (!shouldBreak) {
        [self scheduleCall];
    }
}


@end
