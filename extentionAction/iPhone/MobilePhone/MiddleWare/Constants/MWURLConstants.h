//
//  MWURLConstants.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-5-6.
//  存放URL相关的常量
//

#import "ANDataSource.h"

#ifndef AutoNavi_MWURLConstants_h
#define AutoNavi_MWURLConstants_h

#pragma mark

#define GetUrlFromDocument(name) [ANDataSource getURLFromDocument:name]

#pragma mark  ---------------------厦门后台---------------------
#pragma mark 厦门服务器

#define kNetDomain                       GetUrlFromDocument(@"kNetDomain")?GetUrlFromDocument(@"kNetDomain"):@"http://iphone.autonavi.com/"
#define kNetDomain1                      GetUrlFromDocument(@"kNetDomain1")?GetUrlFromDocument(@"kNetDomain1"):@"http://website.autonavi.com/"

#pragma mark  ---------------------AOS---------------------
#pragma mark 设备信息上传

#define marketBannerBaseURL GetUrlFromDocument(@"marketBannerBaseURL")?GetUrlFromDocument(@"marketBannerBaseURL"):@"http://sns.amap.com/ws/auth/user-device/?"

#pragma mark 用户反馈

#define UserFeedBack_URL         GetUrlFromDocument(@"UserFeedBack_URL")?GetUrlFromDocument(@"UserFeedBack_URL"):@"http://sns.amap.com/ws/feedback/report"

#pragma mark ---------------------ANAV---------------------
#pragma mark 车主服务

//车主服务
#define kCarOwnerServiceURL                    GetUrlFromDocument(@"kCarOwnerServiceURL")?GetUrlFromDocument(@"kCarOwnerServiceURL"):@"http://us.autonavi.com/navisoftware/ownerservice"

//红点提醒
#define kRedPointTipsURL GetUrlFromDocument(@"kRedPointTipsURL")?GetUrlFromDocument(@"kRedPointTipsURL"):@"http://us.autonavi.com/navisoftware/flag"

//天气
#define WEATHER_URL GetUrlFromDocument(@"WEATHER_URL")?GetUrlFromDocument(@"WEATHER_URL"):@"http://service.anav.com/carowner/weather2/"

//沿途天气
#define WEATHER_ALLLOAD_URL GetUrlFromDocument(@"WEATHER_ALLLOAD_URL")?GetUrlFromDocument(@"WEATHER_ALLLOAD_URL"):@"http://service.anav.com/carowner/routeweather/"

#pragma mark 网络搜索

//智能搜索，周边搜索，目的地停车场
#define NetSearchURL GetUrlFromDocument(@"NetSearchURL")?GetUrlFromDocument(@"NetSearchURL"):@"http://gis.autonavi.com/servicesearch"

//沿途周边搜索
#define NetSearchURLLineArround GetUrlFromDocument(@"NetSearchURLLineArround")?GetUrlFromDocument(@"NetSearchURLLineArround"):@"http://gis.autonavi.com/routesearch"


#pragma mark 云端规避

#define kCloudDetourURL GetUrlFromDocument(@"kCloudDetourURL")?GetUrlFromDocument(@"kCloudDetourURL"):@"http://mlbs.autonavi.com/naviservices/avoid"

#pragma mark 人工导航
//短信验证码
#define kICallSMSURL GetUrlFromDocument(@"kICallSMSURL")?GetUrlFromDocument(@"kICallSMSURL"):@"http://us.autonavi.com/navisoftware/clientvalidata"
//人工导航
#define kICallURL         GetUrlFromDocument(@"kICallURL")?GetUrlFromDocument(@"kICallURL"):@"http://us.autonavi.com/naviApplication/ptt"


#pragma mark 历史路线

#define KHistoryRouteSyncURL    GetUrlFromDocument(@"KHistoryRouteSyncURL")?GetUrlFromDocument(@"KHistoryRouteSyncURL"):@"http://us.autonavi.com/navisoftware/hisRoad"

#pragma mark 驾驶轨迹

//驾驶轨迹同步
#define KDrivingTrackSyncURL    GetUrlFromDocument(@"KDrivingTrackSyncURL")?GetUrlFromDocument(@"KDrivingTrackSyncURL"):@"http://us.autonavi.com/navisoftware/trajectory"

//驾驶轨迹分享
#define KDrivingTrackShareURL   GetUrlFromDocument(@"KDrivingTrackShareURL")?GetUrlFromDocument(@"KDrivingTrackShareURL"):@"http://us.autonavi.com/naviApplication/shortUrl"

//驾驶轨迹html5地址
#define kDrivingTrackLongURL  GetUrlFromDocument(@"kDrivingTrackLongURL")?GetUrlFromDocument(@"kDrivingTrackLongURL"):@"http://service.anav.com/carowner/driverskills/"

//里程,驾驶得分上传
#define kMileageURL           GetUrlFromDocument(@"kMileagePostURL")?GetUrlFromDocument(@"kMileagePostURL"):@"http://us.autonavi.com/naviApplication/mileage"

#pragma mark 开机闪屏

#define kLaunchImageURL          GetUrlFromDocument(@"kLaunchImageURL")?GetUrlFromDocument(@"kLaunchImageURL"):@"http://us.autonavi.com/naviApplication/flash"

#pragma mark 软件升级

#define kSoftWareUpdateURL       GetUrlFromDocument(@"kSoftWareUpdateURL")?GetUrlFromDocument(@"kSoftWareUpdateURL"):@"http://nis.autonavi.com/nis/apkversion"


#pragma mark 方言下载

#define kDialectRequestURL       GetUrlFromDocument(@"kDialectRequestURL")?GetUrlFromDocument(@"kDialectRequestURL"):@"http://nis.autonavi.com/nis/dialect"


#pragma mark 开机欢迎语音下载

#define kPowerVoiceRequestURL    GetUrlFromDocument(@"kPowerVoiceRequestURL")?GetUrlFromDocument(@"kPowerVoiceRequestURL"):@"http://us.autonavi.com/navisoftware/tips"

#pragma mark 地图数据下载

#define kMapdataRequestURL    GetUrlFromDocument(@"kMapdataRequestURL")?GetUrlFromDocument(@"kMapdataRequestURL"):@"http://nis.autonavi.com/nis/mapUpdate"

#pragma mark 收藏夹、历史目的地、电子眼同步

#define kSynFavPoiRequestURL    GetUrlFromDocument(@"kSynFavPoiRequestURL")?GetUrlFromDocument(@"kSynFavPoiRequestURL"):@"http://nis.autonavi.com/nis/syncdata"

#pragma mark 用户（北京后台）

#define kAccountRequestURL    GetUrlFromDocument(@"kAccountRequestURL")?GetUrlFromDocument(@"kAccountRequestURL"):@"http://nis.autonavi.com"

#endif
