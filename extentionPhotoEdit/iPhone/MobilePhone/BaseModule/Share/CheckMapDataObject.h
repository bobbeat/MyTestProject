//
//  CheckMapDataObject.h
//  AutoNavi
//
//  Created by gaozhimin on 14-7-26.
//
//

#import <Foundation/Foundation.h>

/*
 * @brief 检测地图数据，弹出响应对话框。
 */
@interface CheckMapDataObject : NSObject

/*
 * @brief 是否提示为不合理路径规划
 * @parm  isFit YES为不合理规划路径
 */
+ (void)setNotFitcal:(BOOL)isFit;

/*
 * @brief 检测地图中心点是否有地图数据 用于移图时的检测 不会弹出提示框
 * @return -1:海 0:无数据区域 1:有数据
 */
+ (int)CheckMapData;

/*
 * @brief 根据poi检测地图数据，用于查看poi，无数据时会弹出提示框
 * @return -1:海 0:无数据区域 1:有数据
 */
+ (int)CheckMapDataWith:(MWPoi *)poi cancelHandler:(GDAlertViewHandler)handler;

/*
 * @brief 根据缺失城市行政编码，提示缺失城市，会弹出提示框
 * @parm missingCityAdmincode 缺失城市的行政编码
 * @parm missingCount 缺失城市的个数
 * @parm bRoute 是否为演算的缺失城市
 */
+ (void)TipTheMissingCity:(int *)missingCityAdmincode missingCount:(int)missingCount bRoute:(BOOL)bRoute cancelHandler:(GDAlertViewHandler)handler;;

@end
