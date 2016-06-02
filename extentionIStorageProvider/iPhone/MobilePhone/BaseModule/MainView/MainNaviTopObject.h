//
//  MainNaviTopObject.h
//  AutoNavi
//
//  Created by bazinga on 14-9-2.
//  Copyright (c) 2014年 bazinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoveTextLable.h"
#import "MainDefine.h"

typedef void(^HandleTap)(UITapGestureRecognizer *);
typedef void(^HandleSwipe)(UISwipeGestureRecognizer *);

@interface MainNaviTopObject : NSObject
{

    UIImageView *_imageRight;               //顶部向右的小箭头
    MoveTextLable *_labelNextRoad;              //下一个道路名显示名称
    UILabel  *_labelQianfang;                   //前方道路
    UILabel *_labelEnter ;                      //进入
    UIImageView *_buttonLeftDirect;      //方向转向图标——左上角
	UILabel *_labelLeft;        //下一个路口的距离
}

@property (nonatomic,retain,readonly) UIImageView *imageViewNaviTopBG;
@property (nonatomic, retain,readonly)  UIImageView *imageDirectAndDistance;

@property (nonatomic, copy) HandleTap handleTap;
@property (nonatomic, copy) HandleSwipe handleSwipe;

/*!
  @brief    初始化
  @param
  @author   by bazinga
  */
- (id) init;

/*!
  @brief    设置（前方）控件的文字
  @param    string ： 文字标题
  @author   by bazinga
  */
- (void) setQianfangText:(NSString *)string;

/*!
  @brief    设置（进入）控件的文字
  @param    string ： 文字标题
  @author   by bazinga
  */
- (void) setEnterText:(NSString *)string;

/*!
  @brief    设置（下一道路名）控件的文字
  @param    string ： 文字标题
  @author   by bazinga
  */
- (void) setNextRoadText:(NSString *)string;

/*!
  @brief    设置（剩余距离）控件的问题
  @param    string：剩余距离
  @author   by bazinga
  */
- (void) setLeftText:(NSString *)string;

/*!
  @brief    设置转向图片
  @param
  @author   by bazinga
  */
- (void) setImageDirect:(UIImage *)image;

/*!
  @brief    重新加载视图坐标
  @param
  @author   by bazinga
  */
- (void) reloadFrame;

/*!
  @brief    设置改视图是否隐藏
  @param    hidden - YES: 隐藏  NO：显示
  @author   by bazinga
  */
- (void) setViewHidden:(BOOL)hidden;

/*!
  @brief    下一道路名是否隐藏
  @param    hidden - YES: 隐藏  NO：显示
  @author   by bazinga
  */
- (void) setNextRoadHidden:(BOOL)hidden;
@end
