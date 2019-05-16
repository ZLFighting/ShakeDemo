# ShakeDemo
iOS-高仿微信摇一摇动画效果加震动音效

众所周知, 微信中的摇一摇功能: 搜索人/歌曲/电视，同样在一些其他类APP中也有一个摇一摇签到, 摇一摇随机选号等功能，下面以微信摇一摇功能来介绍实现原理.

![](https://github.com/ZLFighting/ShakeDemo/blob/master/ShakeDemo/Shake2.gif)

> 第2种实现，相比第一种：
1. 优化了摇动手机页面，整体的摇动而不是之前第一种的两半式的摇动
2. 新增摇动声音的开关控制，可单独做声音控制工具类


![](https://github.com/ZLFighting/ShakeDemo/blob/master/ShakeDemo/Shake1.gif)

> 第1种实现步骤:
1. 监听摇一摇方法
2. 解决摇一摇失效的情况.
3. 摇一摇阶段需要震动及声音.
4. 摇一摇阶段需要动画效果.

对于摇一摇功能, 在iOS中系统默认为我们提供了摇一摇的功能检测API.  iOS 中既然已经提供了接口, 我们直接调用就好了.
```
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
```

## 实现原理 ##

**1. 监听摇一摇方法 **
```
// 摇一摇开始
- (void)motionBegan:(UIEventSubtype)motion withEvent:(nullable UIEvent *)event NS_AVAILABLE_IOS(3_0);
// 摇一摇结束
- (void)motionEnded:(UIEventSubtype)motion withEvent:(nullable UIEvent *)event NS_AVAILABLE_IOS(3_0);
// 摇一摇取消
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(nullable UIEvent *)event NS_AVAILABLE_IOS(3_0);
```
**2. 解决摇一摇失效的情况.**
ps: 使用 Xcode6.x 后创建的项目,仅仅实现第一步监听就可以实现,没有遇到这种问题.
```
- (BOOL)canBecomeFirstResponder {
return YES;
}
```
**3. 摇一摇阶段需要震动及声音.**
```
// 摇动开始
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
```
```
// 摇动结束
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {

if (motion ==UIEventSubtypeMotionShake ) {

// 1.添加摇动动画
// 见第四点, 推荐第四点的方法二

// 2.设置播放音效
SystemSoundID soundID;
NSString *path = [[NSBundle mainBundle ] pathForResource:@"shake_sound_male" ofType:@"wav"];
AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
// 添加摇动声音
AudioServicesPlaySystemSound (soundID);

// 3.设置震动
AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
}
```
**4. 摇一摇阶段需要动画效果.**
微信的摇一摇功能是先在视图上放一个摇后要显示的图片:手拿手机的图片, 这个图片就是上下两半拼在一起给人一种一张图片的感觉；当检测到摇一摇 捕捉到晃动事件后，上下两张图片分别上下做一个动画移动(上面的一半往上移,下面的往下移)，在completion 里面再移回来.

这里有两种方法:
**方法一: 抽出来添加动画效果的方法, 在摇一摇结束方法里添加这个方法.**
```
- (void)addAnimations {

// 让imgup上下移动
CABasicAnimation *translation2 = [CABasicAnimation animationWithKeyPath:@"position"];
translation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
translation2.fromValue = [NSValue valueWithCGPoint:CGPointMake(160, 115)];
translation2.toValue = [NSValue valueWithCGPoint:CGPointMake(160, 40)];
translation2.duration = 0.5;
translation2.repeatCount = 1;
translation2.autoreverses = YES;

// 让imagdown上下移动
CABasicAnimation *translation = [CABasicAnimation animationWithKeyPath:@"position"];
translation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
translation.fromValue = [NSValue valueWithCGPoint:CGPointMake(160, 345)];
translation.toValue = [NSValue valueWithCGPoint:CGPointMake(160, 420)];
translation.duration = 0.5;
translation.repeatCount = 1;
translation.autoreverses = YES;

[self.imgDown.layer addAnimation:translation forKey:@"translation"];
[self.imgUp.layer addAnimation:translation2 forKey:@"translation2"];
}
```
**方法二. 在摇一摇开始和结束里添加摇动动画效果及菊花效果**
```
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

// 菊花暂停转动并隐藏
[self.aiLoad stopAnimating];
self.aiLoad.hidden = YES;
}
```
当然也有使用摇一摇做其他功能的,可以在当结束摇动时，就发送一个网络请求作相关操作即可。

您的支持是作为程序媛的我最大的动力, 如果觉得对你有帮助请送个Star吧,谢谢啦
