//
//  MainOtherObject.m
//  AutoNavi
//
//  Created by bazinga on 14-9-10.
//  Copyright (c) 2014年 bazinga. All rights reserved.
//

#import "MainOtherObject.h"

@implementation MainOtherObject

@synthesize buttonClick = _buttonClick;

- (id) initWithView:(UIView *)view
{
    self = [super init];
    if(self)
    {
        
        _view = view;
        //平行道路
        _buttonParallelRoad = [MainControlCreate createButtonWithTitle:nil
                                                           normalImage:IMAGE(@"Route_cancelDetour.png", IMAGEPATH_TYPE_2)
                                                         heightedImage:IMAGE(@"Route_cancelDetourPress.png", IMAGEPATH_TYPE_2)
                                                                   tag:BUTTON_PARALLELROAD
                                                                target:self
                                                                action:@selector(buttonAction:)];
        [_buttonParallelRoad setBackgroundImage:IMAGE(@"Route_cancelDetour.png", IMAGEPATH_TYPE_2)
                                       forState:UIControlStateNormal];
        [_buttonParallelRoad setBackgroundImage:IMAGE(@"Route_cancelDetourPress.png", IMAGEPATH_TYPE_2)
                                       forState:UIControlStateHighlighted];
        [_buttonParallelRoad setImage:IMAGE(@"RouteDetourImage.png", IMAGEPATH_TYPE_1)
                             forState:UIControlStateNormal];
        [view addSubview:_buttonParallelRoad];
        
        //高速路牌
        _buttonGuidePost = [MainControlCreate createButtonWithTitle:nil
                                                        normalImage:IMAGE(@"MainShowGuidePost.png", IMAGEPATH_TYPE_1)
                                                      heightedImage:nil
                                                                tag:BUTTON_GUIDEPOST
                                                             target:self
                                                             action:@selector(buttonAction:)];
        _buttonGuidePost.showsTouchWhenHighlighted = YES;
        _buttonGuidePost.hidden = YES;
        [view addSubview:_buttonGuidePost];
        //实时交通
        _buttonReal =   [MainControlCreate createButtonWithTitle:nil
                                                     normalImage:IMAGE(@"mainRealTraffic.png", IMAGEPATH_TYPE_2)
                                                   heightedImage:IMAGE(@"mainRealTrafficPress.png", IMAGEPATH_TYPE_2)
                                                             tag:BUTTON_REAL_BUTTON
                                                          target:self
                                                          action:@selector(buttonAction:)];
        [view addSubview:_buttonReal];
        _buttonReal.hidden = NO;
        //回车位按钮
        _buttonBackCar = [MainControlCreate createButtonWithTitle:nil
                                                      normalImage:IMAGE(@"mainBackCar.png", IMAGEPATH_TYPE_2)
                                                    heightedImage:IMAGE(@"mainBackCarPress.png", IMAGEPATH_TYPE_2)
                                                              tag:BUTTON_BACK_CAR
                                                           target:self
                                                           action:@selector(buttonAction:)];
        [view addSubview:_buttonBackCar];
        
        //指北针按钮
        _buttonSwitchTripDirect =  [MainControlCreate createButtonWithTitle:nil
                                                                normalImage:IMAGE(@"mainDirect.png", IMAGEPATH_TYPE_2)
                                                              heightedImage:IMAGE(@"mainDirect.png", IMAGEPATH_TYPE_2)
                                                                        tag:BUTTON_SET_VIEWMODE
                                                                     target:self
                                                                     action:@selector(buttonAction:)];
        [view addSubview:_buttonSwitchTripDirect];
        
        //全览按钮
        _buttonAllSee = [MainControlCreate createButtonWithTitle:STR(@"Main_AllSee", Localize_Main)
                                                     normalImage:IMAGE(@"main_AllSee.png", IMAGEPATH_TYPE_2)
                                                   heightedImage:IMAGE(@"main_AllSeePress.png", IMAGEPATH_TYPE_2)
                                                             tag:BUTTON_ALLSEE
                                                          target:self
                                                          action:@selector(buttonAction:)];

        if(isiPhone)
        {
            _buttonAllSee.titleLabel.font  = [UIFont systemFontOfSize:10.0f];
            _buttonAllSee.titleEdgeInsets = UIEdgeInsetsMake(15, 0, 0, 0);
        }
        else
        {
            _buttonAllSee.titleLabel.font  = [UIFont systemFontOfSize:13.0f];
            _buttonAllSee.titleEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 0);
        }
        [view addSubview:_buttonAllSee];
        //取消周边
        _buttonCancelNearBy = [MainControlCreate createButtonWithTitle:STR(@"Main_cancelNearby", Localize_Main)
                                                           normalImage:IMAGE(@"Route_cancelDetour.png", IMAGEPATH_TYPE_2)
                                                         heightedImage:IMAGE(@"Route_cancelDetourPress.png", IMAGEPATH_TYPE_2)
                                                                   tag:BUTTON_CANCEL_NEARBY
                                                                target:self
                                                                action:@selector(buttonAction:)];
        _buttonCancelNearBy.titleLabel.textAlignment = NSTextAlignmentCenter;
        _buttonCancelNearBy.titleLabel.numberOfLines = 2;
        _buttonCancelNearBy.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _buttonCancelNearBy.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _buttonCancelNearBy.hidden = YES;
        [view addSubview:_buttonCancelNearBy];
    }
    return self;
}

- (void) dealloc
{
    CRELEASE(_buttonClick);
    [super dealloc];
}

#pragma mark - ---  外部调用函数  ---
/*!
  @brief    重新加载界面坐标
  @param
  @author   by bazinga
  */
- (void) reloadFrame
{

    CGAffineTransform tempAt = _buttonSwitchTripDirect.transform;
    CGAffineTransform at =CGAffineTransformMakeRotation(0);//设置Frame前，先将角度旋转为0度，要不会发生变形
    [_buttonSwitchTripDirect setTransform:at];
    //平行道路
    [_buttonParallelRoad setFrame:CGRectMake(0, 0, CONFIG_BUTTON_NORMAL_WIDTH, CONFIG_BUTTON_NORMAL_WIDTH)];
    [_buttonReal setFrame:CGRectMake(0, 0, CONFIG_BUTTON_NORMAL_WIDTH, CONFIG_BUTTON_NORMAL_WIDTH)];
    [_buttonSwitchTripDirect setFrame:CGRectMake(0, 0, CONFIG_BUTTON_NORMAL_WIDTH, CONFIG_BUTTON_NORMAL_WIDTH)];
    [_buttonGuidePost setFrame:CGRectMake(0, 0, CONFIG_BUTTON_NORMAL_WIDTH, CONFIG_BUTTON_NORMAL_WIDTH)];
    [_buttonAllSee setFrame:CGRectMake(0, 0, CONFIG_BUTTON_NORMAL_WIDTH, CONFIG_BUTTON_NORMAL_WIDTH)];
    [_buttonBackCar setFrame:CGRectMake(0, 0, CONFIG_BUTTON_NORMAL_WIDTH, CONFIG_BUTTON_NORMAL_WIDTH)];
    [_buttonCancelNearBy setFrame:CGRectMake(0, 0, CONFIG_BUTTON_NORMAL_WIDTH, CONFIG_BUTTON_NORMAL_WIDTH)];
    
    
    CGFloat rightHeight  = 0;
    CGFloat leftHeight = 0;
    
    if([[ANParamValue sharedInstance] isPath] == NO) //巡航
    {
        rightHeight = CONFIG_CRUISE_TOP_HEIGHT;
        leftHeight = CONFIG_CRUISE_TOP_HEIGHT;
    }
    else //导航
    {
        rightHeight = CONFIG_NAVI_TOP_NAME_HEIGHT;
        leftHeight = CONFIG_NAVI_TOP_DIRE_HEIGHT;
    }
    
    [_buttonReal setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                       rightHeight + CONFIG_BUTTON_SAPCE + CONFIG_BUTTON_NORMAL_WIDTH / 2)];

    [_buttonSwitchTripDirect setCenter:CGPointMake(CONFIG_CENTER_LEFT,
                                                   leftHeight + CONFIG_BUTTON_SAPCE +  CONFIG_BUTTON_NORMAL_WIDTH / 2)];
    if(isiPhone)
    {
        [_buttonGuidePost setCenter:CGPointMake(CONFIG_CENTER_RIGHT - CONFIG_BUTTON_SAPCE - CONFIG_BUTTON_NORMAL_WIDTH,
                                                rightHeight + CONFIG_BUTTON_SAPCE + CONFIG_BUTTON_NORMAL_WIDTH / 2)];
    }
    else
    {
        [_buttonGuidePost setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                rightHeight + CONFIG_BUTTON_SAPCE * 3 + CONFIG_BUTTON_NORMAL_WIDTH * 2.5)];
    }
    
    if(Interface_Flag == 0)
    {
        if(isiPhone)
        {
            //Y : 减去导航低栏高度，状态栏高度，3个按钮间空白，2个放大缩小按钮高度，1.5个正常按钮高度，1个比例尺高度
            [_buttonParallelRoad  setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                        MAIN_POR_HEIGHT - CONFIG_NAVI_BOTTOM_HEIGHT
                                                        - CONFIG_HISTOGRAM_HEIGHT - 3 * CONFIG_BUTTON_SAPCE
                                                        - 2 * CONFIG_NARROW_BUTTON_HEIGHT - (CONFIG_BUTTON_NORMAL_WIDTH * 3) / 2
                                                        - CONFIG_METER_HEIGHT)];
            
            //全览
            [_buttonAllSee setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                MAIN_POR_HEIGHT - CONFIG_NAVI_BOTTOM_HEIGHT
                                                - CONFIG_HISTOGRAM_HEIGHT - CONFIG_BUTTON_SAPCE
                                                 - CONFIG_BUTTON_NORMAL_WIDTH / 2)];
            
            [_buttonCancelNearBy setCenter:CGPointMake(CONFIG_CENTER_LEFT,
                                                       MAIN_POR_HEIGHT - CONFIG_NAVI_BOTTOM_HEIGHT
                                                       -CONFIG_HISTOGRAM_HEIGHT - 2 * CONFIG_BUTTON_SAPCE
                                                       - CONFIG_BUTTON_NORMAL_WIDTH * 1.5)];
            
            if([[ANParamValue sharedInstance] isPath] == NO)
            {
                [_buttonBackCar setCenter:CGPointMake(CONFIG_CENTER_LEFT,
                                                      MAIN_POR_HEIGHT - CONFIG_CRUISE_BOTTOM_HEIGHT
                                                      - CONFIG_METER_HEIGHT - CONFIG_BUTTON_SAPCE
                                                      - CONFIG_BUTTON_NORMAL_WIDTH / 2)];
            }
            else
            {
                [_buttonBackCar setCenter:CGPointMake(CONFIG_CENTER_LEFT,
                                                     MAIN_POR_HEIGHT - CONFIG_NAVI_BOTTOM_HEIGHT
                                                     - CONFIG_HISTOGRAM_HEIGHT - CONFIG_BUTTON_SAPCE
                                                     - CONFIG_BUTTON_NORMAL_WIDTH / 2)];
            }
        }
        else
        {
            
            //Y : 减去导航低栏高度，状态栏高度，3个按钮间空白，2个放大缩小按钮高度，1.5个正常按钮高度，1个比例尺高度
            [_buttonParallelRoad  setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                        MAIN_POR_HEIGHT - CONFIG_NAVI_BOTTOM_HEIGHT
                                                        - CONFIG_HISTOGRAM_HEIGHT - 3 * CONFIG_BUTTON_SAPCE
                                                        - 2 * CONFIG_NARROW_BUTTON_HEIGHT - (CONFIG_BUTTON_NORMAL_WIDTH * 3) / 2
                                                        - CONFIG_METER_HEIGHT)];
            
            //全览
            [_buttonAllSee setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                 MAIN_POR_HEIGHT - CONFIG_NAVI_BOTTOM_HEIGHT
                                                 - CONFIG_HISTOGRAM_HEIGHT - CONFIG_BUTTON_SAPCE
                                                 - CONFIG_BUTTON_NORMAL_WIDTH / 2)];
            
            [_buttonCancelNearBy setCenter:CGPointMake(CONFIG_CENTER_LEFT,
                                                       MAIN_POR_HEIGHT - CONFIG_NAVI_BOTTOM_HEIGHT
                                                       -CONFIG_HISTOGRAM_HEIGHT - 2 * CONFIG_BUTTON_SAPCE
                                                       - CONFIG_BUTTON_NORMAL_WIDTH * 1.5)];
            
            if([[ANParamValue sharedInstance] isPath] == NO)
            {
                [_buttonBackCar setCenter:CGPointMake(CONFIG_CENTER_LEFT,
                                                      MAIN_POR_HEIGHT - CONFIG_CRUISE_BOTTOM_HEIGHT
                                                      - CONFIG_METER_HEIGHT - CONFIG_BUTTON_SAPCE
                                                      - CONFIG_BUTTON_NORMAL_WIDTH / 2)];
            }
            else
            {
                [_buttonBackCar setCenter:CGPointMake(CONFIG_CENTER_LEFT,
                                                      MAIN_POR_HEIGHT - CONFIG_NAVI_BOTTOM_HEIGHT
                                                      - CONFIG_HISTOGRAM_HEIGHT - CONFIG_BUTTON_SAPCE
                                                      - CONFIG_BUTTON_NORMAL_WIDTH / 2)];
            }

        }
    }
    else
    {
        if(isiPhone)
        {
            //Y : 3个按钮间空白，1个放大缩小按钮高度，1个正常按钮高度，1个比例尺高度

            
            [_buttonAllSee setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                               MAIN_LAND_HEIGHT - CONFIG_BUTTON_NORMAL_WIDTH * 1.5f - CONFIG_METER_HEIGHT - CONFIG_BUTTON_SAPCE * 2)];
            
            [_buttonParallelRoad setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                       _buttonAllSee.center.y -  CONFIG_BUTTON_SAPCE  - CONFIG_BUTTON_NORMAL_WIDTH)];
            
            [_buttonBackCar setCenter:CGPointMake(CONFIG_CENTER_LEFT,
                                                  MAIN_LAND_HEIGHT - CONFIG_BUTTON_SAPCE - CONFIG_BUTTON_NORMAL_WIDTH/2)];
            
            [_buttonCancelNearBy setCenter:CGPointMake(CONFIG_CENTER_LEFT + CONFIG_BUTTON_SAPCE + CONFIG_BUTTON_NORMAL_WIDTH,
                                                       MAIN_LAND_HEIGHT - CONFIG_BUTTON_SAPCE - CONFIG_BUTTON_NORMAL_WIDTH / 2)];
        }
        else
        {
            //Y : 减去导航低栏高度，状态栏高度，3个按钮间空白，2个放大缩小按钮高度，1.5个正常按钮高度，1个比例尺高度
            [_buttonParallelRoad  setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                        MAIN_LAND_HEIGHT - CONFIG_NAVI_BOTTOM_HEIGHT
                                                        - CONFIG_HISTOGRAM_HEIGHT - 3 * CONFIG_BUTTON_SAPCE
                                                        - 2 * CONFIG_NARROW_BUTTON_HEIGHT - (CONFIG_BUTTON_NORMAL_WIDTH * 3) / 2
                                                        - CONFIG_METER_HEIGHT)];
            
            //全览
            [_buttonAllSee setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                                 MAIN_LAND_HEIGHT - CONFIG_NAVI_BOTTOM_HEIGHT
                                                 - CONFIG_HISTOGRAM_HEIGHT - CONFIG_BUTTON_SAPCE
                                                 - CONFIG_BUTTON_NORMAL_WIDTH / 2)];
            
            [_buttonCancelNearBy setCenter:CGPointMake(CONFIG_CENTER_LEFT,
                                                       MAIN_LAND_HEIGHT - CONFIG_NAVI_BOTTOM_HEIGHT
                                                       -CONFIG_HISTOGRAM_HEIGHT - 2 * CONFIG_BUTTON_SAPCE
                                                       - CONFIG_BUTTON_NORMAL_WIDTH * 1.5)];
            
            if([[ANParamValue sharedInstance] isPath] == NO)
            {
                [_buttonBackCar setCenter:CGPointMake(CONFIG_CENTER_LEFT,
                                                      MAIN_LAND_HEIGHT - CONFIG_CRUISE_BOTTOM_HEIGHT
                                                      - CONFIG_METER_HEIGHT - CONFIG_BUTTON_SAPCE
                                                      - CONFIG_BUTTON_NORMAL_WIDTH / 2)];
            }
            else
            {
                [_buttonBackCar setCenter:CGPointMake(CONFIG_CENTER_LEFT,
                                                      MAIN_LAND_HEIGHT - CONFIG_NAVI_BOTTOM_HEIGHT
                                                      - CONFIG_HISTOGRAM_HEIGHT - CONFIG_BUTTON_SAPCE
                                                      - CONFIG_BUTTON_NORMAL_WIDTH / 2)];
            }
        }
    }
    [_buttonSwitchTripDirect setTransform:tempAt];
}

/*!
  @brief
  @param
  @author   by bazinga
  */
- (void) reloadTextColor:(int) type
{
    if(type == 1)
    {
        if(Interface_Flag == 0)
        {
            [_buttonCancelNearBy setTitleColor:GETSKINCOLOR(MAIN_CANCELDETOUR_NIGHT_POR_COLOR) forState:UIControlStateNormal];
        }
        else
        {
            [_buttonCancelNearBy setTitleColor:GETSKINCOLOR(MAIN_CANCELDETOUR_NIGHT_LAND_COLOR) forState:UIControlStateNormal];
        }
        [_buttonAllSee setTitleColor:GETSKINCOLOR(MAIN_NIGHT_METER_COLOR) forState:UIControlStateNormal];
    }
    else
    {
        [_buttonAllSee setTitleColor:GETSKINCOLOR(MAIN_DAY_METER_COLOR) forState:UIControlStateNormal];
        
        if(Interface_Flag == 0 || !isiPhone)
        {
            [_buttonCancelNearBy setTitleColor:GETSKINCOLOR(MAIN_CANCELDETOUR_DAY_POR_COLOR) forState:UIControlStateNormal];
        }
        else
        {
            [_buttonCancelNearBy setTitleColor:GETSKINCOLOR(MAIN_CANCELDETOUR_DAY_LAND_COLOR) forState:UIControlStateNormal];
        }
    }


}

/*!
  @brief    设置平行道路是否隐藏
  @param
  @author   by bazinga
  */
- (void) setParallelRoadHidden:(BOOL) hidden
{
    _buttonParallelRoad.hidden = hidden;
}

/*!
  @brief    获取平行道路是否隐藏
  @param
  @author   by bazinga
  */
- (BOOL) getParallelRoadHidden
{
    return _buttonParallelRoad.hidden;
}

/*!
  @brief    设置实时交通灯是否隐藏
  @param
  @author   by bazinga
  */
- (void) setRealHidden:(BOOL) hidden
{
    _buttonReal.hidden = hidden;
}

/*!
  @brief    设置高速路牌是否隐藏
  @param
  @author   by bazinga
  */
- (void) setGuidePostHidden:(BOOL) hidden
{
    _buttonGuidePost.hidden = hidden;
}

/*!
  @brief    获取高速路牌是否隐藏
  @param
  @author   by bazinga
  */
- (BOOL) GetGuidePostHidden
{
    return _buttonGuidePost.hidden;
}

/*!
  @brief    设置指北针按钮是否隐藏
  @param
  @author   by bazinga
  */
- (void) setSwitchTripDirectHidden:(BOOL) hidden
{
    _buttonSwitchTripDirect.hidden = hidden;
}

/*!
  @brief    设置全览按钮是否隐藏
  @param
  @author   by bazinga
  */
- (void) setAllSeeHidden:(BOOL) hidden
{
    _buttonAllSee.hidden = hidden;
}

/*!
  @brief    设置取消周边是否隐藏
  @param
  @author   by bazinga
  */
- (void) setCancelNearbyHidden:(BOOL) hidden
{
    _buttonCancelNearBy.hidden = hidden;
}

/*!
  @brief    重新加载字体
  @param
  @author   by bazinga
  */
- (void) reloadText
{
    if(isiPhone)
    {
        if(fontType == 2)
        {
            _buttonCancelNearBy.titleLabel.font = [UIFont systemFontOfSize:13];
        }
        else
        {
            _buttonCancelNearBy.titleLabel.font = [UIFont systemFontOfSize:14];
        }
    }
    else
    {
        if(fontType == 2)
        {
            _buttonCancelNearBy.titleLabel.font = [UIFont systemFontOfSize:16];
        }
        else
        {
            _buttonCancelNearBy.titleLabel.font = [UIFont systemFontOfSize:21];
        }
    }
    
    [_buttonCancelNearBy setTitle:STR(@"Main_cancelNearby", Localize_Main) forState:UIControlStateNormal];
}

/*!
  @brief    设置指北针的角度
  @param
  @author   by bazinga
  */
- (void) setSwitchTransform:(CGAffineTransform)at
{
    [_buttonSwitchTripDirect setBackgroundImage:IMAGE(@"mainDirect.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [_buttonSwitchTripDirect setBackgroundImage:IMAGE(@"mainDirect.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
    [_buttonSwitchTripDirect setTransform:at];
}

/*!
  @brief    重新白天黑夜图片
  @param
  @author   by bazinga
  */
- (void) reloadImage
{
    UIImage *image = IMAGE(@"mainBackCar.png", IMAGEPATH_TYPE_2);
    UIImage *imagePress =IMAGE(@"mainBackCarPress.png", IMAGEPATH_TYPE_2);
    if(Interface_Flag == 1 && isiPhone)
    {
        UIImage *tempImage = IMAGE(@"mainBackCarLand.png", IMAGEPATH_TYPE_2);
        UIImage *tempImagePress = IMAGE(@"mainBackCarLandPress.png", IMAGEPATH_TYPE_2);
        image =  tempImage== nil ?  image :  tempImage;
        imagePress = tempImagePress == nil ? imagePress : tempImagePress;
    }
    
    [_buttonBackCar setBackgroundImage:image forState:UIControlStateNormal];
    [_buttonBackCar setBackgroundImage:imagePress forState:UIControlStateHighlighted];
    
    [_buttonParallelRoad setBackgroundImage:IMAGE(@"Route_cancelDetour.png", IMAGEPATH_TYPE_2)
                                   forState:UIControlStateNormal];
    [_buttonParallelRoad setBackgroundImage:IMAGE(@"Route_cancelDetourPress.png", IMAGEPATH_TYPE_2)
                                   forState:UIControlStateHighlighted];
}

/*!
  @brief    重载全览按钮图片
  @param
  @author   by bazinga
  */
- (void) relaodAllSeeImage:(BOOL) overView
{
    if(!overView)
    {
        [_buttonAllSee setBackgroundImage:IMAGE(@"main_AllSee.png", IMAGEPATH_TYPE_2)
                                 forState:UIControlStateNormal];
        [_buttonAllSee setBackgroundImage:IMAGE(@"main_AllSeePress.png", IMAGEPATH_TYPE_2)
                                 forState:UIControlStateHighlighted];
        [_buttonAllSee setTitle:STR(@"Main_AllSee", Localize_Main) forState:UIControlStateNormal];
    }
    else
    {
        [_buttonAllSee setBackgroundImage:IMAGE(@"main_AllSeeBack.png", IMAGEPATH_TYPE_2)
                                 forState:UIControlStateNormal];
        [_buttonAllSee setBackgroundImage:IMAGE(@"main_AllSeeBackPress.png", IMAGEPATH_TYPE_2)
                                 forState:UIControlStateHighlighted];
        [_buttonAllSee setTitle:STR(@"Main_back", Localize_Main) forState:UIControlStateNormal];
    }

}

/*!
  @brief    重新加载取消周边按钮图片
  @param
  @author   by bazinga
  */
- (void) reloadCancelNearByImage
{
    UIImage *image1 = IMAGE(@"Route_cancelDetour.png", IMAGEPATH_TYPE_2);
    UIImage *imagePress = IMAGE(@"Route_cancelDetourPress.png", IMAGEPATH_TYPE_2) ;
    if(Interface_Flag == 1 && isiPhone)
    {
        image1 = IMAGE(@"Route_cancelDetourLand.png", IMAGEPATH_TYPE_2) == nil ?
        image1 : IMAGE(@"Route_cancelDetourLand.png", IMAGEPATH_TYPE_2);
        
        imagePress = IMAGE(@"Route_cancelDetourLandPress.png", IMAGEPATH_TYPE_2)  == nil ?
        imagePress : IMAGE(@"Route_cancelDetourLandPress.png", IMAGEPATH_TYPE_2);
    }

    [_buttonCancelNearBy setBackgroundImage:image1 forState:UIControlStateNormal];
    [_buttonCancelNearBy setBackgroundImage:imagePress forState:UIControlStateHighlighted];
}

/*!
  @brief    重新加载交通灯按钮图片
  @param
  @author   by bazinga
  */
- (void) relaodRealIamge
{
    //实时交通（坐上红绿灯）管理按钮
    if([MWEngineSwitch isTMCOn])
    {
        [_buttonReal setBackgroundImage:IMAGE(@"mainRealTraffic.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [_buttonReal setBackgroundImage:IMAGE(@"mainRealTrafficPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
    }
    else
    {
        [_buttonReal setBackgroundImage:IMAGE(@"mainRealTrafficDisnable.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [_buttonReal setBackgroundImage:IMAGE(@"mainRealTrafficDisnablePress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
    }
}

/*!
  @brief    设置是否置顶
  @param
  @author   by bazinga
  */
- (void) setGuidePostIsTop:(BOOL) top
{
    if (top)
    {
        
        [_view bringSubviewToFront:_buttonGuidePost];
    }
    else
    {
        [_view sendSubviewToBack:_buttonGuidePost];
    }
}
#pragma mark - ---  辅助函数  ---




- (void) buttonAction:(id) sender
{
    if(self.buttonClick)
    {
        self.buttonClick(sender);
    }
}

@end
