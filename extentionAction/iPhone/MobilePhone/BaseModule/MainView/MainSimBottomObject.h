//
//  MainSimBottomObject.h
//  AutoNavi
//
//  Created by bazinga on 14-9-2.
//  Copyright (c) 2014年 bazinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BottomButton.h"
#import "MainDefine.h"

@interface MainSimBottomObject : NSObject
{
    BottomButton *_bottomButtonSimuStop;    //模拟导航停止
    BottomButton *_bottomButtonSimuPlay;    //模拟导航开始/暂停
    BottomButton *_bottomSelect;            //模拟导航选择速度
}

@property (nonatomic, retain, readonly) UIView *viewSimuBG;     //模拟导航底

@property (nonatomic, copy) MainButtonClick mainButtonClick;    //按钮点击事件

- (id) init;

/*!
  @brief    设置视图是否隐藏
  @param
  @author   by bazinga
  */
- (void) setViewHidden:(BOOL)hidden;

/*!
  @brief    重新加载控件坐标
  @param
  @author   by bazinga
  */
- (void) reloadFrame;

/*!
  @brief    设置模拟导航 开始/暂停 图片
  @param    isPlay —— YES : 开始图片   NO：暂停图片
  @author   by bazinga
  */
- (void) setSimPlayImage:(BOOL) isPlay;

/*!
  @brief    设置速度的标题
  @param
  @author   by bazinga
  */
- (void) setSelectTitle:(NSString *)string;

/*!
  @brief    获取模拟导航速度选择的坐标
  @param
  @author   by bazinga
  */
- (CGRect) getSelectRect;

@end
