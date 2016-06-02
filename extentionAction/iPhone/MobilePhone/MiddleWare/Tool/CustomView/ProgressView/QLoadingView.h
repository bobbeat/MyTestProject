//
//  QLoadingView.h
//  AutoNavi
//
//  Created by huang longfeng on 11-9-17.
//  Copyright 2011 autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ANParamValue.h"

@interface QLoadingView : UIView {

	UIView *backgroundView;
	UIImageView *imageView;
	UILabel *labelInfo;
	UIImageView *boardView;
	UIActivityIndicatorView *activityView;
	//UINavigationController *navigationController;
	
}
//@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
//@property(nonatomic,retain) UIImageView *imageView;
//@property(nonatomic,readonly) UIActivityIndicatorView *activityView;
+ (id)shareInstance;
/**
 **功能：隐藏loadview
 **输入：animated－是否动画隐藏
 **/
+ (void)hideWithAnimated:(BOOL)animated;
/**
 **功能：显示包含图片的loadingview
 **输入：image－显示图片 info－显示文字内容 autoHide－是否自动隐藏
 **/
+ (void)showImage:(UIImage *)image info:(NSString *)info autoHide:(BOOL)autoHide;
/**
 **功能：将当前视图移到最顶层
 **/
+ (void)bringLoadingViewToFront;
/**
 **功能：显示在传入的view上
 **输入：info－显示的文字内容 view－显示在哪个view上
 **/
+ (void)showLoadingView:(NSString *)info view:(UIWindow *)view;
/**
 **功能：覆盖整个屏幕，屏蔽所有点击事件
 **输入：info－显示的文字内容
 **/
+ (void)showDefaultLoadingView:(NSString *)info;
/**
 **功能：显示可自动隐藏的alertview
 **输入：text－显示的文字内容 time－显示的时间
 **/
+ (void)showAlertWithoutClick:(NSString *)text ShowTime:(float)time;
@end
