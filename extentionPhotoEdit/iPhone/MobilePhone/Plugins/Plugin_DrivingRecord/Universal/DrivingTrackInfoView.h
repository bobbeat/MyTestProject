//
//  DrivingTrackInfoView.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-10.
//
//

#import <UIKit/UIKit.h>

@class ColorLable;

@interface DrivingTrackInfoView : UIView <UITextFieldDelegate>

@property (nonatomic, retain) ColorLable *drivingScoreLabel;
@property (nonatomic, retain) ColorLable *totalDistanceLabel;
@property (nonatomic, retain) ColorLable *totalTimeLabel;
@property (nonatomic, retain) ColorLable *averageSpeedLabel;
@property (nonatomic, retain) ColorLable *fuelConsumptionScoreLabel;
@property (nonatomic, retain) ColorLable *safetyScoreLabel;
@property (nonatomic, retain) ColorLable *haccelerationScoreLabel;
@property (nonatomic, retain) ColorLable *brakesScoreLabel;
@property (nonatomic, retain) ColorLable *uturnScoreLabel;
@property (nonatomic, retain) ColorLable *hypervelocityScoreLabel;
@property (nonatomic, retain) ColorLable *yawLabel;
@property (nonatomic, retain) ColorLable *courseLabel;

@end
