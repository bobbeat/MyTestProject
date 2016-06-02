//
//  Plugin_DataVerify_UncompressController.h
//  plugin_DataVerify
//
//  Created by yi yang on 11-11-25.
//  Copyright 2011年 autonavi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWSkinDownloadManager.h"


@interface Plugin_DataVerifyUncompressController : ANViewController <TaskStatusDelegate>
{
    UILabel                 *lblContent;
    UILabel                 *lblIndex;
    UIImageView             *imgBG;
    UIImageView             *imageViewLabelBac;
    UIActivityIndicatorView *activityWaiting;
    NSMutableArray          *currentFileList;
    NSMutableArray          *failFileList;
    NSString                *zipDestPath;
    
    BOOL                    quitUnCompress;
    BOOL                    isFinish;
    BOOL                    isCompressFail;
    BOOL                    singleResult;
    int                     zipIdx;
    int                     zipFail;
    MWSkinDownloadManager   *skinManager;
    int                     dataVerityType;
}

@property (nonatomic,retain) UILabel *lblContent;
@property (nonatomic,retain) UILabel *lblIndex;
@property (nonatomic,retain) UIActivityIndicatorView* activityWaiting;


#pragma mark private

-(id)initWithFileList:(NSArray*)uncompressFiles ZipTodestPath:(NSString*)zipTodestPath DataVerityType:(int)verityType;

@end