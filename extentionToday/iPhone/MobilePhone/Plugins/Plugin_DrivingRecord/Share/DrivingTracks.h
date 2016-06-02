//
//  DrivingTracks.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-3.
//
//
//轨迹文件格式
/* 1、name 文件名称：用日期来表示
   2、description 描述
   3、根据安卓那边的格式有三个Placemark 的内容 分别是 1、轨迹线 Trace 2、TTS 数组 3、Turn Info 转向信息 数组
   4、轨迹线 Trace（包含  gdCoordType、 description、altitudeMode、coordinates(经度,纬度,海拔)）
   5、TTS（包含 gdCoordType、coordinates（精度,纬度）、gdVoiceText）
   6、Turn Info 转向信息 （包含 gdCoordType、coordinates、gdTurn）
 */

#import <Foundation/Foundation.h>

@interface DCoordinate : NSObject

@property (nonatomic, assign) int lon;              //经度
@property (nonatomic, assign) int lat;              //纬度
@property (nonatomic, assign) int Altitude;         //海拔
@property (nonatomic, assign) int nSpeed;           //速度
@property (nonatomic, assign) int arrayNum;         //在数组中的索引
@property (nonatomic, assign) int coordType;        //记录点类型 0-一般点 1－超速 2-加速 3-刹车 4-转弯 5-偏航

@end

@interface DTrace : NSObject

@property (nonatomic, copy) NSString *gdCoordType;   //高德地图坐标样式
@property (nonatomic, copy) NSString *mDescription;   //描述 默认为空
@property (nonatomic, copy) NSString *altitudeMode;  //默认 absolute
@property (nonatomic, retain) NSMutableArray *coordinates; //经纬度，海拔

@end


@interface DTTS : NSObject

@property (nonatomic, copy) NSString *gdCoordType;   //高德地图坐标样式
@property (nonatomic, assign) int lon;              //经度
@property (nonatomic, assign) int lat;              //纬度
@property (nonatomic, copy) NSString *gdVoiceText;    //语音播报文本

@end


@interface DTurnInfo : NSObject

@property (nonatomic, copy) NSString *gdCoordType;   //高德地图坐标样式
@property (nonatomic, assign) int lon;              //经度
@property (nonatomic, assign) int lat;              //纬度
@property (nonatomic, assign) int gdTurn;        //转向id

@end



@interface DrivingTracks : NSObject

@property (nonatomic, copy) NSString *name;//轨迹名称
@property (nonatomic, retain) DTrace *trace;//轨迹点
@property (nonatomic, retain) NSMutableArray *yawArray;//偏航点数组
@property (nonatomic, retain) NSMutableArray *ttsArray;//语音播报TTS数组
@property (nonatomic, retain) NSMutableArray *turnInfoArray;//转向DTurnInfo数组
@property (nonatomic, retain) NSMutableArray *haccelerationArray;//急加油点数组
@property (nonatomic, retain) NSMutableArray *brakesArray;//急刹车点数组
@property (nonatomic, retain) NSMutableArray *uturnArray;//急转弯点数组
@property (nonatomic, retain) NSMutableArray *hypervelocityArray;//超速点数组

@end
