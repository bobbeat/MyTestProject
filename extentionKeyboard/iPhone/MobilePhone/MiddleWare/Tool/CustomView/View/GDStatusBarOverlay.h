//
//  GDStatusBarOverlay.h
//  AutoNavi
//
//  Created by huang longfeng on 13-12-24.
//
//

#import <Foundation/Foundation.h>

@class GDStatusBarOverlay;

typedef void (^GDStatusBarBasicBlock)(void);

typedef enum {
    GDStatusBarOverlayAnimationTypeNone,         /* 无动画 */
    GDStatusBarOverlayAnimationTypeFromTop,      /* 自上而下 */
    GDStatusBarOverlayAnimationTypeFade          /* 淡出 */
} GDStatusBarOverlayAnimationType;

typedef enum {
    GDStatusBarOverlayStatusSuccess,             /* 成功状态栏 */
    GDStatusBarOverlayStatusError                /* 失败状态栏 */
} GDStatusBarOverlayStatus;

@interface GDStatusBarOverlay : UIWindow {
    UIView *_progressView;
}

+ (GDStatusBarOverlay *)shared;

/**
 显示状态栏信息
 
 @param message  显示信息
 @param loading  是否显示菊花
 @param animated 是否动画
 */
+ (void)showWithMessage:(NSString *)message loading:(BOOL)loading animated:(BOOL)animated;

/**
 改变状态栏文字（在已经有显示状态栏都情况下才能显示）
 
 @param message  显示信息
 @param animated 是否动画
 */
+ (void)setMessage:(NSString *)message animated:(BOOL)animated;

/**
 显示状态栏信息（自动隐藏）
 
 @param message  显示信息
 @param duration 显示时间
 @param animated 是否动画
 */
+ (void)showWithAutoHideMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated;

/**
 隐藏状态栏
 
 @param animated 是否动画
 */
+ (void)dismissAnimated:(BOOL)animated;


/**
 改变进度条进度值
 
 @param progress 进度值1-0
 @param animated 是否动画
 */
+ (void)setProgress:(float)progress animated:(BOOL)animated;

/**
 显示菊花
 
 @param show     是否显示
 @param animated 是否动画
 */
+ (void)showActivity:(BOOL)show animated:(BOOL)animated;

/**
 设置状态栏背景颜色
 
 @param backgroundColor 颜色值
 */
+ (void)setBackgroundColor:(UIColor *)backgroundColor;

/**
 设置状态栏样式
 
 @param statusBarStyle  UIStatusBarStyle（状态栏样式）
 @param animated        是否动画
 */
+ (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated;

/**
 设置点击状态栏处理
 
 @param actionBlock  block
 */
+ (void)setActionBlock:(GDStatusBarBasicBlock)actionBlock;

/**
 设置进度条背景颜色
 
 @param backgroundColor 颜色值
 */
+ (void)setProgressBackgroundColor:(UIColor *)backgroundColor;

/**
 设置显示动画
 
 @param animation 动画类型GDStatusBarOverlayAnimationType
 */
+ (void)setAnimation:(GDStatusBarOverlayAnimationType)animation;

@end
