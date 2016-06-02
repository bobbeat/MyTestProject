//
//  ANNavigateManager.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-12-16.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ANRoute;
@class ANGuideInfo;
@class ANRouteCalculator;
@class ANRouteCalculateResult;
@class ANSafetyInfo;
@class ANRoad;
@class ANGuidePathStatistics;
@protocol ANNavigateProtocol;
#import "ANVoicePlayer.h"
#import "ANGuideHeader.h"

/**
 *  导航对象
 */
@interface ANGuide : NSObject

/**
 *  使用路径进行初始化
 *
 *  @param route 路径
 *
 *  @return 导航对象
 */
-(instancetype)initWithRoute:(ANRoute *)route;
/**
 *  协议
 */
@property (strong, nonatomic) NSMutableArray *delegates;
/**
 *  语音播放频率
 */
@property (nonatomic) ANGuidePromptFrequency promptFrequency;
/**
 *  导航状态
 */
@property (nonatomic, readonly) ANGuideStatus status;
/**
 *  当前导航信息
 */
@property (strong, nonatomic, readonly) ANGuideInfo *guideInfo;
/**
 *  路径信息
 */
@property (strong, nonatomic, readonly) ANGuidePathStatistics *pathStatistics;
/**
 *  当前导航的路径
 */
@property (strong, nonatomic, readonly) ANRoute *route;
/**
 *  快速生成导航对象
 *
 *  @param route 路径
 *
 *  @return 导航对象
 */
+(ANGuide *)guideStartWithRoute:(ANRoute *)route;
/**
 *  开始导航
 *
 *  @return 启动是否成功
 */
-(BOOL)startGuide;
/**
 *  更换道路
 *
 *  @param road 道路信息
 *
 *  @return 更换是否成功
 */
-(BOOL)changeRoad:(ANRoad *)road;
/**
 *  停止导航
 *
 *  @return 停止是否成功
 */
-(BOOL)stopGuide;
/**
 *  播放导航语音
 *
 *  @return 操作是否成功
 */
-(BOOL)playGuideVoice;
/**
 *  强制重播导航语音
 *
 *  @return 操作是否成功
 */
-(BOOL)replayGuideVoice;

@end