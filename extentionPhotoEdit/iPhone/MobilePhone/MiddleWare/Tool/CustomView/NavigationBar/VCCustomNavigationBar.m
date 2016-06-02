//
//  VCCustomNavigationBar.m
//  Custom NavBar
//
//  Created by ljj on 12-7-16.
//  Copyright (c) 2012Âπ?autonavi. All rights reserved.
//

#import "VCCustomNavigationBar.h"

@implementation VCCustomNavigationBar
@synthesize navigationBarBackgroundImage = _navigationBarBackgroundImage;
@synthesize landscapeBarBackground = _landscapeBarBackground;
@synthesize portraitBarBackground = _portraitBarBackground;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    self.isRotate=YES;
    [self setNavigationImage];
    self.navigationBarBackgroundImage=self.portraitBarBackground;
    self.tintColor = [UIColor blackColor];
    //状态栏透明需打开下面代码
    if ([self respondsToSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:)])
    {
        [self setBackgroundImage:self.navigationBarBackgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarStyleDefault];
    }
    else
    {
        [self setBackgroundImage:self.navigationBarBackgroundImage forBarMetrics:UIBarStyleDefault];
        if ([self respondsToSelector:@selector(setShadowImage:)])
        {
              [self setShadowImage:[[[UIImage alloc]init] autorelease]];
        }
       
    }
}
-(void) setNavigationImage
{
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
    {
        if (isPad)
        {
            self.landscapeBarBackground = IMAGE(@"navigatorBarBgOS7.png",IMAGEPATH_TYPE_1);
        }
        else
        {
            self.landscapeBarBackground = IMAGE(@"navigatorBarBglOS7.png",IMAGEPATH_TYPE_1);
        }
        self.portraitBarBackground = IMAGE(@"navigatorBarBgOS7.png",IMAGEPATH_TYPE_1);
    }
    else
    {
        if (isPad)
        {
            self.landscapeBarBackground = IMAGE(@"navigatorBarBg.png",IMAGEPATH_TYPE_1);
        }
        else
        {
            self.landscapeBarBackground = IMAGE(@"navigatorBarBgl.png",IMAGEPATH_TYPE_1);
        }
        self.portraitBarBackground = IMAGE(@"navigatorBarBg.png",IMAGEPATH_TYPE_1);
    }
}

-(void)refeshBackground
{
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self setNavigationImage];
    if(currentOrientation == UIInterfaceOrientationPortrait || currentOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
         self.navigationBarBackgroundImage=self.portraitBarBackground;
    }
    else
    {
        self.navigationBarBackgroundImage=self.landscapeBarBackground;
    }
    
    //状态栏透明需打开下面代码
    if ([self respondsToSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:)])
    {
        [self setBackgroundImage:self.navigationBarBackgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarStyleDefault];
    }
    else
    {
        [self setBackgroundImage:self.navigationBarBackgroundImage forBarMetrics:UIBarStyleDefault];
        if ([self respondsToSelector:@selector(setShadowImage:)])
        {
            [self setShadowImage:[[[UIImage alloc]init] autorelease]];
        }
    }
    [self setNeedsDisplay];
}
-(void)setIsRotate:(BOOL)isRotate
{
    _isRotate=isRotate;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (isRotate) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBackgroundImage:) name:UIDeviceOrientationDidChangeNotification object:NULL];
    }
}

//状态栏透明需屏蔽下面函数
//- (void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
//    if(NSFoundationVersionNumber  <= NSFoundationVersionNumber_iOS_6_1)
//    {
//        UIImage *image = IMAGE(@"viewBackground.png", IMAGEPATH_TYPE_1);
//        [image drawAsPatternInRect:rect];
//    
//        if (self.navigationBarBackgroundImage)
//        {
//            [self.navigationBarBackgroundImage drawAsPatternInRect:rect];
//        }
//    }
//    
//}
- (void)ChangeOrientation:(UIDeviceOrientation)temp
{
    UIDeviceOrientation currentOrientation = temp;
    [self setNavigationImage];
    if(currentOrientation == UIDeviceOrientationPortrait || currentOrientation == UIDeviceOrientationPortraitUpsideDown)
    {
        self.navigationBarBackgroundImage=self.portraitBarBackground;
    }
    else
    {
        self.navigationBarBackgroundImage=self.landscapeBarBackground;
    }
    //状态栏透明需打开下面代码
    if ([self respondsToSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:)])
    {
        [self setBackgroundImage:self.navigationBarBackgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarStyleDefault];
    }
    else
    {
        [self setBackgroundImage:self.navigationBarBackgroundImage forBarMetrics:UIBarStyleDefault];
        if ([self respondsToSelector:@selector(setShadowImage:)])
        {
            [self setShadowImage:[[[UIImage alloc]init] autorelease]];
        }
    }
}

- (void)setBackgroundForDeviceOrientation:(UIDeviceOrientation)orientation;
{
    if (!_isRotate)
    {
        return;
    }
    if (!OrientationSwitch) {
        return;
    }
    
    [self ChangeOrientation:orientation];
    [self setNeedsDisplay];
}

- (void)clearBackground
{
    self.navigationBarBackgroundImage = nil;
    [self setNeedsDisplay];
}

- (void)dealloc {
    self.landscapeBarBackground = nil;
    self.portraitBarBackground = nil;
    self.navigationBarBackgroundImage = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)changeBackgroundImage:(NSNotification *)notification {
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    if ( (currentOrientation == UIDeviceOrientationFaceUp)
        || (currentOrientation == UIDeviceOrientationFaceDown)
        || (currentOrientation == UIDeviceOrientationUnknown)) {
        return;
    }
    [self setBackgroundForDeviceOrientation:currentOrientation];
}

@end
