//
//  Plugin_POI.h
//  AutoNavi
//
//  Created by huang on 13-8-15.
//
//

#import <Foundation/Foundation.h>
#import "ModuleDelegate.h"

#define POI_NAVIGATIONCONTROLLER        @"navigationController"
#define POI_TYPE                        @"type" //0->导航 1->周边，2->附近，3->检索 4->电子眼 6->常用 7->设置 8->沿途周边 9->目的地停车场 11->收藏点编辑 12->添加点
#define POI_DATA                        @"data"                       //数据
#define POI_ISBACKSUPERVIEWCONTROLLER   @"isBackSuperViewController"  //是否返回当前进入界面
#define POI_DELEGATE                    @"delegate"                   //layerSelectPOIDelegate协议
#define POI_VIEWCONTROLLER              @"viewController"
#define POI_DATA_FROMMAINCONTROLLER     @"fromMainController"
#define POI_CategoryID                  @"CategoryID"                 //类别ID用于沿途周边检索

#define POI_Array                       @"POI_Array"                  //数组里面存路线规划的点
#define POI_WhereGo                     @"POI_WhereGo"                //从那里进入导航 0->主界面进入 1->设起点进入 2->添加途经点进入 3->移图添加途经点进入

#define POI_PoiPoint                    @"poi"                        //MWPOI类型的poi点
/*!
  @brief 相应模块调用该方法进入该模块
  @param param: NSDictionary 包含   
 
 key                             value

 controller                      上一级导航页面
 type                            0->导航1->周边2->附近3->检索4->电子眼6->常用7->设置8->沿途周边9->目的地停车场11->收藏点编辑 12->添加点
 data                            数据
 isBackSuperViewController       是否返回当前进入界面
 layerSelectPOIDelegate          layerSelectPOIDelegate协议
 CategoryID                      类别ID
 POI_Array                       数组里面存路线规划的点
 POI_PoiPoint                    MWPOI类型的poi点
  @return 0失败;        1成功
  */


@interface Plugin_POI : NSObject<ModuleDelegate>
@end
@class MWPoi;
@protocol POISelectPOIDelegate <NSObject>
-(void)selectPoi:(MWPoi*)object withOperation:(int)operation;
@optional
-(void)selectPoiWithArray:(NSArray*)array withIndex:(int)index;
-(void)PoiDesParkingStopArray:(NSArray *)array;

@end