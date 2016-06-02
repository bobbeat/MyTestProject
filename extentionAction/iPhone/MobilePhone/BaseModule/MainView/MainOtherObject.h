//
//  MainOtherObject.h
//  AutoNavi
//
//  Created by bazinga on 14-9-10.
//  Copyright (c) 2014年 bazinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainDefine.h"

@interface MainOtherObject : NSObject
{
    UIButton *_buttonParallelRoad;      //平行道路切换
    
    UIButton *_buttonGuidePost;              //高速路牌按钮 。蓝色层叠
    
    UIButton * _buttonReal;                     //实时交通显示灯按钮
    
    UIButton *_buttonBackCar;       //回车位按钮
    
    UIButton *_buttonSwitchTripDirect;          //指南针方向按钮

    UIButton *_buttonAllSee;                //全览按钮
    
    UIButton *_buttonCancelNearBy;  //取消周边

    UIView *_view;
}

/*!
  @brief    按钮点击事件
  @param
  @author   by bazinga
  */
@property (nonatomic, copy) MainButtonClick buttonClick;

/*!
  @brief    初始化控件，并传入视图
  @param
  @author   by bazinga
  */
- (id) initWithView:(UIView *)view;

/*!
  @brief    重新加载界面坐标
  @param
  @author   by bazinga
  */
- (void) reloadFrame;

/*!
  @brief    重载文字颜色
  @param
  @author   by bazinga
  */
- (void) reloadTextColor:(int) type;

/*!
  @brief    设置平行道路是否隐藏
  @param
  @author   by bazinga
  */
- (void) setParallelRoadHidden:(BOOL) hidden;

/*!
  @brief    获取平行道路是否隐藏
  @param
  @author   by bazinga
  */
- (BOOL) getParallelRoadHidden;

/*!
  @brief    设置实时交通灯是否隐藏
  @param
  @author   by bazinga
  */
- (void) setRealHidden:(BOOL) hidden;

/*!
  @brief    设置高速路牌是否隐藏
  @param
  @author   by bazinga
  */
- (void) setGuidePostHidden:(BOOL) hidden;

/*!
  @brief    获取高速路牌是否隐藏
  @param
  @author   by bazinga
  */
- (BOOL) GetGuidePostHidden;

/*!
  @brief    设置指北针按钮是否隐藏
  @param
  @author   by bazinga
  */
- (void) setSwitchTripDirectHidden:(BOOL) hidden;

/*!
  @brief    设置全览按钮是否隐藏
  @param
  @author   by bazinga
  */
- (void) setAllSeeHidden:(BOOL) hidden;

/*!
  @brief    设置取消周边是否隐藏
  @param
  @author   by bazinga
  */
- (void) setCancelNearbyHidden:(BOOL) hidden;

/*!
  @brief    设置字体
  @param
  @author   by bazinga
  */
- (void) reloadText;

/*!
  @brief    重新回车位加载图片
  @param
  @author   by bazinga
  */
- (void) reloadImage;

/*!
  @brief    设置指北针的角度
  @param
  @author   by bazinga
  */
- (void) setSwitchTransform:(CGAffineTransform)at;

/*!
  @brief    重载全览按钮图片
  @param
  @author   by bazinga
  */
- (void) relaodAllSeeImage:(BOOL) overView;

/*!
  @brief    重新加载取消周边按钮图片
  @param
  @author   by bazinga
  */
- (void) reloadCancelNearByImage;

/*!
  @brief    重新加载交通灯按钮图片
  @param
  @author   by bazinga
  */
- (void) relaodRealIamge;

/*!
  @brief    设置是否置顶
  @param
  @author   by bazinga
  */
- (void) setGuidePostIsTop:(BOOL) top;

@end
