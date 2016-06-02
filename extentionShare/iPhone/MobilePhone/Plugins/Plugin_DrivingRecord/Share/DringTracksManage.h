//
//  DrivingTracksManage.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-3.
//
//

#import <Foundation/Foundation.h>
#import "DrivingTracks.h"
#import "DrivingInfo.h"

typedef enum TrackCountType { //轨迹统计信息
    
    TrackCountType_Normal = 0,     //统计
    TrackCountType_Start,          //开始统计
    TrackCountType_End,            //结束统计
    TrackCountType_Hacceleration,  //急加油
    TrackCountType_Brakes,         //急刹车
    TrackCountType_Uturn,          //急转弯
    TrackCountType_Hypervelocity,  //超速
    
} TrackCountType;


@interface DringTracksManage : NSObject <MWPoiOperatorDelegate,NetRequestExtDelegate>

@property (nonatomic, copy) NSString *shareText;    //分享内容
@property (nonatomic, assign) float averageScore;   //平均驾驶分数
@property (nonatomic,assign) id<NetReqToViewCtrDelegate> delegate;
@property (nonatomic, assign) id<NetReqToViewCtrDelegate> historyDelegate;

+ (DringTracksManage *)sharedInstance;


- (void)drivingTrackCalculateWithNewLocation:(CLLocation *)newLocation oldLocation:(CLLocation *)oldLocation andType:(TrackCountType)type;

/**
 * 计算超速次数和得分
 * @param ttsString 语音播报字符串
 */
- (void)countHypervelocityWithTTSString:(NSString *)ttsString;

- (DrivingInfo *)getDrivingInfo;

- (NSMutableArray *)getDrivingInfoList;

//读取轨迹文件
- (DrivingTracks *)readDrivingTrackWithID:(NSString *)trackID dataURL:(NSString *)dataURL;

- (void)addYawInfoWithLon:(int)lon Lat:(int)lat;

//获取未同步驾驶记录条数
- (int)getUnSyncDrivingFileCount;

- (NSMutableArray *)getAllDrivingInfoList;
- (DrivingInfo *)getDrivingInfoWithID:(NSString *)trackID;
- (void)deleteDrivingTrackWithIndex:(int)index;
- (BOOL)deleteDrivingTrackInfoWithID:(NSString *)trackInfoID;
//保存轨迹文件信息
- (BOOL)storeDrivingTrackInfo;
- (void)removeAllDrivingTrackInfo;
//获取未同步轨迹信息列表
- (NSMutableArray *)getUnSyncDrivingInfoList;
- (void)setPostType;
/**
 * 计算轨迹总急刹车，急加油，急转弯，超速得分
 * @param type 计算类型
 */
- (double)countBeatNumWithScore:(int)score;

- (void)drivingTrackRequestWithType:(RequestType)type pageIndex:(Byte)pageIndex pageCount:(Byte)pageCount drivingTrack:(DrivingInfo *)trackInfo;
- (void)drivingTrackFileDownloadWithURL:(NSString *)trackFileURL;
- (void)historyRouteSync;
- (NSString *)countMoodTextWithType:(DrivingResultType)type;
- (void)historyModifyAccount;

/**
 * 复制一份新的数据到newUserID
 * param reNameUserID 要复制的用户id
 * param newUserID 复制后的用户id
 * @return
 */
- (BOOL)reNamedrivingTrackUserIDWithUserID:(NSString *)reNameUserID NewUserID:(NSString *)newUserID;

@end
