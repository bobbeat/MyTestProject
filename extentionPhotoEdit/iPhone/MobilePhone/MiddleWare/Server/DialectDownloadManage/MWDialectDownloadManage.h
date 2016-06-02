//
//  MWDialectDownloadManage.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-1-15.
//
//

#import <Foundation/Foundation.h>
#import "plugin-cdm-TaskManager.h"
#import "NetKit.h"
#import "MWDialectDownloadTask.h"


@interface MWDialectDownloadManage : NSObject <TaskStatusDelegate,NetRequestExtDelegate>

{
    NSMutableArray *dialectTaskList;
    NSMutableArray *serviceDialectTaskList;
    id<TaskStatusDelegate> delegate;
    NSString       *dialectDownloadURL;    //方言下载地址
    NSString       *dialectMatchVersion;   //匹配的版本号
    NSString       *dialectName;           //方言名称
    
    long long      dialectSize;            //方言大小
    BOOL           cancelDialectCheck;
}
@property (nonatomic ,readonly)  NSMutableArray *dialectTaskList;
@property (nonatomic ,readonly)  NSMutableArray *serviceDialectTaskList;
@property (nonatomic ,assign)    id<TaskStatusDelegate> delegate;
@property (nonatomic ,assign)    id<NetReqToViewCtrDelegate> reqDelegate;
@property (nonatomic ,copy)      NSString *dialectDownloadURL;
@property (nonatomic ,copy)      NSString *dialectMatchVersion;
@property (nonatomic ,copy)      NSString *dialectName;
@property (nonatomic ,assign)    long long dialectSize;
@property (nonatomic ,assign)    BOOL cancelDialectCheck;


+ (MWDialectDownloadManage *)sharedInstance;

/*!
  @brief 请求方言下载链接
  */
- (void)RequestDialect;

/*!
  @brief 把DialectTaskList中的所有任务信息保存到文件系统，一般是在退出程序时调用
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
- (MWDialectDownloadTask *)getTaskWithTaskID:(int)taskID;

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
  @brief 添加任务到任务队列
  @return 返回-1表示加入失败，>=0表示成功加入后在DialectTaskList中的索引
  */
-(int)addTask:(MWDialectDownloadTask*) task atFirst:(BOOL) first;

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
  @brief 获取本地方言
 .@param taskID 方言id
  @return MWDialectDownloadTask 方言对象
  */
- (MWDialectDownloadTask *)getLocalDialectTaskWithTaskID:(int)taskID;

/*!
  @brief 方言下载网络状态判断处理
  */
- (void)newFuntionDialectNetWorkHandle:(MWDialectDownloadTask *)sender Type:(RequestType)requestType;

/*!
  @brief 将任务添加到任务列表中
  */
-(BOOL)addTaskToListWithTaskID:(int)taskID requestType:(RequestType)type;


/*!
  @brief 切换语音播报
 .@param taskID 任务id，本地默认的方言传－1，其他传相对应的id
  @return
  */
- (BOOL)switchTTSPathWithTaskID:(int)taskID;


/*!
  @brief 获取方言名称
  */
- (NSString *)getDialectTitle:(NSString *)arrayString;


/*!
  @brief 只暂停指定索引的任务，不自动下载等待的任务
  @param index 任务索引
  @return 成功返回 YES 失败返回 NO
  */
- (BOOL)stopCurrent:(int)index;

/*!
  @brief 获取任务列表中所有任务需要的空间大小
  @return 所需空间大小
  */
-(long long)getNeedSize;


/*!
  @brief 下载更新语音
 .@param taskID 任务id
  @return
  */
- (BOOL)downloadTTSWithTaskID:(int)taskID;

/*!
  @brief 获取本地方言列表
  @return
  */
- (NSMutableArray *)getDialectTaskIDList;

/*!
  @brief 把serviceDialectTaskList中的所有任务信息保存到文件系统，一般是在退出程序时调用
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)serviceStore;

@end
