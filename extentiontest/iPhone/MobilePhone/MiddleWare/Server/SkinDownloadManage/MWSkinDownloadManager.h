//
//  MWSkinDownloadManager.h
//  AutoNavi
//
//  Created by huang longfeng on 13-11-19.
//
//

#import <Foundation/Foundation.h>
#import "plugin-cdm-TaskManager.h"
#import "NetKit.h"

@interface MWSkinDownloadManager : NSObject <TaskStatusDelegate,NetRequestExtDelegate>

{
    NSMutableArray *skinTaskList;
    NSMutableDictionary *updateVersionDictionary; //保存更新的皮肤版本号
    id<TaskStatusDelegate> delegate;
    NSString       *skinDownloadURL;    //皮肤下载地址
    NSString       *skinMatchVersion;   //匹配的版本号
    NSString       *skinName;           //皮肤名称
    int            skinID;              //皮肤id
    long long      skinSize;            //皮肤大小
    BOOL           cancelSkinCheck;
}
@property (nonatomic ,readonly)  NSMutableArray *skinTaskList;
@property (nonatomic ,retain)    NSMutableDictionary *updateVersionDictionary;
@property (nonatomic ,assign)    id<TaskStatusDelegate> delegate;
@property (nonatomic ,copy)      NSString *skinDownloadURL;
@property (nonatomic ,copy)      NSString *skinMatchVersion;
@property (nonatomic ,copy)      NSString *skinName;
@property (nonatomic ,assign)    int skinID;
@property (nonatomic ,assign)    long long skinSize;
@property (nonatomic ,assign)    BOOL cancelSkinCheck;

+ (MWSkinDownloadManager *)sharedInstance;

/*!
  @brief 请求皮肤下载链接
  */
- (void)RequestSkinURLWithSkinID:(int)skinId;

/*!
  @brief 开始皮肤检测
  @return
  */
- (void)skinCheckStart;

/*!
  @brief 把skinTaskList中的所有任务信息保存到文件系统，一般是在退出程序时调用
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)store;

/*!
  @brief 从文件系统还原通过save保存的所有任务信息，一般是在进入程序时调用，该方法调用将把skinTaskList中的所有任务更新为最后一次调用save保存的任务
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)restore;

/*!
  @brief TaskManager可能处于两种状态：1、无任何任务在执行：TaskManager按某种策略选择一个任务来执行 2、有任务在执行：直接返回
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)start;

/*!
  @brief  任务可能处于两种状态：
 1、无任何任务在执行：TaskManager按index来选择任务
 2、有任务在执行：
 1.1、正在执行的任务就是index，那么直接返回；
 2.1、正在执行的任务不是index，那么让正在执行的任务变为等待，转而执行index指定的任务
  @param  index 要下载的索引值
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)start:(int)index;

/*!
  @brief 下载指定id的任务
  @return
  */
- (void)startWithTaskID:(int)taskID;

/*!
  @brief 停止TaskManager中正在执行的任务，整个TaskManager处于停止状态
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)stop;

/*!
  @brief 停止TaskManager中index对应的任务：注意：只有状态为TASK_STATUS_RUNNING的任务才能被stop
  @param index对应的任务处于等待状态，那么直接返回，对应的任务处于执行状态，那么让正在执行的任务变为等待
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)stop:(int)index;

/*!
  @brief 停止TaskManager中taskID对应的任务：注意：只有状态为TASK_STATUS_RUNNING的任务才能被stop
  @param taskID对应的任务处于等待状态，那么直接返回，对应的任务处于执行状态，那么让正在执行的任务变为等待
  @return 成功返回 YES 失败返回 NO
  */
- (BOOL)stopWithTaskID:(int)taskID;

/*!
  @brief 只暂停指定索引的任务，不自动下载等待的任务
  @param taskID 任务id
  @return 成功返回 YES 失败返回 NO
  */
- (BOOL)stopWithOutOtherStartWithTaskID:(int)taskID;

/*!
  @brief 暂停所有的任务
  */
- (void)stopAllTask;

/*!
  @brief 通过taskid获取任务
  @param taskID 任务ID
  @return 返回对应的任务
  */
- (Task *)getTaskWithTaskID:(int)taskID;

/*!
  @brief 移除索引为index处的任务，该操作会删除该任务。如果恰好该任务处于运行状态，removeTask后，整个TaskManager中将无任务在执行
  @param index 任务索引
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)removeTask:(int) index;

/*!
  @brief 移除索引为index处的任务，该操作会删除该任务。如果恰好该任务处于运行状态，removeTaskId后，整个TaskManager中将无任务在执行
  @param taskId 任务ID
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)removeTaskId:(long) taskId;

/*!
  @brief  删除某一状态的任务
  @return 返回删除个数
  */
-(int)removeTasksForStatus:(int) status;

/*!
  @brief 将任务添加到任务列表中
  */
-(void)addTaskToList;

/*!
  @brief 皮肤下载网络状态判断处理
  */
- (void)skinNetWorkHandle:(Task *)sender;

/*!
  @brief 开始皮肤检测
  @return
  */
- (void)skinCheckContinue;

/*!
  @brief 添加任务到任务队列
  @return 返回-1表示加入失败，>=0表示成功加入后在skinTaskList中的索引
  */
-(int)addTask:(Task*) task atFirst:(BOOL) first;

/*!
  @brief  返回YES表示TaskManager中对应的taskID任务正在运行
  @return 有任务在运行返回 YES 没有返回 NO
  */
- (BOOL)isRunningWithTaskID:(int)taskID;

/*!
  @brief 返回队列中，状态为status的第一个任务的索引
  @param status 任务状态
  @return 返回指<0则表示没找到可被执行的任务，否则表示任务的索引
  */
-(int)_firstIndexWithStatus:(int)status;

/*!
  @brief 只暂停指定索引的任务，不自动下载等待的任务
  @param index 任务索引
  @return 成功返回 YES 失败返回 NO
  */
- (BOOL)stopCurrent:(int)index;

/*!
  @brief 把updateVersionDictionary中的所有任务信息保存到文件系统，一般是在退出程序时调用
  @return 成功返回 YES 失败返回 NO
  */
- (BOOL)storeSkinUpdateVersion;

/*!
  @brief 设置更新版本号
  */
- (void)setUpdateVersion:(NSString *)version;

@end
