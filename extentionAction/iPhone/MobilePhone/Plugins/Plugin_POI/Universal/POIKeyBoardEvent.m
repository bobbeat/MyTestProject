//
//  POIKeyBoardButton.m
//  AutoNavi
//
//  Created by huang on 13-8-24.
//
//

#import "POIKeyBoardEvent.h"
#import <QuartzCore/QuartzCore.h>
#import "POIDefine.h"


@interface POIKeyBoardEvent()
{
    
}

@end

@implementation POIKeyBoardEvent

-(id)initWithView:(UIView*)view
{
    self=[super init];
    if (self) {
        if (isPad) {
            return self;
        }
        
        _button=[UIButton buttonWithType:UIButtonTypeCustom];
        [_button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_button setBackgroundImage:IMAGE(@"POIKeyboardBtn1.png",IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        _button.frame=CGRectMake(-100, -100, 39, 32);
        [view addSubview:_button];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationReceived:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationReceived:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        UIViewController *viewController= [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            
            isNavigationBarHidden = !viewController.navigationController.isNavigationBarHidden;
        }
        else
        {
            isNavigationBarHidden=NO;
        }
        
        Interface_Flag?[self changeLandscapeControlFrameWithImage]:[self changePortraitControlFrameWithImage];
    }
    return self;
}
-(void)buttonAction:(UIButton *)button
{
    if (self.textFiled) {
        !isShow?[self.textFiled becomeFirstResponder]:[self.textFiled resignFirstResponder];
    }
    if (self.delegate &&[self.delegate respondsToSelector:@selector(keyBoardEvent:)]) {
        [self.delegate keyBoardEvent:isShow];
    }
    NSString *iamgeName = !isShow?@"POIKeyboardBtn1.png":@"POIKeyboardBtn2.png";
    [_button setBackgroundImage:IMAGE(iamgeName,IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
}
-(void)setHiddenButton:(BOOL)isHidden
{
    if (_button) {
        _button.hidden=isHidden;
    }
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.delegate=nil;
    CRELEASE(_textFiled);
    CLOG_DEALLOC(self);
    [super dealloc];
}
#pragma mark -
#pragma mark notification
-(void)notificationReceived:(NSNotification*) notification
{
    
    if ([notification.name isEqualToString: UIApplicationDidChangeStatusBarOrientationNotification]) {
        
        Interface_Flag?[self changeLandscapeControlFrameWithImage]:[self changePortraitControlFrameWithImage];
        return;
    }
    
    
    float height2;
    if (!_button) {
        NSLog(@"按钮不存在");
        return;
    }
    
    _button.layer.anchorPoint=CGPointMake(1, 1);
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue= [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    height2=Interface_Flag==0?APPHEIGHT:APPWIDTH;
    if ([notification.name isEqualToString:UIKeyboardDidShowNotification]) {
        _button.hidden=NO;
        isShow=YES;
        _button.layer.position=CGPointMake(CGRectGetWidth(keyboardRect)-13, height2-CGRectGetHeight(keyboardRect)-navigationBarHeight*isNavigationBarHidden+self.addKeyboardButtonY);
        
    }
    
    else if([notification.name isEqualToString:UIKeyboardWillHideNotification])
    {
        if(_isShowInView==NO)
        {
            _button.hidden=YES;
        }
        _button.layer.position=CGPointMake(CGRectGetWidth(keyboardRect)-13, height2-navigationBarHeight*isNavigationBarHidden+self.addKeyboardButtonY);
        isShow=NO;
    }
    NSString *iamgeName = !isShow?@"POIKeyboardBtn1.png":@"POIKeyboardBtn2.png";
    [_button setBackgroundImage:IMAGE(iamgeName,IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    if (isPad)
        return;
    _button.hidden=NO;
    navigationBarHeight=44*isNavigationBarHidden;
    _button.layer.anchorPoint=CGPointMake(1, 1);
    if (!isShow) {
        if(_isShowInView==NO)
        {
            _button.hidden=YES;
        }
        _button.layer.position=CGPointMake(APPWIDTH-13, APPHEIGHT-navigationBarHeight+self.addKeyboardButtonY);
    }
}
//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    if (isPad)
        return;
    _button.hidden=NO;
    navigationBarHeight=32*isNavigationBarHidden;
    _button.layer.anchorPoint=CGPointMake(1, 1);
    if (!isShow) {
        if(_isShowInView==NO)
        {
            _button.hidden=YES;
        }
        _button.layer.position=CGPointMake(APPHEIGHT-13,APPWIDTH-navigationBarHeight+self.addKeyboardButtonY);
    }
}


@end
