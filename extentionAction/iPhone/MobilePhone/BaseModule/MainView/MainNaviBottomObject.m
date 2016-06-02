//
//  MainNaviBottomObject.m
//  AutoNavi
//
//  Created by bazinga on 14-9-2.
//  Copyright (c) 2014年 bazinga. All rights reserved.
//

#import "MainNaviBottomObject.h"

#define BLANK_HEGIHT  (isiPhone ? 6.0f : 6.0f)

@implementation MainNaviBottomObject
@synthesize imageViewNaviBottomBG = _imageViewNaviBottomBG;
@synthesize overSpeedBack = _overSpeedBack;
/*!
  @brief    初始化函数
  @param
  @author   by bazinga
  */
- (id) init
{
    self = [super init];
    if(self)
    {
        //底栏
        _imageViewNaviBottomBG = [[UIImageView alloc]init];
        _imageViewNaviBottomBG.backgroundColor = GETSKINCOLOR(ROUTE_BLACK_TOP_BAR_COLOR);
        
        _imageViewNaviBottomBG.userInteractionEnabled = YES;
        _buttonStop = [MainControlCreate createButtonWithTitle:nil
                                                   normalImage:IMAGE(@"mainNaviDelButton.png", IMAGEPATH_TYPE_1)
                                                 heightedImage:IMAGE(@"mainNaviDelButtonPress.png", IMAGEPATH_TYPE_1)
                                                           tag:BUTTON_STOPNAVI
                                                        target:self
                                                        action:@selector(buttonClcik:)];
        [_imageViewNaviBottomBG addSubview:_buttonStop];

        _buttonList = [MainControlCreate createButtonWithTitle:nil
                                                   normalImage:IMAGE(@"mainNaviListButton.png", IMAGEPATH_TYPE_1)
                                                 heightedImage:IMAGE(@"mainNaviListButtonPress.png", IMAGEPATH_TYPE_1)
                                                           tag:BUTTON_LIST_MENU
                                                        target:self
                                                        action:@selector(buttonClcik:)];
        [_imageViewNaviBottomBG addSubview:_buttonList];
        
        _colorLabelSpeed = [self getInitColorLabel];
        [_imageViewNaviBottomBG addSubview:_colorLabelSpeed];
        _colorLabelDistance = [self getInitColorLabel];
        [_imageViewNaviBottomBG addSubview:_colorLabelDistance];
        
        _colorLabelTime = [self getInitColorLabel];
        [_imageViewNaviBottomBG addSubview:_colorLabelTime];
        
        [self initSpeedImageView];
    }
    return self;
}

- (void) initSpeedImageView
{
    _overSpeedBack = [[UIImageView alloc]init];
    _overSpeedBack.backgroundColor = [UIColor clearColor];
    _overSpeedBack.hidden = YES;
    
    _speedNumBack =  [[UIImageView alloc]init];
    _speedNumBack.backgroundColor = [UIColor clearColor];
    _speedNumBack.image = IMAGE(@"overSpeedBack.png", IMAGEPATH_TYPE_1);
    
    _speedNum =  [[UILabel alloc]init];
    _speedNum.backgroundColor = [UIColor clearColor];
    _speedNum.font = [UIFont fontWithName:@"Helvetica-Bold" size:isiPhone ? 21.0f : 31.0f];
    _speedNum.textAlignment = NSTextAlignmentCenter;
    
    [_overSpeedBack addSubview:_speedNumBack];
    [_overSpeedBack addSubview:_speedNum];
    
    [_speedNumBack release];
    [_speedNum release];
    
    [self setSpeedFrame];
}

- (void) setSpeedFrame
{
    float width = isiPhone ? 44.0f : 68.0f;
    
    CGRect rect = CGRectMake(BLANK_HEGIHT, BLANK_HEGIHT, width, width);
    
    [_overSpeedBack setFrame:CGRectMake(0, 0, width + BLANK_HEGIHT * 2, width + BLANK_HEGIHT * 2)];
    [_speedNumBack setFrame:rect];
    [_speedNum setFrame:rect];
}

- (ColorLable *) getInitColorLabel
{
    ColorLable *colorLabel = [[[ColorLable alloc]initWithFrame:CGRectMake(0, 0,
                                                                        150,44)
                                                  ColorArray:[NSArray arrayWithObject:GETSKINCOLOR(LEFTROAD_LABEL_COLOR)]
                                               TextFontArray:[UIFont systemFontOfSize:isiPhone ? 16.0f : 24.0f]] autorelease];
    colorLabel.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);
    colorLabel.font = [UIFont systemFontOfSize:isiPhone ? 12.0f : 21.0f];
    colorLabel.textAlignment = NSTextAlignmentCenter;
    return  colorLabel;
}

- (void) dealloc
{
    CRELEASE(_imageViewNaviBottomBG);
    CRELEASE(_overSpeedBack);
    [super dealloc];
}

#pragma mark -  ---  外部调用函数  ---
/*!
  @brief    设置视图的显示隐藏
  @param
  @author   by bazinga
  */
- (void) setViewHidden:(BOOL)hidden
{
    _imageViewNaviBottomBG.hidden = hidden;
}


/*!
  @brief    获取菜单栏的位置
  @param
  @author   by bazinga
  */
- (CGRect) getListFrame
{
    NSLog(@"%@",NSStringFromCGRect( _buttonList.frame));
    return _buttonList.frame;
}

/*!
  @brief    设置导航信息字符串
  @param
  @author   by bazinga
  */
- (void) setRoadInfoText:(NSString *) speed
               distances:(NSString *) distances
                    time:(NSString *) time
{
    _colorLabelSpeed.text = speed;
    _colorLabelDistance.text = distances;
    _colorLabelTime.text = time;
}

#pragma mark - ---  重载坐标  ---
- (void) reloadFrame
{
    CGSize pathSize = CGSizeZero;
    if(Interface_Flag == 0)
    {
        if(isiPhone)//竖屏
        {
            //导航底部的半透明条
            [_imageViewNaviBottomBG setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH, CONFIG_NAVI_BOTTOM_HEIGHT)];
            [_imageViewNaviBottomBG setCenter:CGPointMake(MAIN_POR_WIDTH / 2,
                                                          MAIN_POR_HEIGHT - _imageViewNaviBottomBG.frame.size.height / 2)];
            
            //停止导航 && 菜单栏
            [_buttonStop setFrame:CGRectMake(0, 0, 50, CONFIG_NAVI_BOTTOM_HEIGHT)];
            [_buttonList setFrame:CGRectMake(0, 0, 50, CONFIG_NAVI_BOTTOM_HEIGHT)];
            [_buttonList setCenter:CGPointMake(MAIN_POR_WIDTH - 25, 22)];

        }
        else//ipad竖屏
        {
            
            //导航底部的半透明条
            [_imageViewNaviBottomBG setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH, CONFIG_NAVI_BOTTOM_HEIGHT)];
            [_imageViewNaviBottomBG setCenter:CGPointMake(MAIN_POR_WIDTH / 2,
                                                          MAIN_POR_HEIGHT - _imageViewNaviBottomBG.frame.size.height / 2)];
            //停止导航 && 菜单栏
            [_buttonStop setFrame:CGRectMake(0, 0, 77.0f, CONFIG_NAVI_BOTTOM_HEIGHT)];
            [_buttonList setFrame:CGRectMake(0, 0, 77.0f, CONFIG_NAVI_BOTTOM_HEIGHT)];
            [_buttonList setCenter:CGPointMake(MAIN_POR_WIDTH - 39.0f, 32.5f)];

        }
    }
    else
    {
        if(isiPhone)  //横屏
        {
            //导航底部的半透明条
            CGFloat bottomWidth = MAIN_LAND_WIDTH - 4 * CONFIG_BUTTON_NORMAL_WIDTH - 6 * CONFIG_BUTTON_SAPCE;
            [_imageViewNaviBottomBG setFrame:CGRectMake(0, 0, bottomWidth, CONFIG_NAVI_BOTTOM_HEIGHT)];
            [_imageViewNaviBottomBG setCenter:CGPointMake(MAIN_LAND_WIDTH / 2, MAIN_LAND_HEIGHT  - CONFIG_BUTTON_SAPCE - CONFIG_BUTTON_NORMAL_WIDTH / 2)];
            
            //停止导航 && 菜单栏
            CGFloat bili = _imageViewNaviBottomBG.frame.size.height / 44.0f;
            [_buttonStop setFrame:CGRectMake(0, 0, 50.0f * bili, 44.0f * bili)];
            [_buttonList setFrame:CGRectMake(0, 0, 50.0f * bili, 44.0f * bili)];
            [_buttonList setCenter:CGPointMake(_imageViewNaviBottomBG.frame.size.width - _buttonStop.frame.size.width / 2, _buttonStop.frame.size.height / 2)];
            pathSize = CGSizeMake(5, 5);
        }
        else//ipad横屏
        {
            //导航底部的半透明条
            [_imageViewNaviBottomBG setFrame:CGRectMake(0, 0, MAIN_LAND_WIDTH , CONFIG_NAVI_BOTTOM_HEIGHT)];
            [_imageViewNaviBottomBG setCenter:CGPointMake(MAIN_LAND_WIDTH /2,
                                                          MAIN_LAND_HEIGHT - _imageViewNaviBottomBG.frame.size.height / 2)];
            
            //停止导航 && 菜单栏
            [_buttonStop setFrame:CGRectMake(0, 0, 77.0f, CONFIG_NAVI_BOTTOM_HEIGHT)];
            [_buttonList setFrame:CGRectMake(0, 0, 77.0f, CONFIG_NAVI_BOTTOM_HEIGHT)];
            [_buttonList setCenter:CGPointMake(MAIN_LAND_WIDTH - 39.0f, 32.5f)];
        }

    }
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_imageViewNaviBottomBG.bounds byRoundingCorners:UIRectCornerBottomRight | UIRectCornerBottomLeft cornerRadii:pathSize];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = _imageViewNaviBottomBG.bounds;
    maskLayer.path = maskPath.CGPath;
    _imageViewNaviBottomBG.layer.mask = maskLayer;
    [maskLayer release];
    
    CGFloat infoWidth = _imageViewNaviBottomBG.frame.size.width - 2 * _buttonStop.frame.size.width - 4.0f;
    CGFloat defaultWidth = _buttonStop.frame.size.width + 2;
    CGRect colorRect = CGRectMake(defaultWidth, 0, infoWidth / 3, _imageViewNaviBottomBG.frame.size.height);
    [_colorLabelSpeed setFrame:colorRect];
    
    [_overSpeedBack setCenter:CGPointMake(_imageViewNaviBottomBG.frame.origin.x + _colorLabelSpeed.center.x,
                                          _imageViewNaviBottomBG.frame.origin.y - _overSpeedBack.frame.size.height / 2 - CONFIG_HISTOGRAM_HEIGHT )];
    
    colorRect = CGRectMake(defaultWidth + infoWidth / 3, 0, infoWidth / 3, _imageViewNaviBottomBG.frame.size.height);
    [_colorLabelDistance setFrame:colorRect];

    colorRect = CGRectMake(defaultWidth + infoWidth * 2 / 3 , 0, infoWidth / 3, _imageViewNaviBottomBG.frame.size.height);
    [_colorLabelTime setFrame:colorRect];

    
}

/*!
  @brief    设置速度
  @param    设置的速度
  @author   by bazinga
  */
- (void) setSpeed:(int) speed
{
    _speedNum.text = [NSString stringWithFormat:@"%d",speed];
}

/*!
  @brief    设置限速是否显示
  @param    是否显示
  @author   by bazinga
  */
- (void) setSpeedHidden:(BOOL) hidden
{
    _overSpeedBack.hidden = hidden;
}

/*!
  @brief    是否超速
  @param
  @author   by bazinga
  */
- (void) isOverSpeed:(BOOL)isOver
{
    _overSpeedBack.backgroundColor = isOver ? [UIColor clearColor]: [UIColor clearColor];
    _colorLabelSpeed.backgroundColor = isOver ? RGBACOLOR(255.0f, 1.0f, 12.0f, 0.4f) :[UIColor clearColor];
}

#pragma mark - ---  按钮响应事件  ---
- (void) buttonClcik:(id)sender
{
    if(self.mainButtonClick)
    {
        self.mainButtonClick(sender);
    }
}

@end
