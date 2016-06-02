//
//  MileRecordDataControl.h
//  objectToplist
//
//  Created by weihong.wang on 14-4-9.
//  Copyright (c) 2014年 wangweihong. All rights reserved.
//
/*
 日期        总里程(m)    今日里程(m)    本周里程(m)    今日未上传里程(m)
 20140428       0             0             0               5
 20140428       0             0             0               2+5 （一天只存一条 把重复的干掉）
 ————————————————————————————————————————————————————————————————————————
 20140429       0             0             0               3
 
 ——————————————此时与服务器同步成功，并且把之前的未上传记录全部清空———————————————
 20140429       10            3            10               0
 ————————————————————————————————————————————————————————————————————————
 
 20140429       10             3            10               6
 20140501       10             0            10               5
 20140502       10             0            10               8
 
 下周一
 20140505       10             0             0               6
 
 
 
 规则：1、 总里程(m)    今日里程(m)    本周里程(m) 都是从服务器获得的数据。
 今日里程 一天清空一次； 本周里程 一周清空一次；
 2、 日期一样的话，并且未上传，就把之前的今日未上传里程累加；
 3、 一天只保存一条记录；
 4、 今日里程 每天一开始都是0
 5、 本周里程  每周一开始都是0
 6、 今日未上传里程 每天一开始都是0 并且当天的记录并且未上传的情况下，需要保存在Plist。
 
 
 例如：20140505 那一天的界面显示方法：
 
 总里程=总里程+所有未上传的里程数
 = 10+（6+5+8+6）
 
 今日里程 = 今日里程 + 所有今日未上传的里程数
 = 0 + 6
 
 20140502的 周里程 = 周里程 + 所有当周未上传的里程数
 = 10 +（6+5+8）
 */


#import <Foundation/Foundation.h>
#import "MileageData.h"
#import "MWMileageList.h"

@interface MileRecordDataControl : NSObject <NetRequestExtDelegate>

@property (nonatomic, retain)NSTimer* recordMileTimer;
@property (nonatomic, retain)MileageData *mData; //存储未上传单天单条里程信息
@property (nonatomic, retain)NSMutableArray *mileRecordDataList;//本地存未上传里程列表信息
@property (nonatomic, retain) MWMileageList *mileageServiceList;//服务器下发里程信息
@property (nonatomic, copy) NSString *shortURL; //分享短地址
@property (nonatomic ,assign)    id<NetReqToViewCtrDelegate> reqDelegare;
@property (nonatomic, retain)NSString *xmlString ;//构造上传XML

//里程上传
- (void)mileageRequestWithType:(RequestType)type;

- (BOOL)isSameUserDate:(int)mile;// 累加今日未上传里程
//构造Miledata 初始化单条信息加入mileRecordDataList数组
-(void)makeMiledata:(int)tmile;
//清空之前本地保存的数据
-(void)cleanMileRecordDataList;

//读文件里面该用户保存的服务端同步过来的总里程
-(NSString *)readServerReCordAllData;
//读文件里面该用户保存的服务端同步过来的周里程
-(NSString*)readServerReCordWeekData;
//读取 与服务器最后一次同步保存的今日里程 如果不是今日的数据 则返回0;
-(NSString*)readServerReCordTodayData;
//读取 最后一次保存的未上传的今日里程  否 则返回0;
-(NSString*)readNoUpdata;


//计算出界面显示的总里程 = （总里程）最后一次服务保存的里程 + 所有未上传的里程
-(NSString*)readAllUpData;
//计算出界面要显示的本周里程 =（周里程）服务端最后一次保存的当周里程+当周未上传的里程
-(NSString*)readAllWeekMile;
//计算出界面要显示的今日里程 = （今日里程）服务端最后一次保存的今日里程+今日未上传的里程
-(NSString*)readAlltodayMile;

//获取今年的第几周
-(long int)returnCompsWeek:(NSString *)dateStr;
//获取系统当前日期
-(NSString*)returnCurrentDate;

-(void)encryptionList:(NSMutableArray*)sarray;
-(void)decryptList:(NSArray*)readRecordList;



//登陆账号后，把未登陆的账号的数据付给第一次登陆的
-(void)modifyAccount;
+ (MileRecordDataControl *)sharedInstance;
@end
