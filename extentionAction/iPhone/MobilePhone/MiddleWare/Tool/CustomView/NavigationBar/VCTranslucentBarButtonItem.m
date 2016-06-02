//
//  VCTranslucentBarButtonItem.m
//  Custom NavBar
//
//  Created by ljj on 12-7-16.
//  Copyright (c) 2012￥ﾹ?autonavi. All rights reserved.
//

#import "VCTranslucentBarButtonItem.h"
#import "ANParamValue.h"

@interface VCTranslucentBarButtonItem()
{
    UIView *_newImageView;
    BOOL _hiddenNew;
}

@end

@implementation VCTranslucentBarButtonItem
@synthesize type = _type;

+ (UIImage *)backgroundImageWithType:(VCTranslucentBarButtonItemType)theType {
    NSString *filename;
    UIImage *originalImage, *buttonImage;
    NSInteger leftcap, rightcap;
    switch (theType) {
        case VCTranslucentBarButtonItemTypeForward:{
            filename = @"forwardbutton";
            leftcap = 8;
            rightcap = 13;
            break;
        }
        case VCTranslucentBarButtonItemTypeBackward: {
            filename = @"BackBtn1.png";
            leftcap = 0;
            rightcap = 0;
            break;
        }
        case VCTranslucentBarButtonItemTypeRedColor:{
            filename = @"POICityChooseBtn1.png";
            leftcap = 5;
            rightcap = 5;
            break;
        }
        case VCTranslucentBarButtonItemTypeNormal:
             VCTranslucentBarButtonItemTypeLeftCancel:
        {
            filename = @"NavigationBtn.png";
            leftcap = 5;
            rightcap = 5;
            break;
        }
        default: {

            filename = @"NavigationBtn.png";
            leftcap = 5;
            rightcap = 5;
            break;
        }
    }
    
    originalImage = IMAGE(filename, IMAGEPATH_TYPE_1);
    buttonImage = [originalImage stretchableImageWithLeftCapWidth:leftcap topCapHeight:rightcap];
    
    return buttonImage;
}

+(UIImage*)backgroundImageHighlightedWithType:(VCTranslucentBarButtonItemType)theType
{
    NSString *filename;
    UIImage *originalImage, *buttonImage;
    NSInteger leftcap, rightcap;
    switch (theType) {
        case VCTranslucentBarButtonItemTypeForward:{
            filename = @"forwardbutton";
            leftcap = 8;
            rightcap = 13;
            break;
        }
        case VCTranslucentBarButtonItemTypeBackward: {
            filename = @"BackBtn2.png";
            leftcap = 0;
            rightcap = 0;
            break;
        }
        case VCTranslucentBarButtonItemTypeRedColor:{
            filename = @"POICityChooseBtn2.png";
            leftcap = 5;
            rightcap = 5;
            break;
        }
        case VCTranslucentBarButtonItemTypeNormal:
            VCTranslucentBarButtonItemTypeLeftCancel:
        default: {
            filename = @"NavigationBtn1.png";
            leftcap = 5;
            rightcap = 5;
            break;
        }
    }

    originalImage = IMAGE(filename, IMAGEPATH_TYPE_1);
    buttonImage = [originalImage stretchableImageWithLeftCapWidth:leftcap topCapHeight:rightcap];
    return buttonImage;
}
+ (UIButton *)buttonWithTitle:(NSString *)title type:(VCTranslucentBarButtonItemType)theType {
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [[self class] backgroundImageWithType:theType];
    aButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    aButton.backgroundColor = [UIColor clearColor];
    if (theType==VCTranslucentBarButtonItemTypeBackward)
    {
        [aButton setImage:[[self class] backgroundImageWithType:theType] forState:UIControlStateNormal];
        [aButton setImage:[[self class] backgroundImageHighlightedWithType:theType] forState:UIControlStateHighlighted];
        aButton.frame=CGRectMake(0,0, buttonImage.size.width + 20,  buttonImage.size.height + 15);
        if (IOS_7) {
            aButton.imageEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 20);
        }
        
    }
    else
    {
        [aButton setBackgroundImage:[[self class] backgroundImageWithType:theType] forState:UIControlStateNormal];
        [aButton setBackgroundImage:[[self class] backgroundImageHighlightedWithType:theType] forState:UIControlStateHighlighted];

        [aButton setTitle:title forState:UIControlStateNormal];
        [aButton setTitle:title forState:UIControlStateHighlighted];

        UIFont *font = [UIFont systemFontOfSize:kSize6];
        aButton.titleLabel.font = font;
        
        [aButton setTitleColor:GETSKINCOLOR(@"NavigationRightButtonDisabledColor") forState:UIControlStateDisabled];
        [aButton setTitleColor:GETSKINCOLOR(@"NavigationRightButtonHighlightedColor") forState:UIControlStateHighlighted];
        [aButton setTitleColor:GETSKINCOLOR(@"NavigationRightButtonColor") forState:UIControlStateNormal];

        CGSize labelSize = [title sizeWithFont:font];
        
        float button_width = 0;
        float button_height = 32;
        if (isiPhone)
        {
            if (Interface_Flag == 0)
            {
                button_width = 85;
            }
            else
            {
                button_height = 24;
                button_width = iPhone5?115:100;
            }
        }
        else
        {
            button_width = Interface_Flag?220:135;
        }
        button_width = (labelSize.width + 30.0f > button_width)?button_width:labelSize.width + 30.0f;
        if (VCTranslucentBarButtonItemTypeLeftCancel == theType)
        {
            aButton.frame = CGRectMake(IOS_7?-4:7, 0, button_width, button_height);
        }
        else
        {
            aButton.frame = CGRectMake(IOS_7?11:0, 0, button_width, button_height);
        }
    }
    return aButton;
}

- (id)initWithType:(VCTranslucentBarButtonItemType)theType title:(NSString *)title target:(id)target action:(SEL)action
{
    if ((self = [super init]))
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeButtonBackground:) name:UIDeviceOrientationDidChangeNotification object:nil];
        self.type = theType;
        self.target = target;
        self.title = title;
        self.action = action;
        
        UIButton *button = [[self class] buttonWithTitle:self.title type:self.type];
        [button setExclusiveTouch:YES];
        [button addTarget:self.target action:self.action forControlEvents:UIControlEventTouchUpInside];
        if (theType == VCTranslucentBarButtonItemTypeBackward)
        {
            self.customView = button;
        }
        else
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, button.frame.size.width + 7, button.frame.size.height)];
            view.backgroundColor = [UIColor clearColor];
            view.userInteractionEnabled = YES;
            self.customView = view;
            [view release];
            [view addSubview:button];
        }
        button.tag = 112;
        _hiddenNew = YES;
    }
    
    return self;
}

- (void)setNewHidden:(BOOL)hidden
{
    _hiddenNew = hidden;
    UIView *view = ( UIView *)[self customView];
    UIButton *button = (UIButton *)[view viewWithTag:112];
    if (hidden == NO)
    {
        if ([button isKindOfClass:[UIButton class]])
        {
            CGRect contrastRect = CGRectMake(0, 0, 26, 14);
            CGSize imageSize = contrastRect.size;
            CGSize buttonSize = button.frame.size;
            if (_newImageView)
            {
                _newImageView.hidden = NO;
            }
            else
            {
                
                CGFloat contrastRadius = contrastRect.size.height/2.0f;
                
                _newImageView = [[UIView alloc] initWithFrame:contrastRect];
                [_newImageView setBackgroundColor: [UIColor clearColor]];
                [_newImageView.layer setCornerRadius: contrastRadius];
                [_newImageView.layer setShadowColor: [GETSKINCOLOR(@"NewShadowColor") CGColor]];
                [_newImageView.layer setShadowOffset: CGSizeMake(0, 1)];
                [_newImageView.layer setShadowOpacity: 0.4];
                [_newImageView.layer setShadowRadius: 0.8];
                [_newImageView.layer setMasksToBounds:NO];
                [button addSubview:_newImageView];
                [_newImageView release];
                
                UILabel *lable = [[UILabel alloc] initWithFrame:contrastRect];
                [lable setBackgroundColor: [UIColor redColor]];
                [lable.layer setCornerRadius: contrastRadius];
                lable.text = @"NEW";
                lable.font = [UIFont systemFontOfSize:9];
                lable.textColor = GETSKINCOLOR(@"NewTitleColor");
                lable.textAlignment = NSTextAlignmentCenter;
                [_newImageView addSubview: lable];
                [lable release];
            }
            _newImageView.frame = CGRectMake(buttonSize.width - imageSize.width + 6, -4, imageSize.width, imageSize.height);
        }
    }
    else
    {
        if (_newImageView)
        {
            _newImageView.hidden = YES;
        }
    }
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    UIView *view = ( UIView *)[self customView];
    UIButton *button = (UIButton *)[view viewWithTag:112];
    [button setEnabled:enabled];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)changeButtonBackground:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if ((orientation == UIDeviceOrientationFaceUp)
        || (orientation == UIDeviceOrientationFaceDown)
        || (orientation == UIDeviceOrientationUnknown)) {
        return;
    }
    
    if (_newImageView)
    {
        [_newImageView removeFromSuperview];
        _newImageView = nil;
    }
    
    BOOL hiden = self.customView.hidden;
    UIButton *button = [[self class] buttonWithTitle:self.title type:self.type];
    [button addTarget:self.target action:self.action forControlEvents:UIControlEventTouchUpInside];
    if (self.type == VCTranslucentBarButtonItemTypeBackward)
    {
        button.hidden = hiden;
        self.customView = button;
    }
    else
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, button.frame.size.width + 7, button.frame.size.height)];
        view.backgroundColor = [UIColor clearColor];
        view.userInteractionEnabled = YES;
        view.hidden = hiden;
        self.customView = view;
        [view release];
        [view addSubview:button];
    }
    button.tag = 112;
    [self setNewHidden:_hiddenNew];
    [self setEnabled:self.isEnabled];
}


@end
