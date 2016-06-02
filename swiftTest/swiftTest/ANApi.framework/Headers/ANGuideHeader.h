//
//  ANGuideHeader.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 12/26/14.
//  Copyright (c) 2014 liyuhang. All rights reserved.
//

#ifndef ProjectDemoOnlyCode_ANGuideHeader_h
#define ProjectDemoOnlyCode_ANGuideHeader_h
@class ANGuide;
@class ANRouteCalculator;
@class ANRouteCalculateResult;
@class ANGuideSimulator;
/**
 * 安全播报类别
 */
typedef NS_ENUM(NSUInteger, ANGuideSafetyAlertMode) {
    ANGuideSafetyAlertNone       = 0,    ///< 不播报
    ANGuideSafetyAlertAllTheWay  = 2     ///< 全程播报
    
} ;

/**
 * 语音提示频率
 */
typedef NS_ENUM(NSUInteger, ANGuidePromptFrequency) {
    ANGuidePromptFrequencyNormal      = 0,    ///< 一般
    ANGuidePromptFrequencyFrequent    = 1     ///< 一般
    
} ;

/**
 * 导航状态
 */
typedef NS_ENUM(NSUInteger, ANGuideStatus) {
    ANGuideStatusIdle = 0,  ///<未开始
    ANGuideStatusGuiding,   ///<导航中
    ANGuideStatusPaused,    ///<暂停
    ANGuideStatusStopped,   ///<停止
    ANGuideStatusFinished,  ///<完成
    ANGuideStatusError,     ///<错误
};

/**
 * 导航协议
 */
@protocol ANGuideProtocol <NSObject>

/**
 *  更换平行路
 *
 *  @param guide         导航对象
 *  @param parallelRoads 平行路信息
 */
-(void)guide:(ANGuide *)guide didChangeParallelRoads:(NSMutableArray *)parallelRoads;

//-(void)guide:(ANGuide *)guide didChangeSafetyAlert:(ANSafetyInfo *)safetyInfo;

/**
 *  导航完成重新计算
 *
 *  @param guide      导航对象
 *  @param calculator 路线计算对象
 *  @param result     路线计算结果
 */
-(void)guide:(ANGuide *)guide didFinishRecalculation:(ANRouteCalculator *)calculator withResult:(ANRouteCalculateResult *)result;

/**
 *  偏航
 *
 *  @param guide 导航对象
 */
-(void)guideDidDeviateFromRoute:(ANGuide *)guide;

/**
 *  导航状态变更
 *
 *  @param guide 导航对象
 */
-(void)guideDidChangeStatus:(ANGuide *)guide;

/**
 *  遭遇放大路口
 *  遭遇蓝色看板
 *  遭遇放大路牌
 *  经过行程点
 *  通知开启放大路口
 *  通知关闭放大路口
 */

@end

/**
 *  模拟导航协议
 */
@protocol ANGuideSimulatorProtocol <NSObject>

/**
 *  模拟导航状态变更
 *
 *  @param guide 导航对象
 */
-(void)guideSimulatorDidChangeStatus:(ANGuideSimulator *)guide;

@end


#endif
