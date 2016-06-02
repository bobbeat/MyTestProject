//
//  MainCruiseTopObject.h
//  AutoNavi
//
//  巡航状态下 -- 顶部搜索栏控件
//
//  Created by bazinga on 14-9-1.
//  Copyright (c) 2014年 bazinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainDefine.h"

@interface MainCruiseTopObject : NSObject
{
    UIButton *_buttonSoundSearch;               //声音搜索
    ANButton *_anbuttonTopSearch;               //可点击的进入搜索的按钮
    UIImageView *_imageviewMagnifier;           //搜索的放大镜图片
    UIButton *_buttonViewFace;                //头像按钮
    UIImageView *_imageFaceNew;                 //头像上的 new 红点
    UIImageView *_imageViewdiv;               //声音的按钮分割线
}

@property (nonatomic, retain,readonly) UIImageView *imageTopSearch;  //顶部的搜索框背景

@property (nonatomic, copy) MainButtonClick mainButtonClick;

/*!
  @brief    初始化函数
  @param
  @author   by bazinga
  */
- (id) init;

/*!
  @brief    重新加载头像
  @param
  @author   by bazinga
  */
- (void) reloadFaceImage;

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
  @brief    隐藏 new 的红点图标
  @param
  @author   by bazinga
  */
- (void) hiddenFaceNew;

/*!
  @brief    设置是否显示顶部搜索栏（巡航显示，导航隐藏）
  @param    hidden —— YES: 隐藏  NO: 显示
  @author   by bazinga
  */
- (void) setTopHidden:(BOOL) hidden;

/*!
  @brief    设置顶部搜索栏的大小
  @param    rect —— 顶部搜索栏的大小
  @author   by bazinga
  */
- (void) setTopFrame:(CGRect )rect;

/*!
  @brief    中英繁切换，设置文字
  @param
  @author   by bazinga
  */
- (void) reloadText;
@end
