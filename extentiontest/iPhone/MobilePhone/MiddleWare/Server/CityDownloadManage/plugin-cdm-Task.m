//
//  Task.m
//  plugin-CityDataManager
//
//  Created by mark on 11-11-3.
//  Copyright (c) 2011年 Autonavi. All rights reserved.
//

#import "plugin-cdm-Task.h"

@implementation Task

@synthesize delegate,title,taskId,current,total,status,selected,updated;

-(void)run{}     // 执行任务
-(void)stop{}    // 停止任务，对停止的任务执行run操作，任务须能从停止处继续执行
-(void)erase{}   // 删除任务以及任务相关的资源
-(int)percent{return 0;}    // 获取任务的进度百分比[0~100]
-(BOOL)store{return NO;}    // 任务保存
-(BOOL)restore{return NO;}  // 任务恢复
-(NSString*)description{return @"an abstract task";} // 某个任务的进度描述

- (void)dealloc
{
    if (title)
    {
        [title release];
        title = nil;
    }
    [super dealloc];
}
@end
