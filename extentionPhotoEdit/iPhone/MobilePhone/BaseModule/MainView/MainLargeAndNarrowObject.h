//
//  MainLargeAndNarrowObject.h
//  AutoNavi
//
//  主界面 放大，缩小 按钮
//
//  Created by bazinga on 14-8-29.
//  Copyright (c) 2014年 bazinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainDefine.h"

@interface MainLargeAndNarrowObject : NSObject
{
    GMAPVIEWTYPE _mapViewType;      //放大缩小的地图模式，默认是主地图
    BOOL _isLongPressed;            //是否长按放大，缩小
    
    NSTimer *inc_timer, *dec_timer; //放大缩小长按定时器
}

//缩小按钮
@property (nonatomic,retain,readonly) UIButton *buttonNarrow;
//放大按钮
@property (nonatomic,retain,readonly) UIButton *buttonEnlarge;
//比例次按钮
@property (nonatomic,retain,readonly) UIButton *buttonMeter;

//放大缩小按钮点击时间
@property (nonatomic,copy) MainButtonClick mainButtonClick;

/*!
  @brief    初始化函数
  @param
  @author   by bazinga
  */
- (id) init;
/*!
  @brief    初始化函数
  @param    mapViewType ： 放大缩小的起作用的地图模式
  @author   by bazinga
  */
- (id) initWithMapType:(GMAPVIEWTYPE)mapViewType;

/*!
  @brief    设置放大缩小起作用的地图模式
  @param    mapViewType ： 放大缩小的起作用的地图模式
  @author   by bazinga
  */
- (void) setMapView:(GMAPVIEWTYPE)mapViewType;

/*!
  @brief    设置比例次大小
  @param
  @author   by bazinga
  */
- (void) setMeterString:(NSString *)meterString;

/*!
  @brief    定时器是否在运行
  @param
  @author   by bazinga
  */
- (BOOL) isTimerRunning;

/*!
  @brief    重新加载图片，白天黑夜 or 皮肤
  @param
  @author   by bazinga
  */
- (void) reloadImage;

/*!
  @brief    重新加载文字颜色，白天 or 黑夜
  @param
  @author   by bazinga
  */
- (void) reloadTextColor:(int) type;

/*!
  @brief    加载放大缩小的按钮坐标大小
  @param
  @author   by bazinga
  */
- (void) reloadControlFrame;

@end
