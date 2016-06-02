//
//  ANSafetyHeader.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-11-5.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#ifndef ProjectDemoOnlyCode_ANSafetyHeader_h
#define ProjectDemoOnlyCode_ANSafetyHeader_h

/**
 * 安全信息类别
 */
typedef NS_ENUM(NSUInteger, ANSafetyCategory) {
    /**
     *  所有类别
     */
    ANSafetyCategoryAll,
    /**
     *  违章摄像头
     */
    ANSafetyCategoryIllegalCamera,
    /**
     *  专用道摄像头
     */
    ANSafetyCategoryLaneCamera,
    /**
     *  测速摄像头、测速雷达
     */
    ANSafetyCategoryRestrictionCamera,
    /**
     *  最大限速标志
     */
    ANSafetyCategorySpeedLimit,
    /**
     *  监控摄像头
     */
    ANSafetyCategorySurveillanceCamera
};


#endif
