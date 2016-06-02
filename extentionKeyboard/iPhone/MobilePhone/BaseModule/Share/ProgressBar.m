//
//  ProgressBar.m
//  jindutiao
//
//  Created by jiangshu.fu on 13-9-6.
//  Copyright (c) 2013年 傅水木. All rights reserved.
//

#import "ProgressBar.h"

@implementation ProgressInfo

@synthesize status,percent;

@end


@implementation ProgressBar

//不同状态使用的图片

@synthesize arrayInfo = _arrayInfo;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        self.arrayInfo = tempArray;
        [tempArray release];
    }
    return self;
}

- (void) dealloc
{
    [_arrayInfo release];
    [super dealloc];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    float currentPercent = 0;
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    UIImage *drawImage;
    for(ProgressInfo *progress in self.arrayInfo)
    {
        switch (progress.status) {
            case CompleteStatus:
            {
                drawImage = IMAGE(@"mainCompleteStatus.png", IMAGEPATH_TYPE_1);
            }
                break;
            case UnfinishStatus:
            {
                drawImage = IMAGE(@"mainUnfinishStatus.png", IMAGEPATH_TYPE_1);
            }
                break;
            case UnblockedStatus:
            {
                drawImage = IMAGE(@"mainUnblockedStatus.png", IMAGEPATH_TYPE_1);
            }
                break;
            case SlowlyStaus:
            {
                drawImage = IMAGE(@"mainSlowlyStaus.png", IMAGEPATH_TYPE_1);
            }
                break;
            case StopStatus:
            {
                drawImage = IMAGE(@"mainStopStatus.png", IMAGEPATH_TYPE_1);
            }
                break;
            default:
            {
                NSLog(@"ProgressInfo Default");
            }
                break;
        }
        [drawImage drawInRect:CGRectMake(currentPercent * width,
                                        0,
                                        progress.percent * width,
                                         height)];
        
        currentPercent += progress.percent;
    }
    
}


@end
