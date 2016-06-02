//
//  QLoadingView.m
//  AutoNavi
//
//  Created by huang longfeng on 11-9-17.
//  Copyright 2011 autonavi. All rights reserved.


#import "QLoadingView.h"

#define MainView ((UIWindow *)[[UIApplication sharedApplication].windows objectAtIndex:0]).rootViewController.view

#define LOADINGVIEW_SHOW_DURATION 2
#define LOADINGVIEW_ANIMATE_DURATION 1

@protocol QLoadingView
- (void)hideWithAnimate;

@end

static QLoadingView *sShareLoadingView;

@implementation QLoadingView

+ (id)shareInstance
{
	if(sShareLoadingView == nil)
	{
		sShareLoadingView = [[self alloc] initWithFrame:CGRectMake(200, 200, 200, 200)];
	}
	return sShareLoadingView;
}

- (id)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundColor = [UIColor clearColor];
		
		backgroundView = [[UIView alloc] initWithFrame:self.bounds];
		backgroundView.backgroundColor = [UIColor blackColor];
		backgroundView.alpha = 0.2;
		backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:backgroundView];
		
		UIViewAutoresizing viewAutoResizing = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |
		UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		
		boardView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"info_bkg.png" ]];
        
        [boardView setFrame:CGRectMake(0.0, 0.0, 130.0, 120.0)];
		boardView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2 );
		boardView.autoresizingMask = viewAutoResizing;
		//boardView.userInteractionEnabled = YES;
		
		[self addSubview:boardView];
		
		
		activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityView.center = CGPointMake(boardView.bounds.size.width/2, 40);
		activityView.hidesWhenStopped = YES;
		[boardView addSubview:activityView];
		
		labelInfo = [[UILabel alloc] initWithFrame:CGRectMake(boardView.bounds.size.width/2 - 60,
															  60, boardView.bounds.size.width - 10.0, 60)];
		labelInfo.numberOfLines = 2;
		labelInfo.backgroundColor = [UIColor clearColor];
		labelInfo.textAlignment = NSTextAlignmentCenter;
		labelInfo.textColor = [UIColor whiteColor];
		labelInfo.font = [UIFont systemFontOfSize:16];
		labelInfo.shadowColor = [UIColor blackColor]; 
		labelInfo.shadowOffset = CGSizeMake(0, 1.0);
		[boardView addSubview:labelInfo];
	    
		imageView = [[UIImageView alloc] initWithFrame:CGRectMake(boardView.bounds.size.width/2 - 41, 
																  15, 81, 38)];
		//imageView.userInteractionEnabled = YES;
		[boardView addSubview:imageView];
		imageView.hidden = YES;
	}
	
	return self;
}

- (void)dealloc
{
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)autoHide
{
	[self performSelector:@selector(hideWithAnimate) withObject:nil afterDelay:LOADINGVIEW_SHOW_DURATION];
}

- (void)hideWithAnimate
{
	if(self.superview !=nil)
	{
		self.alpha = 1.0f;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.5];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
		self.alpha = 0.0f;
        
		[UIView commitAnimations];
		
		//[[NSNotificationCenter defaultCenter] postNotificationName:loadingview  object:nil];
		
	}
}

- (void)setImage:(UIImage *)image
{
	if(image)
	{
		imageView.image = image;
        imageView.frame = CGRectMake(0,
                                     0,
                                     image.size.width,
                                     image.size.height);
        imageView.center = CGPointMake(boardView.frame.size.width / 2, boardView.frame.size.height / 2 - 12.0f);
		imageView.hidden = NO;
		[activityView stopAnimating];
	}else
	{
		imageView.hidden = YES;
		activityView.hidden = NO;
		[activityView startAnimating];
	}
}

- (void)setModelInView:(BOOL)value
{
	backgroundView.hidden = !value;
	if(value)
	{
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}else
	{
		self.bounds = boardView.bounds;
		self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
		| UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	}	
}


- (void)setInfo:(NSString *)info
{
	labelInfo.text = info;
    if (!info || [info length] == 0) {
        activityView.center = CGPointMake(boardView.bounds.size.width/2, boardView.bounds.size.height/2);
    }
    else{
        activityView.center = CGPointMake(boardView.bounds.size.width/2, 40);
    }
    
}


#pragma mark -
#pragma mark class methods

+ (void)showInView:(UIWindow *)view image:(UIImage *)image info:(NSString *)info 
		  animated:(BOOL)animated modeled:(BOOL)modeled autoHide:(BOOL)autoHide
{
	
	
	sShareLoadingView = [QLoadingView shareInstance];
	[sShareLoadingView removeFromSuperview];
	sShareLoadingView.frame = view.bounds;
	sShareLoadingView.autoresizesSubviews = YES;

	// setImage
	[sShareLoadingView setImage:image];
	
	//setInfo
	[sShareLoadingView setInfo:info];
	//setModelInView
	[sShareLoadingView setModelInView:modeled];
	
	
	//setAnimated
	if(animated)
	{
		sShareLoadingView.alpha = 0.0f;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:LOADINGVIEW_ANIMATE_DURATION];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		sShareLoadingView.alpha = 1.0f;
		[UIView commitAnimations];
		
	}else
	{
		sShareLoadingView.alpha = 1.0f;
	}
	
	if(autoHide)
	{
		[sShareLoadingView autoHide];
	}
	
	[view addSubview:sShareLoadingView];
}
/**
 **功能：隐藏loadview
 **输入：animated－是否动画隐藏
 **/
+ (void)hideWithAnimated:(BOOL)animated
{
	sShareLoadingView = [QLoadingView shareInstance];
    animated = NO;
	if(animated)
	{
		[sShareLoadingView hideWithAnimate];
	}else
	{
		[sShareLoadingView removeFromSuperview];
	}
	
	
	
	
}
/**
 **功能：显示包含图片的loadingview
 **输入：image－显示图片 info－显示文字内容 autoHide－是否自动隐藏
 **/
+ (void)showImage:(UIImage *)image info:(NSString *)info autoHide:(BOOL)autoHide
{
	
	[QLoadingView showInView:(UIWindow *)MainView image:image 
					  info:info animated:NO modeled:NO autoHide:autoHide];
}
/**
 **功能：将当前视图移到最顶层
 **/
+ (void)bringLoadingViewToFront
{
    sShareLoadingView = [QLoadingView shareInstance];
    UIView *superview = [sShareLoadingView superview];
    if (superview && sShareLoadingView)
    {
        [superview bringSubviewToFront:sShareLoadingView];
    }
}
/**
 **功能：显示在传入的view上
 **输入：info－显示的文字内容 view－显示在哪个view上
 **/
+ (void)showLoadingView:(NSString *)info view:(UIWindow *)view
{
	
	[QLoadingView showInView:view 
					   image:nil
						info:info 
					animated:NO modeled:YES autoHide:NO];
}
/**
 **功能：覆盖整个屏幕，屏蔽所有点击事件
 **输入：info－显示的文字内容
 **/
+ (void)showDefaultLoadingView:(NSString *)info 
{
	
	
	[QLoadingView showInView:(UIWindow *)MainView
					   image:nil
						info:info 
					animated:NO modeled:YES autoHide:NO];
}


@end
