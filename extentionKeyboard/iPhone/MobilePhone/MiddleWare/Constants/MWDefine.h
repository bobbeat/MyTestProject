//
//  MWDefine.h
//  AutoNavi
//
//  Created by huang longfeng on 13-7-30.
//
//
#import "ANOperateMethod.h"
#import "MWPreference.h"
#import "ANDataSource.h"
#import "NSString+Category.h"
#import "UIImage+Category.h"
#import "GDSkinColor.h"
#import "UIDevice+Category.h"
#import "Plugin_Account.h"
#import "OpenUDID.h"

#import "UIDevice+Category.h"

#ifndef AutoNavi_MWDefine_h
#define AutoNavi_MWDefine_h

#pragma mark 常用

//服务商id，相当于imei
#define VendorID                  [UIDevice GetVendorID]

//推送设备令牌
#define deviceTokenEx             ([MWPreference sharedInstance].deviceToken)? [MWPreference sharedInstance].deviceToken : @"0123456789012345678901234567890123456789012345678901234567890123"        //获取deviceToken

//mac地址,iOS 7系统该值都是0f607264fc6318a92b9e13c65db7cd3c
#define deviceID                  [[UIDevice currentDevice] uniqueDeviceIdentifier]      //获取设备id

// idfa: ios 6及以下 ： 返回 mac  ios 7及以上返回 idfa
#define IDFA       [UIDevice ADDeviceIdentifier]
// IDFV : 供应商 ID : ios 6及以下 ： 返回 mac  ios 7及以上返回 idfv
#define IDFV     [UIDevice vendorDeviceIdentifier]
// OpenUDID
#define OpenUDIDValue  [OpenUDID value]

//转换函数
#define StrlenWithGchar(str) [NSString GMD_strlenWith16:str]
#define GcharToNSString(str) [NSString GMD_Cstring16ToNSString:str]
#define NSStringToGchar(str) [NSString GMD_NSStringToCstring16:str]
#define ConvertGcharToChar(dest,orig1) [NSString GMD_convertUTF16to8With:dest orig:orig1]
#define ConvertChartoGchar(dest,orig1) [NSString GMD_convertUTF8to16With:dest orig:orig1]
#define GcharMemcpy(dest, src1, len1)  [NSString GMD_GcharMemcpyWih:dest src:src1 len:len1]


#define MapVersionNoV             [MWEngineTools GetMapVersionNoV]//地图数据版本号，没有字母V

#define GDEngineVersion             [MWEngineTools GetEngineVersion]//引擎版本号

#define GDEngineNOVVersion          [MWEngineTools GetEngineVersionNoV]//引擎版本号没有加V

#define UserSID             [Plugin_Account getAccountInfoWith:5]//获取用户sid 登录令牌

#define UserID_Account             [Plugin_Account getAccountInfoWith:2]//获取用户userid

#define UserName_Account             [Plugin_Account getAccountInfoWith:3]//获取用户名称

#define LoginStatus_Account             [Plugin_Account getAccountInfoWith:1]//获取用户登陆状态,此判断与用户id有关，不存在用户id，将会把登陆状态置为未登录


//网络连接类型:0-无网络; 1-3G; 2-WIFI
#define NetWorkType               [[ANDataSource sharedInstance] isNetConnecting]

#define  CRELEASE(x) if(x){ [x release]; x=nil;}    //释放内存

#pragma mark 版本相关

#define SOFTVERSIONNUM                9.3f
#define SOFTVERSION             [NSString stringWithFormat:@"%s","V 9.3.1.41001.2129"]
#define SOFTVERSIONCODE           12

#pragma mark 后台相关
#pragma  mark - --- ANAV 信息  ---
/*
 ANAV
 属性          属性名称       说明                                                      对应宏
 
 设备号        imei          设备终端唯一标示                                            VendorID
 软件版本号     apkversion    应用软件版本号                                             SOFTVERSIONCODE
 数据版本号     mapversion    数据版本号                                                 MapVersionNoV
 终端机型       model         用户机型                                                  deviceModel
 分辨率        resolution    终端分辨率                                                 DeviceResolutionString
 系统          os            系统版本号                                                 CurrentSystemVersion
 注册用户id     userid        用户id                                                    UserID_Account
 登录令牌       sid           SessionId
 渠道编号       syscode       软件安装渠道编号                                            KNetChannelID
 产品编号       pid           1:android/winp 导航;2:ios 导航。默认为 1                    PID
 鉴权标签       sign          鉴权标签（MD5(KNetChannelID+parameter+"@"+kNetSignKey)）MD5加密统一使用NSString的分类方法:stringFromMD5
 */

#define KNetChannelID @"41001"   //渠道编号

#define kNetSignKey @"370060C88A374151A175AB60C5FCA7C5"  //md5值计算 String sign = MD5.md5s(syscode+parameter+"@"+key).toUpperCase（）
#define PID                         @"2"               //产品编号 1:android/winp 导航;2:ios
#define SID                         @""                //登录令牌 北京后台
#define NetFontType                 (int)[[ANDataSource sharedInstance] getNetFontType]  //北京后台文字类型
#define NetProcessTime              [[ANDataSource sharedInstance] getNetProcessTime]    //北京后台请求时间
#define PformID                     @"1"                // 平台,0:android;1:ios;2:winp8 ,H5 界面相关

#pragma  mark - --- AOS 信息  ---
/*
 AOS
 
 属性          属性名称           说明                                                      对应宏
 
 秘钥       计算签名用的 key   算sign值的KEY, 需系统统一分配                              USER_DEVICE_INFO_KEY
 产品代码       dip     产品代码 请求发起方的应用唯一标识, 可严格区分不同应用、不同平台等等     USER_DEVICE_INFO_APPID
 授权号       channel         授权号, 由系统统一分配                                    USER_DEVICE_INFO_CHANNEL
 MAC           diu           设备的唯一标示符                                         USER_DEVICE_INFO_MAC
               dic           客户端渠道代码                                           USER_DEVICE_INFO_DIC
               div           客户端版本号,用于标志客户端产品的不同软件版本                 SOFT_AOS_VERSION
               did           数据版本号,用于标志客户端产品的不同数据版本                   MapVersionNoV
               die           引擎版本号,用于标志客户端产品的不同引擎版本                   GDEngineNOVVersion
 */
#define  USER_DEVICE_INFO_KEY  @"e68D08A215344f7c81013DDH96a7e3bf"  /*算sign值的KEY, 需系统统一分配*/
#define  USER_DEVICE_INFO_APPID    @"11143"          //dip = appid, 产品代码 请求发起方的应用唯一标识, 可严格区分不同应用、不同平台等等
#define  USER_DEVICE_INFO_CHANNEL   @"navigation"     //channel	授权号, 由系统统一分配
#define  USER_DEVICE_INFO_MAC  IDFV                  //设备的唯一标示符
#define USER_DEVICE_INFO_DIC KNetChannelID          //AOS 渠道号
#define SOFT_AOS_VERSION        ([NSString stringWithFormat:@"IOS%@090300",isiPhone ? @"H" : @"P"])

#pragma mark 软件相关=======================================================================

#define fontType                  (int)[[MWPreference sharedInstance] getValue:PREF_UILANGUAGE]   //字体类型

#define Interface_Flag            (int)[UIDevice getDeviceOrientation]  //横竖屏方向

#define OrientationSwitch         [[MWPreference sharedInstance] getValue:PREF_INTERFACESTATE]  //横竖屏开关

#define Orientation               [[MWPreference sharedInstance] getValue:PREF_INTEFACEORIENTATION]  //界面方向

#define DIFFENT_STATUS_HEIGHT (((float)NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) ? 20 : 0) //os 7 以上系统添加20的位移


#pragma mark 本地化相关

//调用示例：IMAGE(@"a.png",IMAGEPATH_TYPE_1) 说明：目前imagePathType有两个枚举类型，IMAGEPATH_TYPE_1、IMAGEPATH_TYPE_2；IMAGEPATH_TYPE_1表示图片资源从bundle中获取，IMAGEPATH_TYPE_2表示图片资源从指定路径获取
#define IMAGE(name,imagePathType) [UIImage imageWithName:name pathType:imagePathType]

//调用示例：STR(@"alert",@"name")
#define STR(key,tableName)        [[ANOperateMethod sharedInstance] GMD_SetLocalizeKey:key table:tableName]
#define Setting_STR(key)          STR(key,@"SettingLocalizable")

#define Localize_POI                   @"POI"
#define Localize_Account               @"Account"
#define Localize_POIShare              @"POIShare"
#define Localize_Track                 @"Track"
#define Localize_CityDownloadManage    @"CityDownloadManage"
#define Localize_Setting               @"Setting"
#define Localize_Universal             @"Universal"
#define Localize_UserFeedback          @"UserFeedback"
#define Localize_TMC                   @"TMC"
#define Localize_NetMap                @"NetMap"
#define Localize_Main                  @"Main"
#define Localize_Icall                 @"Icall"
#define Localize_RouteOverview         @"RouteOverview"
#define Localize_CarService            @"CarService"
#define Localize_DrivingTrack          @"DrivingTrack"
#define Localize_MileRecord            @"MileRecord"


#pragma mark 方法

//字符转换
#define CSTRING_TO_NSSTRING(cString) [NSString stringWithCString:cString encoding: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]
#define NSSTRING_TO_CSTRING(string)	[string cStringUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]

//BarButtonItem
#define LEFTBARBUTTONITEM(TITLE, SELECTOR)	[[[VCTranslucentBarButtonItem alloc] initWithType:VCTranslucentBarButtonItemTypeBackward title:TITLE target:self action:SELECTOR] autorelease]
#define RIGHTBARBUTTONITEM(TITLE, SELECTOR) [[[VCTranslucentBarButtonItem alloc] initWithType:VCTranslucentBarButtonItemTypeNormal title:TITLE target:self action:SELECTOR] autorelease]
#define RIGHTBARBUTTONITEM1(TITLE, SELECTOR) [[[VCTranslucentBarButtonItem alloc] initWithType:VCTranslucentBarButtonItemTypeRedColor title:TITLE target:self action:SELECTOR] autorelease]

// --- 从plist中获取颜色。a —— 获取颜色所使用的key值(类型 —— NSString)  ---
#define GETSKINCOLOR(a) ([[GDSkinColor sharedInstance] getColorByKey:(a)])

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define IMAGECOLOR(name,type) [UIColor colorWithPatternImage:IMAGE(name,type)]


#pragma mark 系统相关========================================================================

//当前设备分辨率名称（iPhone3,iPhone4,iPhone5,iPad,NewPad）
#define DeviceResolutionName [UIDevice currentResolutionName]

//当前设备分辨率字符串（640x960）
#define DeviceResolutionString [UIDevice getResolutionString]

// 是否iPad
#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
// 是否iPhone
#define isiPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

// 是否模拟器
#define isSimulator (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)

//根window
#define MainWindow ((UIWindow *)[[UIApplication sharedApplication].windows objectAtIndex:0]).rootViewController.view

#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

//获取系统版本
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]    //系统版本号float
#define CurrentSystemVersion [[UIDevice currentDevice] systemVersion]        //系统版本号，例：7.0.4 不是浮点数请小心使用
#define deviceModel [[UIDevice currentDevice] model]                         //设备型号
#define IsSteal  [UIDevice isJail]
#define IOS_7   (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)


#pragma mark 界面排布

//屏幕宽度
#define SCREENWIDTH [[ANOperateMethod sharedInstance] getScreenWidth]
//屏幕高度
#define SCREENHEIGHT [[ANOperateMethod sharedInstance] getScreenHeight]

//应用程序宽度
#define APPWIDTH [[ANOperateMethod sharedInstance] getApplicationFrameWidth]
//应用程序宽度
#define APPHEIGHT [[ANOperateMethod sharedInstance] getApplicationFrameHeight]
//应用程序分辨率比例，可以用来判断是否高清
#define SCALE ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] ? [[UIScreen mainScreen] scale] : 1.0)
#define ISRETINA ((SCALE == 2.0) ? 1 : 0)

#define NAVICTR_V 44.0 //竖屏导航栏高度
#define NAVICTR_H (isiPhone ? 32.0 : 44.0) //横屏导航栏高度

#define CONTENTHEIGHT_V [[ANOperateMethod sharedInstance] getApplicationFrameContentHeight_V] //竖屏，扣除导航栏、状态栏，剩余的页面高度
#define CONTENTHEIGHT_H [[ANOperateMethod sharedInstance] getApplicationFrameContentHeight_H] //横屏，扣除导航栏、状态栏，剩余的页面高度

#define iPhoneOffset  ((int)[[UIScreen mainScreen] currentMode].size.height % 480)/2.0  //iphone5位置偏移

//通用高度
#define kHeight1     38
#define kHeight2     48//通用单元格高度(一行)
#define kHeight3     65
#define kHeight4     35
#define kHeight5     56//通用单元格高度(两行)

//通用字体大小
#define kSize1       20
#define kSize2       17 //通用text字体大小
#define kSize3       13
#define kSize4       19
#define kSize5       17 //通用detailtext字体大小
#define kSize6       13

#define ALPHA_HIDEN (float)0.4//上一段，下一段按钮不可用时透明度
#define ALPHA_APEAR (float)1.0

#pragma mark 工程模式
#define PROJECTMODE    1     //工程模式

#pragma mark 待定

//95190手机绑定中验证码绑定标识
#define license_id_normal @"12345"
#define license_id_95190 @"95190"

//模拟导航速度设置  —— 低，中，高，跳跃
#define SIM_LOW_SPEED 40.0f
#define SIM_MID_SPEED 200.0f
#define SIM_HIGH_SPEED 600.0f
#define SIM_JUMP_SPEED  1000.0f


#endif
