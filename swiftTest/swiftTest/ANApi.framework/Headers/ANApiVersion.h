//
//  ANApiVersion.h
//  ANApi
//
//  Created by yang yi on 14-12-25.
//  Copyright (c) 2014年 Autonavi. All rights reserved.
//

#ifndef ANApi_ANApiVersion_h
#define ANApi_ANApiVersion_h
#import <UIKit/UIKit.h>

/*****更新日志：*****
 V0.1.0： 测试版
 支持地图浏览，基础操作
 支持路径演算、引导
 支持POI搜索
 ...
 支持地理编码转换等功能
 --------------------
 *********************/
/**
 *获取当前地图API的版本号
 *return  返回当前API的版本号
 */
extern NSString* ANGetApiVersion()
{
    return @"0.1.0";
}
#endif
