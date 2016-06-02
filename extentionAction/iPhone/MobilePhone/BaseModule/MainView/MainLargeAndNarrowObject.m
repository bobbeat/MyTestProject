//
//  MainLargeAndNarrowObject.m
//  AutoNavi
//
//  Created by bazinga on 14-8-29.
//  Copyright (c) 2014年 bazinga. All rights reserved.
//

#import "MainLargeAndNarrowObject.h"
#import "MainDefine.h"
#import "UMengEventDefine.h"

@implementation MainLargeAndNarrowObject

@synthesize buttonEnlarge = _buttonEnlarge;
@synthesize buttonMeter = _buttonMeter;
@synthesize buttonNarrow = _buttonNarrow;
@synthesize mainButtonClick = _mainButtonClick;

#pragma mark - ---  初始化函数，释放函数  ---
- (id) init
{
    self  = [super init];
    if(self)
    {
        _mapViewType = GMAP_VIEW_TYPE_MAIN;
        //初始化按钮//放大缩小
        _buttonEnlarge = [[MainControlCreate createButtonWithTitle:nil
                                                      normalImage:IMAGE(@"mainEnlargeMap.png", IMAGEPATH_TYPE_2)
                                                    heightedImage:IMAGE(@"mainEnlargeMapPress.png", IMAGEPATH_TYPE_2)
                                                              tag:BUTTON_ENLARGEMAP
                                                           target:self
                                                           action:@selector(decFun:)] retain];
        UILongPressGestureRecognizer *longPress =[[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(ZoomInLongPressed:)]autorelease];
        longPress.minimumPressDuration =0.2;
        [_buttonEnlarge addGestureRecognizer:longPress];
        
        _buttonNarrow = [[MainControlCreate createButtonWithTitle:nil
                                                         normalImage:IMAGE(@"mainNarrow.png", IMAGEPATH_TYPE_2)
                                                       heightedImage:IMAGE(@"mainNarrowPress.png", IMAGEPATH_TYPE_2)
                                                                 tag:BUTTON_NARROWMAP
                                                              target:self
                                                              action:@selector(incFun:)] retain];
        longPress =[[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(ZoomOutLongPressed:)]autorelease];
        longPress.minimumPressDuration =0.2;
        [_buttonNarrow addGestureRecognizer:longPress];
        
        //比例次显示
        _buttonMeter = [[MainControlCreate createButtonWithTitle:nil
                                                     normalImage:IMAGE(@"mainScaleIcon.png", IMAGEPATH_TYPE_2)
                                                   heightedImage:nil
                                                             tag:-1
                                                          target:nil
                                                          action:nil] retain];
        _buttonMeter.titleLabel.font = [UIFont systemFontOfSize:10];
        
        
        _isLongPressed = NO;

    }
    return self;
}

/*!
  @brief    初始化函数
  @param    mapViewType ： 放大缩小的起作用的地图模式
  @author   by bazinga
  */
- (id) initWithMapType:(GMAPVIEWTYPE)mapViewType
{
    self = [self  init];
    if(self)
    {
        _mapViewType = mapViewType;
    }
    return self;
}

- (void) dealloc
{
    CRELEASE(_buttonEnlarge);
    CRELEASE(_buttonNarrow);
    CRELEASE(_mainButtonClick);
    CRELEASE(_buttonMeter);
    [super dealloc];
}


#pragma mark - ---  外部调用函数  ---
/*!
  @brief    设置放大缩小起作用的地图模式
  @param    mapViewType ： 放大缩小的起作用的地图模式
  @author   by bazinga
  */
- (void) setMapView:(GMAPVIEWTYPE)mapViewType
{
    _mapViewType = mapViewType;
}

/*!
  @brief    设置比例次大小
  @param
  @author   by bazinga
  */
- (void) setMeterString:(NSString *)meterString
{
    [self.buttonMeter setTitle:meterString forState:UIControlStateNormal];
    
    if ([self.buttonMeter.titleLabel.text isEqualToString:@"15m"])
    {
        _buttonEnlarge.alpha = ALPHA_HIDEN;
        _buttonNarrow.alpha = ALPHA_APEAR;
        
    }
    else if ([self.buttonMeter.titleLabel.text isEqualToString:@"500km"])
    {
        _buttonEnlarge.alpha = ALPHA_APEAR;
        _buttonNarrow.alpha = ALPHA_HIDEN;
    }
    else
    {
        _buttonEnlarge.alpha = ALPHA_APEAR;
        _buttonNarrow.alpha = ALPHA_APEAR;
    }
}

/*!
  @brief    定时器是否在运行
  @param
  @author   by bazinga
  */
- (BOOL) isTimerRunning
{
    return (dec_timer != nil || inc_timer != nil);
}

/*!
  @brief    重新加载图片，白天黑夜 or 皮肤
  @param
  @author   by bazinga
  */
- (void) reloadImage
{
    //竖屏状态或者是iPad都不用横屏的图片
    UIImage *enlargeImage = IMAGE(@"mainEnlargeMap.png", IMAGEPATH_TYPE_2);
    UIImage *enlargeImagePressed = IMAGE(@"mainEnlargeMapPress.png", IMAGEPATH_TYPE_2);
    UIImage *narrowImage = IMAGE(@"mainNarrow.png", IMAGEPATH_TYPE_2);
    UIImage *narrowImagePressed = IMAGE(@"mainNarrowPress.png", IMAGEPATH_TYPE_2);
    if(Interface_Flag == 1 && isiPhone)
    {
        enlargeImage = IMAGE(@"mainEnlargeMapLandscape.png", IMAGEPATH_TYPE_2);
        enlargeImagePressed = IMAGE(@"mainEnlargeMapPressLandscape.png", IMAGEPATH_TYPE_2);
        narrowImage = IMAGE(@"mainNarrowLandscape.png", IMAGEPATH_TYPE_2);
        narrowImagePressed = IMAGE(@"mainNarrowPressLandscape.png", IMAGEPATH_TYPE_2);
    }
    [_buttonEnlarge setBackgroundImage:enlargeImage forState:UIControlStateNormal];
    [_buttonEnlarge setBackgroundImage:enlargeImagePressed forState:UIControlStateHighlighted];
    [_buttonNarrow setBackgroundImage:narrowImage forState:UIControlStateNormal];
    [_buttonNarrow setBackgroundImage:narrowImagePressed forState:UIControlStateHighlighted];
}

/*!
  @brief    重新加载文字颜色，白天 or 黑夜
  @param
  @author   by bazinga
  */
- (void) reloadTextColor:(int) type
{
    if(type == 1)
    {
        [_buttonMeter setTitleColor:GETSKINCOLOR(MAIN_NIGHT_METER_COLOR) forState:UIControlStateNormal];
    }
    else
    {
        [_buttonMeter setTitleColor:GETSKINCOLOR(MAIN_DAY_METER_COLOR) forState:UIControlStateNormal];
    }
}

/*!
  @brief    加载放大缩小的按钮坐标大小
  @param
  @author   by bazinga
  */
- (void) reloadControlFrame
{
    //设置按钮的高宽
    [_buttonNarrow setFrame:CGRectMake(0.0f, 0.0f, CONFIG_NARROW_BUTTON_WIDTH, CONFIG_NARROW_BUTTON_HEIGHT)];
    [_buttonEnlarge setFrame:CGRectMake(0.0f, 0.0f, CONFIG_NARROW_BUTTON_WIDTH, CONFIG_NARROW_BUTTON_HEIGHT)];
    [_buttonMeter setFrame:CGRectMake(0.0f, 0.0f, CONFIG_METER_WIDTH, CONFIG_METER_HEIGHT)];
    if(Interface_Flag == 0)
    {
        if(isiPhone)
        {
            if([[ANParamValue sharedInstance] isPath] == NO)
            {
                //设置中心点坐标
                [_buttonMeter setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                    MAIN_POR_HEIGHT - CONFIG_CRUISE_BOTTOM_HEIGHT - CONFIG_BUTTON_SAPCE - CONFIG_METER_HEIGHT / 2)];
                
            }
            else
            {
                //减去 —— 导航低栏高度，柱状图高度，全览按钮高度，1.5个 按钮间隙，0.5个_buttonMeter高度
                [_buttonMeter setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                    MAIN_POR_HEIGHT - CONFIG_NAVI_BOTTOM_HEIGHT - CONFIG_HISTOGRAM_HEIGHT - CONFIG_BUTTON_NORMAL_WIDTH - CONFIG_BUTTON_SAPCE * 1.5 - CONFIG_METER_HEIGHT / 2)];

            }
            [_buttonNarrow setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                 _buttonMeter.frame.origin.y - CONFIG_BUTTON_SAPCE / 2 - CONFIG_NARROW_BUTTON_HEIGHT / 2)];
            
            [_buttonEnlarge setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                  _buttonNarrow.frame.origin.y - CONFIG_NARROW_BUTTON_HEIGHT / 2)];
        }
        else
        {
            if([[ANParamValue sharedInstance] isPath] == NO)
            {
                //放大，缩小
                [_buttonMeter setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                    MAIN_POR_HEIGHT- CONFIG_CRUISE_BOTTOM_HEIGHT
                                                    - CONFIG_BUTTON_SAPCE - CONFIG_METER_HEIGHT / 2)];
                _buttonMeter.titleLabel.font = [UIFont systemFontOfSize:13];

            }
            else
            {
                
                [_buttonMeter setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                   MAIN_POR_HEIGHT - CONFIG_NAVI_BOTTOM_HEIGHT
                                                    - CONFIG_HISTOGRAM_HEIGHT - CONFIG_BUTTON_SAPCE * 1.5
                                                    - CONFIG_BUTTON_NORMAL_WIDTH - CONFIG_METER_HEIGHT / 2)];
                _buttonMeter.titleLabel.font = [UIFont systemFontOfSize:13];
            }
            
            [_buttonNarrow setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                 _buttonMeter.frame.origin.y - CONFIG_BUTTON_SAPCE / 2 - CONFIG_NARROW_BUTTON_HEIGHT / 2)];
            
            [_buttonEnlarge setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                  _buttonNarrow.frame.origin.y - CONFIG_NARROW_BUTTON_HEIGHT / 2)];
        }
    }
    else
    {
        if(isiPhone)
        {
            [_buttonNarrow setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                 MAIN_LAND_HEIGHT - CONFIG_BUTTON_SAPCE - CONFIG_NARROW_BUTTON_HEIGHT / 2 )];
            [_buttonEnlarge setCenter:CGPointMake(CONFIG_CENTER_RIGHT - CONFIG_BUTTON_SAPCE -  CONFIG_NARROW_BUTTON_WIDTH ,
                                                  _buttonNarrow.center.y)];
            [_buttonMeter setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                               _buttonNarrow.frame.origin.y - CONFIG_BUTTON_SAPCE/2 - CONFIG_METER_HEIGHT /2 )];
        }
        else
        {
            if([[ANParamValue sharedInstance] isPath] == NO)
            {
                //放大，缩小
                [_buttonMeter setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                    MAIN_LAND_HEIGHT- CONFIG_CRUISE_BOTTOM_HEIGHT
                                                    - CONFIG_BUTTON_SAPCE - CONFIG_METER_HEIGHT / 2)];
                _buttonMeter.titleLabel.font = [UIFont systemFontOfSize:13];
                
            }
            else
            {
                
                [_buttonMeter setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                    MAIN_LAND_HEIGHT - CONFIG_NAVI_BOTTOM_HEIGHT
                                                    - CONFIG_HISTOGRAM_HEIGHT - CONFIG_BUTTON_SAPCE * 1.5
                                                    - CONFIG_BUTTON_NORMAL_WIDTH - CONFIG_METER_HEIGHT / 2)];
                _buttonMeter.titleLabel.font = [UIFont systemFontOfSize:13];
            }
            
            [_buttonNarrow setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                 _buttonMeter.frame.origin.y - CONFIG_BUTTON_SAPCE / 2 - CONFIG_NARROW_BUTTON_HEIGHT / 2)];
            
            [_buttonEnlarge setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                  _buttonNarrow.frame.origin.y - CONFIG_NARROW_BUTTON_HEIGHT / 2)];
        }
    }
}

#pragma mark -  ---  放大缩小函数  ---
- (void)ZoomInLongPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
	{
        _isLongPressed = YES;
		inc_timer = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                     target:self
                                                   selector:@selector(decFun:)
                                                   userInfo:nil
                                                    repeats:YES];
        [inc_timer fire];
	}
	else if (recognizer.state == UIGestureRecognizerStateChanged)
	{
        
	}else 	if (recognizer.state == UIGestureRecognizerStateEnded)
	{
        [self Stop_Idec:self.buttonEnlarge];
	}
    
    
}

- (void)ZoomOutLongPressed:(UILongPressGestureRecognizer *)recognizer
{
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
	{
        _isLongPressed = YES;
		dec_timer = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                     target:self
                                                   selector:@selector(incFun:)
                                                   userInfo:nil
                                                    repeats:YES];
        [dec_timer fire];
	}
	else if (recognizer.state == UIGestureRecognizerStateChanged)
	{
        
	}else 	if (recognizer.state == UIGestureRecognizerStateEnded)
	{
        [self Stop_Idec:self.buttonNarrow];
	}
}

- (void)decFun:(NSTimer *)timer
{
    [MobClick event:UM_EVENTID_ZOOM_COUNT label:UM_LABEL_ZOOM_FROM_TOUCH];
    if (_isLongPressed)
    {
        _isLongPressed = NO;
        return;
    }

    if ([self.buttonMeter.titleLabel.text isEqualToString:@"15m"])
    {
        if (inc_timer != nil) {
            [inc_timer invalidate];
            inc_timer = nil;
        }
        return;
    }
    if(self.mainButtonClick)
    {
        self.mainButtonClick(self.buttonEnlarge);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:[NSNumber numberWithBool:NO]];
    [[MWMapOperator sharedInstance] MW_ZoomMapView:_mapViewType ZoomFlag:GSETMAPVIEW_LEVEL_IN ZoomLevel:0];
}


- (void)incFun:(NSTimer *)timer
{
    [MobClick event:UM_EVENTID_ZOOM_COUNT label:UM_LABEL_ZOOM_FROM_TOUCH];
    if (_isLongPressed)
    {
        _isLongPressed = NO;
        return;
    }
    if ([self.buttonMeter.titleLabel.text isEqualToString:@"500km"])
    {
        if (dec_timer != nil) {
            [dec_timer invalidate];
            dec_timer = nil;
        }
        return;
    }
    if(self.mainButtonClick)
    {
        self.mainButtonClick(self.buttonNarrow);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:[NSNumber numberWithBool:NO]];
    
    [[MWMapOperator sharedInstance] MW_ZoomMapView:_mapViewType ZoomFlag:GSETMAPVIEW_LEVEL_OUT ZoomLevel:0];
}


- (void)Stop_Idec:(id)sender {
	
	NSLog(@"Stop_Idec");
	UIButton *button = (UIButton *)sender;
	if (button.tag==BUTTON_ENLARGEMAP)
	{
		if (inc_timer != nil) {
            [inc_timer invalidate];
            inc_timer = nil;
        }
	}
	else if (button.tag==BUTTON_NARROWMAP)
	{
        if (dec_timer != nil) {
            [dec_timer invalidate];
            dec_timer = nil;
        }
	}
}

@end
