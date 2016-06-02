//
//  MWDayNight.h
//  AutoNavi
//
//  Created by gaozhimin on 14-5-7.
//
//

#import <Foundation/Foundation.h>

/*!
  @brief 日夜模块
  */

@interface MWDayNight : NSObject

/*!
 @brief 白天黑夜色盘同步
 */
+ (void)SyncDayNightTheme;

/*!
 @brief 白天黑夜切换,更新界面ui
 */
+ (void)SetDayNightModeCallback;

/*!
 @brief 获取白天黑夜色盘数组
 */
+ (NSArray *)getDayNightArray;

/*!
 @brief 获取白天黑夜色盘索引
 */
+ (int)getDayNightSchemeIndex;

/*!
 @brief 设置白天黑夜色盘索引
 */
+ (GSTATUS)setDayNightSchemeWithIndex:(int)schemeIndex;
@end
