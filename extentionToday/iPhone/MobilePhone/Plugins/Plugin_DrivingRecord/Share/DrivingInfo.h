//
//  DrivingInfo.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-3.
//
//
/**********驾驶信息序列化**************
id 由终端生成 userid+时间毫 秒数
操作类型 1=新增,2=修改,3=删除
轨迹名称
轨迹长度 单位/km
轨迹得分
轨迹耗时 单位/分钟
平均速度
油耗
安全
急加油次数
急刹车次数
急转弯次数
超速次数
 
数据类型 kml,text
创建时间 格式 yyyyMMddHHmmSS
轨迹修改时间 格式 yyyyMMddHHmmSS
***************************************/
#import <Foundation/Foundation.h>

typedef enum DrivingResultType
{
    DrivingResultType_Police     = 0,     //警察
    DrivingResultType_Economical = 1,     //省钱
    DrivingResultType_Happy      = 2,     //开心
    DrivingResultType_Rookie     = 3,     //菜鸟
    DrivingResultType_Air        = 4,     //神气
    
} DrivingResultType;

@interface DrivingInfo : NSObject
@property (nonatomic, copy) NSString *drivingID;//由终端生成 userid+时间毫 秒数
@property (nonatomic, copy) NSString *userID;//用户id
@property (nonatomic, assign) int optype;//操作类型  1-新增 2－修改 3-删除 4-删除并且已经同步过
@property (nonatomic, assign) int postType;//开机上传标志 0-未上传 1-已上传
@property (nonatomic, copy) NSString *name; //轨迹名称

@property (nonatomic, assign) int trackLength;//轨迹长度
@property (nonatomic, assign) double trackScore;//轨迹得分
@property (nonatomic, assign) int trackTimeConsuming;//轨迹耗时
@property (nonatomic, assign) double averageSpeed;//平均速度
@property (nonatomic, assign) double higherSpeed;//最高速度
@property (nonatomic, assign) double fuelConsumption;//油耗
@property (nonatomic, assign) double safetyScore;//安全得分

@property (nonatomic, assign) int haccelerationCount;//急加油次数
@property (nonatomic, assign) int brakesCount;   //急刹车次数
@property (nonatomic, assign) int uturnCount;   //急转弯次数
@property (nonatomic, assign) int hypervelocityCount;//超速次数
@property (nonatomic, assign) int yawCount; //偏航次数tr

@property (nonatomic, copy) NSString *dataType;//数据类型
@property (nonatomic, copy) NSString *creatTime;//创建时间
@property (nonatomic, copy) NSString *updateTime;//轨迹修改时间
@property (nonatomic, assign) DrivingResultType resultType; //文案 有五类情绪：警察，省钱，开心，菜鸟，神气

@property (nonatomic, retain) MWPoi *startPOI; //起点
@property (nonatomic, retain) MWPoi *desPOI;   //终点
@property (nonatomic, copy) NSString *dataURL; //轨迹下载地址
@property (nonatomic, assign) int isComprass;  //数据包是否压缩
@property (nonatomic, assign) int beatNum; //击败多少人百分比

@end
