//
//  MWMileageList.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-4-11.
//
//

#import <Foundation/Foundation.h>

@interface MWMileageList : NSObject

@property (nonatomic, assign) int total;                       //总里程
@property (nonatomic, assign) int week;                        //周里程
@property (nonatomic, assign) int today;                       //日里程
@property (nonatomic, assign) int total_ranking;               //总排名
@property (nonatomic, assign) int week_ranking;                //区域周排名
@property (nonatomic, assign) int area;                        //区域
@property (nonatomic, retain) NSMutableArray *totalUserRanking;//全国总排行
@property (nonatomic, retain) NSMutableArray *areaUserRanking; //区域周排行

@end

@interface MWMileageUserDetail : NSObject

@property (nonatomic, copy) NSString *userName;   //用户名
@property (nonatomic, assign) int total;          //总里程

@end