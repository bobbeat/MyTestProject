//
//  ANAreaInfo.h
//  ProjectDemoOnlyCode
//
//  Created by yuhang on 14-11-7.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * @brief: area type
 */
typedef NS_ENUM(NSUInteger, AreaInfoType)
{
    
    AreaInfoTypeCountry = 0,    ///< 国家
    AreaInfoTypeProvince = 1,  ///< 省
    AreaInfoTypeMunicipality = 2,  ///< 直辖市
    AreaInfoTypeNormalCity = 3,  ///< 城市
    AreaInfoTypeTown = 4,  ///< 乡镇
};

@protocol ANAreaInfo <NSObject>

@end
/**
 *  地区信息
 */
@interface ANAreaInfo : NSObject
{
    
}

//
@property (nonatomic, assign)       AreaInfoType    areaType;                   // area type
//
@property (nonatomic, copy)         NSString*       areaName;
@property (nonatomic, copy)         NSString*       areaNameSpell;
//
@property (nonatomic, assign)       int             adminCode;
@property (nonatomic, assign)       int             telCode;                    // tel code
//
@property (nonatomic, assign)       long            lonOfAdmin;                 // 行政区域中心
@property (nonatomic, assign)       long            latOfAdmin;                 //
//
@property (nonatomic, strong)       NSArray*        arrayOfSubAreaInfos;

@end
