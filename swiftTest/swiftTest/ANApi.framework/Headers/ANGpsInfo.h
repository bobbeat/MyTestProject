//
//  ANGpsInfo.h
//  ProjectDemoOnlyCode
//
//  Created by yuhang on 14-11-10.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  gps信息
 */
@interface ANGpsInfo : NSObject
{
    
}

@property (nonatomic, assign)   NSInteger	lon;           /**< 经度 */
@property (nonatomic, assign)   NSInteger	lat;           /**< 纬度 */
@property (nonatomic, assign)   Byte        status;        /**< A：有效，V：无效 */
@property (nonatomic, assign)   Byte        longitude;     /**< E表示东经，W表示西经 */
@property (nonatomic, assign)   Byte        latitude;      /**< N表示北纬，S表示南纬 */
@property (nonatomic, assign)   Byte        year;          /**< 年 */
@property (nonatomic, assign)   Byte        month;         /**< 月 */
@property (nonatomic, assign)   Byte        day;           /**< 日 */
@property (nonatomic, assign)   Byte        hour;          /**< 时 */
@property (nonatomic, assign)   Byte        minute;        /**< 分 */
@property (nonatomic, assign)   Byte        second;        /**< 秒 */
@property (nonatomic, assign)   Byte        satelliteNum;  /**< 卫星颗数 */
@property (nonatomic, assign)   Byte        mode;		   /**< GPS模式 A=自主定位，D=差分，E=估算，N=数据无效*/
@property (nonatomic, assign)   double      speed;         /**< 速度 */
@property (nonatomic, assign)   double      azimuth;       /**< 方位角 */
@property (nonatomic, assign)   double      HDOP;          /**< 水平精度定位因子 */
@property (nonatomic, assign)   double      altitude;      /**< 海拔 */
@end
