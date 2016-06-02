//
//  MainBottomMenuObject.h
//  AutoNavi
//
//  顶栏菜单栏的按钮 —— 四个按钮： 导航，附近，服务，设置
//
//  Created by jiangshu-fu on 14-8-28.
//
//

#import <Foundation/Foundation.h>
#import "BottomMenuBar.h"
#import "MainDefine.h"

@interface MainBottomMenuObject : NSObject
{
    NSMutableArray *_arrayMenuBarinfo;              //所有信息数据
    NSMutableDictionary *_dictMenuKeyForAppear;     //底栏显示的数据信息
    UIImageView *_imageViewNew;                     //设置 new
    UIImageView *_imageViewNewCar;                  //车主服务 new
}

@property (nonatomic, retain, readonly) BottomMenuBar *bottomMenuBar;                  //底栏菜单的背景
@property (nonatomic, copy) MainButtonClick bottomMenuClick;

/*!
  @brief    设置底部菜单栏是否隐藏
  @param
  @author   by bazinga
  */
- (void) setBottomMenuBarHidden:(BOOL)hidden;

/*!
  @brief    设置 设置 按钮是否隐藏
  @param
  @author   by bazinga
  */
- (void) setSettingNewHidden:(BOOL) hidden;

/*!
  @brief    设置车主服务按钮红点是否隐藏
  @param
  @author   by bazinga
  */
- (void) setCarNewHidden:(BOOL) hidden;

/*!
  @brief    重新加载按钮图片
  @param
  @author   by bazinga
  */
- (void) reloadBottomBarButtonImage;

/*!
  @brief    重新加载按钮颜色
  @param
  @author   by bazinga
  */
- (void) reloadBottomBarButtonTextColor:(int)type;

/*!
  @brief    中英文切换文字
  @param
  @author   by bazinga
  */
- (void) reloadBottomText;

/*!
  @brief    设置低栏四个按钮的位置
  @param
  @author   by bazinga
  */
- (void) setRealBottomButtonFrame;

@end
