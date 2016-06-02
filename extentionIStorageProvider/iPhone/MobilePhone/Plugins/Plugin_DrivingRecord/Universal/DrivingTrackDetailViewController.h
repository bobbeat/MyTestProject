//
//  DrivingTrackDetailViewController.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-13.
//
//

#import <UIKit/UIKit.h>
#import "DringTracksManage.h"
#import "LXActivity.h"

@interface DrivingTrackDetailViewController : ANViewController <NetReqToViewCtrDelegate,LXActivityDelegate>

- (void)setValueWithDrivingTrack:(DrivingInfo *)trackInfo;

@end
