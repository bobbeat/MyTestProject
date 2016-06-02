//
//  MainDefine.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-7-3.
//
//

#import <Foundation/Foundation.h>

#ifndef MAIN_DEFINE_H
#define MAIN_DEFINE_H

#import "MainControlCreate.h"


#pragma mark - ---  程序定义的宽高  ---
//定义程序的界面的高宽
#define STATUS_BAR_HEIGHT  [[UIApplication sharedApplication] statusBarFrame].size.height
//竖屏
#define MAIN_POR_WIDTH       SCREENWIDTH
#define MAIN_POR_HEIGHT      (SCREENHEIGHT - (((float)NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) ? 0 : 20) - (STATUS_BAR_HEIGHT == 40 ? 20:0))
//横屏
#define MAIN_LAND_WIDTH      SCREENHEIGHT
#define MAIN_LAND_HEIGHT     (SCREENWIDTH- (((float)NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) ? 0 : 20))
#define BOTTOM_DIS_HEIGHT 28.0f     //  横屏状态下距离底的距离
#define BUTTON_BOUNDARY  (isiPhone ? 28.0f : 38.0f )    //   主界面右侧按钮的中心距离

#pragma mark - ---  按钮点击 block  ---

typedef void(^MainButtonClick)(id);

#pragma mark - ---  主界面控件对象坐标位置  ---

//巡航状态下，顶部和底部的 XX
#define CONFIG_CRUISE_TOP_HEIGHT (isiPhone ? (DIFFENT_STATUS_HEIGHT + 44.0f) : (DIFFENT_STATUS_HEIGHT + 66.0f))
#define CONFIG_CRUISE_BOTTOM_HEIGHT (isiPhone ? (Interface_Flag == 0 ? 44.0f : 40.0f ) : 72.0f)

//导航状态下，顶部和底部的 XX
#define CONFIG_NAVI_TOP_DIRE_HEIGHT (isiPhone ? (Interface_Flag == 0 ? (DIFFENT_STATUS_HEIGHT + 85.0f) : (86.0f + DIFFENT_STATUS_HEIGHT)):(Interface_Flag == 0 ? (DIFFENT_STATUS_HEIGHT + 143.0f) : (143.0f + DIFFENT_STATUS_HEIGHT)))
#define CONFIG_NAVI_TOP_NAME_HEIGHT (isiPhone ? (Interface_Flag == 0 ? (DIFFENT_STATUS_HEIGHT + 85.0f) : (43.0f + DIFFENT_STATUS_HEIGHT)):(Interface_Flag == 0 ? (DIFFENT_STATUS_HEIGHT + 143.0f) : (81.0f + DIFFENT_STATUS_HEIGHT)))

//导航时候，低栏的高度
#define CONFIG_NAVI_BOTTOM_HEIGHT  (isiPhone ? (Interface_Flag == 0 ? 44.0f : 36.0f) : 65.0f )

//按钮之间的间距
#define CONFIG_BUTTON_SAPCE (isiPhone ? 8.0f : 10.0f)
//正常按钮的长宽
#define CONFIG_BUTTON_NORMAL_WIDTH (isiPhone ? 40.0f : 60.0f)

/*!
  @brief    放大缩小按钮部分, 比例尺图片
  @author   by bazinga
  */
#define CONFIG_NARROW_BUTTON_WIDTH (isiPhone ? 40.0f : 60.0f)
#define CONFIG_NARROW_BUTTON_HEIGHT (isiPhone ? (Interface_Flag == 0 ? 42.0f : 40.0f) : 63.0f)
#define CONFIG_METER_WIDTH  (isiPhone ? 36.0f : 50.0f)
#define CONFIG_METER_HEIGHT (isiPhone ? 12.0f : 20.0f)

#define CONFIG_HISTOGRAM_HEIGHT (isiPhone ? 5.0f : 6.0f)   //光柱图的高度
//右侧按钮的中心点坐标（减去  按钮间的间隔 + 正常按钮宽度的一半）
#define CONFIG_CENTER_RIGHT ((Interface_Flag == 0 ? MAIN_POR_WIDTH : MAIN_LAND_WIDTH) - CONFIG_BUTTON_SAPCE - CONFIG_BUTTON_NORMAL_WIDTH / 2)
//左侧按钮的中心店坐标 (按钮间的间隔 + 正常按钮宽度的一半)
#define CONFIG_CENTER_LEFT (CONFIG_BUTTON_SAPCE + CONFIG_BUTTON_NORMAL_WIDTH / 2)

#endif