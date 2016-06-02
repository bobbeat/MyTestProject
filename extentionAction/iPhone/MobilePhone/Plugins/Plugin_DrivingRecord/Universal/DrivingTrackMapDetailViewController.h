//
//  DrivingTrackMapDetailViewController.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-13.
//
//

#import <UIKit/UIKit.h>
#import "PaintingView.h"
#import "MWMapAddIconOperator.h"

typedef enum DRIVINGTRACKVIEWTYPE
{
    DRIVINGTRACKVIEWTYPE_WHOLE = 0,      //显示所有
    DRIVINGTRACKVIEWTYPE_HYSPEED = 1,    //显示超速
    DRIVINGTRACKVIEWTYPE_ACCELERATE = 2, //显示急加油
    DRIVINGTRACKVIEWTYPE_BRAKES  = 3,    //显示刹车
    DRIVINGTRACKVIEWTYPE_TURN = 4,       //显示
    
}DRIVINGTRACKVIEWTYPE;

@class DrivingTracks;

@interface DrivingTrackMapDetailViewController : ANViewController <PaintingViewDelegate,MWMapPoiAddIconDelegate>

@property (nonatomic, retain) DrivingTracks *trackInfo;

@end
