//
//  MWPathConstants.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-5-6.
//  存放路径相关
//  命名规则：功能名_PATH

#ifndef AutoNavi_MWPathConstants_h
#define AutoNavi_MWPathConstants_h

#define document_path               [NSHomeDirectory() stringByAppendingString:@"/Documents"]


#pragma mark 配置

#define oldPreferenceFilePath       [NSHomeDirectory() stringByAppendingString:@"/Documents/NaviSetting.plist"]         //旧配置文件
#define preferenceFilePath          [NSHomeDirectory() stringByAppendingString:@"/Documents/NaviSettingModel.plist"]    //新配置文件


#pragma mark 服务器切换

#define ServiceSwitchFile_PATH      [NSHomeDirectory() stringByAppendingString:@"/Documents/url.txt"]                   //测试服务器文件


#pragma mark 用户行为统计

#define UBCFile_Path                [NSHomeDirectory() stringByAppendingString:@"/Documents/UBCNew.plist"]              //用户行为统计


#pragma mark 皮肤

#define Skin_path                   [NSString stringWithFormat:@"%@/Skin/", document_path]
#define kSkinUpdateVersion          @"/Skin/SkinUpdateVersionList.plist"                                                 //皮肤更新列表
#define kSkinPlist                  @"/Skin/SkinDownloadList.plist"                                                      //皮肤下载列表
#define skinConfigBundlePath        [[NSBundle mainBundle] pathForResource:@"skinConfigList" ofType:@"plist"]            //皮肤的配置文件
#define skinConfigDocumentPath      [NSHomeDirectory() stringByAppendingString:@"/Documents/Skin/skinConfigList.plist"]  //皮肤的配置文件
#define SKIN_PLIST_NAME             @"/colorConfig.plist"                                                                //颜色配置

#pragma mark 功能引导
#define NEW_JUDGE_PATH              [NSHomeDirectory() stringByAppendingString:@"/Documents/FeatureGuilds/newJudge.plist"]

#define  RedPointService_path        [NSString stringWithFormat:@"%@/FeatureGuilds/", document_path]
#define RED_POINT_PATH              [NSHomeDirectory() stringByAppendingString:@"/Documents/FeatureGuilds/featureGuides.plist"]

#pragma mark 语音播报

#define tts_path                    [NSHomeDirectory() stringByAppendingString:@"/Documents/navi/Dialect"] //语音资源路径


#pragma mark 地图数据

#define FILE_NAME                   "AutoNavi_Mapdata.dat"                                                                //一体化数据文件名
#define sn_path                     [[NSHomeDirectory() stringByAppendingString:@"/Documents/GPS/sn.dat"] UTF8String]
#define mapVersion_path             [[NSHomeDirectory() stringByAppendingString:@"/Documents/navi/map_v.dat"] UTF8String]
#define SIM_GPS_PATH                "/Volumes/WORK/Data"                                 //模拟器数据路径
#define DataDownload_PATH       [NSHomeDirectory() stringByAppendingString:@"/Documents/DataDownload/"]      //地图数据下载文件
#define DataDownloadlistFile_PATH   [NSHomeDirectory() stringByAppendingString:@"/Documents/DataDownload/DataDownloadList.plist"]      //地图数据下载列表
#define navi_PATH        [NSHomeDirectory() stringByAppendingString:@"/Documents/navi"]     //资源文件
#define download_PATH    [NSHomeDirectory() stringByAppendingString:@"/Documents/data/download"] //网络下载所需文件夹
#define chnOverall_PATH  [NSHomeDirectory() stringByAppendingString:@"/Documents/data/chn/overall"] //基础数据的基础资源
#define overall_PATH     [NSHomeDirectory() stringByAppendingString:@"/Documents/data/overall"] //基础数据的配置文件

#define cityData_PATH    [NSHomeDirectory() stringByAppendingString:@"/Documents/data/chn"]   //城市数据目录

#pragma mark 资源文件

#define EngineResolution_path  [[UIScreen mainScreen] respondsToSelector: @selector(scale)]?[NSString stringWithFormat:@"/Documents/navi/%.0fx%.0f/",SCREENWIDTH*[UIScreen mainScreen].scale,SCREENHEIGHT*[UIScreen mainScreen].scale]:[NSString stringWithFormat:@"/Documents/navi/%.0fx%.0f/",SCREENWIDTH,SCREENHEIGHT]

#define g_data_path  [[NSHomeDirectory() stringByAppendingString:EngineResolution_path]  UTF8String]

#define GresourceFile_PATH          [NSHomeDirectory() stringByAppendingString:@"/Documents/GresourseDownloadList.plist"]  //资源文件下载列表

#pragma mark 地图数据路径

#define Map_Data_Path [NSHomeDirectory() stringByAppendingString:@"/Documents/data/"]  //地图数据路径

#pragma mark 路径

#define guideRoute_path             [NSHomeDirectory() stringByAppendingString:@"/Documents/path/"]
#define route_path                  [[NSHomeDirectory() stringByAppendingString:@"/Documents/GNaviData/path.dat"] UTF8String]         //续航文件
#define routeSavePath               @"GNaviData/address/routeHistory.plist"                                                           //历史路线列表

#define DrivingTrack_PATH           [NSHomeDirectory() stringByAppendingString:@"/Documents/DrivingTrack/"]    //驾驶轨迹
#define DrivingTrackInfo_PATH       [NSHomeDirectory() stringByAppendingString:@"/Documents/DrivingTrack/DrivingTrackInfo.plist"]    //驾驶轨迹信息

#pragma mark 账号

#define account_path                [NSHomeDirectory() stringByAppendingString:@"/Documents/Account/accountInfo.plist"]              //账号信息


#pragma mark 里程

#define Mileage_path                [NSString stringWithFormat:@"%@/MileageRecord/", document_path]
#define MileageRecordFile_PATH      [NSHomeDirectory() stringByAppendingString:@"/Documents/MileageRecord/recordMile.plist"]  //里程统计信息


#pragma mark 云端避让

#define CloudDetour_path            [NSString stringWithFormat:@"%@/AvoidInfo/", document_path]
#define kCloudDetourPlist            @"/AvoidInfo/cloudDetourList.plist"                                                       //云端避让信息


#pragma mark 车主服务

#define CarOwnerService_path        [NSString stringWithFormat:@"%@/CarOwnerService/", document_path]
#define kCarOwnerServicePlist        @"/CarOwnerService/CarOwnerServiceList.plist"                                             //车主服务列表
#define kCarOwnerServiceDictionary   @"plugin.plist"


#pragma mark 方言

#define Dialect_path                [NSString stringWithFormat:@"%@/Dialect/", document_path]
#define dialectConfigDocumentPath   [NSHomeDirectory() stringByAppendingString:@"/Documents/Dialect/dialectConfigList.plist"]
#define kDialectPlist                @"/Dialect/dialectDownloadList.plist"                                                   //方言下载列表



#pragma mark 缓存

#define CacheFileName                @"ResCache.plist"

#pragma mark GNaviData路径,主要存放引擎生成的相关文件

#define GNaviData_Directory [NSHomeDirectory() stringByAppendingString:@"/Documents/GNaviData"]

#pragma mark 收藏夹

#define Collect_Directory           [NSHomeDirectory() stringByAppendingString:@"/Documents/GNaviData/address"]       //收藏文件夹路径
#define CONTACT_FILE_NAME           @"Contacts.plist"                                                       //联系人
#define Favorite_Path               [Collect_Directory stringByAppendingString:@"/Favorite.plist"]          //我的收藏夹
#define History_Path                [Collect_Directory stringByAppendingString:@"/History.plist"]           //历史目的地
#define SmartEye_Path               [Collect_Directory stringByAppendingString:@"/SmartEye.plist"]          //电子眼
#define SynTime_Path           [Collect_Directory stringByAppendingString:@"/synTime.plist"] //同步时间保存

#define ForbiddenPoi_Path           [[NSBundle mainBundle] pathForResource:@"ForbiddenPoi" ofType:@"plist"] //涉密poi文件

#pragma mark 搜索历史

#define  POI_SEARCH_FILE_NAME @"SearchHistory.plist"


#pragma mark 网络地图

#define NET_PATH                    [NSHomeDirectory() stringByAppendingString:@"/Documents/NetPath.plist"]


#pragma mark log

#define AutoNaviLogFile_PATH        [NSHomeDirectory() stringByAppendingString:@"/Documents/myLog.txt"]     //程序log
#define GPSLogFile_PATH             [NSHomeDirectory() stringByAppendingString:@"/Documents/gps.txt"]       //gps信号


#pragma mark 基础资源版本号文件存放路径

#define NaviResVersion_PATH             [NSHomeDirectory() stringByAppendingString:@"/Documents/navi/res_version"]

#pragma mark TMC城市数组

#define TmcCityPath        [[NSBundle mainBundle] pathForResource:@"TmcCity" ofType:@"plist"]            //tmc城市

#endif
