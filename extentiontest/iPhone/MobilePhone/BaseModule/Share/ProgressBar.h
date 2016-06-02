//
//  ProgressBar.h
//  jindutiao
//
//  Created by jiangshu.fu on 13-9-6.
//  Copyright (c) 2013年 傅水木. All rights reserved.
//


/***
 * 类名： 导航行驶过程中进度条类
 * 变量： arrayInfo —— 记录要绘画的道路状态 。 里面保存的对象为 —— ProgressInfo类对象
 ***/

#import <UIKit/UIKit.h>

typedef enum ProgressBarStatus {
    CompleteStatus = 0,  //已走完显示（灰色）
    UnfinishStatus,      //未走完显示（蓝色）
    UnblockedStatus,     //畅通显示  （绿色）
    SlowlyStaus,         //缓行      （黄色）
    StopStatus,          //拥堵      （红色）
}ProgressBarStatus;

@interface ProgressInfo : NSObject

@property (nonatomic, assign) ProgressBarStatus status;     //交通状态
@property (nonatomic, assign) float percent;                //比例


@end

@interface ProgressBar : UIView

//object —— ProgressInfo 
@property (nonatomic, retain) NSMutableArray *arrayInfo;

@end
