//
//  MWCloudDetourManage.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-3-24.
//
//

#import <Foundation/Foundation.h>
#import "plugin-cdm-TaskManager.h"
#import "NetKit.h"

@interface MWCloudDetourManage : NSObject <TaskStatusDelegate,NetRequestExtDelegate>

@property (nonatomic ,readonly)  NSMutableArray *cloudDetourTaskList;
@property (nonatomic ,assign)    id<TaskStatusDelegate> delegate;


+ (MWCloudDetourManage *)sharedInstance;

/*!
  @brief 请求云端规避
  */
- (void)RequestCloudDetour;

/*!
  @brief  移除所有任务
  */
- (void)removeAllTask;

/*!
  @brief 更新云端避让文件
  */
- (void)updateCloudAvoidPath;

/*!
  @brief 把cloudDetourTaskList中的所有任务信息保存到文件系统，一般是在退出程序时调用
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)store;

/*!
  @brief 从文件系统还原通过save保存的所有任务信息，一般是在进入程序时调用，该方法调用将把cloudDetourTaskList中的所有任务更新为最后一次调用save保存的任务
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)restore;

@end
