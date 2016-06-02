//
//  ANCandidate.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-12-11.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  候选字查询类型
 */
typedef NS_ENUM(NSInteger, ANCandidateSearchType)
{
    ANCandidateSearchTypePoiName = 0,   ///<POI名称
    ANCandidateSearchTypePoiSpell,      ///<POI全拼
    ANCandidateSearchTypeAreaName,      ///<行政区域名称
};

@interface ANCandidateSearchOption : NSObject

@property (nonatomic) ANCandidateSearchType searchType;

@property (strong, nonatomic) NSString *name;

@end

/**
 *  候选字对象
 */
@interface ANCandidate : NSObject

//+ (NSArray *)candidatesWithOption:(ANCandidateSearchOption *)candidateSearchOption;

@end
