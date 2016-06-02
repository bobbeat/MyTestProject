//
//  SoundGuideView.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-6-18.
//
//

#import "SoundGuideView.h"
#import "KLSwitch.h"

#define BACKGROUND_IMAGE    IMAGE(@"main_soundTips.png", IMAGEPATH_TYPE_1)
#define BACKGROUND_FRAME    CGRectMake(0, 0, 276.0f,106)

@interface SoundGuideView()
{
    CGRect _hiddenRect;     //隐藏的按钮的位置
    UILabel *_titleLabel;   //message label
    UILabel *_welcomeLabel; //欢迎语框
    UIButton *_buttonClose;  //关闭
    KLSwitch *_switch;  //switch开关
    UIImageView *_lineImageView;    //红线
}

@end

@implementation SoundGuideView

@synthesize isHidden = _isHidden;


/*!
  @brief    初始化函数
  @param
  @author   by bazinga
  */
- (id) initHiddenRect:(CGRect)rect
{
    self = [super init];
    if(self)
    {
        _hiddenRect = rect;
        [self initControl];
    }
    return self;
}

- (void) setHiddenFrame:(CGRect)frame
{
    _hiddenRect = frame;
    [self setGuidCenter];
}

- (void) setGuidCenter
{
    CGFloat x = _hiddenRect.origin.x + _hiddenRect.size.width / 2 -( BACKGROUND_FRAME.size.width/2 - 40.0f);
    CGFloat y = _hiddenRect.origin.y - BACKGROUND_FRAME.size.height/2 + 3;
    _soundView.center = CGPointMake(x,
                              y);
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (fontType == 2)
    {
        _titleLabel.numberOfLines = 2;
        [_titleLabel setFrame:CGRectMake(10, 10, 240, 35)];
        [_welcomeLabel setFrame:CGRectMake(0, 46, 150, 45)];
    }
}

- (void) initControl
{
    
    self.userInteractionEnabled = YES;
    self.backgroundColor = RGBACOLOR(0.0, 0.0, 0.0, 0.75f);
    
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    view.backgroundColor = [UIColor clearColor];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:view];
    [view release];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePress:)];
    recognizer.numberOfTapsRequired = 1;
    recognizer.numberOfTouchesRequired = 1;
    [view addGestureRecognizer:recognizer];
    [recognizer release];
    
    _soundView = [[UIImageView alloc]init];
    [self addSubview:_soundView];
    _soundView.image = [BACKGROUND_IMAGE stretchableImageWithLeftCapWidth:BACKGROUND_IMAGE.size.width / 2
                                                       topCapHeight:BACKGROUND_IMAGE.size.height / 2];
    [_soundView setFrame:BACKGROUND_FRAME];
    
    _soundView.userInteractionEnabled = YES;
    
    _lineImageView = [[UIImageView alloc] initWithImage:IMAGE(@"menulandscapeGrayLine.png", IMAGEPATH_TYPE_1)];
    _lineImageView.frame = CGRectMake(9, 50, 232, 1);
    [_soundView addSubview:_lineImageView];
    [_lineImageView release];
    
    _welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 46, 135, 45)];
    _welcomeLabel.text = STR(@"Setting_Welcome", Localize_Setting);
    _welcomeLabel.textColor = RGBCOLOR(155, 155, 155);
    _welcomeLabel.backgroundColor = [UIColor clearColor];
    _welcomeLabel.font = [UIFont systemFontOfSize:14];
    _welcomeLabel.textAlignment =  NSTextAlignmentCenter;
    [_soundView addSubview:_welcomeLabel];
    [_welcomeLabel release];
    
    __block SoundGuideView *blockSelf = self;
    _switch = [[KLSwitch alloc] initWithFrame:CGRectMake(185, 55, 51, 27) ];
    [_switch setOn:[[MWPreference sharedInstance] getValue:PREF_SWITCHEDVOICE]];
    _switch.didChangeHandler = ^(BOOL isOn)
    {
        if(isOn)
        {
            [[MWPreference sharedInstance] setValue:PREF_SWITCHEDVOICE Value:1];
        }
        else
        {
            [[MWPreference sharedInstance] setValue:PREF_SWITCHEDVOICE Value:0];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [blockSelf closePress:nil];
        });
       
    };
    [_soundView addSubview:_switch];
    [_switch release];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.numberOfLines = 2;
    _titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _titleLabel.text = STR(@"Main_ZhilingMessage", Localize_Main);
    _titleLabel.backgroundColor = [UIColor clearColor];
    [_titleLabel setFrame:CGRectMake(10, 20, 240, 30)];
    if (fontType == 2)
    {
        [_titleLabel setFrame:CGRectMake(10, 10, 240, 30)];
        [_welcomeLabel setFrame:CGRectMake(0, 46, 150, 45)];
    }
    [_titleLabel sizeToFit];
    CGFloat buttonWidth =  40.0;
    CGFloat buttonHeight = 40.0;
    
    UIImage *noarmalImage = IMAGE(@"SoundClose.png", IMAGEPATH_TYPE_1);
    UIImage *highlightedImage = IMAGE(@"SoundClose_on.png", IMAGEPATH_TYPE_1);
    _buttonClose = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonClose.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_buttonClose setImage:noarmalImage forState:UIControlStateNormal];
    [_buttonClose setImage:highlightedImage forState:UIControlStateNormal];
    [_buttonClose setFrame:CGRectMake(0,
                                     0,
                                     buttonWidth,
                                      buttonHeight)];
    _buttonClose.center = CGPointMake(_soundView.bounds.size.width - buttonWidth/2.0, buttonHeight/2.0);
    [_buttonClose addTarget:self action:@selector(closePress:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [_soundView addSubview:_titleLabel];
    [_soundView addSubview:_buttonClose];
    [_titleLabel release];
    [self setGuidCenter];
}

- (void) dealloc
{
    if(_clickClose)
    {
        [_clickClose release];
        _clickClose = nil;
    }
    if(_clickContinue)
    {
        [_clickContinue release];
        _clickContinue = nil;
    }
    [super dealloc];
}

- (void) setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
}

- (void) closePress:(id)sender
{
    self.hidden = YES;
    if (_clickClose)
    {
        _clickClose(nil);
    }
}


//- (void) setIsHidden:(BOOL)isHidden withAnimate:(BOOL)isAnimate
//{
//    _isHidden = isHidden;
//    [self hiddenView:isAnimate];
//}
//
//- (void) hiddenView :(BOOL) animation
//{
//}
//
//- (void) showView :(BOOL) animation
//{
//    
//}
//
//- (void) setHiddenRect
//{
//    
//}



@end
