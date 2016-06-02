//
//  ANDemoInfo.h
//  ANApi
//
//  Created by autonavi\wang.weiyang on 14-10-20.
//  Copyright (c) 2014年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  demo信息
 */
@interface ANDemoInfo : NSObject

/**
 *  行政区域名
 */
@property (strong, nonatomic) NSString *adminName;
/**
 *  演示demo列表
 */
@property (strong, nonatomic) NSArray *demoItems;

@end
