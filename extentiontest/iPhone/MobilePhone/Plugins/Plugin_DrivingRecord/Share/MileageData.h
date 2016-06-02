//
//  MileageData.h
//  objectToplist
//
//  Created by weihong.wang on 14-4-9.
//  Copyright (c) 2014年 wangweihong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MileageData : NSObject
@property (nonatomic, copy) NSString *userID;	        //用户名称
@property (nonatomic, copy) NSString *recordDate;	        //记录日期
@property (nonatomic, copy) NSString *totalMileage;	    //总里程
@property (nonatomic, copy) NSString *upTodayMileage;	    //今日里程
@property (nonatomic, copy) NSString *weekMileage;        //本周里程
@property (nonatomic, copy) NSString *noUpTodayMileage;    //今日未上传里程
@end
