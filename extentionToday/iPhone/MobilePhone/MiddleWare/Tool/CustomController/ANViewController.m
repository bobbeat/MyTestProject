
//
//  ViewControllerMO.m
//  AutoNavi
//
//  Created by GHY on 12-3-14.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ANViewController.h"
#import "ANParamValue.h"
#import "QLoadingView.h"
#import "ControlCreat.h"
#import "VCCustomNavigationBar.h"
#import "GDActionSheet.h"
#import "GDAlertView.h"
#import "PaintingView.h"

@interface ANViewController ()
{
    
}



@end
@implementation ANViewController
@synthesize gdtitle;

- (void)reloadBackgroundImage  //重现加载背景图片
{
    self.view.layer.contents = (id)[self getBackgroundViewImage].CGImage;
}

- (UIImage *)getBackgroundViewImage
{
    UIImage *image = IMAGE(@"viewBackground.png", IMAGEPATH_TYPE_1);
    if (!image)
    {
        return nil;
    }
    UIView *view = self.view;
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0,view.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    [image drawAsPatternInRect:view.bounds];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (id)init 
{
	self = [super init];
	if (self) 
	{
		
	}
	return self;
}

#pragma mark - UIViewController delegate methods

- (void)dealloc 
{
    self.gdtitle = nil;
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad 
{
	[super viewDidLoad];

    //IOS 7
    if(IOS_7)
    {
        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars=NO;
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    
}
//IOS7
//状态栏透明需屏蔽此函数
//-(void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    
//    if (self.navigationController &&self.navigationController.navigationBarHidden==NO) {
//        return;
//    }
//    if (IOS_7) {
//        CGRect rect=[[UIScreen mainScreen] applicationFrame];
//        rect.origin.x=0;
//        rect.origin.y=20;
//        rect.size.width=CCOMMON_APP_WIDTH;
//        rect.size.height=CCOMMON_APP_HEIGHT;
//        self.view.frame=rect;
////        [self changeLogicAfterRotation];
//    }
//    
//}
- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
    if ([UIApplication sharedApplication].idleTimerDisabled == NO)//modify by gzm for 设置任意一个poi导航后，该值会成为了NO，变成了会自动锁屏，要重新设置成YES at 2014-10-31
    {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
    self.view.layer.contents = (id)[self getBackgroundViewImage].CGImage;
    [self changeLogicAfterRotation];
    [self changeControlText];
}


-(void)setTitle:(NSString *)title
{
    self.gdtitle = title;
    UIView *custom = self.navigationItem.rightBarButtonItem.customView;
    int buttonWith = 0;
    //add by gzm for 导航栏右边按钮隐藏时，不取长度 at 2014-7-23
    if (custom.hidden == NO)
    {
        buttonWith = custom.frame.size.width;
    }
    //add by gzm for 导航栏右边按钮隐藏时，不取长度 at 2014-7-23
    if (buttonWith <= 50)
    {
        buttonWith = 50;
    }
    int lable_width = self.view.bounds.size.width - 2 *buttonWith - 10;
    int lable_height = 44;
    if (isiPhone)
    {
        if (Interface_Flag == 1)
        {
            lable_height = 32;
        }

    }
    UILabel *label;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    view.backgroundColor = [UIColor clearColor];
    
    UIFont *font=[UIFont systemFontOfSize:kSize1];
    label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, lable_width, lable_height)];
    label.center = CGPointMake(5, 5);
    label.backgroundColor=[UIColor clearColor];
    label.font = font;
    label.text=title;
    label.tag = 112;
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=NAVIGATIONBARTITLECOLOR;
    [view addSubview: label];
    [label release];
    
    self.navigationItem.titleView = view;
    [view release];
   
}

- (void)viewDidAppear:(BOOL)animated
{
    [MapViewManager ClearBufferViewSuperview];  //在每次view显示的时候，需要将MapViewManager中缓存视图中从superview上移除，用于下次添加。
    [super viewDidAppear:animated];
    [self setTitle:self.gdtitle];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
//        self.view.backgroundColor=RGBCOLOR(237, 237, 237);
		[self landscapeLogic];
        [self changeLandscapeControlFrameWithImage];
	}
	else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{

//        self.view.backgroundColor=RGBCOLOR(237, 237, 237);
		[self portraitLogic];
        [self changePortraitControlFrameWithImage];
    }
    self.view.layer.contents = (id)[self getBackgroundViewImage].CGImage;
    [self setTitle:self.gdtitle];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (!OrientationSwitch)
    {
        return (Orientation == interfaceOrientation);
    }
    
	return  YES;
}

//横屏逻辑处理
- (void)landscapeLogic
{
	
}

//竖屏逻辑处理
- (void)portraitLogic
{
	
}

//调整竖屏控件坐标和图片 
-(void)changePortraitControlFrameWithImage
{
    
}

//调整横屏控件坐标和图片 
-(void)changeLandscapeControlFrameWithImage
{
    
}

-(void)changeLogicAfterRotation
{
    if (Interface_Flag == 0)
    {
        [self portraitLogic];
        [self changePortraitControlFrameWithImage];
    }
    else if(Interface_Flag == 1)
    {
        [self landscapeLogic];
        [self changeLandscapeControlFrameWithImage];
    }
}

//改变控制文本
-(void)changeControlText
{
    
}
#pragma mark -
#pragma mark 常用控件创建
#pragma mark ---------------------------------------------------------------------------------------------------------------
#pragma mark UIButton
- (UIButton *)createButtonWithTitle:(NSString *)titleT normalImage:(NSString *)normalImage heightedImage:(NSString *)heightedImage tag:(NSInteger)tagN
{
	UIButton *button = [ControlCreat createButtonWithTitle:titleT normalImage:normalImage heightedImage:heightedImage tag:tagN];
	
	[button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}


- (UIButton *)createButtonWithTitle:(NSString *)titleT normalImage:(NSString *)normalImage heightedImage:(NSString *)heightedImage tag:(NSInteger)tagN withImageType:(IMAGEPATHTYPE)type
{
	UIButton *button = [ControlCreat createButtonWithTitle:titleT normalImage:normalImage heightedImage:heightedImage tag:tagN withImageType:type];
	
	[button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}


// 添加带拉伸参数的初始化函数lyh10-25
- (UIButton*)createButtonWithTitle:(NSString *)titleT normalImage:(NSString *)normalImage heightedImage:(NSString *)heightedImage tag:(NSInteger)tagN strechParamX:(NSInteger)xParam strechParamY:(NSInteger)yParam
{
	UIButton *button = [ControlCreat createButtonWithTitle:titleT normalImage:normalImage heightedImage:heightedImage tag:tagN strechParamX:xParam strechParamY:yParam];
	
	[button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

- (UIButton*)createButtonWithTitle:(NSString *)titleT normalImage:(NSString *)normalImage heightedImage:(NSString *)heightedImage tag:(NSInteger)tagN strechParamX:(NSInteger)xParam strechParamY:(NSInteger)yParam withType:(IMAGEPATHTYPE)type
{
	UIButton *button = [ControlCreat createButtonWithTitle:titleT normalImage:normalImage heightedImage:heightedImage tag:tagN strechParamX:xParam strechParamY:yParam withType:type];
	
	[button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}


- (ANButton *)createANButtonWithTitle:(NSString *)title 
								image:(UIImage *)image
						 imagePressed:(UIImage *)imagePressed
							 imageTop:(UIImage *)imageTop 
								  tag:(NSInteger)tagN
                      textOffsetValue:(CGFloat)textOffsetValue
{	
	ANButton *button = [ControlCreat createANButtonWithTitle:title image:image imagePressed:imagePressed imageTop:imageTop tag:tagN textOffsetValue:textOffsetValue];
	
	[button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];

	return button;
}

#pragma mark UIActivityIndicatorView
- (UIActivityIndicatorView *)createActivityIndicatorViewWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style
{
	
	return [ControlCreat createActivityIndicatorViewWithActivityIndicatorStyle:style];
}


#pragma mark UILabel
- (UILabel *)createLabelWithText:(NSString *)text fontSize:(CGFloat)size textAlignment:(UITextAlignment)textAlignment
{
	
	return [ControlCreat createLabelWithText:text fontSize:size textAlignment:textAlignment];
}


#pragma mark － UISearchBar
- (UISearchBar *)createSearchBarWithPlaceholder:(NSString *)placeholder tag:(NSInteger)tag
{
	
	return [ControlCreat createSearchBarWithPlaceholder:placeholder tag:tag];
}


#pragma mark － UIActionSheet

- (GDActionSheet *)createGDActionSheetWithTitle:(NSString *)titleT
                                       delegate:(id<GDActionSheetDelegate>)delegate
							cancelButtonTitle:(NSString *)cancelButtonTitle
                       destructiveButtonTitle:(NSString *)destructiveButtonTitle
                                          tag:(NSInteger)tagN
							otherButtonTitles:(NSString*)other,...

{
    va_list list;
    va_start(list, other);
    
    GDActionSheet *actionSheet = [[GDActionSheet alloc] initWithTitle:titleT
                                                             delegate:delegate
                                                    cancelButtonTitle:cancelButtonTitle
                                               destructiveButtonTitle:destructiveButtonTitle
                                                    otherButtonTitles:nil];
    actionSheet.tag = tagN;
    NSString *string=other;//va_arg(list, (NSString*));
    while (string) {
        [actionSheet addOtherButton:string];
        string= va_arg(list,NSString*);
    }
    
    [actionSheet ShowOrHiddenActionSheet:YES Animation:YES];
    
    return [actionSheet autorelease];
    
}

- (UIActionSheet *)createActionSheetWithTitle:(NSString *)titleT
							cancelButtonTitle:(NSString *)cancelButtonTitle
                       destructiveButtonTitle:(NSString *)destructiveButtonTitle
                                            tag:(NSInteger)tagN
							otherButtonTitles:(NSString*)other,...
										  
{
    va_list list;
    va_start(list, other);
    
   UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:titleT
                                              delegate:self
                                     cancelButtonTitle:nil
                                destructiveButtonTitle:nil
                                     otherButtonTitles:nil];

    NSString *string=other;//va_arg(list, (NSString*));
    while (string) {
        [actionSheet addButtonWithTitle:string];
        string= va_arg(list,NSString*);
    }
    if(destructiveButtonTitle != nil)
    {
        [actionSheet addButtonWithTitle:destructiveButtonTitle];
        actionSheet.destructiveButtonIndex=actionSheet.numberOfButtons-1;
    }
    if(cancelButtonTitle != nil)
    {
        [actionSheet addButtonWithTitle:cancelButtonTitle];
        actionSheet.cancelButtonIndex=actionSheet.numberOfButtons-1;
    }
    actionSheet.tag = tagN;
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
   
    return [actionSheet autorelease];
    
}

- (UIActionSheet *)createActionSheetWithTitle:(NSString *)titleT
							cancelButtonTitle:(NSString *)cancelButtonTitle
                       destructiveButtonTitle:(NSString *)destructiveButtonTitle
							otherButtonTitles:(NSArray *)otherButtonTitles
										  tag:(NSInteger)tagN
{
	UIActionSheet *actionSheet = [ControlCreat createActionSheetWithTitle:titleT cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles tag:tagN];
	
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
	return actionSheet;
}



#pragma mark - UIAlertView
- (GDAlertView *)createAlertViewWithTitle:(NSString *)titleT
								  message:(NSString *)message
						cancelButtonTitle:(NSString *)cancelButtonTitle
						otherButtonTitles:(NSArray *)otherButtonTitles 
									  tag:(NSInteger)tagN
{
    __block id weakself = self;
    GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:titleT andMessage:message];
    alertView.tag = tagN;
    if (cancelButtonTitle) {
        [alertView addButtonWithTitle:cancelButtonTitle type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView) {
            if (weakself && [weakself respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
            {
                [weakself alertView:(UIAlertView *)alertView clickedButtonAtIndex:0];
            }
        }];
    }
    if (otherButtonTitles && otherButtonTitles.count > 0) {
        for (int i = 0 ; i < [otherButtonTitles count] ; i++) {
            [alertView addButtonWithTitle:[otherButtonTitles objectAtIndex:i] type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView) {
                if (weakself && [weakself respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
                {
                    int clickIndex = 0;
                    if (cancelButtonTitle) {
                        clickIndex = i + 1;
                    }
                    else{
                        clickIndex = i;
                    }
                    [weakself alertView:(UIAlertView *)alertView clickedButtonAtIndex:clickIndex];
                }
            }];
        }
    }
    
    [alertView show];
    
    return [alertView autorelease];
    
}

#pragma mark - UITextView
- (UITextView *)createTextViewWithTitle:(NSString *)text fontSize:(CGFloat)size textAlignment:(UITextAlignment)textAlignment tag:(NSInteger)tag
{
	UITextView *textView = [ControlCreat createTextViewWithTitle:text fontSize:size textAlignment:textAlignment tag:tag];
    
	textView.delegate = self;
	return textView;
}

#pragma mark - UITextField
- (UITextField *)createTextFieldWithPlaceholder:(NSString *)text fontSize:(CGFloat)size tag:(NSInteger)kViewTag
{
	
    UITextField *textFieldRounded = [ControlCreat createTextFieldWithPlaceholder:text fontSize:size tag:kViewTag];
    
    textFieldRounded.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
		
	return textFieldRounded;
}

#pragma mark ---  UISwitch  ---
- (UISwitch *) createSwitchWithFrame:(CGRect)frame tag:(NSInteger)kSwitchtag
{
    
    return [ControlCreat createSwitchWithFrame:frame tag:kSwitchtag];
}

/***************************************************************************************************************
 * 函数名称: - (KLSwitch *) createKLSwitchWithTag:(NSInteger)kSwitchtag selector:(SEL)selector;
 * 功能描述: KLSwitch控件创建
 * 参    数:   kSwitchtag：标记 selector:执行函数
 * 返 回 值: KLSwitch
 * 其它说明:
 ****************************************************************************************************************/
- (KLSwitch *) createKLSwitchWithTag:(NSInteger)kSwitchtag selector:(SEL)selector
{
    return [ControlCreat createKLSwitchWithTag:kSwitchtag target:self selector:selector];
}

#pragma mark ---  UISlider  ---
- (UISlider *) createSliderWithFrame:(CGRect)frame
                           minValue:(float)sliderMiniValue
                           maxValue:(float)sliderMaxValue
                        appearValue:(float)appearVlaue
                                tag:(NSInteger)ktag
{
    
    return [ControlCreat createSliderWithFrame:frame minValue:sliderMiniValue maxValue:sliderMaxValue appearValue:appearVlaue tag:ktag];
}

- (UISlider *) createCustomSliderWithFrame:(CGRect)frame
                                leftTrack:(UIImage *)leftImage
                               rightTrack:(UIImage *)rightImage
                          silderBallImage:(UIImage *)ballImage
                                 minValue:(float)sliderMiniValue
                                 maxValue:(float)sliderMaxValue
                              appearValue:(float)appearVlaue
                                      tag:(NSInteger)ktag
{
   
    return [ControlCreat createCustomSliderWithFrame:frame leftTrack:leftImage rightTrack:rightImage silderBallImage:ballImage minValue:sliderMiniValue maxValue:sliderMaxValue appearValue:appearVlaue tag:ktag];
}

#pragma mark ---  UIProgressView  ---
- (UIProgressView *) createProgressWithFrame:(CGRect)frame
                           viewProgressStyle:(UIProgressViewStyle) progressStyle
                               progressValue:(float) progress
                                         tag:(NSInteger)ktag
{
    
    return [ControlCreat createProgressWithFrame:frame viewProgressStyle:progressStyle progressValue:progress tag:ktag];
}

#pragma mark ---  UIPickView  ---
- (UIPickerView *) createPickViewWithFrame : (CGRect) frame tag:(NSInteger)ktag
{
    
    return  [ControlCreat createPickViewWithFrame:frame tag:ktag];
}

#pragma mark ---  UIImageView  ---
- (UIImageView *) createImageViewWithFrame: (CGRect) frame
                               normalImage:(UIImage *)normalImage
                                       tag:(NSInteger)ktag
{
    return  [ControlCreat createImageViewWithFrame:frame normalImage:normalImage tag:ktag];
}

#pragma mark ---  UIWebView  ---
- (UIWebView *) createWebViewWithFrame: (CGRect) frame
                                   tag:(NSInteger)ktag
{
    
    return [ControlCreat createWebViewWithFrame:frame tag:ktag];
}

#pragma mark ---  UITableView  ---
- (UITableView *) createTableViewWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    
    return [ControlCreat createTableViewWithFrame:frame style:style];
}


#pragma mark - LoadingView
#pragma mark ----------------------------------------------------------------------------------------------------------------

- (void)showDefaultLoadingView:(NSString *)string
{
    [QLoadingView showDefaultLoadingView:string];
}

- (void)showLoadingViewInView:(NSString *)string view:(UIView *)view
{
    [QLoadingView showLoadingView:string view:(UIWindow *)view];
}

- (void)showAutoHideAlertView:(NSString *)string showTime:(float)time
{
    [QLoadingView showAlertWithoutClick:string ShowTime:time];
}

- (void)hideLoadingViewWithAnimated:(BOOL)animated
{
    [QLoadingView hideWithAnimated:animated];
}
@end


