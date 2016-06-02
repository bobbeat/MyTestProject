//
//  ANGuideSimulator.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 12/26/14.
//  Copyright (c) 2014 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ANRoute;
@class ANGuideInfo;
@class ANSafetyInfo;
@class ANRoad;
@class ANGuidePathStatistics;
@protocol ANNavigateProtocol;
#import "ANVoicePlayer.h"
#import "ANGuideHeader.h"

@interface ANGuideSimulator : NSObject

-(instancetype)initWithRoute:(ANRoute *)route;

@property (strong, nonatomic) NSMutableArray *delegates;

@property (assign, nonatomic) id<ANVoicePlayer> voicePlayerDelegate;

@property (nonatomic) ANGuidePromptFrequency promptFrequency;

@property (nonatomic, readonly) ANGuideStatus status;

@property (strong, nonatomic, readonly) ANGuideInfo *guideInfo;

@property (strong, nonatomic, readonly) ANGuidePathStatistics *pathStatistics;

@property (strong, nonatomic, readonly) ANRoute *route;

+(ANGuideSimulator *)guideSimulatorStartWithRoute:(ANRoute *)route;

-(BOOL)startGuide;

-(BOOL)pauseGuide;

-(BOOL)resumeGuide;

-(BOOL)stopGuide;

-(BOOL)playGuideVoice;

-(BOOL)replayGuideVoice;

@end
