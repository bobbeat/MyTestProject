//
//  TaskManager.h
//  plugin-CityDataManager
//
//  Created by mark on 11-11-3.
//  Copyright (c) 2011年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Task;

enum {
    TASK_STATUS_READY       = 0,    // 就绪状态：可以切换为运行，或阻塞
    TASK_STATUS_RUNNING     = 1,    // 运行状态：可以切换为就绪，或阻塞
    TASK_STATUS_FINISH      = 2,    // 完成状态：不可再切换为任何别的状态
    TASK_STATUS_BLOCK       = 3,    // 阻塞状态：可以切换为就绪。阻塞状态不能直接切换到运行状态
};

//@protocol TaskDelegate <NSObject>
//
//-(void)run;     // 执行某个任务
//-(void)stop;    // 停止某个任务
//-(void)erase;   // 删除某个任务
//-(int)progress; // 获取某个任务的进度百分比[0~100]
//-(BOOL)store;    // 通知某个任务做保存
//-(BOOL)restore;  // 通知某个任务做恢复
//-(NSString*)description; // 某个任务的进度描述
//
//@end

/*
 正在执行的任务对象使用该委托来通知TaskManager执行进度、状况
 */
@protocol TaskStatusDelegate <NSObject>

/*
 进度通知
 sender：通知发送者
 current：当前已完成的工作量
 total：总的工作量
 */
-(void)progress:(Task*)sender current:(long long)current total:(long long)total;

/*
 任务完成通知
 sender：通知发送者
 */
-(void)finished:(Task*)sender;

/*
 出现异常通知
 sender：通知发送者
 exception：异常内容
 */
-(void)exception:(Task*)sender exception:(id)exception;

/*
  数据解压完成通知
  sender: 通知发送者
 */
- (void)unZipFinish:(Task*)sender;

@end


///*
// TaskManager使用该委托来通知客户类各个任务的执行进度、状况
// 客户类通过处理该委托来更新界面等
// */
//@protocol ClientDelegate <NSObject>
//
///*
// 进度通知
// tasks：任务列表
// current：当前已完成的工作量列表
// total：总的工作量列表
// */
//-(void)progress:(NSArray*)tasks current:(NSArray*)current total:(NSArray*)total;
//
///*
// 任务完成通知
// tasks：任务列表
// */
//-(void)finished:(NSArray*)tasks;
//
///*
// 出现异常通知
// tasks：任务列表
// exception：异常内容列表
// */
//-(void)exception:(NSArray*)tasks exception:(NSArray*)exception;
//
//@end



/*
 TaskManager职责：
 1、存储各个任务对象，维护各个任务状态
 2、启动、停止、移除任务队列中某个任务，并处理TaskStatusDelegate委托，进而把任务进度、状况通知给客户
 3、序列化、反序列化队列中的所有任务对象
 注意问题：
 1。引擎提供document中已下载完成的城市的行政编码
 2。引擎提供一个接口：传入一个行政编码，返回document中是否存在此城市
 3。每次启动反序列化，都要去判断这些未完成的任务是否还有必要执行。
    实例：当序列化后，当前有个厦门的任务，下次启动之前用户拖进厦门城市数据，启动程序后，程序应当检查下载列表，把下载列表中厦门任务的状态置为已完成。
 4。当用户拖入一个城市数据，下载列表中并无此城市的下载任务，下次启动程序后要将该城市数据加入到下载列表任务中，并把状态标记未已完成。
    实例：用户拖入厦门地图数据，下载任务中并没有厦门的下载任务，启动程序后，应将厦门加入到任务列表中，并标记为已完成。
 5。用户已经有分城市数据的完整基础路网数据，当用户再拖入全国数据后，要删除全部分城市数据。
 
 场景：从itunes拖了【厦门】、【福州】数据包并解压到手机，但此时用户还未用导航软件下载过任何城市（意味着基础路网没下载过）
 步骤：
 1、启动导航，此时任务列表中显示无任何任务
 
 2-a、用户选择了下载【泉州】
 3-a、由于【基础路网】没下载过，故会在任务列表中显示【基础路网】、【泉州】
 4-a、【基础路网】下载完成后，此时列表中要增加【厦门】、【福州】这两个已通过itunes拖到手机的城市数据任务对象，并状态设置为已完成
 
 2-b、用户选择了下载【厦门】（此时，【厦门】已经通过itunes拖并解压到手机了）
 3-b、由于【基础路网】没下载过，故会在任务列表中显示【基础路网】、【厦门】
 4-b、【基础路网】下载完成后，此时列表中要增加【厦门】、【福州】这两个已通过itunes拖到手机的城市数据任务对象，并状态设置为已完成
 
 综上所述，在【基础路网】下载完成后，需要对任务队列中的任务做一次扫描：
 1、手机中已存在的城市而任务队列中不存在，则立即以这些手机中存在的城市实例化出下载任务对象并加入队列，并把这些任务对象状态设置为已完成
 */

@interface TaskManager : NSObject<TaskStatusDelegate>
{
@private
    // 这两个数组是一一对应的，一个任务对应一个状态值
    NSMutableArray* taskList;          // 用于保存各项任务
    NSMutableArray* TravelTaskList;          // 用于保存下载旅游电子书任务
    //NSMutableArray* mTaskStatusList;    // 用于保存各项任务的状态
    id<TaskStatusDelegate> delegate;    // 客户类填充该属性，以便TaskManager把通知发送给客户类
}

@property(nonatomic,assign)id<TaskStatusDelegate> delegate; // 客户类填充该属性，以便TaskManager把通知发送给客户类
@property(nonatomic,readonly)NSArray* taskList;             // 客户类可以读取该列表，以便得到任务的信息
@property(nonatomic,readonly)NSArray* TravelTaskList;
+(TaskManager*)taskManager;
//+(void)releaseInstance;

// 返回任务队列中的任务id列表
//-(NSArray*)getTaskId;

// 返回-1表示加入失败，>=0表示成功加入后在TaskManager中的索引
-(int)addTask:(Task*) task atFirst:(BOOL) first;

// 移除索引为index处的任务，该操作会删除该任务。
// 如果恰好该任务处于运行状态，removeTask后，整个TaskManager中将无任务在执行
-(BOOL)removeTask:(int) index;

// 移除任务id的任务，该操作会删除该任务。
// 如果恰好该任务处于运行状态，removeTaskId后，整个TaskManager中将无任务在执行
-(BOOL)removeTaskId:(long) taskId;

// 移除所有状态为status的任务，返回移除的个数
-(int)removeTasksForStatus:(int) status;

// TaskManager可能处于两种状态：
// 1、无任何任务在执行：TaskManager按某种策略选择一个任务来执行
// 2、有任务在执行：直接返回
-(BOOL)start;

// 停止TaskManager中正在执行的任务，整个TaskManager处于停止状态
-(BOOL)stop;

// TaskManager可能处于两种状态：
// 1、无任何任务在执行：TaskManager按index来选择任务
// 2、有任务在执行：
//      分两种情况：
//      1、正在执行的任务就是index，那么直接返回；
//      2、正在执行的任务不是index，那么让正在执行的任务变为等待，转而执行index指定的任务
-(BOOL)start:(int)index;

- (BOOL)firstStart:(int)index;

// 停止TaskManager中index对应的任务：
// 1、index对应的任务处于等待状态，那么直接返回
// 2、index对应的任务处于执行状态，那么让正在执行的任务变为等待
-(BOOL)stop:(int)index;

//只暂停指定索引的任务，不自动下载等待的任务
- (BOOL)stopCurrent:(int)index;
//暂停所有的任务
- (void)stopAllTask;
// 返回YES表示TaskManager中有任务正在运行
-(BOOL)isRunning;

// 把TaskManager中的所有任务信息保存到文件系统，一般是在退出程序时调用
-(BOOL)store;

// 从文件系统还原通过save保存的所有任务信息，一般是在进入程序时调用，该方法调用将把TaskManager中的所有任务更新为最后一次调用save保存的任务
-(BOOL)restore;


//-(BOOL)moveUp:(int)index;
//-(BOOL)moveDown:(int)index;

//获取任务列表中所有任务需要的空间大小
-(long long)getNeedSize:(NSArray *)downloadArray;

//将本地存在的地图数据添加到下载队列中，并把状态置为完成
-(int)addLocalTask:(Task*) task atFirst:(BOOL) first;

//检查已经下载完成的城市是否有更新，更新task的updated标志位
//无更新返回NO，有更新返回YES
-(BOOL)checkUpdate;//只返回有无更新
-(BOOL)getUpdateStatus;//重新设置updated字段，返回有无更新

//已下载完成无更新的任务同最新数据列表同步各个字段信息。
-(void)checkTaskInfo;

//更新全部城市
-(void)updateAll;
//更新某个城市
-(void)updatecity:(int)adcode;

//获取不匹配数据的task
-(NSArray *)getNoMatchTask;

-(void) processNoMatchTask;

//返回本地已经下载完成且不支持交叉的task数组
-(NSArray *)getNoCrossTask;

//不支持交叉使用数据的处理
-(void) processNoCrossTask;

-(id) getTaskInfoFromMapList:(int)adcode;

// 从头开始向尾扫描mTaskList列表，直到遇到一个状态为TASK_STATUS_READY的任务对象
// 返回指<0则表示没找到可被执行的任务，否则表示所选任务的索引
-(int)_selectOneTaskToRun;


// 返回队列中，状态为status的第一个任务的索引
// 返回指<0则表示没找到可被执行的任务，否则表示任务的索引
-(int)_firstIndexWithStatus:(int)status;

//返回队列中，任务id为taskID的任务索引
- (int)_indexWithTaskID:(int)taskID;

// 根据taskId来判断task是否已经存在队列中
-(BOOL)_taskExisted:(Task*)task;

//将本地数据添加到任务列表中
-(void)addLocalDataToList;

//将本地数据添加到旅游电子书任务列表中
-(void)addLocalDataToTravelList;


//获取完成的任务个数
- (int)getFinishTaskNumber;
//获取相应类型的对应索引的任务
- (Task *)getTaskWithIndex:(int)index taskStatus:(BOOL)taskStatus;
//根据taskid开始任务
- (void)startWithTaskID:(int)taskID;
- (void)stopWithTaskID:(int)taskID;
//通过taskid获取任务
- (Task *)getTaskWithTaskID:(int)taskID;

//删除一体化时保存tasklist到任务列表文件中
-(BOOL)removeCountryTaskList;
// 移除所有任务
- (void)removeAllTask;
//开始所有的任务
- (void)startAllTask;
//移除所选项目
- (void)removeSelectedTask;
//勾选所有任务
- (void)selectAllTask:(BOOL)flag;
//是否全部都在下载，等待下载，或者都已完成
- (BOOL)isAllRunning;
//是否全部暂停
- (BOOL)isAllStop;
//是否有任务选中
- (BOOL)isSelectedTask;
//是否全部选中
- (BOOL)isAllSelected;
//获取任务列表中所有任务需要的空间大小
-(long long)getAllTaskNeedSize;
//删除不兼容的数据版本号的任务
- (void)removeNotMatchTaskWithArray:(NSArray *)array;
//有更新的删除
-(void)update_erase:(int) taskID;
//获取task在tableview的行号
- (int )getTaskIndex :(int)taskID finished:(BOOL)isfinished;

@end
