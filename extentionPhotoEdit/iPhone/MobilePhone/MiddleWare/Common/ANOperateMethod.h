//  
//  ANOperateMethod.h
//  AutoNavi
//
//  功能点(例如回家，回公司，开启，关闭某个功能)
//
//  Created by GHY on 12-3-1.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "plugin_PoiNode.h"
#import "MWPoiOperator.h"
#import <CoreLocation/CoreLocation.h>

@class MWPoi;
@protocol UIAccelerometerDelegate;
@protocol NetReqToViewCtrDelegate;

@interface ANOperateMethod : NSObject <UIAlertViewDelegate,UIAccelerometerDelegate,NetReqToViewCtrDelegate>
{
    int   localizeType;
}

@property (nonatomic,assign) int   localizeType;

#pragma mark 单例
+ (ANOperateMethod *)sharedInstance;

#pragma mark 设置相应的目录不备份
- (void)GMD_BackUp;


#pragma mark 拨打95190
- (void)GMD_Call_95190:(NSString *)phone;

#pragma mark 将view转化成镜子中的view显示
- (void)GMD_ChangeTomirrorViewInView:(UIView *)view isSwitch:(BOOL)isSwitch;

#pragma mark 设置系统语言
-(BOOL)GMD_SetSystemLanguage:(BOOL)isEngineInit;

#pragma mark 阿拉伯数字转汉字
- (NSString *)ArabToChinese:(int)num;

#pragma mark 设置本地化路径
- (NSString *)GMD_SetLocalizeKey:(NSString *)key table:(NSString *)tableName;

- (void)GMD_PassInfoToHud;



#pragma mark- 兼容引擎旧文件
-(void)GMD_CompatibilityOldEngineFiles;

#pragma mark- 创建轨迹和收藏夹的存放文件夹目录
-(void)GMD_CreatRelatedFolder;


#pragma mark - 跳转到appstore
/*param:0 更新软件 1：评价软件*/
+(void)rateToAppStore:(int)param;

#pragma mark- 实时交通语音播报
- (void)GMD_TrafficPlaySound;

#pragma mark- GPS信号情况播报
- (void)GMD_PlayGPS;

/*!
  @brief 里程计算接口
 *-------------------------------------
 *0           不记录gps信息点
 *15以下       4秒
 *16-30        3秒
 *31-60        2秒
 *61-90及以上   1秒
 *-------------------------------------
 *距离计算:每收到一个GPS点,就判断该点不上一个“记录点”的时间差是否满足时间间隔,若是就记录,若丌是就直接丢弃
  @param newLocation 新定位点
  @param oldLocation 旧定位点
  @return 成功返回 YES 失败返回 NO
  */
- (int)GMD_MileageCalculateWithNewLocation:(CLLocation *)newLocation oldLocation:(CLLocation *)oldLocation;


#pragma mark -获取屏幕宽度，高度

- (CGFloat)getScreenWidth;
- (CGFloat)getScreenHeight;
- (CGFloat)getApplicationFrameWidth;
- (CGFloat)getApplicationFrameHeight;
- (CGFloat)getApplicationFrameContentHeight_V;
- (CGFloat)getApplicationFrameContentHeight_H;
@end
