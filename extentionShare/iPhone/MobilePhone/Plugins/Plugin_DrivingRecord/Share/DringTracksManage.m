//
//  DrivingTracksManage.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-3.
//
//  驾驶轨迹记录管理

#import "DringTracksManage.h"
#include <math.h>
#import "MWPoiOperator.h"
#import "GDAlertView.h"
#import "JSON.h"
#import "DDXML.h"
#import "ThreeDes.h"
#import "MWMapOperator.h"
#import "XMLDictionary.h"
#import "NSString+Category.h"

@interface DringTracksManage ()
{
    MWPoiOperator *poiOperator;
}

@property (nonatomic, retain) DrivingInfo   *drivingTrackInfo;       //轨迹信息，存放当前驾驶轨迹信息
@property (nonatomic, retain) DrivingTracks *drivingTrackFile;       //轨迹文件对象，存放当前驾驶轨迹文件信息
@property (nonatomic, retain) NSMutableArray *drivingTrackInfoArray; //轨迹信息数组，存放所有轨迹信息
@property (nonatomic,copy) NSString *trackStartTime;                 //上一个记录点时间
@property (nonatomic,copy) NSString *countStartTime;                 //统计急加油，急刹车，急转弯开始时间点
@property (nonatomic,copy) NSString *trackFirstTime;                 //第一个记录点时间
@property (nonatomic,assign) GCOORD trackStartCoord;                 //上一个记录点经纬度
@property (nonatomic,assign) float preCourse;                        //上一个记录点方位角 0～359.9 －1为无效值
@property (nonatomic,assign) double preSpeed;                        //上一个记录点速度
@property (nonatomic,assign) GCOORD preCoord;                        //上一个统计点经纬度
@property (nonatomic,retain) NSMutableArray *locationArray;          //保存5个定位点，用来判断急转弯

@end

@implementation DringTracksManage

+ (instancetype)sharedInstance {
    
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[self alloc] init];
        [sharedInstance restoreDrivingTrackInfo];
    });
    
    return sharedInstance;
}

- (id)init
{
    if (self = [super init])
    {
        _drivingTrackInfoArray = [[NSMutableArray alloc] init];
        _drivingTrackFile = [[DrivingTracks alloc] init];
        _locationArray = [[NSMutableArray alloc] init];
        poiOperator = [[MWPoiOperator alloc] initWithDelegate:self];
    }
    return self;
}

#pragma mark - 轨迹属性

/**
 * 驾驶记录
 * @param  newLocation 当前gps信息
 * @param  oldLocation 上一个gps信息
 * @param  type 记录类型 TrackCountType_Start－开始记录 TrackCountType_Normal－记录中 TrackCountType_End－结束记录
 * @return
 */
- (void)drivingTrackCalculateWithNewLocation:(CLLocation *)newLocation oldLocation:(CLLocation *)oldLocation andType:(TrackCountType)type
{
    static int overLowSpeedCount = 0; //行驶速度大于10km／h超过60次，则打分，否则不打分
    static double highterSpeed = 0.0; //行驶最大速度
    
    if (!self.drivingTrackInfo) {
        _drivingTrackInfo = [[DrivingInfo alloc] init];
    }
    
    if (type == TrackCountType_Normal)//统计信息，记录定位点
    {
        if (![ANParamValue sharedInstance].isPath || [ANParamValue sharedInstance].isNavi) {
            return;
        }
        
        if (!self.trackStartTime || _trackStartCoord.x == 0 || _trackStartCoord.y == 0) //保存第一个记录点的时间和经纬度
        {
            //把起点加入记录点
            [self addStartPOIToTrackPOI];
            
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            [formatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            self.trackStartTime = [formatter1 stringFromDate:[NSDate date]];
            self.countStartTime = [formatter1 stringFromDate:[NSDate date]];
            [formatter1 release];
            
            self.preSpeed = newLocation.speed;
            
            _trackStartCoord.x = newLocation.coordinate.longitude * 1000000;
            _trackStartCoord.y = newLocation.coordinate.latitude * 1000000;
            _preCourse = newLocation.course;
            
            return;
        }
        
        int trackDic = 0;
        
        GGPSINFO pGpsInfo1 = {0};
        GDBL_GetGPSInfo(&pGpsInfo1);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date1 = [formatter dateFromString:self.trackStartTime];
        
        NSDate *countDate = nil;
        
        @synchronized(self.countStartTime)
        {
            
            countDate = [formatter dateFromString:self.countStartTime];
            
        }
        
        NSDate *date2 = [NSDate date];
    
        NSTimeInterval aTimer = [date2 timeIntervalSinceDate:date1];
        NSTimeInterval countTimer = [date2 timeIntervalSinceDate:countDate]; //急加油，急刹车，急转弯，超速统计时间间隔
        
        GCOORD newCoord = {0};
        
        newCoord.x = newLocation.coordinate.longitude * 1000000;
        newCoord.y = newLocation.coordinate.latitude * 1000000;
        
        if ((newLocation.speed > 0.1f) && (self.preSpeed > 0.1f) && (countTimer > 0.9f) && pGpsInfo1.nValid == 1)//时间大于1秒
        {
            GCARINFO carInfo = {0};
            [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carInfo];
            
            //统计急加油、急刹车次数和得分
            BOOL res = [self countHaccelerationAndBrakeWithFirstSpeed:self.preSpeed lastSpeed:newLocation.speed time:countTimer lon:carInfo.Coord.x lat:carInfo.Coord.y];
            
            //统计急转弯次数和得分
            if (!res) {
                [self countUturnWithLocation:newLocation];
            }
            
            self.preSpeed = newLocation.speed;
            self.countStartTime = [formatter stringFromDate:[NSDate date]];
            _preCoord.x = carInfo.Coord.x;
            _preCoord.y = carInfo.Coord.y;
            
        }
        
        if ((pGpsInfo1.nSpeed > 0.0f) && (aTimer > 0.9f) && (newLocation.course >= 0.0f))//时间大于1秒
        {
            
            //两点之间的方位角小于5则认为是直线，不记录，如果大于5则记录
            if ((fabs(newLocation.course - self.preCourse) > 7.0f))
            {
                //经纬度转化为高德经纬度
                GCOORD gdCoord = {0};
                gdCoord = [MWEngineTools WGSToGDCoord:newCoord];
                //记录定位点
                [self addTrackPointWithLon:0 Lat:0 Altitude:newLocation.altitude coordType:0];
                
                //计算两点之间的距离
                 trackDic = [MWEngineTools CalcDistanceFrom:_trackStartCoord To:gdCoord];
                self.trackStartTime = [formatter stringFromDate:[NSDate date]];
                _trackStartCoord.x = gdCoord.x;
                _trackStartCoord.y = gdCoord.y;
                
                self.preCourse = newLocation.course;
            }
            
            
            
        }
        
        [formatter release];
        formatter  = nil;
        
        if (newLocation.speed > 2.8f) {
            overLowSpeedCount++;
        }
        
        if (newLocation.speed > highterSpeed) {//获取行驶最高速度
            highterSpeed = newLocation.speed;
        }
        
        //轨迹总距离
        self.drivingTrackInfo.trackLength = self.drivingTrackInfo.trackLength + trackDic;
        
    }
    else if (type == TrackCountType_Start)
    {
        
        [self releaseDrivingTrackInfo];
        [self releaseDrivingTrackFile];
        
        self.trackStartTime = nil;
        self.countStartTime = nil;
        
        //设置驾驶轨迹开始时间
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.trackFirstTime = [formatter stringFromDate:[NSDate date]];
        [formatter release];
        
        _trackStartCoord.x = 0;
        _trackStartCoord.y = 0;
        self.preCourse = 0;
        self.preSpeed = 0;
        overLowSpeedCount = 0;
        highterSpeed = 0;
        
    }
    else if (type == TrackCountType_End)
    {
        int bRoute = 0;
        GDBL_GetParam(G_GUIDE_STATUS, &bRoute);
        if (!bRoute) {
            return;
        }
        
        if (self.drivingTrackInfo.trackLength < 1000 || overLowSpeedCount < 60)
        {
            
            NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_AlertDistanceShortOnce];
            if (!string) {
                
                [[NSUserDefaults standardUserDefaults] setValue:@"click" forKey:USERDEFAULT_AlertDistanceShortOnce];
                
                GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"DrivingTrack_alertDistanceTooShort", Localize_DrivingTrack)];
                [alertView show];
                [alertView release];
            }
            
            return;
        }
        //驾驶轨迹总时间
        self.drivingTrackInfo.trackTimeConsuming = [self countDrivingTimeWithStartTime:self.trackFirstTime];
        
        //平均速度
        self.drivingTrackInfo.averageSpeed = [self countAverageSpeedWithTotalDis:self.drivingTrackInfo.trackLength totalTime:self.drivingTrackInfo.trackTimeConsuming];
        
        double fuelEfficiencyScore = 90.0;//燃油效率得分目前为90
        double hypervelocityScore = [self countScoreWithType:TrackCountType_Hypervelocity];
        double haccelerationScore = [self countScoreWithType:TrackCountType_Hacceleration];
        double brakesScore = [self countScoreWithType:TrackCountType_Brakes];
        double uturnTotalScore = [self countScoreWithType:TrackCountType_Uturn];
        
        //安全得分
        self.drivingTrackInfo.safetyScore = [self countSafeScoreWithHypervelocityScore:hypervelocityScore haccelerationScore:haccelerationScore brakesScore:brakesScore uturnScore:uturnTotalScore];
        
        //油耗得分
        self.drivingTrackInfo.fuelConsumption = [self countFuelConsumptionWithHaccelerationScore:haccelerationScore brakesScore:brakesScore fuelEfficiencyScore:fuelEfficiencyScore];
        
        //轨迹得分
        self.drivingTrackInfo.trackScore = [self countTotalScoreWithSafeScore:self.drivingTrackInfo.safetyScore fuelConsumption:self.drivingTrackInfo.fuelConsumption];
        
        //结果类型
        self.drivingTrackInfo.resultType = [self countMoodTextWithAverageSpeed:self.drivingTrackInfo.averageSpeed brakesCount:self.drivingTrackInfo.brakesCount haccelerationCount:self.drivingTrackInfo.haccelerationCount hypervelocityCount:self.drivingTrackInfo.hypervelocityCount];
        
        //最高速度
        self.drivingTrackInfo.higherSpeed = highterSpeed*3.6;
        
        [self addEndPOIToTrackPOI];
        
    }
    
}

/**
 * 保存驾驶轨迹列表
 * @return YES 保存成功 NO 保存失败
 */
- (BOOL)storeDrivingTrackInfo
{
    @synchronized(_drivingTrackInfoArray)
    {
        if ([NSKeyedArchiver archiveRootObject:self.drivingTrackInfoArray toFile:DrivingTrackInfo_PATH])
            return YES;
        
        
        return NO;
        
    }
}

/**
 * 恢复驾驶轨迹列表
 * @return YES 保存成功 NO 保存失败
 */
- (BOOL)restoreDrivingTrackInfo
{
    
	@synchronized(_drivingTrackInfoArray)
    {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:DrivingTrackInfo_PATH];
        [self.drivingTrackInfoArray removeAllObjects];
        
        if (array && [array isKindOfClass:[NSArray class]]) {
            
            for (DrivingInfo *trackInfo in array) {
                
                if (![self isDrivingTrackInfoExistWithDrivingInfo:trackInfo]) {
                    
                    [self.drivingTrackInfoArray addObject:trackInfo];
                    
                }
                
            }
        }
        
        return YES;
        
    }
}

/**
 * 判断驾驶记录是否存在,userID参与判断
 */
- (BOOL)isDrivingTrackInfoExistWithDrivingInfo:(DrivingInfo *)drivingInfo
{
    @synchronized(_drivingTrackInfoArray)
    {
        if (!drivingInfo) {
            return YES;
        }
        
        int drivingCount = self.drivingTrackInfoArray.count;
        for (int i = 0 ; i < drivingCount; i ++) {
            
            DrivingInfo *info = [self.drivingTrackInfoArray caObjectsAtIndex:i];
            
            if (info && [info.drivingID isEqualToString:drivingInfo.drivingID] && [info.userID isEqualToString:drivingInfo.userID]) {
                
                return YES;
            }
        }
        
        return NO;
    }
}

/**
 * 判断驾驶记录是否存在,userID不参与判断
 */
- (BOOL)isDrivingTrackInfoExistWithDrivingID:(NSString *)drivingID
{
    @synchronized(_drivingTrackInfoArray)
    {
        if (!drivingID) {
            return YES;
        }
        
        int drivingCount = self.drivingTrackInfoArray.count;
        for (int i = 0 ; i < drivingCount; i ++) {
            
            DrivingInfo *info = [self.drivingTrackInfoArray caObjectsAtIndex:i];
            
            if (info && [info.drivingID isEqualToString:drivingID]) {
                
                return YES;
            }
        }
        
        return NO;
    }
}

/**
 * 新增驾驶记录（保存当前的驾驶记录）
 */
- (void)addDrivingTrackInfo
{
    if (!self.drivingTrackInfo) {
        _drivingTrackInfo = [[DrivingInfo alloc] init];
    }
    
    NSDateFormatter *formatterqtime = [[NSDateFormatter alloc] init];
    [formatterqtime setDateFormat:@"yyyyMMddHHmmss"];
    NSString *timeString = [formatterqtime stringFromDate: [NSDate date]];
    
    if ([self isDrivingTrackInfoExistWithDrivingID:timeString]) {//如果驾驶记录存在则不添加
        
        [formatterqtime release];
        
        return;
    }
    
    self.drivingTrackInfo.drivingID = timeString;
    self.drivingTrackInfo.userID = UserID_Account;
    self.drivingTrackInfo.optype = 1;  //新增
    self.drivingTrackInfo.postType = 0;
    self.drivingTrackInfo.dataType = @"kml";
    self.drivingTrackInfo.creatTime = timeString;
    self.drivingTrackInfo.updateTime = timeString;
    
    [self.drivingTrackInfoArray insertObject:self.drivingTrackInfo atIndex:0];
    
   // CRELEASE(drivingTrackInfo);
    [self storeDrivingTrackFileWithID:timeString];
    [self storeDrivingTrackInfo];
    
    [formatterqtime release];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.drivingTrackInfo) {
            
            NSDictionary *dic = [NSDictionary dictionaryWithObject:self.drivingTrackInfo forKey:@"drivingTrackInfo"];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdata_DrivingTrack] userInfo:dic];
        }
        
    });
}

/**
 * 清除轨迹属性内存
 */
- (void)releaseDrivingTrackInfo
{
    CRELEASE(_drivingTrackInfo);
}

/**
 * 获取当前驾驶记录
 * @return DrivingInfo 当前驾驶轨迹记录
 */
- (DrivingInfo *)getDrivingInfo
{
    return _drivingTrackInfo;
}

/**
 * 获取指定驾驶记录（根据驾驶id获取－驾驶id为保存驾驶记录的时间，精确到毫秒)
 * @param trackID 驾驶记录id －－驾驶id为保存驾驶记录的时间，精确到毫秒
 * @return DrivingInfo 当前驾驶轨迹记录
 */
- (DrivingInfo *)getDrivingInfoWithID:(NSString *)trackID
{
    @synchronized(_drivingTrackInfoArray)
    {
        
        DrivingInfo *trackInfo = nil;
        
        if (!trackID) {
            return trackInfo;
        }
        
        for (DrivingInfo *info in self.drivingTrackInfoArray) {
            
            if ([trackID isEqualToString:info.drivingID]) {
                trackInfo = info;
                return trackInfo;
            }
        }
        
        return trackInfo;
    }
}

/**
 * 获取所有驾驶记录（包含删除的)
 * @return NSMutableArray 所有驾驶记录列表
 */
- (NSMutableArray *)getAllDrivingInfoList
{
    @synchronized(_drivingTrackInfoArray)
    {
        return self.drivingTrackInfoArray;
    }
}

/**
 * 获取需要显示的所有驾驶记录（不包含删除的)
 * @return NSMutableArray 所有驾驶记录列表
 */
- (NSMutableArray *)getDrivingInfoList
{
    @synchronized(_drivingTrackInfoArray)
    {
        
        [self modifyAccount];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        if (self.drivingTrackInfoArray && self.drivingTrackInfoArray.count > 0) {
            
            for (DrivingInfo *trackInfo in self.drivingTrackInfoArray) {
                if (trackInfo.optype != 3 && trackInfo.optype != 4 && [trackInfo.userID isEqualToString:UserID_Account]) {
                    
                    [array addObject:trackInfo];
                    
                }
                
            }
        }
        return [array autorelease];
    }
}

/**
 * 获取未同步轨迹记录列表
 * @return NSMutableArray 所有未同步的驾驶记录列表
 */
- (NSMutableArray *)getUnSyncDrivingInfoList
{
    @synchronized(_drivingTrackInfoArray)
    {
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        if (self.drivingTrackInfoArray && self.drivingTrackInfoArray.count > 0) {
            
            for (DrivingInfo *trackInfo in self.drivingTrackInfoArray) {
                
                NSString *filePath = [NSString stringWithFormat:@"%@%@.plist",DrivingTrack_PATH,trackInfo.drivingID];
                
                NSArray *array_url = [trackInfo.dataURL componentsSeparatedByString:@"/"];
                NSString *base_filePath = nil;
                if (array_url)
                {
                    NSString *tmpString = [array_url lastObject];
                    if (tmpString) {
                        base_filePath = [NSString stringWithFormat:@"%@%@.plist",DrivingTrack_PATH,tmpString];
                    }
                }
                
                if ((trackInfo.optype != 0 && trackInfo.optype != 4 && [trackInfo.userID isEqualToString:UserID_Account]))
                {
                    if (trackInfo.optype == 3) {
                        [array addObject:trackInfo];
                    }
                    else if (trackInfo.optype == 1 && ([[NSFileManager defaultManager] fileExistsAtPath:filePath] || [[NSFileManager defaultManager] fileExistsAtPath:base_filePath]))
                    {
                        [array addObject:trackInfo];
                    }
                    
                    
                }
                
            }
        }
        return [array autorelease];
        
    }
}


/**
 * 复制一份新的数据到newUserID
 * param reNameUserID 要复制的用户id
 * param newUserID 复制后的用户id
 * @return
 */
- (BOOL)reNamedrivingTrackUserIDWithUserID:(NSString *)reNameUserID NewUserID:(NSString *)newUserID
{
    if (!reNameUserID || !newUserID || ![reNameUserID isKindOfClass:[NSString class]] || ![newUserID isKindOfClass:[NSString class]]) {
        return NO;
    }
    
    @synchronized(_drivingTrackInfoArray)
    {
        
        int count = self.drivingTrackInfoArray.count;
        NSMutableArray *addarray = [NSMutableArray array];
        for (int i = 0; i < count; i ++) {
            
            DrivingInfo *info = [self.drivingTrackInfoArray caObjectsAtIndex:i];
            
            if (info.optype != 3 && info.optype != 4 && [info.userID isEqualToString:reNameUserID])
            {
                BOOL isExist = NO;
                for (int j = 0; j < count; j++)
                {
                    DrivingInfo *temp = [self.drivingTrackInfoArray caObjectsAtIndex:j];
                    if ([temp.userID isEqualToString:newUserID] && [temp.drivingID isEqualToString:info.drivingID])
                    {
                        isExist = YES;
                        break;
                    }
                }
                if (isExist == NO)
                {
                    DrivingInfo *addItem = [[DrivingInfo alloc] init];
                    addItem.postType = info.postType;
                    addItem.name = info.name;
                    addItem.trackLength = info.trackLength;
                    addItem.trackScore = info.trackScore;
                    addItem.trackTimeConsuming = info.trackTimeConsuming;
                    addItem.averageSpeed = info.averageSpeed;
                    addItem.higherSpeed = info.higherSpeed;
                    addItem.fuelConsumption = info.fuelConsumption;
                    addItem.safetyScore = info.safetyScore;
                    addItem.haccelerationCount = info.haccelerationCount;
                    addItem.brakesCount = info.brakesCount;
                    addItem.uturnCount = info.uturnCount;
                    addItem.hypervelocityCount = info.hypervelocityCount;
                    addItem.yawCount = info.yawCount;
                    addItem.dataType = info.dataType;
                    addItem.resultType = info.resultType;
                    addItem.startPOI = info.startPOI;
                    addItem.desPOI = info.desPOI;
                    addItem.dataURL = info.dataURL;
                    addItem.isComprass = info.isComprass;
                    addItem.beatNum = info.beatNum;
                    addItem.drivingID = info.drivingID;
                    addItem.creatTime = info.creatTime;
                    addItem.updateTime = info.updateTime;
                    addItem.optype = 1;
                    addItem.userID = newUserID;
                    [addarray addObject:addItem];
                    [addItem release];
                }
            }
        }
        [self.drivingTrackInfoArray addObjectsFromArray:addarray];
        [self storeDrivingTrackInfo];
        return YES;
    }
}

/**
 * 获取未同步驾驶记录条数
 * @return NSMutableArray 所有未同步的驾驶记录个数
 */
- (int)getUnSyncDrivingFileCount
{
    int count = 0;
    
    if (self.drivingTrackInfoArray) {
        
        for (DrivingInfo *info in self.drivingTrackInfoArray) {
            if (info.optype != 0 && info.optype != 4) {
                count ++;
            }
        }
    }
    
    return count;
}

/**
 * 删除所有驾驶记录及文件
 */
- (void)removeAllDrivingTrackInfo
{
    
    [self removeAllDrivingTrackFile];
    
    if (self.drivingTrackInfoArray) {
        
        int count = self.drivingTrackInfoArray.count;
        
        NSDateFormatter *formatterqtime = [[NSDateFormatter alloc] init];
        [formatterqtime setDateFormat:@"yyyyMMddHHmmss"];
        NSString *timeString = [formatterqtime stringFromDate: [NSDate date]];
        
        for (int i = 0; i < count; i++) {
            
            DrivingInfo *info = [self.drivingTrackInfoArray caObjectsAtIndex:i];
            
            if (info.optype != 4)
            {
                info.optype = 3;
            }
            info.updateTime = timeString;
        }
        
        [formatterqtime release];
    }
    
    [self storeDrivingTrackInfo];
    
}

/**
 * 删除指定驾驶记录
 * @param trackInfoID 驾驶记录id
 * @return YES 删除成功 NO 删除失败
 */
- (BOOL)deleteDrivingTrackInfoWithID:(NSString *)trackInfoID
{
    BOOL res = NO;
    
    if (!trackInfoID) {
        return res;
    }
    
    int count = self.drivingTrackInfoArray.count;
    
    NSDateFormatter *formatterqtime = [[NSDateFormatter alloc] init];
    [formatterqtime setDateFormat:@"yyyyMMddHHmmss"];
    NSString *timeString = [formatterqtime stringFromDate: [NSDate date]];
    
    for (int i = 0; i < count; i++) {
        
        DrivingInfo *info = [self.drivingTrackInfoArray caObjectsAtIndex:i];
        
        if ([trackInfoID isEqualToString:info.drivingID]) {
            
            
            info.optype = 3;
            
            info.updateTime = timeString;
            
            [self delegeDrivingTrackFileWithID:info.drivingID];
            
            res = YES;
            
            break;
        }
        
    }
    
    [formatterqtime release];
    
    [self storeDrivingTrackInfo];
    
    return res;
}

/**
 * 删除指定驾驶记录
 * @param index 驾驶记录索引
 */
- (void)deleteDrivingTrackWithIndex:(int)index
{
    int count = self.drivingTrackInfoArray.count;
    
    if (index >= count) {
        return;
    }
    
    NSDateFormatter *formatterqtime = [[NSDateFormatter alloc] init];
    [formatterqtime setDateFormat:@"yyyyMMddHHmmss"];
    NSString *timeString = [formatterqtime stringFromDate: [NSDate date]];
    
    DrivingInfo *info = [self.drivingTrackInfoArray caObjectsAtIndex:index];
    
    info.optype = 3;
    info.updateTime = timeString;
    
    [self storeDrivingTrackInfo];
    
}

/**
 * 设置得分上传标识 （上传驾驶记录得分成功，则把postType 置为1）
 */
- (void)setPostType
{
    int count = self.drivingTrackInfoArray.count;
    
    for (int i = 0; i< count; i++) {
        
        DrivingInfo *info = [self.drivingTrackInfoArray caObjectsAtIndex:i];
        info.postType = 1;
        
    }
    
    [self storeDrivingTrackInfo];
}

/**
 * 设置轨迹同步标识 （上传驾驶记录得分成功，则把optype 置为0）
 */
- (void)setOPType
{
    int count = self.drivingTrackInfoArray.count;
    NSString *currentId = UserID_Account;
    for (int i = 0; i < count; i ++) {
        
        DrivingInfo *info = [self.drivingTrackInfoArray caObjectsAtIndex:i];
        if ([info.userID isEqualToString:currentId]) //modify by gzm for 只有相同用户id才同步标识 at 2014-11-18
        {
            if (info.optype == 3 || info.optype == 4) {
                info.optype = 4;
            }
            else{
                info.optype = 0;
            }
        }
    }
    
}

/**
 * 删除已经删除并且得分已经上传的记录
 */
- (void)removePostAndSyncAndDeleteTrack
{
    NSMutableArray *deleteArray = [[NSMutableArray alloc] init];
    
    for (DrivingInfo *info in self.drivingTrackInfoArray) {
        if (info.optype == 4 && info.postType == 1) {
            [deleteArray addObject:info];
        }
    }
    
    [self.drivingTrackInfoArray removeObjectsInArray:deleteArray];
    
    [deleteArray release];
    
}


#pragma mark - 轨迹文件

/**
 * 保存轨迹文件信息
 * @param drivingTrackID 驾驶记录id
 * @return YES 保存成功 NO 保存失败
 */
- (BOOL)storeDrivingTrackFileWithID:(NSString *)drivingTrackID
{
    if (!drivingTrackID)
        return NO;
    
    //大于100条删除最后一条未同步的数据
    int unSyncCount = [self getUnSyncDrivingFileCount];
    
    if (unSyncCount > 100) {
        
        int trackCount = self.drivingTrackInfoArray.count;
        
        for (int i = trackCount - 1; i > 0; i--) {
            
            DrivingInfo *info = [self.drivingTrackInfoArray caObjectsAtIndex:i];
            
            if (info.optype == 1 || info.optype == 2) {
                
                if ([self delegeDrivingTrackFileWithID:info.drivingID])
                {
                    info.optype = 3;
                    break;
                }
                
                
            }
        }
    }
    
    if (self.drivingTrackFile)
    {
        self.drivingTrackFile.name = drivingTrackID;
        NSString *fileName = [NSString stringWithFormat:@"%@%@.plist",DrivingTrack_PATH,drivingTrackID];
        if ([NSKeyedArchiver archiveRootObject:self.drivingTrackFile toFile:fileName])
            return YES;
    }
    
    
    return NO;
}


/**
 * 读取轨迹文件
 * @param trackID 驾驶记录id
 * @return DrivingTracks 驾驶记录文件
 */
- (DrivingTracks *)readDrivingTrackWithID:(NSString *)trackID dataURL:(NSString *)dataURL
{
    DrivingTracks *driving = nil;
    
    if (!trackID)
    {
        return driving;
    }
    
    NSString *filePath = [NSString stringWithFormat:@"%@%@.plist",DrivingTrack_PATH,trackID];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        driving = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
    else{
        
        NSString *cutString = [NSString stringWithFormat:@"/%@",UserID_Account];
        NSString *String = [dataURL CutToNSStringBackWard:cutString];
        NSString *tmpString = [dataURL CutToNSStringBackWard:@"/"];
        NSString *drivingTrackID = @"";
        
        if (String && String.length > 0) {
            NSString *tmp = [NSString stringWithFormat:@"%@%@",String,UserID_Account];
            drivingTrackID = [dataURL CutFromNSString:tmp];
        }
        else{
            drivingTrackID = [dataURL CutFromNSString:tmpString];
        }
        
        NSString *filePathTmp = [NSString stringWithFormat:@"%@%@.plist",DrivingTrack_PATH,drivingTrackID];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePathTmp]) {
            driving = [NSKeyedUnarchiver unarchiveObjectWithFile:filePathTmp];
        }
        
        return driving;
    }
    
    return [driving autorelease];
}

/**
 * 删除轨迹文件
 * @param trackID 驾驶记录id
 * @return YES 删除成功 NO 删除失败
 */
- (BOOL)delegeDrivingTrackFileWithID:(NSString *)trackID
{
    
    BOOL res = NO;
    
    if (!trackID) {
        return res;
    }
    
    NSString *filePath = [NSString stringWithFormat:@"%@%@.plist",DrivingTrack_PATH,trackID];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        res = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    return res;
}

/**
 * 清除轨迹文件内存
 */
- (void)releaseDrivingTrackFile
{
    CRELEASE(_drivingTrackFile);
}

/**
 * 清除所有轨迹文件
 */
- (void)removeAllDrivingTrackFile
{
    for (DrivingInfo * info in self.drivingTrackInfoArray) {
        
        NSString *filePath = [NSString stringWithFormat:@"%@%@.plist",DrivingTrack_PATH,info.drivingID];
        
        if ( [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}


/**
 * 添加轨迹点－经纬度，海拔
 * @param lon 经度
 * @param lat 纬度
 * @param altitude 海拔
 */
- (void)addTrackPointWithLon:(int)lon Lat:(int)lat Altitude:(int)altitude coordType:(int)coordType
{
    
    if (!self.drivingTrackFile) {
        _drivingTrackFile = [[DrivingTracks alloc] init];
    }
    
    DCoordinate *coordinate = [[DCoordinate alloc] init];
    
    if ((lon == 0) || (lat == 0)) {
        
        GCARINFO carInfo = {0};
        [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carInfo];
        coordinate.lon = carInfo.Coord.x;
        coordinate.lat = carInfo.Coord.y;
    }
    else{
        coordinate.lon = lon;
        coordinate.lat = lat;
    }
    
    coordinate.Altitude = altitude;
    coordinate.coordType = coordType;
    
    [self.drivingTrackFile.trace.coordinates addObject:coordinate];
    
    [coordinate release];
    
}

/**
 * 添加tts－语音播报内容，经纬度，经纬度类型
 * @param coordType 经纬度类型
 * @param lon 经度
 * @param lat 纬度
 * @param ttsText 语音文本
 */
- (void)addTrackTTSWithCoordType:(int)coordType Lon:(int)lon Lat:(int)lat TTSText:(NSString *)ttsText
{
    if (!ttsText || (0 == lon) || (0 == lat))  {
        return;
    }
    
    if (!self.drivingTrackFile) {
        _drivingTrackFile = [[DrivingTracks alloc] init];
    }
    
    DTTS *ttsNode = [[DTTS alloc] init];
    ttsNode.gdCoordType = coordType;
    ttsNode.lon = lon;
    ttsNode.lat = lat;
    ttsNode.gdVoiceText = ttsText;
    
    [self.drivingTrackFile.ttsArray addObject:ttsNode];
    
    [ttsNode release];
    
}


/**
 * 添加TurnInfo-转向信息，经纬度，经纬度类型，转向id
 * @param coordType 经纬度类型
 * @param lon 经度
 * @param lat 纬度
 * @param turnid 转向id
 */
- (void)addTrackTurnInfoWithCoordType:(int)coordType Lon:(int)lon Lat:(int)lat TurnID:(int)turnid
{
    if ( (0 == lon) || (0 == lat))  {
        return;
    }
    
    if (!self.drivingTrackFile) {
        _drivingTrackFile = [[DrivingTracks alloc] init];
    }
    
    DTurnInfo *turnInfoNode = [[DTurnInfo alloc] init];
    turnInfoNode.gdCoordType = coordType;
    turnInfoNode.lon = lon;
    turnInfoNode.lat = lat;
    turnInfoNode.gdTurn = turnid;
    
    [self.drivingTrackFile.turnInfoArray addObject:turnInfoNode];
    
    [turnInfoNode release];
    
}

/**
 * 偏航信息统计
 * @param lon 经度
 * @param lat 纬度
 */
- (void)addYawInfoWithLon:(int)lon Lat:(int)lat
{
    if ( (0 == lon) || (0 == lat))  {
        return;
    }
    
    if (!self.drivingTrackFile) {
        _drivingTrackFile = [[DrivingTracks alloc] init];
    }
    if (!self.drivingTrackInfo) {
        _drivingTrackInfo = [[DrivingInfo alloc] init];
    }
    
    DCoordinate *coordinateNode = [[DCoordinate alloc] init];
    coordinateNode.lon = lon;
    coordinateNode.lat = lat;
    coordinateNode.arrayNum = (self.drivingTrackFile.yawArray.count + 1);
    
    [self.drivingTrackFile.yawArray addObject:coordinateNode];
    
    [coordinateNode release];
    
    self.drivingTrackInfo.yawCount = self.drivingTrackInfo.yawCount + 1;
   
}

/**
 * 统计轨迹信息
 * @param type 统计类型
 * @param score 得分
 */
- (void)addTrackInfoPoiWithType:(TrackCountType)type score:(double)score lon:(int)lon lat:(int)lat
{
    int mLon = lon;
    int mLat = lat;
    
    if (mLon == 0 || mLat == 0) {
        
        GCARINFO carInfo = {0};
        [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carInfo];
        
        mLon = carInfo.Coord.x;
        mLat = carInfo.Coord.y;
    }
    
    if (type == TrackCountType_Hacceleration) {
        
        
        [self addHaccelerationWithLon:mLon Lat:mLat score:score];
        
    }
    else if (type == TrackCountType_Brakes)
    {
        
        [self addBrakesWithLon:mLon Lat:mLat score:score];
        
    }
    else if (type == TrackCountType_Uturn)
    {
        
        [self addUturnWithLon:mLon Lat:mLat score:score];
        
    }
    else if (type == TrackCountType_Hypervelocity)
    {
        
        [self addHypervelocityWithLon:mLon Lat:mLat score:score];
        
    }
}

/**
 * 保存急加速信息
 * @param lon 经度
 * @param lat 纬度
 * @param score 得分
 */
- (void)addHaccelerationWithLon:(int)lon Lat:(int)lat score:(double)score
{
    if ( (0 == lon) || (0 == lat))  {
        return;
    }
    
    if (!self.drivingTrackFile) {
        _drivingTrackFile = [[DrivingTracks alloc] init];
    }
    
    DCoordinate *lastObject = [self.drivingTrackFile.haccelerationArray lastObject];
    DCoordinate *lastBrakeObject = [self.drivingTrackFile.brakesArray lastObject];
    
    if (lastObject || lastBrakeObject) {
        
        GCOORD firstCoord = {0};
        GCOORD firstBrakeCoord = {0};
        GCOORD current = {0};
        
        firstCoord.x = lastObject.lon;
        firstCoord.y = lastObject.lat;
        firstBrakeCoord.x = lastBrakeObject.lon;
        firstBrakeCoord.y = lastBrakeObject.lat;
        
        current.x = lon;
        current.y = lat;
        
         int   trackDic = [MWEngineTools CalcDistanceFrom:firstCoord To:current];
         int   brakeDic = [MWEngineTools CalcDistanceFrom:firstBrakeCoord To:current];
        if ((trackDic < 200) || (brakeDic < 100)) { //两点之间小于200米则不记录
            return;
        }
    }
    
    [self addTrackPointWithLon:_preCoord.x Lat:_preCoord.y Altitude:0 coordType:0];//添加上一个统计点，便于柱状图显示
    [self addTrackPointWithLon:lon Lat:lat Altitude:0 coordType:2]; //添加急刹车，急加油，超速，急转弯点到轨迹点中
    
    DCoordinate *coordinateNode = [[DCoordinate alloc] init];
    coordinateNode.lon = lon;
    coordinateNode.lat = lat;
    coordinateNode.Altitude = score;
    coordinateNode.arrayNum = (self.drivingTrackFile.trace.coordinates.count + 1);
    
    [self.drivingTrackFile.haccelerationArray addObject:coordinateNode];
    
    [coordinateNode release];
    
    self.drivingTrackInfo.haccelerationCount = self.drivingTrackInfo.haccelerationCount + 1;//急加油次数加1
    
}

/**
 * 保存急刹车信息
 * @param lon 经度
 * @param lat 纬度
 * @param score 得分
 */
- (void)addBrakesWithLon:(int)lon Lat:(int)lat score:(double)score
{
    if ( (0 == lon) || (0 == lat))  {
        return;
    }
    
    if (!self.drivingTrackFile) {
        _drivingTrackFile = [[DrivingTracks alloc] init];
    }
    
    DCoordinate *lastObject = [self.drivingTrackFile.brakesArray lastObject];
    DCoordinate *lastHaccObject = [self.drivingTrackFile.haccelerationArray lastObject];
    
    if (lastObject || lastHaccObject) {
        
        GCOORD firstCoord = {0};
        GCOORD firstHaccCoord = {0};
        GCOORD current = {0};
        
        firstCoord.x = lastObject.lon;
        firstCoord.y = lastObject.lat;
        firstHaccCoord.x = lastHaccObject.lon;
        firstHaccCoord.y = lastHaccObject.lat;
        
        current.x = lon;
        current.y = lat;
        
        
        int   trackDic = [MWEngineTools CalcDistanceFrom:firstCoord To:current];
        int   haccDis = [MWEngineTools CalcDistanceFrom:firstHaccCoord To:current];
        if ((trackDic < 200) || (haccDis < 100)) { //两点之间小于200米则不记录
            return;
        }
    }
    
    [self addTrackPointWithLon:_preCoord.x Lat:_preCoord.y Altitude:0 coordType:0];//添加上一个统计点，便于柱状图显示
    [self addTrackPointWithLon:lon Lat:lat Altitude:0 coordType:3]; //添加急刹车，急加油，超速，急转弯点到轨迹点中
    
    DCoordinate *coordinateNode = [[DCoordinate alloc] init];
    coordinateNode.lon = lon;
    coordinateNode.lat = lat;
    coordinateNode.Altitude = score;
    coordinateNode.arrayNum = (self.drivingTrackFile.trace.coordinates.count + 1);
    
    [self.drivingTrackFile.brakesArray addObject:coordinateNode];
    
    [coordinateNode release];
    
    self.drivingTrackInfo.brakesCount = self.drivingTrackInfo.brakesCount + 1;//急刹车次数加1
    
}

/**
 * 保存急转弯信息
 * @param lon 经度
 * @param lat 纬度
 * @param score 得分
 */
- (void)addUturnWithLon:(int)lon Lat:(int)lat score:(double)score
{
    if ( (0 == lon) || (0 == lat))  {
        return;
    }
    
    if (!self.drivingTrackFile) {
        _drivingTrackFile = [[DrivingTracks alloc] init];
    }
    
    DCoordinate *lastObject = [self.drivingTrackFile.uturnArray lastObject];
    
    if (lastObject) {
        
        GCOORD firstCoord = {0};
        GCOORD current = {0};
        
        firstCoord.x = lastObject.lon;
        firstCoord.y = lastObject.lat;
        
        current.x = lon;
        current.y = lat;
        
        int   trackDic = [MWEngineTools CalcDistanceFrom:firstCoord To:current];
        if (trackDic < 100) { //两点之间小于100米则不记录
            return;
        }
    }
    
    [self addTrackPointWithLon:lon Lat:lat Altitude:0 coordType:4]; //添加急刹车，急加油，超速，急转弯点到轨迹点中
    
    DCoordinate *coordinateNode = [[DCoordinate alloc] init];
    coordinateNode.lon = lon;
    coordinateNode.lat = lat;
    coordinateNode.Altitude = score;
    coordinateNode.arrayNum = (self.drivingTrackFile.trace.coordinates.count + 1);
    
    [self.drivingTrackFile.uturnArray addObject:coordinateNode];
    
    [coordinateNode release];
    
    self.drivingTrackInfo.uturnCount = self.drivingTrackInfo.uturnCount + 1;
   
}

/**
 * 保存超速信息
 * @param lon 经度
 * @param lat 纬度
 * @param score 得分
 */
- (void)addHypervelocityWithLon:(int)lon Lat:(int)lat score:(double)score
{
    if ( (0 == lon) || (0 == lat))  {
        return;
    }
    
    if (!self.drivingTrackFile) {
        _drivingTrackFile = [[DrivingTracks alloc] init];
    }
    
    DCoordinate *lastObject = [self.drivingTrackFile.hypervelocityArray lastObject];
    
    if (lastObject) {
        
        GCOORD firstCoord = {0};
        GCOORD current = {0};
        
        firstCoord.x = lastObject.lon;
        firstCoord.y = lastObject.lat;
        
        current.x = lon;
        current.y = lat;
        
        int   trackDic = [MWEngineTools CalcDistanceFrom:firstCoord To:current];
        if (trackDic < 400) { //两点之间小于200米则不记录
            return;
        }
    }
    
    [self addTrackPointWithLon:lon Lat:lat Altitude:0 coordType:1]; //添加急刹车，急加油，超速，急转弯点到轨迹点中
    
    DCoordinate *coordinateNode = [[DCoordinate alloc] init];
    coordinateNode.lon = lon;
    coordinateNode.lat = lat;
    coordinateNode.Altitude = score;
    coordinateNode.arrayNum = self.drivingTrackFile.trace.coordinates.count;
    
    [self.drivingTrackFile.hypervelocityArray addObject:coordinateNode];
    
    [coordinateNode release];
    
    //统计超速次数
    self.drivingTrackInfo.hypervelocityCount = self.drivingTrackInfo.hypervelocityCount + 1;
   
}

/**
 * 保存起点信息
 */
- (void)addStartPOIToTrackPOI
{

    GPOI *ppJourneyPoint = {0};
    GSTATUS res = GDBL_GetCurrentJourneyPoint(&ppJourneyPoint);
    
    if (GD_ERR_OK == res)
    {
        
        if (ppJourneyPoint[0].Coord.x != 0 || ppJourneyPoint[0].Coord.y != 0) {
            
            [self addTrackPointWithLon:ppJourneyPoint[0].Coord.x Lat:ppJourneyPoint[0].Coord.y Altitude:0 coordType:0];
            self.drivingTrackInfo.startPOI.longitude = ppJourneyPoint[0].Coord.x;
            self.drivingTrackInfo.startPOI.latitude = ppJourneyPoint[0].Coord.y;
            self.drivingTrackInfo.startPOI.szName = GcharToNSString(ppJourneyPoint[0].szName);
            
        }
    }
    else {
        
        GCARINFO carInfo = {0};
        [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carInfo];
        
        [self addTrackPointWithLon:carInfo.Coord.x Lat:carInfo.Coord.y Altitude:0.0 coordType:0];
        self.drivingTrackInfo.startPOI.longitude = carInfo.Coord.x;
        self.drivingTrackInfo.startPOI.latitude = carInfo.Coord.y;
        self.drivingTrackInfo.startPOI.szName = STR(@"Main_NoDefine", Localize_Main);
    }
}

/**
 * 保存终点信息
 */
- (void)addEndPOIToTrackPOI
{
    if (self.drivingTrackFile && self.drivingTrackFile.trace.coordinates.count > 0) {
        
        DCoordinate *coord = [self.drivingTrackFile.trace.coordinates lastObject];
        GCOORD lastCoord = {0};
        lastCoord.x = coord.lon;
        lastCoord.y = coord.lat;
        
        [poiOperator poiNearestSearchWithCoord:lastCoord];
    }
    
}

#pragma mark - 计算接口
/**
 * 速度配置项
 */
static int pvConfig[5][4] = {
    {85},
    {85,75,65,55},
    {70,60,30,20},
    {65,60,20,10},
    {60,10,0}
};

/**
 * 燃油效率低速配置项
 */
static int peConfig[] = {
    90,
    85,
    65,
    40,
    10
};

/**
 * 急加速评分配置项
 */
static int paConfig[]  = {
    90,
    87,
    84,
    81
};

/**
 * 急刹车评分配置项
 */
static int pbConfig[] = {
    90,
    87,
    84,
    81
};

/**
 * 急转弯评分配置项
 */
static int pcConfig[4][5] = {
    {95,90,85,60,40},
    {90,85,70,55,30},
    {90,85,70,30},
    {80,75,50,30}
};

/**
 * 计算轨迹总急刹车，急加油，急转弯，超速得分
 * @param type 计算类型
 */
- (double)countBeatNumWithScore:(int)score
{
    if (score > 100) {
        return 100.0;
    }
    
    int totalNum = 0;
    int beatsNum = 0;
    
    NSDictionary *array = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_ScoreDetail];
    
    
    if (array) {
        
        
        for (NSString *string in [array allKeys]) {
            
            if ([string intValue] <= score) {
                beatsNum = beatsNum + [[array objectForKey:string] intValue];
            }
            
            totalNum = [[array objectForKey:string] intValue] + totalNum;
            
        }
    }
    else{
        return (score-2)*1.0;
    }
    
    if (totalNum != 0) {
        int num = (int)(beatsNum*100/totalNum);
        return num;
    }
    return 0.0;
}

/**
 * 计算轨迹总急刹车，急加油，急转弯，超速得分
 * @param type 计算类型
 */
- (double)countScoreWithType:(TrackCountType)type
{
    double score = 100.0;
    
    if (type == TrackCountType_Hacceleration) {
        for (DCoordinate *coord in self.drivingTrackFile.haccelerationArray) {
            score = score * coord.Altitude/100.0;
        }
    }
    else if (type == TrackCountType_Brakes)
    {
        for (DCoordinate *coord in self.drivingTrackFile.brakesArray) {
            score = score * coord.Altitude/100.0;
        }
    }
    else if (type == TrackCountType_Uturn)
    {
        for (DCoordinate *coord in self.drivingTrackFile.uturnArray) {
            score = score * coord.Altitude/100.0;
        }
    }
    else if (type == TrackCountType_Hypervelocity)
    {
        for (DCoordinate *coord in self.drivingTrackFile.hypervelocityArray) {
            score = score * coord.Altitude/100.0;
        }
    }
    
    return score;
}

/**
 * 计算情绪文案（警察，省钱，开心，菜鸟，神气）
 * @param averageSpeed       平均速度
 * @param brakeCount         急刹车
 * @param haccelerationCount 急加油
 * @param hypervelocityCount 超速
 * @description  警察      省钱(都是and关系)  开心  菜鸟(都是and关系)   神气(都是and关系)
 * 平均速度               10<x<35                   <=10            >=35
 * 急刹车                  <3                       >=3              <3
 * 急加油                  <3                       >=3              <3
 * 超速           >=8      =0                      0<x<8             =0
 */
- (DrivingResultType)countMoodTextWithAverageSpeed:(double)averageSpeed brakesCount:(int)brakeCount haccelerationCount:(int)haccelerationCount hypervelocityCount:(int)hypervelocityCount
{
    DrivingResultType type = DrivingResultType_Happy;
    
    if (hypervelocityCount >= 8) { //超速大于8次为警察
        type = DrivingResultType_Police;
    }
    else if ((averageSpeed > 10) && (averageSpeed < 35) && (brakeCount < 3) && (haccelerationCount < 3) && (hypervelocityCount == 0)) //省钱
    {
        type = DrivingResultType_Economical;
    }
    else if ((averageSpeed <= 10) && (brakeCount >= 3) && (haccelerationCount >= 3) && (hypervelocityCount > 0) && (hypervelocityCount < 8))//菜鸟
    {
        type = DrivingResultType_Rookie;
    }
    else if ((averageSpeed >= 35) && (brakeCount < 3) && (haccelerationCount < 3) && (hypervelocityCount == 0)) //神气
    {
        type = DrivingResultType_Air;
    }
    else {//开心
        type = DrivingResultType_Happy;
    }
    
    return type;
}

/**
 * 获取驾驶记录对应文案
 * @param type 文案类型
 * @return NSString 文案内容
 */
- (NSString *)countMoodTextWithType:(DrivingResultType)type
{
    NSString *string = @"";
    
    if (type == DrivingResultType_Air) {
        string = STR(@"DrivingTrack_air", Localize_DrivingTrack);
    }
    else if (type == DrivingResultType_Economical)
    {
        string = STR(@"DrivingTrack_economical", Localize_DrivingTrack);
    }
    else if (type == DrivingResultType_Police)
    {
        string = STR(@"DrivingTrack_police", Localize_DrivingTrack);
    }
    else if (type == DrivingResultType_Rookie)
    {
        string = STR(@"DrivingTrack_rookie", Localize_DrivingTrack);
    }
    else if (type == DrivingResultType_Happy)
    {
        string = STR(@"DrivingTrack_happy", Localize_DrivingTrack);
    }
    
    return string;
}

/**
 * 计算超速次数和得分
 * @param ttsString 语音播报字符串
 */
- (void)countHypervelocityWithTTSString:(NSString *)ttsString
{
    if (![ANParamValue sharedInstance].isPath || [ANParamValue sharedInstance].isNavi) {
        return;
    }
    
    NSLog(@"tts:%@",ttsString);
    
    NSString *hypervelocityString = STR(@"DrivingTrack_speedWarning", Localize_DrivingTrack);
    NSString *limitString = STR(@"DrivingTrack_speedLimit", Localize_DrivingTrack);
    NSString *kmString = STR(@"DrivingTrack_kilometers", Localize_DrivingTrack);
    
    NSRange range = [ttsString rangeOfString:hypervelocityString];
    NSRange specialRange = [ttsString rangeOfString:STR(@"DrivingTrack_specialSpeedWarning", Localize_DrivingTrack)];
    if (range.length != 0 || specialRange.length != 0) {
        
        
        //统计超速得分
        float limitSpeed = 0.0f;
        int score = 0;
        GGPSINFO pGpsInfo = {0};
        GDBL_GetGPSInfo(&pGpsInfo);
        
        limitSpeed = [[ttsString CutFromNSString:limitString Tostring:kmString] floatValue];
        
        if (limitSpeed < 1.0f) {
            return;
        }
        
        score = [self countHypervelocityScoreWithMax:(limitSpeed/3.6) average:(pGpsInfo.nSpeed/3.6)];
        
        [self addTrackInfoPoiWithType:TrackCountType_Hypervelocity score:score lon:0 lat:0];
        
        
    }
    
}

/**
 * 计算急转弯次数
 * @param location gps数据
 */
- (void)countUturnWithLocation:(CLLocation *)location
{
    if (location.course < 0) {
        return;
    }
    
    if (self.locationArray.count < 5) {
        [self.locationArray addObject:location];
    }
    else if (self.locationArray.count == 5){
        
        CLLocation *firstLocation = [self.locationArray firstObject];
        CLLocation *lastLocation = [self.locationArray lastObject];
        CLLocation *twoLocation = [self.locationArray objectAtIndex:2];
        CLLocation *location1 = [self.locationArray objectAtIndex:1];
        CLLocation *location3 = [self.locationArray objectAtIndex:3];
        
        
        float degree = fabs(firstLocation.course - lastLocation.course);
        
        if (degree > 80.0f)
        { //方位角之差大于60，则判断为转弯
            
            
            if ((degree > 300.0f) && (((twoLocation.course > 0.0f) && (twoLocation.course < firstLocation.course)) || (twoLocation.course > lastLocation.course))) {
                
                [self.locationArray removeObjectAtIndex:0];
                [self.locationArray addObject:location];
                
                return;
            }
            
            GCOORD wgsFisrtCoord = {0};
            GCOORD wgsLastCoord = {0};
            GCOORD firstCoord = {0};
            GCOORD lastCoord = {0};
            
            wgsFisrtCoord.x = firstLocation.coordinate.longitude * 1000000;
            wgsFisrtCoord.y = firstLocation.coordinate.latitude * 1000000;
            wgsLastCoord.x = lastLocation.coordinate.longitude * 1000000;
            wgsLastCoord.y = lastLocation.coordinate.latitude * 1000000;
            
            firstCoord = [MWEngineTools WGSToGDCoord:wgsFisrtCoord];
            lastCoord = [MWEngineTools WGSToGDCoord:wgsLastCoord];

            
            //转弯轨迹上限制速度计算公式：R = V2/ug  u == 0.2 g == 9.8
            //float trackSpeed = [self countUturnAverageSpeedWithLength:length degree:degree];
            
            float maxSpeed = 0.0f;
            
            for (CLLocation *loc in self.locationArray) {
                if (loc.speed > maxSpeed) {
                    maxSpeed = loc.speed;
                }
            }
            
            float averageSpeed = (firstLocation.speed + location1.speed + twoLocation.speed + location3.speed + lastLocation.speed)/5.0;
            
            
            //如果5个点的最大速度大于限制速度则认为是急转弯
            if ( (firstLocation.speed > 0.0f) && (lastLocation.speed > 0.0f) && (averageSpeed > 8.3f) )
            {
                
                //统计急转弯次数和分数
                int score = [self countTurn:averageSpeed max:maxSpeed];
                
                
                [self addTrackInfoPoiWithType:TrackCountType_Uturn score:score lon:0 lat:0];
                
                [self.locationArray removeAllObjects];
            }
        }
        
        if (self.locationArray.count > 0) {
            
            [self.locationArray removeObjectAtIndex:0];
        }
        
        [self.locationArray addObject:location];
    }
    else {
        [self.locationArray removeAllObjects];
    }
}

/**
 * 计算弯道平均速度
 * @param length 起点终点距离
 * @param degree 起点终点夹角
 */
- (float)countUturnAverageSpeedWithLength:(int)length degree:(float)degree
{
    return sqrt(length*0.2*9.8/2*sin(degree/2));
}

/**
 * 计算急加油次数、急刹车次数
 * @param limit 限制速度
 * @param value 当前速度
 */
- (BOOL)countHaccelerationAndBrakeWithFirstSpeed:(double)firstSpeed lastSpeed:(double)lastSpeed time:(float)time lon:(int)lon lat:(int)lat
{
    BOOL res = NO;
    float a = 0.0f;
    a = (lastSpeed - firstSpeed)/time;
    
    int aScore = [self countAccelerationScore:a];
    int bScore = [self countBrakesScore:a];
    
    if (aScore != 100) { //急加油
        
        res = YES;
        
        [self addTrackInfoPoiWithType:TrackCountType_Hacceleration score:aScore lon:lon lat:lat];
        
    }
    if (bScore != 100) {//急刹车
        
        res = YES;
        
        [self addTrackInfoPoiWithType:TrackCountType_Brakes score:bScore lon:lon lat:lat];
        
    }
    
    return res;
}

/**
 * 计算超过比例的函数
 * @param limit 限制速度
 * @param value 当前速度
 */
- (float)countRatioWithLimit:(float)limit currentSpeed:(float)value{
    return  abs(value-limit)/limit;
}

/**
 * 计算超速得分
 * @param max 限制速度
 ＊@param average 当前速度
 */
- (int)countHypervelocityScoreWithMax:(float)max average:(float)average
{
    int score = 100;
    float radio = [self countRatioWithLimit:max currentSpeed:average];
    max = max*3.6f;
    average = average*3.6f;
    if(radio>0&&radio<=0.1){
        score = pvConfig[0][0];
    }else if(max<=50){
        if(radio>0.1&&radio<=0.2){
            score = pvConfig[1][0];
        }else if(radio>0.2&&radio<=0.5){
            score = pvConfig[1][1];
        }else if(radio>0.5&&radio<=0.7){
            score = pvConfig[1][2];
        }else{
            score = pvConfig[1][3];
        }
    }else if(max>50&&max<=80){
        if(radio>0.1&&radio<=0.2){
            score = pvConfig[2][0];
        }else if(radio>0.2&&radio<=0.5){
            score = pvConfig[2][1];
        }else if(radio>0.5&&radio<=0.7){
            score = pvConfig[2][2];
        }else{
            score = pvConfig[2][3];
        }
    }else if(max>80&&max<=100){
        if(radio>0.1&&radio<=0.2){
            score = pvConfig[3][0];
        }else if(radio>0.2&&radio<=0.5){
            score = pvConfig[3][1];
        }else if(radio>0.5&&radio<=0.7){
            score = pvConfig[3][2];
        }else{
            score = pvConfig[3][3];
        }
    }else if(max>100){
        if(radio>0.1&&radio<=0.5){
            score = pvConfig[4][0];
        }else if(radio>0.5&&radio<=0.7){
            score = pvConfig[4][1];
        }else{
            score = pvConfig[4][2];
        }
    }
    return score;
}

/**
 * 计算加速度所在范围的得分
 * @param  value 加速度
 * @return
 */
- (int)countAccelerationScore:(float)value
{
    int s = 100;
    if(value>2.1&&value<=3){
        s = paConfig[0];
    }else if(value>3&&value<=4){
        s = paConfig[1];
    }else if(value>4&&value<=5){
        s = paConfig[2];
    }else if(value>5){
        s = paConfig[3];
    }
    return s;
}

/**
 * 计算刹车加速度所在范围的得分
 * @param value 刹车加速度
 * @return
 */
- (int)countBrakesScore:(float)value{
    
    int s = 100;
    if(value>=-3&&value<-2.5){
        s = pbConfig[0];
    }else if(value>=-4&&value<-3){
        s = pbConfig[1];
    }else if(value>=-5&&value<-4){
        s = pbConfig[2];
    }else if(value<-5){
        s = pbConfig[3];
    }
    return s;
}

/**
 * 计算转弯速度所在范围的得分
 * @param maxspeed      本次转弯的最大速度
 * @param curve_speed   弯道的限制速度
 */
- (int)countTurn:(float)curve_speed max:(float)max{
    float v = curve_speed;
    
    int score = 100;
    float mv = v*3.6f;
    if(max > v){
        float radio = [self countRatioWithLimit:v currentSpeed:max];
        if(mv>0&&mv<=20){
            if(radio>0&&radio<=0.1){
                score = pcConfig[0][0];
            }else if(radio>0.1&&radio<=0.2){
                score = pcConfig[0][1];
            }else if(radio>0.2&&radio<=0.5){
                score = pcConfig[0][2];
            }else if(radio>0.5&&radio<=0.7){
                score = pcConfig[0][3];
            }else{
                score = pcConfig[0][4];
            }
        }else if(mv>20&&mv<=40){
            if(radio>0&&radio<=0.1){
                score = pcConfig[1][0];
            }else if(radio>0.1&&radio<=0.2){
                score = pcConfig[1][1];
            }else if(radio>0.2&&radio<=0.5){
                score = pcConfig[1][2];
            }else if(radio>0.5&&radio<=0.7){
                score = pcConfig[1][3];
            }else{
                score = pcConfig[1][4];
            }
        }else if(mv>40&&mv<=60){
            if(radio>0&&radio<=0.1){
                score = pcConfig[2][0];
            }else if(radio>0.1&&radio<=0.2){
                score = pcConfig[2][1];
            }else if(radio>0.2&&radio<=0.5){
                score = pcConfig[2][2];
            }else{
                score = pcConfig[2][3];
            }
        }else{
            if(radio>0&&radio<=0.1){
                score = pcConfig[3][0];
            }else if(radio>0.1&&radio<=0.2){
                score = pcConfig[3][1];
            }else if(radio>0.2&&radio<=0.5){
                score = pcConfig[3][2];
            }else{
                score = pcConfig[3][3];
            }
        }
    }
    return score;
}

/**
 * 计算总里程 (单位： km)
 * @param dis
 * @return
 */
- (double)countTotalDistanceWithDis:(int)dis
{
    return floor(dis/100)/10;
}

/**
 * 计算平均速度 (单位： km/h)
 * @param totalDis
 * @param startTime
 * @return
 */
- (double)countAverageSpeedWithTotalDis:(int)totalDis totalTime:(int)totalTime
{
    
    if (totalTime == 0) {
        return 1.0;
    }
    
    double averageSpeed = floor((totalDis*1.0f)/(totalTime*60.0f)*3.6f);
    
    if (averageSpeed < 0.1f) {
        averageSpeed = 0.1;
    }
    
    return averageSpeed;
}

/**
 * 计算油耗得分
 * @param haccelerationScore         急加速得分
 * @param brakesScore                急刹车得分
 * @param fuelEfficiencyScore        燃油效率得分
 * @return
 */
- (double)countFuelConsumptionWithHaccelerationScore:(double)haccelerationScore brakesScore:(double)brakesScore fuelEfficiencyScore:(double)fuelEfficiencyScore
{
    return floor(0.3*haccelerationScore+0.3*brakesScore+0.4*fuelEfficiencyScore);
}

/**
 * 计算安全得分
 * @param hypervelocityScore        超速得分
 * @param haccelerationScore        急加速得分
 * @param brakesScore               急刹车得分
 * @param uturnScore                急转弯得分
 * @return
 */
- (double)countSafeScoreWithHypervelocityScore:(double)hypervelocityScore
                            haccelerationScore:(double)haccelerationScore
                                   brakesScore:(double)brakesScore
                                    uturnScore:(double)uturnScore
{
    return floor(0.2*brakesScore+0.2*haccelerationScore+0.4*hypervelocityScore+0.2*uturnScore);
}

/**
 * 计算驾驶得分
 * @param safeScore    安全得分
 * @param fuelConsumptionScore    油耗得分
 * @return
 */
- (double)countTotalScoreWithSafeScore:(double)safeScore fuelConsumption:(double)fuelConsumptionScore
{
    return floor(safeScore*0.6+fuelConsumptionScore*0.4);
}

/**
 * 计算选手等级
 * @param drivingScore    驾驶得分
 * @return
 */
- (float)countLevelWithDrivingScore:(double)drivingScore
{
    float starLevel = 0;
    //long  r = round(random()*10)%2;
    if(drivingScore<45){
        starLevel = 1;
    }else if(drivingScore>=45&&drivingScore<50){
        starLevel = 1.5f;
    }else if(drivingScore>=50&&drivingScore<58){
        starLevel = 2;
    }else if(drivingScore>=58&&drivingScore<66){
        starLevel = 2.5f;
    }else if(drivingScore>=66&&drivingScore<74){
        starLevel = 3;
    }else if(drivingScore>=74&&drivingScore<81){
        starLevel = 3.5f;
    }else if(drivingScore>=81&&drivingScore<88){
        starLevel = 4;
    }else if(drivingScore>=88&&drivingScore<95){
        starLevel = 4.5f;
    }else if(drivingScore>=95){
        starLevel = 5;
    }
    
    return starLevel;
}

/**
 * 计算驾驶时间
 * @param startTime
 * @return
 */
- (int)countDrivingTimeWithStartTime:(NSString *)startTime
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date1 = [formatter dateFromString:startTime];
    NSDate *date2 = [NSDate date];
    int  min = [date2 timeIntervalSinceDate:date1];
    
    [formatter release];
    
    if (min < 60) {
        return 1;
    }
    return min/60;
}

- (void)dealloc
{
    
    [super dealloc];
}

#pragma mark - poi附近点
/*!
 @brief 当前点最近的POI点查询回调函数
 @param coord 发起POI查询的查询选项(具体字段参考GCOORD类中的定义)
 @param result 查询结果(具体字段参考MWPoi类中的定义)
 */
-(void)poiNearestSearch:(GCOORD)coord Poi:(MWPoi *)poi
{
    
    self.drivingTrackInfo.desPOI.szName = [NSString stringWithFormat:STR(@"Main_NearBy", Localize_Main),poi.szName];

    GMAPCENTERINFO mapCenter = {0};
    GHMAPVIEW phMapView;
    GDBL_GetMapViewHandle(GMAP_VIEW_TYPE_MAIN, &phMapView);
    GDBL_GetMapViewCenterInfo(phMapView, &mapCenter);
    
    GROADINFO pRoadInfo = {0};
    GDBL_GetRoadInfoByCoord(&coord, &pRoadInfo);
    
    if (coord.x == mapCenter.CenterCoord.x && coord.y == mapCenter.CenterCoord.y && pRoadInfo.nDistance < poi.lDistance) {
        
        self.drivingTrackInfo.desPOI.szName = [NSString stringWithFormat:STR(@"Main_NearBy", Localize_Main),[NSString chinaFontStringWithCString:mapCenter.szRoadName]];
        
    }
    
    if ([self.drivingTrackInfo.startPOI.szName length] < 1) {
        self.drivingTrackInfo.startPOI.szName = STR(@"Main_NoDefine", Localize_Main);
    }
    
    self.drivingTrackInfo.name = [NSString stringWithFormat:@"%@-%@",self.drivingTrackInfo.startPOI.szName,self.drivingTrackInfo.desPOI.szName];
    
    //添加轨迹属性
    [self addDrivingTrackInfo];
    
}

/*!
 @brief 通知查询成功或失败的回调函数
 @param poiOperatorOption 发起查询的查询选项
 @param errCode 错误码 \n
 */
-(void)search:(id)poiOperatorOption Error:(NSError *)error
{
    //点击车位获取附近点详情弹出框
    MWSearchOption *poiInfo = (MWSearchOption *)poiOperatorOption;
    if (poiInfo.longitude == 0 || poiInfo.latitude == 0)
    {
        //添加轨迹属性
        [self addDrivingTrackInfo];
        return;
    }
    GCOORD pcoord ={0};
    pcoord.x = poiInfo.longitude;
    pcoord.y = poiInfo.latitude;
    if ([MWAdminCode  checkIsExistDataWithCoord:pcoord] == 0 )
    {
        //添加轨迹属性
        [self addDrivingTrackInfo];
        return;
    }
    GCOORD pcood={0};
    pcood.x = poiInfo.longitude;
    pcood.y = poiInfo.latitude;
    MWAreaInfo * info = [MWAdminCode GetCurAdareaWith:[MWAdminCode GetAdminCode:pcood]];
    int adminCode =[MWAdminCode GetAdminCode:pcood];
    NSString * cityName = [MWAdminCode GetCityNameWithAdminCode:adminCode];
    NSString *townName = @"";
    if (info.szTownName && [info.szTownName length] > 0)
    {
        townName = info.szTownName;
    }
    NSString *poiName;
    if(cityName.length > 0 || townName.length > 0)
    {
        poiName = [NSString stringWithFormat:@"%@%@",cityName,townName];
    }
    else
    {
        poiName = @"";
    }
    if (poiName && [poiName length] > 0)
    {
        self.drivingTrackInfo.desPOI.szName = poiName;
    }
    else
    {
        self.drivingTrackInfo.desPOI.szName = STR(@"Main_unNameRoad", Localize_Main);
    }
    
    if ([self.drivingTrackInfo.startPOI.szName length] < 1) {
        self.drivingTrackInfo.startPOI.szName = STR(@"Main_NoDefine", Localize_Main);
    }
    
    self.drivingTrackInfo.name = [NSString stringWithFormat:@"%@-%@",self.drivingTrackInfo.startPOI.szName,self.drivingTrackInfo.desPOI.szName];
    
    //添加轨迹属性
    [self addDrivingTrackInfo];
}

#pragma mark -轨迹记录网络接口－轨迹同步，分享，轨迹文件下载

/*!
 @brief 驾驶记录同步，驾驶记录分享地址
 @param type 请求类型
 @param pageIndex 同步页数索引
 @param pageCount 同步下发个数
 @param trackInfo 轨迹信息
 */
- (void)drivingTrackRequestWithType:(RequestType)type pageIndex:(Byte)pageIndex pageCount:(Byte)pageCount drivingTrack:(DrivingInfo *)trackInfo
{
    [self modifyAccount];
    
    NSMutableDictionary *urlParams = [[NSMutableDictionary alloc] init];
    [urlParams setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kNetRequestStringBoundary] forKey:@"Content-Type"];
    [urlParams setValue:VendorID forKey:@"imei"];
    [urlParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [urlParams setValue:MapVersionNoV forKey:@"mapversion"];
    [urlParams setValue:deviceModel forKey:@"model"];
    [urlParams setValue:DeviceResolutionString forKey:@"resolution"];
    [urlParams setValue:CurrentSystemVersion forKey:@"os"];
    [urlParams setValue:UserID_Account forKey:@"userid"];
    [urlParams setValue:KNetChannelID forKey:@"syscode"];
    [urlParams setValue:PID forKey:@"pid"];
    if (type == RT_DrivingTrackSyncRequest) {
        NSString *signString = [[NSString stringWithFormat:@"%@%@@%@",KNetChannelID,UserID_Account,kNetSignKey] stringFromMD5];
        [urlParams setValue:signString forKey:@"sign"];
    }
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    
    condition.requestType = type;
    condition.httpHeaderFieldParams = urlParams;
    
    if (type == RT_DrivingTrackSyncRequest) {
        condition.httpMethod = @"POST";
        condition.bodyData = [self getBodyDataStringWithRequestType:RT_DrivingTrackSyncRequest pageIndex:pageIndex pageCount:pageCount];
        condition.urlParams = nil;
        condition.baceURL = KDrivingTrackSyncURL;
    }
    else if (type == RT_DrivingTrackShareRequest) {
        
        double topSpeed = (trackInfo.higherSpeed > 0) ? trackInfo.higherSpeed : 0.0;
        
        NSMutableDictionary *longUrlDic = [[NSMutableDictionary alloc] init];
        [longUrlDic setValue:[NSNumber numberWithInt:trackInfo.beatNum] forKeyPath:@"winscore"];
        [longUrlDic setValue:[NSNumber numberWithDouble:trackInfo.trackScore] forKeyPath:@"score"];
        [longUrlDic setValue:[NSString stringWithFormat:@"%.1f",trackInfo.trackLength/1000.0] forKeyPath:@"distence"];
        [longUrlDic setValue:[NSNumber numberWithInt:trackInfo.trackTimeConsuming] forKeyPath:@"duration"];
        [longUrlDic setValue:[NSString stringWithFormat:@"%.0f",trackInfo.averageSpeed] forKeyPath:@"avaspeed"];
        [longUrlDic setValue:[NSString stringWithFormat:@"%.0f",topSpeed] forKeyPath:@"maxspeed"];
        [longUrlDic setValue:[NSNumber numberWithDouble:trackInfo.fuelConsumption] forKeyPath:@"gas"];
        [longUrlDic setValue:[NSNumber numberWithDouble:trackInfo.safetyScore] forKeyPath:@"safety"];
        [longUrlDic setValue:[NSNumber numberWithInt:trackInfo.haccelerationCount] forKeyPath:@"hgas"];
        [longUrlDic setValue:[NSNumber numberWithInt:trackInfo.brakesCount] forKeyPath:@"hbreak"];
        [longUrlDic setValue:[NSNumber numberWithInt:trackInfo.uturnCount] forKeyPath:@"hturn"];
        [longUrlDic setValue:[NSNumber numberWithInt:trackInfo.hypervelocityCount] forKeyPath:@"hspeed"];
        
        NSString *longURL = [NetRequestExt serializeURL:kDrivingTrackLongURL params:longUrlDic httpMethod:@"GET"];
        
        [longUrlDic release];
        
        NSString *sign = [[NSString stringWithFormat:@"%@%@@%@",KNetChannelID,[ThreeDes encrypt:longURL],kNetSignKey] stringFromMD5];
        NSMutableDictionary *urlDic = [[NSMutableDictionary alloc] init];
        [urlDic setValue:KNetChannelID forKey:@"syscode"];
        [urlDic setValue:[ThreeDes encrypt:longURL] forKey:@"longurl"];
        [urlDic setValue:sign forKey:@"sign"];
        
        condition.httpMethod = @"GET";
        condition.bodyData = nil;
        condition.urlParams = urlDic;
        condition.baceURL = KDrivingTrackShareURL;
        
        [urlDic release];
    }
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [urlParams release];
}

- (void)drivingTrackFileDownloadWithURL:(NSString *)trackFileURL
{
    NSMutableDictionary *urlParams = [[NSMutableDictionary alloc] init];
    [urlParams setValue:VendorID forKey:@"imei"];
    [urlParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [urlParams setValue:MapVersionNoV forKey:@"mapversion"];
    [urlParams setValue:deviceModel forKey:@"model"];
    [urlParams setValue:DeviceResolutionString forKey:@"resolution"];
    [urlParams setValue:CurrentSystemVersion forKey:@"os"];
    [urlParams setValue:UserID_Account forKey:@"userid"];
    [urlParams setValue:KNetChannelID forKey:@"syscode"];
    [urlParams setValue:PID forKey:@"pid"];
    
    NSString *signString = [[NSString stringWithFormat:@"%@%@@%@",KNetChannelID,UserID_Account,kNetSignKey] stringFromMD5];
    [urlParams setValue:signString forKey:@"sign"];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.requestType = RT_DrivingTrackDownload;
    condition.httpHeaderFieldParams = urlParams;
    condition.httpMethod = @"GET";
    condition.bodyData = nil;
    condition.urlParams = nil;
    condition.baceURL = trackFileURL;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [urlParams release];
}

#pragma mark -private Method
- (NSData *)getBodyDataStringWithRequestType:(RequestType)type pageIndex:(Byte)pageIndex pageCount:(Byte)pageCount
{
    NSMutableData *postData = [[NSMutableData alloc] init];
    
    if (type == RT_DrivingTrackSyncRequest) {
        
        Byte protversion = 102; //协议版本号,当前协议版本 102
        Byte needdata = 1;       //是否需要下发同步后的结果列表 0 不需要 ,1 需要
        Byte comprassflag = 0;   //数据是否压缩,压缩方式 gzip 0 不压缩 ,1 压缩
        int trackInfoCount = [self getPostDrivingTrackInfoCount]; //同步条目的数量
        Byte mtrackInfoCountByte = (Byte)trackInfoCount;
        
        char * protversionByte = malloc(1);
        memset(protversionByte,0,1);
        memcpy(protversionByte, &protversion, sizeof(Byte));
        
        char * needdataByte = malloc(1);
        memset(needdataByte,0,1);
        memcpy(needdataByte, &needdata, sizeof(Byte));
        
        char * comprassflagByte = malloc(1);
        memset(comprassflagByte,0,1);
        memcpy(comprassflagByte, &comprassflag, sizeof(Byte));
        
        char * pageIndexByte = malloc(1);
        memset(pageIndexByte,0,1);
        memcpy(pageIndexByte, &pageIndex, sizeof(Byte));
        
        char * pageCountByte = malloc(1);
        memset(pageCountByte,0,1);
        memcpy(pageCountByte, &pageCount, sizeof(Byte));
        
        char * trackInfoCountByte = malloc(1);
        memset(trackInfoCountByte,0,1);
        memcpy(trackInfoCountByte, &mtrackInfoCountByte, sizeof(Byte));
        
        
        [postData appendBytes:protversionByte length:1];
        [postData appendBytes:needdataByte length:1];
        [postData appendBytes:pageCountByte length:1];
        [postData appendBytes:pageIndexByte length:1];
        [postData appendBytes:trackInfoCountByte length:1];
        
        
        if (trackInfoCount > 0) {
            
            NSMutableArray *trackInfoArray = [self getUnSyncDrivingInfoList];
            
            if (trackInfoArray) {
                
                for (DrivingInfo *drivingInfo in trackInfoArray) {
                    
                    if ([drivingInfo.userID isEqualToString:UserID_Account])
                    {
                        if (drivingInfo.higherSpeed <= 0.0) {
                            drivingInfo.higherSpeed = -1;
                        }
                        
                        NSString *idString = [NSString stringWithFormat:@"%@%@",UserID_Account,drivingInfo.drivingID];
                        NSMutableDictionary *drivingInfoDic = [[NSMutableDictionary alloc] init];
                        [drivingInfoDic setValue:idString forKey:@"id"];
                        [drivingInfoDic setValue:[NSNumber numberWithInt:drivingInfo.optype] forKey:@"optype"];
                        [drivingInfoDic setValue:(drivingInfo.name ? drivingInfo.name : @"unDefined") forKey:@"name"];
                        [drivingInfoDic setValue:[NSNumber numberWithInt:drivingInfo.trackLength] forKey:@"length"];
                        [drivingInfoDic setValue:[NSNumber numberWithDouble:drivingInfo.trackScore] forKey:@"score"];
                        [drivingInfoDic setValue:[NSNumber numberWithInt:drivingInfo.trackTimeConsuming] forKey:@"time"];
                        [drivingInfoDic setValue:[NSNumber numberWithDouble:drivingInfo.averageSpeed] forKey:@"avgspeed"];
                        [drivingInfoDic setValue:[NSNumber numberWithDouble:drivingInfo.higherSpeed] forKey:@"topspeed"];
                        [drivingInfoDic setValue:[NSNumber numberWithDouble:drivingInfo.fuelConsumption] forKey:@"oil"];
                        [drivingInfoDic setValue:[NSNumber numberWithDouble:drivingInfo.safetyScore] forKey:@"safe"];
                        [drivingInfoDic setValue:[NSNumber numberWithInt:drivingInfo.haccelerationCount] forKey:@"accelerator"];
                        [drivingInfoDic setValue:[NSNumber numberWithInt:drivingInfo.brakesCount] forKey:@"brake"];
                        [drivingInfoDic setValue:[NSNumber numberWithInt:drivingInfo.uturnCount] forKey:@"turning"];
                        [drivingInfoDic setValue:[NSNumber numberWithInt:drivingInfo.hypervelocityCount] forKey:@"speedlimit"];
                        [drivingInfoDic setValue:drivingInfo.dataType forKey:@"datatype"];
                        [drivingInfoDic setValue:drivingInfo.creatTime forKey:@"createtime"];
                        [drivingInfoDic setValue:drivingInfo.updateTime forKey:@"updatetime"];
                        
                        NSString *jsonString = [drivingInfoDic JSONRepresentation];
                        
                        NSLog(@"驾驶记录同步：%@",jsonString);
                        
                        [drivingInfoDic release];
                        
                        if (jsonString) {
                            
                            int length = [jsonString dataUsingEncoding:NSUTF8StringEncoding].length;
                            
                            char * lengthByte = malloc(4);
                            memset(lengthByte,0,4);
                            
                            for( int i = 0; i < 4; i++ ){
                                lengthByte[i] = (Byte)(length >> ( 24 - i*8 ));
                            }
                            
                            // memcpy(lengthByte, &length, 4);
                            
                            
                            [postData appendBytes:lengthByte length:4];
                            [postData appendBytes:[[jsonString dataUsingEncoding:NSUTF8StringEncoding] bytes] length:length];
                            
                            free(lengthByte);
                        }
                        
                        Byte hasData = 0;
                        DrivingTracks *track = [self readDrivingTrackWithID:drivingInfo.drivingID dataURL:drivingInfo.dataURL];
                        if (track) {
                            
                            hasData = 1;
                            
                        }
                        
                        char * hasDataByte = malloc(1);
                        memset(hasDataByte,0,1);
                        memcpy(hasDataByte, &hasData, 1);
                        
                        [postData appendBytes:hasDataByte length:1];
                        
                        free(hasDataByte);
                        
                        if (hasData) {
                            
                            [postData appendBytes:comprassflagByte length:1];
                            
                            NSString *trackFileString = [self changeToKmlWithTrack:track];
                            
                            if (trackFileString) {
                                
                                int trackFileStringLength = trackFileString.length;
                                
                                char * trackFileStringLengthByte = malloc(4);
                                memset(trackFileStringLengthByte,0,4);
                                
                                for( int i = 0; i < 4; i++ ){
                                    trackFileStringLengthByte[i] = (Byte)(trackFileStringLength >> ( 24 - i*8 ));
                                }
                                //memcpy(trackFileStringLengthByte, &trackFileStringLength, 4);
                                
                                [postData appendBytes:trackFileStringLengthByte  length:4];
                                
                                [postData appendBytes:[[trackFileString dataUsingEncoding:NSUTF8StringEncoding] bytes] length:trackFileString.length];
                                
                                free(trackFileStringLengthByte);
                            }
                            
                            
                        }
                    }
                }
            }
            
        }
        
        free(protversionByte);
        free(needdataByte);
        free(comprassflagByte);
        free(pageIndexByte);
        free(pageCountByte);
        free(trackInfoCountByte);
        
    }
    
    return [postData autorelease];
}

- (int)getPostDrivingTrackInfoCount
{
    
    int trackCount = 0;
    NSMutableArray *trackInfoArray = [self getUnSyncDrivingInfoList];
    trackCount = trackInfoArray.count;
    
    return trackCount;
}

- (NSString *)changeToKmlWithTrack:(DrivingTracks *)driveTrack {
    
    NSString *_kmlStr = nil;
    DrivingTracks *_driveTrack = [driveTrack retain];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (_driveTrack) {
        
        DDXMLElement* elementKml = [DDXMLElement elementWithName:@"kml"];
        
        [elementKml addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://www.opengis.net/kml/2.2"]];
        
        DDXMLElement* apkversion = [DDXMLElement elementWithName: @"apkversion"];
        [apkversion setStringValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE]];
        [elementKml addChild:apkversion];
        
        DDXMLElement* mapversion = [DDXMLElement elementWithName: @"mapversion"];
        [mapversion setStringValue:MapVersionNoV];
        [elementKml addChild:mapversion];
        
        DDXMLElement* syscode = [DDXMLElement elementWithName: @"syscode"];
        [syscode setStringValue:KNetChannelID];
        [elementKml addChild:syscode];
        
        //add by hlf for 双平台统一，新增平台类型字段
        DDXMLElement* system_type = [DDXMLElement elementWithName: @"system_type"];
        [system_type setStringValue:@"1"];//0-android 1-iOS
        [elementKml addChild:system_type];
        
        DDXMLElement* versionCode = [DDXMLElement elementWithName: @"versionCode"];
        [versionCode setStringValue:@"5"];//modi by hlf for 升级协议版本，双平台统一协议
        [elementKml addChild:versionCode];
        
        DDXMLElement* document = [DDXMLElement elementWithName: @"Document"];
        
        DDXMLElement* name = [DDXMLElement elementWithName: @"name"];
        [name setStringValue:_driveTrack.name];
        [document addChild:name];
        
        DDXMLElement* description = [DDXMLElement elementWithName: @"description"];
        [description setStringValue:@"no desc"];
        [document addChild:description];
        
        DDXMLElement* placemark = [DDXMLElement elementWithName:@"Placemark"];
        
        DDXMLElement* tname = [DDXMLElement elementWithName:@"name"];
        [tname setStringValue:@"Trace"];
        [placemark addChild:tname];
        
        DDXMLElement* gDCoordType = [DDXMLElement  elementWithName:@"GDCoordType"];
        [gDCoordType setStringValue:_driveTrack.trace.gdCoordType];
        [placemark addChild:gDCoordType];
        
        DDXMLElement* tdescription = [DDXMLElement elementWithName:@"description"];
        [tdescription setStringValue:_driveTrack.trace.mDescription];
        [placemark addChild:tdescription];
        
        DDXMLElement* LineString = [DDXMLElement elementWithName:@"LineString"];
        DDXMLElement* altitudeMode = [DDXMLElement elementWithName:@"altitudeMode"];
        [altitudeMode setStringValue:_driveTrack.trace.altitudeMode];
        [LineString addChild:altitudeMode];
        
        
        int count = _driveTrack.trace.coordinates.count;
        NSMutableString *string = [[NSMutableString alloc] init];
        
        for ( int i = 0 ; i< count ; i++) {
            DCoordinate *coord = [_driveTrack.trace.coordinates caObjectsAtIndex:i];
            
            if (i == (count - 1)) {
                [string appendFormat:@"%d,%d,%d",coord.lon,coord.lat,coord.Altitude];
            }
            else {
                [string appendFormat:@"%d,%d,%d\n",coord.lon,coord.lat,coord.Altitude];//modi by hlf for 双平台统一，回车
            }
        }
        
        DDXMLElement* coordinates = [DDXMLElement elementWithName:@"coordinates"];
        [coordinates setStringValue:string];
        [LineString addChild:coordinates];
        
        [string release];
        
        [placemark addChild:LineString];
        [document addChild:placemark];
        
        DDXMLElement* specialPlacemark = [DDXMLElement elementWithName:@"Placemark"];
        
        DDXMLElement* specialName = [DDXMLElement elementWithName:@"name"];
        [specialName setStringValue:@"Special_Path"];
        [specialPlacemark addChild:specialName];
        
        
        
        NSMutableString *specialString = [[NSMutableString alloc] init];
        
        for (DCoordinate *sCoord in _driveTrack.hypervelocityArray) {
            [specialString appendFormat:@"1,%d\n",sCoord.arrayNum];
        }
        for (DCoordinate *sCoord in _driveTrack.haccelerationArray) {
            [specialString appendFormat:@"2,%d\n",sCoord.arrayNum];
        }
        for (DCoordinate *sCoord in _driveTrack.brakesArray) {
            [specialString appendFormat:@"3,%d\n",sCoord.arrayNum];
        }
        for (DCoordinate *sCoord in _driveTrack.uturnArray) {
            [specialString appendFormat:@"4,%d\n",sCoord.arrayNum];
        }
        for (DCoordinate *sCoord in _driveTrack.yawArray) {
            [specialString appendFormat:@"5,%d\n",sCoord.arrayNum];
        }
        
        DDXMLElement* SpecialPath = [DDXMLElement elementWithName:@"SpecialPath"];
        [SpecialPath setStringValue:specialString];
        [specialPlacemark addChild:SpecialPath];
        
        [specialString release];
        
        [document addChild:specialPlacemark];
        
        [elementKml addChild:document];
        
        _kmlStr = [[NSString alloc] initWithFormat:@"%@",[elementKml XMLString]];
        
        [pool release];
    }
    
    NSLog(@"kml:%@",_kmlStr);
    return [_kmlStr autorelease];
}

- (void)modifyAccount
{
    int count = self.drivingTrackInfoArray.count;
    
    for (int i = 0; i < count; i++) {
        
        DrivingInfo *drivingInfo = [self.drivingTrackInfoArray caObjectsAtIndex:i];
        
        if ([drivingInfo.userID isEqualToString:@""]) {
            
            drivingInfo.userID = UserID_Account;
        }
        
    }
    
}

- (void)parseRequestData:(id)data
{
    @synchronized(_drivingTrackInfoArray)
    {
        if (!data) {
            return;
        }
        
        [self removeAllDrivingTrackFile];
        
        NSMutableArray *trackArray = [self getAllDrivingInfoList];
        
        id item = [data objectForKey:@"item"];
        
        if ([item isKindOfClass:[NSDictionary class]]) {
            
            DrivingInfo *info = [[DrivingInfo alloc] init];
            
            info.drivingID = [item objectForKey:@"createtime"];
            info.name = [item objectForKey:@"name"];
            info.trackLength = [[item objectForKey:@"length"] intValue];
            info.trackScore = [[item objectForKey:@"score"] doubleValue];
            info.trackTimeConsuming = [[item objectForKey:@"time"] intValue];
            info.averageSpeed = [[item objectForKey:@"avgspeed"] doubleValue];
            info.higherSpeed = [[item objectForKey:@"topspeed"] doubleValue];
            info.fuelConsumption = [[item objectForKey:@"oil"] doubleValue];
            info.safetyScore = [[item objectForKey:@"safe"] doubleValue];
            info.haccelerationCount = [[item objectForKey:@"accelerator"] intValue];
            info.brakesCount = [[item objectForKey:@"brake"] intValue];
            info.uturnCount = [[item objectForKey:@"turning"] intValue];
            info.hypervelocityCount = [[item objectForKey:@"speedlimit"] intValue];
            info.dataType = [item objectForKey:@"datatype"];
            info.isComprass = [[item objectForKey:@"iscomprass"] intValue];
            info.dataURL = [item objectForKey:@"dataurl"];
            info.creatTime = [item objectForKey:@"createtime"];
            info.updateTime = [item objectForKey:@"updatetime"];
            info.optype = 0;
            info.userID = UserID_Account;
            info.resultType = [self countMoodTextWithAverageSpeed:info.averageSpeed brakesCount:info.brakesCount haccelerationCount:info.haccelerationCount hypervelocityCount:info.hypervelocityCount];
            
            BOOL same = NO;
            
            int count = self.drivingTrackInfoArray.count;
            
            for (int i = 0 ; i < count; i++) {
                
                DrivingInfo *tInfo = [self.drivingTrackInfoArray caObjectsAtIndex:i];
                
                if ([info.drivingID isEqualToString:tInfo.drivingID]) {
                    
                    tInfo.name = info.name;
                    tInfo.creatTime = info.creatTime;
                    tInfo.updateTime = info.updateTime;
                    tInfo.dataURL = info.dataURL;
                    tInfo.isComprass = info.isComprass;
                    //modify by gzm for userID不要赋值，tInfo.userID = info.userID;，防止复制出的数据又成了统一帐号的 at 2014-11-13
                    same = YES;
                }
            }
            
            if (!same) {
                
                [trackArray addObject:info];
            }
            
            
            [info release];
            
        }
        else if ([item isKindOfClass:[NSArray class]]){
            
            for (NSDictionary *dic in item) {
                
                DrivingInfo *info = [[DrivingInfo alloc] init];
                
                info.drivingID = [dic objectForKey:@"createtime"];//唯一id跟cteatetime一样
                info.name = [dic objectForKey:@"name"];
                info.trackLength = [[dic objectForKey:@"length"] intValue];
                info.trackScore = [[dic objectForKey:@"score"] doubleValue];
                info.trackTimeConsuming = [[dic objectForKey:@"time"] intValue];
                info.averageSpeed = [[dic objectForKey:@"avgspeed"] doubleValue];
                info.higherSpeed = [[dic objectForKey:@"topspeed"] doubleValue];
                info.fuelConsumption = [[dic objectForKey:@"oil"] doubleValue];
                info.safetyScore = [[dic objectForKey:@"safe"] doubleValue];
                info.haccelerationCount = [[dic objectForKey:@"accelerator"] intValue];
                info.brakesCount = [[dic objectForKey:@"brake"] intValue];
                info.uturnCount = [[dic objectForKey:@"turning"] intValue];
                info.hypervelocityCount = [[dic objectForKey:@"speedlimit"] intValue];
                info.dataType = [dic objectForKey:@"datatype"];
                info.isComprass = [[dic objectForKey:@"iscomprass"] intValue];
                info.dataURL = [dic objectForKey:@"dataurl"];
                info.creatTime = [dic objectForKey:@"createtime"];
                info.updateTime = [dic objectForKey:@"updatetime"];
                info.optype = 0;
                info.userID = UserID_Account;
                info.resultType = [self countMoodTextWithAverageSpeed:info.averageSpeed brakesCount:info.brakesCount haccelerationCount:info.haccelerationCount hypervelocityCount:info.hypervelocityCount];
                
                BOOL same = NO;
                
                int count = self.drivingTrackInfoArray.count;
                
                for (int i = 0 ; i < count; i++) {
                    
                    DrivingInfo *tInfo = [self.drivingTrackInfoArray caObjectsAtIndex:i];
                    
                    if ([info.drivingID isEqualToString:tInfo.drivingID]) {
                        
                        tInfo.name = info.name;
                        tInfo.creatTime = info.creatTime;
                        tInfo.updateTime = info.updateTime;
                        tInfo.dataURL = info.dataURL;
                        tInfo.isComprass = info.isComprass;
                        //modify by gzm for userID不要赋值，tInfo.userID = info.userID;，防止复制出的数据又成了统一帐号的 at 2014-11-13
                        same = YES;
                    }
                }
                
                if (!same) {
                    
                    [trackArray addObject:info];
                }
                
                [info release];
            }
        }
        
        [self setOPType]; //设置同步标示
        [self removePostAndSyncAndDeleteTrack];//清空删除并且同步过，并且得分已经上传的记录
        
        [self storeDrivingTrackInfo];
    }
}

- (BOOL)parseKMLData:(id)data withBaceURL:(NSString *)baceUrl
{
    if (!data) {
        
        if ([_delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
        {
            [_delegate requestToViewCtrWithRequestType:RT_DrivingTrackDownload didFailWithError:nil];
        }
        return NO;
    }
    
    NSString *tmp = [[[NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    NSLog(@"驾驶记录文件：%@",tmp);
    
    NSDictionary *dic = [NSDictionary dictionaryWithXMLData:data];
    if (dic) {
        
        DrivingTracks *track = [[DrivingTracks alloc] init];
        
        
        NSDictionary *document = [dic objectForKey:@"Document"];
        if (document) {
            
            track.name = [document objectForKey:@"name"];
            
            id placeMark = [document objectForKey:@"Placemark"];
            
            if ([placeMark isKindOfClass:[NSArray class]]) {
                
                NSDictionary *traceDic = [placeMark caObjectsAtIndex:0];
                NSDictionary *specialDic = [placeMark caObjectsAtIndex:1];
                
                if (traceDic) {
                    NSDictionary *lineString = [traceDic objectForKey:@"LineString"];
                    
                    if (lineString) {
                        
                        NSString *coordinatesString = [lineString objectForKey:@"coordinates"];
                        
                        if (coordinatesString) {
                            
                            NSString *versionCode = [dic objectForKey:@"versionCode"];
                            if (versionCode && [versionCode intValue] == 5) {//双平台统一协议
                                
                                
                                    NSArray *androidCoordinatesArray = [coordinatesString componentsSeparatedByString:@"\n"];
                                    if (androidCoordinatesArray) {
                                        //解析记录点
                                        for (NSString *tmp in androidCoordinatesArray) {
                                            
                                            NSArray *tmpArray = [tmp componentsSeparatedByString:@","];
                                            
                                            if (tmpArray) {
                                                
                                                DCoordinate *tmpCoord = [[DCoordinate alloc] init];
                                                tmpCoord.lon = [[tmpArray caObjectsAtIndex:0] intValue];
                                                tmpCoord.lat = [[tmpArray caObjectsAtIndex:1] intValue];
                                                tmpCoord.Altitude = [[tmpArray caObjectsAtIndex:2] doubleValue];
                                                
                                                [track.trace.coordinates addObject:tmpCoord];
                                                [tmpCoord release];
                                                
                                            }
                                            
                                        }
                                        //解析特殊点
                                        
                                        if (specialDic) {
                                            
                                            NSString *specialString = [specialDic objectForKey:@"SpecialPath"];
                                            if (specialString) {
                                                NSArray *specialArray = [specialString componentsSeparatedByString:@"\n"];
                                                if (specialArray) {
                                                    for (NSString *specialS in specialArray) {
                                                        NSArray *tmpArray = [specialS componentsSeparatedByString:@","];
                                                        if (tmpArray) {
                                                            
                                                            int type = [[tmpArray caObjectsAtIndex:0] intValue];
                                                            int num = ([[tmpArray caObjectsAtIndex:1] intValue] - 1);
                                                            if (num < 0) {
                                                                num = 0;
                                                            }
                                                            
                                                            DCoordinate *stmp = [track.trace.coordinates caObjectsAtIndex:num];
                                                            
                                                            if (stmp) {
                                                                
                                                                stmp.arrayNum = num + 1;
                                                                stmp.coordType = type;
                                                                
                                                                if (type == 1) {
                                                                    
                                                                    [track.hypervelocityArray addObject:stmp];
                                                                    
                                                                }
                                                                else if (type == 2)
                                                                {
                                                                    
                                                                    [track.haccelerationArray addObject:stmp];
                                                                }
                                                                else if (type == 3)
                                                                {
                                                                    
                                                                    [track.brakesArray addObject:stmp];
                                                                }
                                                                else if (type == 4)
                                                                {
                                                                    
                                                                    [track.uturnArray addObject:stmp];
                                                                }
                                                                else if (type == 5)
                                                                {
                                                                    
                                                                    [track.yawArray addObject:stmp];
                                                                }
                                                                
                                                            }
                                                            
                                                            
                                                            
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                
                            }
                            else
                            {
                                //modi by hlf for android平台是用回车来分隔每个点，因此用空格去解析只会返回一个，所以根据解析的数组个数来区分是要用空格解析还是用回车符来解析 at 2014.11.11
                                NSArray *coordinatesArray = [coordinatesString componentsSeparatedByString:@" "];
                                
                                if (coordinatesArray && coordinatesArray.count > 1) {
                                    //解析记录点
                                    for (NSString *tmp in coordinatesArray) {
                                        
                                        NSArray *tmpArray = [tmp componentsSeparatedByString:@","];
                                        
                                        if (tmpArray) {
                                            
                                            DCoordinate *tmpCoord = [[DCoordinate alloc] init];
                                            tmpCoord.lon = [[tmpArray caObjectsAtIndex:0] intValue];
                                            tmpCoord.lat = [[tmpArray caObjectsAtIndex:1] intValue];
                                            tmpCoord.Altitude = [[tmpArray caObjectsAtIndex:2] doubleValue];
                                            
                                            [track.trace.coordinates addObject:tmpCoord];
                                            [tmpCoord release];
                                            
                                        }
                                        
                                    }
                                    //解析特殊点
                                    
                                    if (specialDic) {
                                        
                                        NSString *specialString = [specialDic objectForKey:@"SpecialPath"];
                                        if (specialString) {
                                            NSArray *specialArray = [specialString componentsSeparatedByString:@" "];
                                            if (specialArray) {
                                                for (NSString *specialS in specialArray) {
                                                    NSArray *tmpArray = [specialS componentsSeparatedByString:@","];
                                                    if (tmpArray) {
                                                        
                                                        int type = [[tmpArray caObjectsAtIndex:0] intValue];
                                                        int num = ([[tmpArray caObjectsAtIndex:1] intValue] - 1);
                                                        if (num < 0) {
                                                            num = 0;
                                                        }
                                                        
                                                        DCoordinate *stmp = [track.trace.coordinates caObjectsAtIndex:num];
                                                        
                                                        if (stmp) {
                                                            
                                                            stmp.arrayNum = num + 1;
                                                            stmp.coordType = type;
                                                            
                                                            if (type == 1) {
                                                                
                                                                [track.hypervelocityArray addObject:stmp];
                                                                
                                                            }
                                                            else if (type == 2)
                                                            {
                                                                
                                                                [track.haccelerationArray addObject:stmp];
                                                            }
                                                            else if (type == 3)
                                                            {
                                                                
                                                                [track.brakesArray addObject:stmp];
                                                            }
                                                            else if (type == 4)
                                                            {
                                                                
                                                                [track.uturnArray addObject:stmp];
                                                            }
                                                            else if (type == 5)
                                                            {
                                                                
                                                                [track.yawArray addObject:stmp];
                                                            }
                                                            
                                                        }
                                                        
                                                        
                                                        
                                                        
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                else {
                                    
                                    NSArray *androidCoordinatesArray = [coordinatesString componentsSeparatedByString:@"\n"];
                                    if (androidCoordinatesArray) {
                                        //解析记录点
                                        for (NSString *tmp in androidCoordinatesArray) {
                                            
                                            NSArray *tmpArray = [tmp componentsSeparatedByString:@","];
                                            
                                            if (tmpArray) {
                                                
                                                DCoordinate *tmpCoord = [[DCoordinate alloc] init];
                                                tmpCoord.lon = [[tmpArray caObjectsAtIndex:0] intValue];
                                                tmpCoord.lat = [[tmpArray caObjectsAtIndex:1] intValue];
                                                tmpCoord.Altitude = [[tmpArray caObjectsAtIndex:2] doubleValue];
                                                
                                                [track.trace.coordinates addObject:tmpCoord];
                                                [tmpCoord release];
                                                
                                            }
                                            
                                        }
                                        //解析特殊点
                                        
                                        if (specialDic) {
                                            
                                            NSString *specialString = [specialDic objectForKey:@"SpecialPath"];
                                            if (specialString) {
                                                NSArray *specialArray = [specialString componentsSeparatedByString:@"\n"];
                                                if (specialArray) {
                                                    for (NSString *specialS in specialArray) {
                                                        NSArray *tmpArray = [specialS componentsSeparatedByString:@","];
                                                        if (tmpArray) {
                                                            
                                                            int type = [[tmpArray caObjectsAtIndex:0] intValue];
                                                            int num = ([[tmpArray caObjectsAtIndex:1] intValue] - 1);
                                                            if (num < 0) {
                                                                num = 0;
                                                            }
                                                            
                                                            DCoordinate *stmp = [track.trace.coordinates caObjectsAtIndex:num];
                                                            
                                                            if (stmp) {
                                                                
                                                                stmp.arrayNum = num + 1;
                                                                stmp.coordType = type;
                                                                
                                                                if (type == 1) {
                                                                    
                                                                    [track.hypervelocityArray addObject:stmp];
                                                                    
                                                                }
                                                                else if (type == 2)
                                                                {
                                                                    
                                                                    [track.haccelerationArray addObject:stmp];
                                                                }
                                                                else if (type == 3)
                                                                {
                                                                    
                                                                    [track.brakesArray addObject:stmp];
                                                                }
                                                                else if (type == 4)
                                                                {
                                                                    
                                                                    [track.uturnArray addObject:stmp];
                                                                }
                                                                else if (type == 5)
                                                                {
                                                                    
                                                                    [track.yawArray addObject:stmp];
                                                                }
                                                                
                                                            }
                                                            
                                                            
                                                            
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            
                        }
                        
                    }
                }
                
            }
            
        }
        
        NSString *cutString = [NSString stringWithFormat:@"/%@",UserID_Account];
        NSString *String = [baceUrl CutToNSStringBackWard:cutString];
        NSString *tmpString = [baceUrl CutToNSStringBackWard:@"/"];
        NSString *drivingTrackID = @"";
        
        if (String.length > 0) {
            NSString *tmp = [NSString stringWithFormat:@"%@%@",String,UserID_Account];
            drivingTrackID = [baceUrl CutFromNSString:tmp];
        }
        else{
            drivingTrackID = [baceUrl CutFromNSString:tmpString];
        }
        
        NSString *fileName = [NSString stringWithFormat:@"%@%@.plist",DrivingTrack_PATH,drivingTrackID];
        [NSKeyedArchiver archiveRootObject:track toFile:fileName];
        
        [track release];
        
    }
    
    return YES;
    
}

#pragma mark - 历史路线同步接口

- (void)historyRouteSync
{
    NSString *postSting = [self getXMLString];
    
    NSString *signString = [[NSString stringWithFormat:@"%@%@@%@",KNetChannelID,UserID_Account,kNetSignKey] stringFromMD5];
    NSMutableDictionary *urlParams = [[NSMutableDictionary alloc] init];
    [urlParams setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kNetRequestStringBoundary] forKey:@"Content-Type"];
    [urlParams setValue:VendorID forKey:@"imei"];
    [urlParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [urlParams setValue:MapVersionNoV forKey:@"mapversion"];
    [urlParams setValue:deviceModel forKey:@"model"];
    [urlParams setValue:CurrentSystemVersion forKey:@"os"];
    [urlParams setValue:UserID_Account forKey:@"userid"];
    [urlParams setValue:KNetChannelID forKey:@"syscode"];
    [urlParams setValue:PID forKey:@"pid"];
    [urlParams setValue:signString forKey:@"sign"];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    
    condition.requestType = RT_HistoryRouteSync;
    condition.httpMethod = @"POST";
    condition.urlParams = nil;
    
    condition.bodyData = [postSting dataUsingEncoding:NSUTF8StringEncoding];
    condition.httpHeaderFieldParams = urlParams;
    condition.baceURL = KHistoryRouteSyncURL;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [urlParams release];
}

- (NSString *)getXMLString
{
    
    [self historyModifyAccount];
    
    NSString *_xmlString = nil;
    NSArray *historyRouteArray = [[MWHistoryRoute sharedInstance] MW_GetSyncUserGuideRouteList];
    
    if (!historyRouteArray) {
        return nil;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddhhmmss"];
    NSString *dateString = [formatter stringFromDate: [NSDate date]];
    [formatter release];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    
    DDXMLElement*  opg = [DDXMLElement elementWithName: @"opg"];
    
    DDXMLElement*  activitycode = [DDXMLElement elementWithName: @"activitycode"];
    [activitycode setStringValue:@"0001"];
    [opg addChild:activitycode];
    
    DDXMLElement*  processtime =[DDXMLElement elementWithName: @"processtime"];
    [processtime setStringValue:dateString];
    [opg addChild:processtime];
    
    DDXMLElement*  actioncode =[DDXMLElement elementWithName: @"actioncode"];
    [actioncode setStringValue:@"0"];
    [opg addChild:actioncode];
    
    DDXMLElement*  version =[DDXMLElement elementWithName: @"version"];
    [version setStringValue:@"0"];
    [opg addChild:version];
    
    DDXMLElement*  svccont = [DDXMLElement elementWithName: @"svccont"];
    
    
    NSString *listString = [NSString stringWithFormat:@"%d",historyRouteArray.count];
    
    DDXMLNode *attribute = [DDXMLDocument attributeWithName:@"size" stringValue:listString];
    DDXMLElement*  list = [DDXMLElement elementWithName:@"list"];
    [list setAttributes:[NSArray arrayWithObjects:attribute, nil]];
    
    for (MWPathPOI *mData in historyRouteArray) {
        if([mData.userID isEqual:UserID_Account])
        {
            DDXMLElement*  road = [DDXMLElement elementWithName: @"road"];
            
            
            DDXMLElement*  userid = [DDXMLElement elementWithName: @"id"];
            [userid setStringValue:mData.serviceID];
            [road addChild:userid];
            
            DDXMLElement*  oprtimeElement = [DDXMLElement elementWithName: @"oprtime"];
            [oprtimeElement setStringValue:mData.operateTime];
            [road addChild:oprtimeElement];
            
            DDXMLElement*  oprtypeElement = [DDXMLElement elementWithName: @"oprtype"];
            [oprtypeElement setStringValue:[NSString stringWithFormat:@"%d",mData.operate]];
            [road addChild:oprtypeElement];
            
            DDXMLElement*  routetypeElement = [DDXMLElement elementWithName: @"routetype"];
            [routetypeElement setStringValue:[NSString stringWithFormat:@"%d",mData.rule]];
            [road addChild:routetypeElement];
            
            DDXMLElement*  nameElement = [DDXMLElement elementWithName: @"name"];
            [nameElement setStringValue:[NSString stringWithFormat:@"<![CDATA[%@]]>",mData.name]];
            [road addChild:nameElement];
            
            NSMutableDictionary *contentDic = [[NSMutableDictionary alloc] init];
            
            NSMutableArray *contentArray = [[NSMutableArray alloc] init];
            
            for (MWPoi *poi in mData.poiArray) {
                
                NSMutableDictionary *poiDic = [[NSMutableDictionary alloc] init];
                
                [poiDic setValue:poi.szName forKey:@"name"];
                [poiDic setValue:[NSString stringWithFormat:@"%ld",poi.longitude] forKey:@"x"];
                [poiDic setValue:[NSString stringWithFormat:@"%ld",poi.latitude] forKey:@"y"];
                [poiDic setValue:[NSString stringWithFormat:@"%d",poi.lNaviLon] forKey:@"offset_x"];
                [poiDic setValue:[NSString stringWithFormat:@"%d",poi.lNaviLat] forKey:@"offset_y"];
                
                [contentArray addObject:poiDic];
                
                [poiDic release];
            }
            
            [contentDic setValue:contentArray forKey:@"poilist"];
            [contentArray release];
            
            NSString *jsonString = [contentDic JSONRepresentation];
            
            [contentDic release];
            
            DDXMLElement*  contentElement = [DDXMLElement elementWithName: @"content"];
            [contentElement setStringValue:[NSString stringWithFormat:@"<![CDATA[%@]]>",jsonString]];
            [road addChild:contentElement];
            
            [list addChild:road];
        }
    }
    
    [svccont addChild:list];
    [opg addChild:svccont];
    
    
    _xmlString = [[NSString alloc]initWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\" ?>%@",[opg XMLString]];
    [pool drain];
    
    NSString *temp = [[_xmlString stringByReplacingOccurrencesOfString:@"]]&gt;" withString:@"]]>"]
                      stringByReplacingOccurrencesOfString:@"&lt;![CDATA" withString:@"<![CDATA"];
    
    [_xmlString release];
    NSLog(@"历史路线xml:%@",temp);
    
    return temp;
}

//如果历史路线保存账号字段为空，则把当前账号赋给它
- (void)historyModifyAccount
{
    NSMutableArray *historyRouteArray = [[MWHistoryRoute sharedInstance] MW_GetGuideRouteList];
    
    int historyCount = historyRouteArray.count;
    
    for (int i = 0; i < historyCount; i ++ ) {
        MWPathPOI *tmilData = [historyRouteArray caObjectsAtIndex:i];
        if ([tmilData.userID isEqualToString:@""]) {
            tmilData.userID = UserID_Account;
        }
    }
    
}

- (void)responseHandleWithDic:(NSDictionary *)dic
{
    if (!dic) {
        return;
    }
    
    if ([[dic objectForKey:@"isreplace"] intValue] == 1) {//需要替换本地数据
        
        [[MWHistoryRoute sharedInstance] MW_RemoveDiskAllGuideRoute];//清空本地数据
        
        NSDictionary *tempDic = [dic objectForKey:@"list"];
        id object = [tempDic objectForKey:@"road"];
        
        NSArray *roadArray = nil;
        if ([object isKindOfClass:[NSDictionary class]])
        {
            roadArray = [NSArray arrayWithObjects:object, nil];
        }
        else
        {
            roadArray = object;
        }
        if (roadArray && roadArray.count > 0) {
            
            for (NSDictionary *roadDic in roadArray) {
                
                MWPathPOI *pathPOI = [[MWPathPOI alloc] init];
                pathPOI.userID = UserID_Account;
                pathPOI.serviceID = [roadDic objectForKey:@"id"];
                pathPOI.operate = [[roadDic objectForKey:@"oprtype"] intValue];
                pathPOI.operateTime = [roadDic objectForKey:@"oprtime"];
                pathPOI.rule = [[roadDic objectForKey:@"routetype"] intValue];
                pathPOI.name = [roadDic objectForKey:@"name"];
                
                
                NSData* aData = [[roadDic objectForKey:@"content"] dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *requestDic = [NSJSONSerialization
                                            
                                            JSONObjectWithData:aData
                                            
                                            options:NSJSONReadingMutableLeaves
                                            
                                            error:nil];
                
                NSArray *poiArray = [requestDic objectForKey:@"poilist"];
                
                if (poiArray) {
                    
                    for (NSDictionary *poiDic in poiArray) {
                        
                        MWPoi *poi = [[MWPoi alloc] init];
                        poi.szName = [poiDic objectForKey:@"name"];
                        poi.longitude = [[poiDic objectForKey:@"x"] intValue];
                        poi.latitude = [[poiDic objectForKey:@"y"] intValue];
                        poi.lNaviLon = [[poiDic objectForKey:@"offset_x"] intValue];
                        poi.lNaviLat = [[poiDic objectForKey:@"offset_y"] intValue];
                        
                        [pathPOI.poiArray addObject:poi];
                        
                        [poi release];
                    }
                }
                
                [[MWHistoryRoute sharedInstance] MW_AddGuideRouteWithPathPOI:pathPOI];
                
                [pathPOI release];
            }
            
            [[MWHistoryRoute sharedInstance] storeRoute];
        }
        
    }
}

#pragma mark - 请求回调
/*!
  @brief 请求应答成功回调
  */
- (void)request:(NetRequestExt *)request didFinishLoadingWithData:(NSData *)data
{
    if (data && [data length])
    {
        if (request.requestCondition.requestType == RT_DrivingTrackDownload) {
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                
                [self parseKMLData:data withBaceURL:request.requestCondition.baceURL];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if ([_delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)])
                    {
                        [_delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFinishLoadingWithResult:nil];
                    }
                    
                });
            });
            
            
            return;
        }
        
        if (request.requestCondition.requestType == RT_HistoryRouteSync) {
            
            NSDictionary *requestDic = [NSDictionary dictionaryWithXMLData:data];
            
            if (requestDic) {
                
                NSDictionary *responseDic = [requestDic objectForKey:@"response"];
                
                if (responseDic && [[responseDic objectForKey:@"rspcode"] isEqualToString:@"0000"])
                {
                    
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(queue, ^{
                        
                        [self responseHandleWithDic:[requestDic objectForKey:@"svccont"]];
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            if ([_historyDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)])
                            {
                                [_historyDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFinishLoadingWithResult:nil];
                            }
                        });
                    });
                    
                    
                }
                else {
                    if ([_historyDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
                    {
                        [_historyDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
                    }
                }
                
                
                
                
            }
            else{
                
                if ([_historyDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
                {
                    [_historyDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
                }
            }
        
        return;
        
        }
        
        NSString *tmp = [[[NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        
        NSLog(@"驾驶记录同步结果：%@",tmp);
        
        NSDictionary *requestDic = [NSJSONSerialization
                                    
                                    JSONObjectWithData:data
                                    
                                    options:NSJSONReadingMutableLeaves
                                    
                                    error:nil];
        
        if (requestDic) {
            
            NSDictionary *responseDic = [requestDic objectForKey:@"response"];
            
            if (responseDic && [[responseDic objectForKey:@"rspcode"] isEqualToString:@"0000"])
            {
                NSDictionary *svccont = [requestDic objectForKey:@"svccont"];
                
                if (RT_DrivingTrackSyncRequest == request.requestCondition.requestType) {
                    
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(queue, ^{
                        
                        [self parseRequestData:svccont];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([_delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)])
                            {
                                [_delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFinishLoadingWithResult:nil];
                            }
                        });
                    });
                }
                else if (RT_DrivingTrackShareRequest == request.requestCondition.requestType){
                    NSDictionary *svccount = [requestDic objectForKey:@"svccount"];
                    
                    if (svccount && [svccount objectForKey:@"shorturl"]) {
                        self.shareText = [svccount objectForKey:@"shorturl"];
                    }
                    
                    
                    if ([_delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)])
                    {
                        [_delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFinishLoadingWithResult:nil];
                    }
                    
                    
                }
                
            }
            else {
                if ([_delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
                {
                    [_delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
                }
            }
            
            
            
            
        }
        else{
            
            if ([_delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
            {
                [_delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
            }
        }
    }
    else {
        
        if (request.requestCondition.requestType == RT_HistoryRouteSync) {
            if ([_historyDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
            {
                [_historyDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
            }
            
        }
        else {
            if ([_delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
            {
                [_delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
            }
        }
        
    }
}
/*!
  @brief 请求失败回调
  */
- (void)request:(NetRequestExt *)request didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError..........");
    
    if (request.requestCondition.requestType == RT_HistoryRouteSync) {
        
        if ([_historyDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
        {
            [_historyDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:error];
        }
    }
    else{
        if ([_delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
        {
            [_delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:error];
        }
    }
	
    
}
@end
