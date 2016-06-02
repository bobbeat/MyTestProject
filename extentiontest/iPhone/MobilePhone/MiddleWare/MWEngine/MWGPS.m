//
//  MWGPS.m
//  AutoNavi
//
//  Created by gaozhimin on 14-5-7.
//
//

#import "MWGPS.h"
#import <sys/time.h>

static NSTimer *g_hmiGpsTimer = nil;   //gps回放计时器
static FILE *g_hmiGpsFile = NULL;     //gos回放文件指针
static BOOL g_stopReplayGPS = NO;

@interface MWGPS()<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    BOOL  _bLocation;   //是否已经定位
}

@property (nonatomic,assign) id<MyCLControllerDelegate> locationDelegate;

@end

@implementation MWGPS

@synthesize locationDelegate;

static MWGPS *g_mwgps = nil;
/**
 **********************************************************************
 \brief 启动定位模块
 \details 启动定位模块
 **********************************************************************/
+ (void)StartUpWithDelegate:(id<MyCLControllerDelegate>)delegate
{
    if (g_mwgps == nil)
    {
        g_mwgps = [[MWGPS alloc] init];
    }
    [g_mwgps startUpdateLocation];
    g_mwgps.locationDelegate = delegate;
}

/**
 **********************************************************************
 \brief 关闭定位模块
 \details 关闭定位模块
 **********************************************************************/
+ (void)CleanUp
{
    [g_mwgps stopUpdateLocation];
}

/**********************************************************************
 * 函数名称: Heading_Startup
 * 功能描述: 启动电子罗盘
 * 输入参数:
 * 输出参数:
 * 返 回 值:
 * 其它说明:
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/3/26		1.0			廖宇
 **********************************************************************/
+(void)HeadingStartup
{
    [g_mwgps startUpdateHeading];
}

/**********************************************************************
 * 函数名称: Heading_Cleanup
 * 功能描述: 关闭电子罗盘
 * 输入参数:
 * 输出参数:
 * 返 回 值:
 * 其它说明:
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/3/26		1.0			廖宇
 **********************************************************************/
+(void)HeadingCleanup
{
    [g_mwgps stopUpdateHeading];
}

/**
 **********************************************************************
 \brief 后台定位处理
 \details 后台定位处理
 **********************************************************************/
+ (void)backgroundLocationHandle
{
    [g_mwgps adjustFilter];
}

/**********************************************************************
 \brief 获取GPS信息
 \details 获取当前GPS基本信息。
 \param[out]  pGpsInfo 结构体GGPSINFO指针，用于返回GPS基本信息
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_FAILED	操作失败
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetGPSInfo:(GGPSINFO *)pGpsInfo
{
    return GDBL_GetGPSInfo(pGpsInfo);
}

/**
 **********************************************************************
 \brief 获取卫星信息
 \details 获取当前卫星基本信息。
 \param[in]  pSatellite 结构体GSATELLITEINFO指针，用于返回卫星基本信息
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_FAILED	操作失败
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetSatelliteInfo:(GSATELLITEINFO *)pSatellite
{
    return GDBL_GetSatelliteInfo(pSatellite);
}

#pragma mark -
#pragma mark 私有方法及系统定位回调

- (instancetype)init
{
    self = [super init];
    if (self) {
        locationManager = [[CLLocationManager alloc] init] ;
		locationManager.delegate = self;
        
        //ios8授权机制，改方法：授权使应用在前台后台都能使用定位服务
        if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        {
            [locationManager requestAlwaysAuthorization];
        }
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(didBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object: nil];
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timer:) userInfo:nil repeats:YES];
    }
    return self;
}

-(void)startUpdateLocation
{
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
}

-(void)stopUpdateLocation
{
    [locationManager stopUpdatingLocation];
}

-(void)startUpdateHeading
{
    locationManager.headingFilter = 6.0; //modify by gzm for 引擎设置的灵敏度为5度，导航中的角度必须大于引擎的灵敏度（不能等于） at 2014-7-25
    [locationManager startUpdatingHeading];
}

-(void)stopUpdateHeading
{
    [locationManager stopUpdatingHeading];
}

/*
 调节定位精度
 */
- (void)adjustFilter
{
    if (isEngineInit != 1)
    {
        return;
    }
    int isPath = 0;
    GDBL_GetParam(G_GUIDE_STATUS, &isPath); //有路径下 提升定位精度

    BOOL isBackNavi = [[MWPreference sharedInstance] getValue:PREF_BACKGROUND_NAVI]; //关闭后台导航时，不需要提升定位精度
    if (!isPath || !isBackNavi)
    {
        [locationManager stopUpdatingLocation];
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        locationManager.distanceFilter = 10.0;
        [locationManager startUpdatingLocation];
    }
    else{
        [locationManager stopUpdatingLocation];
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        locationManager.distanceFilter = 1.0;
        [locationManager startUpdatingLocation];
    }
    //电子罗盘
    int e_compass = 0;
    GDBL_GetParam(G_DISABLE_ECOMPASS, &e_compass);
    if (!e_compass) {
        [self stopUpdateHeading];
    }
}

- (void)willResignActiveNotification:(NSNotification *)notification
{
    [self adjustFilter];
}
- (void)didBecomeActiveNotification:(NSNotification *)notification
{
    [self stopUpdateLocation];
    [self startUpdateLocation];
    if (isEngineInit != 1) {
        return;
    }
    int e_compass = 0;
    GDBL_GetParam(G_DISABLE_ECOMPASS, &e_compass);
    if (!e_compass) {
        [self startUpdateHeading];
    }
}

/*
 * @brief 车标变色容错，20秒内未定位，则设置gps信息为无效
 */
- (void)timer:(NSTimer *)timer
{
    static int count = 0;
    if (_bLocation)
    {
        _bLocation = NO;
        count = 0;
    }
    else
    {
        count ++;
        if (count == 20)
        {
            if (isEngineInit != 1)  //未初始化不能调用引擎接口
            {
                return;
            }
            Guint64 t;
            struct timeval tv_begin;
            gettimeofday(&tv_begin, NULL);
            t = (Guint64)1000000 * (tv_begin.tv_sec) + tv_begin.tv_usec;
            Guint32 time = (Guint32)(t / 1000);
            
            GGPSSTATUS gpsStatus = {0};
            gpsStatus.euDataType = GLOC_DATA_TYPE_GPS_STATUS;
            gpsStatus.nTickTime = time;
            gpsStatus.cStatus = 'V';// A：有效，V：无效
            GDBL_SetLocData(GLOC_DATA_TYPE_GPS_STATUS, &gpsStatus, sizeof(GGPSSTATUS));
        }
    }
}

#if PROJECTMODE

+ (void)saveGPSInfo:(CLLocation *)location time:(Guint32)time
{
    if (g_hmiGpsTimer) //回放GPS信号，则return
    {
        return;
    }
    NSString *date = nil;
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
	date = [dateFormatter stringFromDate:location.timestamp];
    static  NSString *firstPath = nil;
    if (firstPath == nil)
    {
        NSError *myError;
        NSDictionary *DirectoryAttrib = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLong:0777UL] forKey:NSFilePosixPermissions];
        NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/GPSINFO"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:DirectoryAttrib error:&myError];
        }
        firstPath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/GPSINFO/%@.txt",date] retain];
    }
    FILE *f = fopen([firstPath UTF8String], "at");
    if (f)
    {
        NSString *gpsInfo = [NSString stringWithFormat:@"%f %f %f %f %f",location.coordinate.longitude,location.coordinate.latitude,location.course,location.speed,location.altitude];
        fprintf(f, "%s %u\n",[gpsInfo UTF8String],time);
        fclose(f);
    }
}

/**
 **********************************************************************
 \brief 回放gps信号信号
 **********************************************************************/
+ (GSTATUS)replay_HMI_GPS
{
    if (g_hmiGpsFile == NULL)
    {
        g_hmiGpsFile = fopen([[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/GPSINFO/gps.txt"] UTF8String], "r");
        [g_mwgps hmiGpsReplayUseTime];
    }
    if (g_hmiGpsFile)
    {
        fseek(g_hmiGpsFile, 0, SEEK_SET);
    }
    return GD_ERR_OK;
}

/**
 **********************************************************************
 \brief 停止回放gps信号信号
 **********************************************************************/
+ (GSTATUS)stop_replay_HMI_GPS
{
    if (g_hmiGpsTimer)
    {
        [g_hmiGpsTimer invalidate];
        g_hmiGpsTimer = nil;
    }
    if (g_hmiGpsFile)
    {
        fclose(g_hmiGpsFile);
        g_hmiGpsFile = NULL;
    }
    g_stopReplayGPS = YES;
    return GD_ERR_OK;
}

- (void)hmiGpsReplayUseTime
{
    BOOL bUseTime = NO;  //是否使用时间搓
    if (bUseTime)
    {
        if (g_stopReplayGPS)
        {
            g_stopReplayGPS = NO;
            return;
        }
        static long long last_timeInterval = -1;
        if (g_hmiGpsFile) {
            CLLocationDegrees lon = 0;
            CLLocationDegrees lat = 0;
            CLLocationDistance altitude = 0;
            CLLocationDirection course = 0;
            CLLocationSpeed speed = 0;
            long long timeInterval = 0;
            fscanf(g_hmiGpsFile, "%lf%lf%lf%lf%lf%lld",&lon,&lat,&course,&speed,&altitude,&timeInterval);
            if (lon == 0 && lat == 0)
            {
                fclose(g_hmiGpsFile);
                g_hmiGpsFile = NULL;
                return;
            }
//            printf("%lf，%lf，%lf，%lf，%lf，%lld\n",lon,lat,course,speed,altitude,timeInterval);
            CLLocationCoordinate2D coordinate = {0};
            coordinate.longitude = lon;
            coordinate.latitude = lat;
            NSDate *data = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            CLLocation *newlocation = [[CLLocation alloc] initWithCoordinate:coordinate altitude:altitude horizontalAccuracy:0 verticalAccuracy:0 course:course speed:speed timestamp:data];
            
            if (last_timeInterval != -1)
            {
                double delayInSeconds = (double)abs(timeInterval - last_timeInterval)/1000.0;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self GDLocationManager:nil didUpdateLocations:newlocation fromLocation:nil];
                    [newlocation release];
                    [self hmiGpsReplayUseTime];
                });
            }
            else
            {
                last_timeInterval = timeInterval;
                [self GDLocationManager:nil didUpdateLocations:newlocation fromLocation:nil];
                [newlocation release];
                [self hmiGpsReplayUseTime];
            }
            last_timeInterval = timeInterval;
        }
    }
    else
    {
        if (g_hmiGpsTimer == nil) {
            g_hmiGpsTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hmiGpsReplay:) userInfo:nil repeats:YES];
        }
    }
    
}

- (void)hmiGpsReplay:(NSTimer *)timer
{
    if (g_hmiGpsFile) {
        CLLocationDegrees lon = 0;
        CLLocationDegrees lat = 0;
        CLLocationDistance altitude = 0;
        CLLocationDirection course = 0;
        CLLocationSpeed speed = 0;
        long long timeInterval = 0;
        fscanf(g_hmiGpsFile, "%lf%lf%lf%lf%lf%lld",&lon,&lat,&course,&speed,&altitude,&timeInterval);
        if (lon == 0 && lat == 0)
        {
            fseek(g_hmiGpsFile, 0, SEEK_SET);
            fscanf(g_hmiGpsFile, "%lf%lf%lf%lf%lf%lld",&lon,&lat,&course,&speed,&altitude,&timeInterval);
        }
//        printf("%lf，%lf，%lf，%lf，%lf，%lld\n",lon,lat,course,speed,altitude,timeInterval);
        CLLocationCoordinate2D coordinate = {0};
        coordinate.longitude = lon;
        coordinate.latitude = lat;
        NSDate *data = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        CLLocation *newlocation = [[CLLocation alloc] initWithCoordinate:coordinate altitude:altitude horizontalAccuracy:0 verticalAccuracy:0 course:course speed:speed timestamp:data];
        [self GDLocationManager:nil didUpdateLocations:newlocation fromLocation:nil];
        [newlocation release];
    }
    else
    {
        if (g_hmiGpsTimer)
        {
            [g_hmiGpsTimer invalidate];
            g_hmiGpsTimer = nil;
        }
    }
}

#endif

#pragma mark -
#pragma mark CLLocationManagerDelegate
- (void)GDLocationManager:(CLLocationManager *)manager
	   didUpdateLocations:(CLLocation *)newLocation
             fromLocation:(CLLocation *)oldLocation

{
    _bLocation = YES;
    if (isEngineInit != 1) {
        return;
    }
    if ([self.locationDelegate respondsToSelector:@selector(GPSSuccess:newLocation:oldLocation:)])
    {
        GGPSINFOEX gpsinfo = {0};
        gpsinfo.lLon = newLocation.coordinate.longitude*1000000;// 经度
        gpsinfo.lLat =  newLocation.coordinate.latitude*1000000;//  纬度
        gpsinfo.dSpeed = ((newLocation.speed<0?0:newLocation.speed) *3.6);// 速度
        [locationDelegate GPSSuccess:gpsinfo newLocation:newLocation oldLocation:oldLocation];
    }
    
    Guint64 t;
    struct timeval tv_begin;
    gettimeofday(&tv_begin, NULL);
    t = (Guint64)1000000 * (tv_begin.tv_sec) + tv_begin.tv_usec;
    Guint32 time = (Guint32)(t / 1000);
    
    GGPSPOS gpspos = {0};
    gpspos.euDataType = GLOC_DATA_TYPE_GPS_POS;
    gpspos.unTickTime = time;
    gpspos.n8EW = 'E';// E表示东经，W表示西经
    gpspos.n8NS = 'N';//N表示北纬，S表示南纬
    gpspos.stPtS.x = newLocation.coordinate.longitude*1000000;// 经度
    gpspos.stPtS.y = newLocation.coordinate.latitude*1000000;// 纬度
    GSTATUS sign = GDBL_SetLocData(GLOC_DATA_TYPE_GPS_POS, &gpspos, sizeof(GGPSPOS));
    //    NSLog(@" GLOC_DATA_TYPE_GPS_POS  %d",sign);
    GGPSAZI gpsazi = {0};
    gpsazi.euDataType = GLOC_DATA_TYPE_GPS_AZI;
    gpsazi.nTickTime = time;
    gpsazi.fAzi = newLocation.course; // 方位角
    sign = GDBL_SetLocData(GLOC_DATA_TYPE_GPS_AZI, &gpsazi, sizeof(GGPSAZI));
    //    NSLog(@" GLOC_DATA_TYPE_GPS_AZI  %d",sign);
    GGPSSPD gpsSPD = {0};
    gpsSPD.euDataType = GLOC_DATA_TYPE_GPS_SPD;
    gpsSPD.nTickTime = time;
    gpsSPD.fSpd = ((newLocation.speed<0?0:newLocation.speed) *3.6);// 速度
    sign = GDBL_SetLocData(GLOC_DATA_TYPE_GPS_SPD, &gpsSPD, sizeof(GGPSSPD));
    //    NSLog(@" GLOC_DATA_TYPE_GPS_SPD  %d",sign);
    GGPSSATANUM gpsatnum = {0};
    gpsatnum.euDataType = GLOC_DATA_TYPE_GPS_SATANUM;
    gpsatnum.nTickTime = time;
    gpsatnum.nNum = 10;// 卫星颗数
    sign = GDBL_SetLocData(GLOC_DATA_TYPE_GPS_SATANUM, &gpsatnum, sizeof(GGPSSATANUM));
    //    NSLog(@" GLOC_DATA_TYPE_GPS_SATANUM  %d",sign);
    GGPSALT gpsAlt = {0};
    gpsAlt.euDataType = GLOC_DATA_TYPE_GPS_ALT;
    gpsAlt.nTickTime = time;
    gpsAlt.fAlt = newLocation.altitude;//海拔
    sign = GDBL_SetLocData(GLOC_DATA_TYPE_GPS_ALT, &gpsAlt, sizeof(GGPSALT));
    //    NSLog(@" GLOC_DATA_TYPE_GPS_ALT  %d",sign);
    
    NSString *date = [[[NSString alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	long long timestamp;
	[dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
	date = [dateFormatter stringFromDate:newLocation.timestamp];
	timestamp = [date longLongValue];
    
    GGPSDATE gpsDate = {0};
    gpsDate.euDataType = GLOC_DATA_TYPE_GPS_DATE;
    gpsDate.nTickTime = time;
    gpsDate.nYear = timestamp / 10000000000;
	gpsDate.nMonth = timestamp % 10000000000 / 100000000;
	gpsDate.nDay = timestamp % 100000000 / 1000000;
	gpsDate.nHour = timestamp % 1000000 / 10000;
	gpsDate.nMinute = timestamp % 10000 / 100;
	gpsDate.nSecond = timestamp % 100;
    sign = GDBL_SetLocData(GLOC_DATA_TYPE_GPS_DATE, &gpsDate, sizeof(GGPSDATE));
    
    //    NSLog(@" GLOC_DATA_TYPE_GPS_DATE  %d",sign);
    GGPSDOP gpsDop = {0};
    gpsDop.euDataType = GLOC_DATA_TYPE_GPS_DOP;
    gpsDop.nTickTime = time;
    gpsDop.fHDOP  =  0.9;// 水平精度定位因子
    GDBL_SetLocData(GLOC_DATA_TYPE_GPS_DOP, &gpsDop, sizeof(GGPSDOP));
    //    NSLog(@" GLOC_DATA_TYPE_GPS_DOP  %d",sign);
    GGPSSTATUS gpsStatus = {0};
    gpsStatus.euDataType = GLOC_DATA_TYPE_GPS_STATUS;
    gpsStatus.nTickTime = time;
    /*
     1 添加判断条件：是否开启GPS模块
     2 上层设置：    避免车位灰色，但是又有有效信号传入
     */
    int bReceiveGPS;
    GDBL_GetParam(G_DISABLE_GPS, &bReceiveGPS);
    if (bReceiveGPS==0) {
	    gpsStatus.cStatus = 'A';// A：有效，V：无效
    } else {
        gpsStatus.cStatus = 'V';// A：有效，V：无效
    }
    sign = GDBL_SetLocData(GLOC_DATA_TYPE_GPS_STATUS, &gpsStatus, sizeof(GGPSSTATUS));
    //    NSLog(@" GLOC_DATA_TYPE_GPS_STATUS  %d",sign);
    
#if PROJECTMODE
    [MWGPS saveGPSInfo:newLocation time:time];
#endif
}
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    
    if (isEngineInit != 1) {
        return;
    }
    
    //add by ly for 有路径情况下电子罗盘不起效 at 2014.7.30
    Gbool isPath = Gfalse;
    GDBL_GetParam(G_GUIDE_STATUS, &isPath);
    if (isPath == 1) {
        return;
    }
    int face_flag = 0;
    switch([[UIApplication sharedApplication] statusBarOrientation])
    {
        case 1:
            face_flag = 1;
            break;
        case 2:
            face_flag = 3;
            break;
        case 3:
            face_flag = 4;
            break;
        case 4:
            face_flag = 2;
            break;
        default:
            break;
    }
    
    Guint64 t;
    struct timeval tv_begin;
    gettimeofday(&tv_begin, NULL);
    t = (Guint64)1000000 * (tv_begin.tv_sec) + tv_begin.tv_usec;
    Guint32 time = (Guint32)(t / 1000);
    
    GECOMPASSDATA gecompass = {0};
    gecompass.euDataType = GLOC_DATA_TYPE_E_COMPASS;
    gecompass.fAzimuth = newHeading.trueHeading;
    //add by gzm for 有时正北的值为负数，只能使用磁北的值 at 2014-7-25
    if (newHeading.trueHeading < 0 && newHeading.magneticHeading >= 0 )
    {
        gecompass.fAzimuth = newHeading.magneticHeading;
    }
    //add by gzm for 有时正北的值为负数，只能使用磁北的值 at 2014-7-25
    gecompass.n8DeviceAttitude  = face_flag;
    gecompass.unTickTime  = time;
    GDBL_SetLocData(GLOC_DATA_TYPE_E_COMPASS, &gecompass, sizeof(GECOMPASSDATA));
    NSLog(@"GECOMPASSDATA %f,%d",gecompass.fAzimuth,gecompass.n8DeviceAttitude);
    
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    if (g_hmiGpsFile) //回放GPS信号，则return
    {
        return;
    }
    [self GDLocationManager:manager didUpdateLocations:newLocation fromLocation:oldLocation];
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
    if (g_hmiGpsFile) //回放GPS信号，则return
    {
        return;
    }
    NSInteger locationCount = locations.count;
    if (locations && locationCount > 0)
    {
        CLLocation *newLocation = (CLLocation *)[locations lastObject];
        CLLocation *oldLocation = (locationCount > 1) ? [locations objectAtIndex:(locationCount - 2)] : newLocation;
        [self GDLocationManager:manager didUpdateLocations:newLocation fromLocation:oldLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
    if (g_hmiGpsFile) //回放GPS信号，则return
    {
        return;
    }
    if (isEngineInit != 1) {
        return;
    }
    if ((![CLLocationManager locationServicesEnabled]) || error.code == kCLErrorDenied)
    {
        if ([locationDelegate respondsToSelector:@selector(GPSFail:)])
        {
            [locationDelegate GPSFail:error];
        }
    }
    
	
}
@end
