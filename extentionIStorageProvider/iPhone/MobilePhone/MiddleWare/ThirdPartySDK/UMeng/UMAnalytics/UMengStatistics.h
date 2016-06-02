//
//  UMengStatistics.h
//  AutoNavi
//
//  Created by huang on 14-1-3.
//
//

#import <Foundation/Foundation.h>

@interface UMengStatistics : NSObject
//统计实时交通开启时间段
+(void)trafficTimeBucket;                                       //获取系统时间段
+(void)trafficTimeBucket:(int)bucket;                           //手动设置时间段
+(void)recalculationCount:(int)count;                           //偏航次数
+(void)naviDistanceCount:(int)dis;                              //导航距离
//+(void)naviDistanceCount:(int)dis withNaviType:(int)type;       //导航距离带类型
@end
