//
//  SYNetObj.h
//  SuYun
//
//  Created by yu.liao on 15/5/15.
//  Copyright (c) 2015年 yu.liao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  <UIKit/UIKit.h>
/*!
 @brief 请求类型
 */
typedef NS_ENUM(NSInteger, SYNetType)
{
    SYNetType_Login              = 1,
    SYNetType_Logout             = 2,
    SYNetType_VerifyCode         = 3,
    SYNetType_UploadImage        = 4,
    
    SYNetType_DriverReportStatus = 5,
    SYNetType_DriverAuth         = 6,
    
};

typedef enum Van_Type
{
    /** 空：定义[0]元素为空值，这样{@link CallVanActivity.mVanTypeIndex为0时，将不显示内容} */
    VAN_NULL,
    /** 厢货 */
    VAN_ROOM,
    /** 高栏 */
    VAN_HIGH_BAR,
    /** 中栏 */
    VAN_MID_BAR,
    /** 低栏 */
    VAN_LOW_BAR,
    /** 平板 */
    VAN_FLAT,
    /** 冷藏 */
    VAN_COLD,
    /** 保温 */
    VAN_WARM,
    /** 集装箱 */
    VAN_CONTAINER,
    /** 危险品 */
    VAN_DANGER,
    /** 自卸货车 */
    VAN_SELF,
    /** 其他 */
    VAN_OHTER
}Van_Type;

const NSArray *___VanTypeArray;
#define SYVanTypeGet [[NSArray alloc] initWithObjects:@"VAN_NULL",@"VAN_ROOM",@"VAN_HIGH_BAR",@"VAN_MID_BAR",@"VAN_LOW_BAR",@"VAN_FLAT",@"VAN_COLD",@"VAN_WARM",@"VAN_CONTAINER",@"VAN_DANGER",@"VAN_SELF",@"VAN_OHTER", nil]
// Van_Type枚举 to 字串
#define SYVanTypeToString(type) ([SYVanTypeGet objectAtIndex:type])
// 字串 to Van_Type枚举
#define SYVanTypeFromStr(string) ([SYVanTypeGet indexOfObject:string])



typedef enum DriverAuthenticateStatus
{
    /** 未提交认证 */
    STATUS_AUTH_NO_COMMIT,
    
    /** 审核中 */
    STATUS_AUTH_WAITING,
    
    /** 认证失败 */
    STATUS_AUTH_NO_PASS,
    
    /** 认证成功 */
    STATUS_AUTH_PASS
}DriverAuthenticateStatus;

#define SYDriverAuthStatusGet [[NSArray alloc] initWithObjects:@"STATUS_AUTH_NO_COMMIT",@"STATUS_AUTH_WAITING",@"STATUS_AUTH_NO_PASS",@"STATUS_AUTH_PASS", nil]
// Van_Type枚举 to 字串
#define SYDriverAuthStatusToString(type) ([SYDriverAuthStatusGet objectAtIndex:type])
// 字串 to Van_Type枚举
#define SYDriverAuthStatusFromStr(string) ([SYDriverAuthStatusGet indexOfObject:string])

typedef enum DriverBusyStatus
{
    /** 忙碌 */
    STATUS_BUSY,
    
    /** 专车有空 */
    STATUS_IDLE,
    
    //	/** 回程有空 */
    //	STATUS_BACK_IDLE,
    
    /** 未知 */
    STATUS_UNKNOWN
}DriverBusyStatus;

#define SYDriverBusyStatusGet [[NSArray alloc] initWithObjects:@"STATUS_BUSY",@"STATUS_IDLE",@"STATUS_UNKNOWN", nil]
// Van_Type枚举 to 字串
#define SYDriverBusyStatusToString(type) ([SYDriverBusyStatusGet objectAtIndex:type])
// 字串 to Van_Type枚举
#define SYDriverBusyStatusFromStr(string) ([SYDriverBusyStatusGet indexOfObject:string])


#pragma mark - SYRequest
/*!
 @brief 该类为抽象类，定义了网络请求的基本参数，不能直接使用，必须子类化之后才能使用
 */
@interface SYRequest : NSObject

@property (nonatomic) SYNetType requestType;//请求类型

@property (nonatomic,copy) NSString *sid;//用户sessionID,为空:接口不验证SID;不为空:接口需要验证SID

@property (nonatomic) int userid;//用户ID，有的接口不需要此参数，默认传0

@property (nonatomic,copy) NSString *usertype;//用户类型: @“driver”-司机; @“owner”-货主。有的接口不需要此参数，默认空字符串

@property (nonatomic,copy) NSString *platform;//终端平台: @“IOS”-iOS; @“Android”-Android; @"Window"-Window

@end

/*!
 @brief 该类为抽象类，定义了网络请求的返回参数，不能直接使用，必须子类化之后才能使用
 */
@interface SYResponse : NSObject



@end

#pragma mark - LoginRequest

/*!
 @brief 用户登录
 */
@interface LoginRequest : SYRequest

@property (nonatomic,copy) NSString *phone;//用户手机号

@property (nonatomic,copy) NSString *code;//短信验证码


@end

@interface LoginResponse : SYResponse

/*货主和司机共有的参数*/
@property (nonatomic,copy) NSString *sid;//用户sessionID

@property (nonatomic) int userid;//用户ID

@property (nonatomic,copy) NSString *usertype;//用户类型: @“driver”-司机; @“owner”-货主

@property (nonatomic,copy) NSString *username;//用户名称

@property (nonatomic,copy)  NSString *headIcon;//用户头像URL

/*如下是司机端独有的参数*/

@property (nonatomic,copy)  NSString *authStatus;//车主认证状态(终端和服务器端统一使用一套枚举值)

@property (nonatomic,copy)  NSString *driverLicenseImg;//驾驶证照片URL

@property (nonatomic,copy)  NSString *carType;//车辆类型(终端和服务器端统一使用一套枚举值)

@property (nonatomic)  double carLength;//车辆长度

@property (nonatomic)  double carWidth;//车辆宽度

@property (nonatomic)  double carHeight;//车辆高度

@property (nonatomic)  double carLoad;//车辆载重

@property (nonatomic,copy)  NSString *carNum;//车辆牌照号码

@property (nonatomic,copy)  NSString *carName;//车辆名称

@property (nonatomic,copy)  NSString *carPositiveImg;//车辆正面照片URL

@property (nonatomic,copy)  NSString *drivingLicenseImg;//行驶证照片URL

@property (nonatomic,copy)  NSString *driverStatus;//司机工作状态(终端和服务器端统一使用一套枚举值)

@property (nonatomic,copy)  NSString *corpName;//所属物流公司

@property (nonatomic) int corpCode;//物流公司code

@property (nonatomic,copy)  NSString *corpCity;//所在城市

@property (nonatomic,copy)  NSString *corpAddress;//地址

@property (nonatomic,copy)  NSString *corpLicenseImg;//营业执照照片URL

@property (nonatomic,copy)  NSString *corpRegisterTime;//公司注册时间

@end

#pragma mark - LogoutRequest

/*!
 @brief 用户注销
 */
@interface LogoutRequest : SYRequest


@end

@interface LogoutResponse : SYResponse


@end

#pragma mark - VerifyCodeRequest

/*!
 @brief 请求短信验证码
 */
@interface VerifyCodeRequest : SYRequest

@property (nonatomic,copy) NSString *phone;//用户手机号

@end


@interface VerifyCodeResponse : SYResponse

@property (nonatomic,copy) NSString *reserve;//预留参数

@end

#pragma mark - UploadImageRequest

/*!
 @brief 司机工作状态上报
 */
@interface UploadImageRequest : SYRequest

@property (nonatomic,copy) NSString *imgType;//图片类型:"driver_license_img"-驾驶证; @"driving_license_img"-行驶证; @"car_positive_img"-车辆正面图片; @"goods-photo"-货物照片

@property (nonatomic,strong) UIImage *image;//图片

@end


@interface UploadImageResponse : SYResponse

@property (nonatomic,copy) NSString *imgUrl;//图片URL
@property (nonatomic,copy) NSString *imgType;//图片类型

@end

#pragma mark - DriverReportStatusRequest

/*!
 @brief 司机工作状态上报
 */
@interface DriverReportStatusRequest : SYRequest

@property (nonatomic,copy) NSString *driverStatus;//司机工作状态(终端和服务器端统一使用一套枚举值)

@property (nonatomic,copy) NSString *driverStatusLon;//经度

@property (nonatomic,copy) NSString *driverStatusLat;//纬度


@end


@interface DriverReportStatusResponse : SYResponse

@property (nonatomic,copy) NSString *reserve;//预留参数

@end

#pragma mark - DriverAuthRequest

/*!
 @brief 司机认证
 */
@interface DriverAuthRequest : SYRequest

@property (nonatomic,copy) NSString *username;//用户名称

@property (nonatomic) int corpId;//所属物流公司ID

@property (nonatomic,copy)  NSString *carType;//车辆类型(终端和服务器端统一使用一套枚举值)

@property (nonatomic)  double carLength;//车辆长度

@property (nonatomic)  double carWidth;//车辆宽度

@property (nonatomic)  double carHeight;//车辆高度

@property (nonatomic)  double carLoad;//车辆载重

@property (nonatomic,copy)  NSString *carNum;//车辆牌照号码

@property (nonatomic,copy)  NSString *carName;//车辆名称

@property (nonatomic,copy)  NSString *driverLicenseImg;//驾驶证照片URL

@property (nonatomic,copy)  NSString *drivingLicenseImg;//行驶证照片URL

@property (nonatomic,copy)  NSString *carPositiveImg;//车辆正面照片URL

@end


@interface DriverAuthResponse : SYResponse

@property (nonatomic,copy) NSString *authStatus;//授权状态，例:STATUS_AUTH_WAITING

@end



