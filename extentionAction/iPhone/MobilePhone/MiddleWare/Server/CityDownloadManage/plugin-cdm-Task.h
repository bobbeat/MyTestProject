//
//  Task.h
//  plugin-CityDataManager
//
//  Created by mark on 11-11-3.
//  Copyright (c) 2011年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "plugin-cdm-TaskManager.h"

/*
 任务基类
 */
@interface Task : NSObject//<TaskDelegate>
{
@protected
    NSString* title;                    // 任务标题，该属性由客户负责写入
    int taskId;                         // 任务id，该属性由客户负责写入，TaskManager读取该属性来判断某个任务是否已存在
    long long current;                        // 当前已完成的任务量，该属性只读
    long long total;                          // 总的任务量
    int status;                         // 任务状态，该属性由TaskManager写入，非TaskManager对象只允许读取
    BOOL selected;                      //是否选中
    id<TaskStatusDelegate> delegate;    // 任务状态委托，该属性由TaskManager写入，Task子类使用
    BOOL updated;//判断数据是否有更新，YES：本地数据有新数据，NO：本地最新，无更新数据
}

@property (nonatomic,copy)NSString* title;
@property (nonatomic)int taskId;            
@property (nonatomic)long long current;
@property (nonatomic)long long total;
@property (nonatomic)int status;
@property (nonatomic)BOOL selected;
@property (nonatomic,assign)id<TaskStatusDelegate> delegate;
@property (nonatomic)BOOL updated;

-(void)run;             // 执行任务
-(void)stop;            // 停止任务，对停止的任务执行run操作，任务须能从停止处继续执行
-(void)erase;           // 删除任务以及任务相关的资源
-(int)percent;          // 获取任务的进度百分比[0~100]
-(BOOL)store;           // 任务保存（目前无需实现）
-(BOOL)restore;         // 任务恢复（目前无需实现）

@end


