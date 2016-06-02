//
//  MWCarOwnerServiceManage.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-2-27.
//
//

#import <Foundation/Foundation.h>
#import "plugin-cdm-TaskManager.h"
#import "NetKit.h"
#import "MWCarOwnerServiceTask.h"

@interface MWCarOwnerServiceManage : NSObject <TaskStatusDelegate,NetRequestExtDelegate>
{
    
}

@property (nonatomic ,readonly)  NSMutableArray *carOwnerTaskList;
@property (nonatomic ,readonly)  NSMutableArray *carOwnerMoreTaskList;
@property (nonatomic ,assign)    id<TaskStatusDelegate> delegate;
@property (nonatomic ,assign)    id<NetReqToViewCtrDelegate>reqDelegare;

+ (MWCarOwnerServiceManage *)sharedInstance;

/*!
  @brief 请求车主服务列表
  */
- (void)RequestCarOwnerService;

/*!
  @brief 请求车主服务列表(更多)
  */
- (void)RequestMoreCarOwnerService;

/*!
  @brief 请求车主服务列表(详情)
  */
- (void)RequestCarOwnerServiceDetail:(MWCarOwnerServiceTask *)task;

/*!
  @brief 获取服务详情
  @return
  */
- (MWCarOwnerServiceTask *)getDetailCarOwnerServiceTask;
/*!
  @brief 是否有更多服务列表
  @return
  */
- (BOOL)isMore;

/*!
  @brief 通过taskid获取任务
  @param taskID 任务ID
  @return 返回对应的任务
  */
- (MWCarOwnerServiceTask *)getTaskWithTaskID:(NSString *)taskID;

/*!
  @brief 添加任务到任务队列
  @return 返回-1表示加入失败，>=0表示成功加入后在carOwnerTaskList中的索引
  */
-(int)addTask:(MWCarOwnerServiceTask*) task atFirst:(BOOL) first;

/*!
  @brief 下载指定id的任务
  @return
  */
- (void)startWithTaskID:(NSString *)taskID;

/*!
  @brief 把carOwnerTaskList中的所有任务信息保存到文件系统，一般是在退出程序时调用
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)store;

/*!
  @brief 从文件系统还原通过save保存的所有任务信息，一般是在进入程序时调用，该方法调用将把carOwnerTaskList中的所有任务更新为最后一次调用save保存的任务
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)restore;

/*!
  @brief 服务置顶
  @return 成功返回 YES 失败返回 NO
  */
- (BOOL)moveTaskToTopWithTaskID:(NSString *)taskID;

/*!
  @brief 从json字符串中获取对应语言的字符串
  @return 返回字符串
  */
- (NSString *)getStringFormJson:(NSString *)jsonString;

/*!
  @brief 获取安装服务信息
  */
- (NSDictionary *)getInstallCarOwnerServiceInfoWithTaskID:(NSString *)serviceID;

/*!
  @brief 获取安装服务图标
  */
- (UIImage *)getInstallCarOwnerServiceIconWithTaskID:(NSString *)serviceID;

/*!
  @brief 移除索引为index处的任务，该操作会删除该任务。如果恰好该任务处于运行状态，removeTaskId后，整个TaskManager中将无任务在执行
  @param taskId 任务ID
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)removeTaskId:(NSString *) taskId;

/*!
  @brief  删除推荐列表
  */
-(void)removeVipTask;

@end
