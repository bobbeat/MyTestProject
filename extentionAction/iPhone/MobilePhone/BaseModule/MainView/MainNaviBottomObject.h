//
//  MainNaviBottomObject.h
//  AutoNavi
//
//  Created by bazinga on 14-9-2.
//  Copyright (c) 2014年 bazinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ColorLable.h"
#import "MainDefine.h"

@interface MainNaviBottomObject : NSObject
{
    UIButton *_buttonStop;                  //停止导航按钮
    UIButton *_buttonList;                  //菜单栏按钮
//    ColorLable *_colorLabelRoadInfo;    //剩余路线信息
    
    ColorLable *_colorLabelSpeed;       //时速
    ColorLable *_colorLabelDistance;    //距离
    ColorLable *_colorLabelTime;        //时间
    
    UIImageView *_speedNumBack;         //超速文字的背景
    UILabel *_speedNum;             //超速的数字
}

@property (nonatomic, retain,readonly)  UIImageView *imageViewNaviBottomBG;    //底部的底
@property (nonatomic, retain,readonly)  UIImageView *overSpeedBack;             //超速的背景

@property (nonatomic, copy) MainButtonClick mainButtonClick;                    //按钮响应事件
/*!
  @brief    初始化函数
  @param
  @author   by bazinga
  */
- (id) init;

/*!
  @brief    设置视图的显示隐藏
  @param
  @author   by bazinga
  */
- (void) setViewHidden:(BOOL)hidden;

/*!
  @brief    重新加载坐标
  @param
  @author   by bazinga
  */
- (void) reloadFrame;

/*!
  @brief    获取菜单栏的位置
  @param
  @author   by bazinga
  */
- (CGRect) getListFrame;

/*!
  @brief    设置导航信息字符串
  @param
  @author   by bazinga
  */
- (void) setRoadInfoText:(NSString *) speed
               distances:(NSString *) distances
                    time:(NSString *) time;

/*!
  @brief    设置速度
  @param    设置的速度
  @author   by bazinga
  */
- (void) setSpeed:(int) speed;

/*!
  @brief    设置限速是否显示
  @param    是否显示
  @author   by bazinga
  */
- (void) setSpeedHidden:(BOOL) hidden;

/*!
  @brief    是否超速
  @param
  @author   by bazinga
  */
- (void) isOverSpeed:(BOOL)isOver;

@end
