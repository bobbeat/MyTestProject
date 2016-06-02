//
//  MapViewManager.h
//  AutoNavi
//
//  Created by gaozhimin on 14-8-5.
//
//

#import <Foundation/Foundation.h>

@class PaintingView;

@interface MapViewManager : NSObject

/*
 * @brief 用于加载地图
 * @param ctl 加载地图的controller
 * @return PaintingView 加载的地图
 */
+ (PaintingView *)ShowMapViewInController:(UIViewController *)ctl;

/*
 * @brief 用于清楚缓存地图父视图，为下一次加载做准备，在viewdidapeare中调用
 */
+ (void)ClearBufferViewSuperview;

@end
