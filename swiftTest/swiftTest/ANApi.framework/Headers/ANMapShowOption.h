//
//  ANMapShowOption.h
//  ANApi
//
//  Created by liyuhang on 14-12-3.
//  Copyright (c) 2014年 yuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANPoi.h"
#import "ANRouteStep.h"

/**
 *  该参数设置提供显示特定地图功能
 *  一） 对象为nil                               显示默认地图
 *  二） isShowRouteOverview为YES                有路径下，将显示路径全程概览
 *  三） poiShow不为nil                          以当前poi点坐标为中心进行显示
 *  四） SPCode不为nil                           以当前SP坐标为中心显示
 *  五） roadInfo不为nil                         显示路口信息界面
 */
@interface ANMapShowOption : NSObject
{
    
}
/**Property
 * @brief       有路径下，将显示路径全程概览
 *
 */
#pragma mark -
#pragma mark 地图类型一
@property (nonatomic, assign)       BOOL                isShowRouteOverview;

#pragma mark - 
#pragma mark 地图类型二
/**Property
 * @brief       设置显示的poi点，
 *
 */
@property (nonatomic, strong)       ANPoi*              poiShow;

@property (nonatomic, assign)       BOOL                isPoiShowAutoAdjust;
#pragma mark -
#pragma mark 地图类型三
/**Property
 * @brief       查看SP点坐标，
 *
 */
@property (nonatomic, strong)       NSString*           SPCode;

@property (nonatomic, assign)       BOOL                isSpShowAutoAdjust;

#pragma mark -
#pragma mark 地图类型四
/**Property
 * @brief       查看SP点坐标，
 *
 */
@property (nonatomic, strong)       ANRouteStep*    roadInfo;

@property (nonatomic, assign)       BOOL                isRotateMap;


@end
