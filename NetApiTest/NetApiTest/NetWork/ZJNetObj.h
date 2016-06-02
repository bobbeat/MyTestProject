//
//  ZJNetObj.h
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
typedef NS_ENUM(NSInteger, ZJNetType)
{
    ZJNetType_Login              = 1,
    ZJNetType_Logout             = 2,
    ZJNetType_VerifyCode         = 3,
    ZJNetType_UploadImage        = 4,
    
    ZJNetType_Register              ,
    ZJNetType_GetUserInfo              ,
    ZJNetType_AddCarInfo              ,
    ZJNetType_UpdateCarInfo              ,
    ZJNetType_GetCarInfo              ,
    ZJNetType_UpdateUserInfo              ,
    ZJNetType_GetCityInfo              ,
    ZJNetType_GetResInfo              ,
    ZJNetType_GetUserResInfo              ,
    ZJNetType_GetTaskDetailInfo              ,
    ZJNetType_GetUserTaskInfo,
    ZJNetType_ApplyTask,
};

#pragma mark - ZJRequest
/*!
 @brief 该类为抽象类，定义了网络请求的基本参数，不能直接使用，必须子类化之后才能使用
 */
@interface ZJRequest : NSObject

@property (nonatomic) ZJNetType requestType;//请求类型

@property (nonatomic,copy) NSString *sid;//用户sessionID,为空:接口不验证SID;不为空:接口需要验证SID

@property (nonatomic) int userid;//用户ID，有的接口不需要此参数，默认传0

@property (nonatomic,copy) NSString *usertype;//用户类型: @“driver”-司机; @“owner”-货主。有的接口不需要此参数，默认空字符串

@property (nonatomic,copy) NSString *platform;//终端平台: @“IOS”-iOS; @“Android”-Android; @"Window"-Window

@property (nonatomic,copy) NSString *time; //时间戳
@end

/*!
 @brief 该类为抽象类，定义了网络请求的返回参数，不能直接使用，必须子类化之后才能使用
 */
@interface ZJResponse : NSObject



@end

/*!
 @brief 用户信息类
 */
@interface UserInfoObject : NSObject

@property (nonatomic,copy) NSString *tel;//用户手机号

@property (nonatomic,copy) NSString *car_num;//用户手机号

@property (nonatomic,copy) NSString *brand;//品牌

@property (nonatomic,copy) NSString *model;//车型

@property (nonatomic,copy) NSString *colour;//车辆颜色

@property (nonatomic,copy) NSString *vehicle_license;//行驶证

@property (nonatomic,copy) NSString *avatar;//

@property (nonatomic,copy) NSString *lastlogin;//

@property (nonatomic,copy) NSString *nickname;//昵称

@property (nonatomic,copy) NSString *useraddr;//地址

@property (nonatomic,copy) NSString *user_id;//id

@property (nonatomic,copy) NSString *level;//

@end


#pragma mark - RegitsterRequest

/*!
 @brief 用户创建
 */
@interface RegitsterRequest : ZJRequest

@property (nonatomic,copy) NSString *tel;//用户手机号

@property (nonatomic,copy) NSString *passwd;//密码

@property (nonatomic,copy) NSString *nickname;//昵称

@property (nonatomic,copy) NSString *useraddr;//地址

@end

@interface RegitsterResponse : ZJResponse

@property (nonatomic,retain) UserInfoObject *userInfoObject;    //用户信息

@end

#pragma mark - GetUserInfoRequest

/*!
 @brief 获取用户信息
 */
@interface GetUserInfoRequest : ZJRequest

@property (nonatomic,copy) NSString *tel;//用户手机号

@end

@interface GetUserInfoResponse : ZJResponse

@property (nonatomic,retain) UserInfoObject *userInfoObject;    //用户信息

@end

#pragma mark - UpdateUserInfoRequest

/*!
 @brief 获取用户信息
 */
@interface UpdateUserInfoRequest : ZJRequest

@property (nonatomic,retain) UserInfoObject *userInfoObject;    //用户信息

@end

@interface UpdateUserInfoResponse : ZJResponse

@property (nonatomic,retain) UserInfoObject *userInfoObject;    //用户信息

@end

#pragma mark - AddCarInfoRequest

/*!
 @brief 添加车辆信息
 */
@interface AddCarInfoRequest : ZJRequest

@property (nonatomic,retain) UserInfoObject *carInfoObject;    //车辆信息

@end

@interface AddCarInfoResponse : ZJResponse

@property (nonatomic,retain) UserInfoObject *carInfoObject;    //车辆信息

@end

#pragma mark - UpdateCarInfoRequest

/*!
 @brief 添加车辆信息
 */
@interface UpdateCarInfoRequest : ZJRequest

@property (nonatomic,retain) UserInfoObject *carInfoObject;    //车辆信息

@end

@interface UpdateCarInfoResponse : ZJResponse

@property (nonatomic,retain) UserInfoObject *carInfoObject;    //车辆信息

@end

#pragma mark - GetCarInfoRequest

/*!
 @brief 添加车辆信息
 */
@interface GetCarInfoRequest : ZJRequest

@property (nonatomic,copy) NSString *tel;//用户手机号

@end

@interface GetCarInfoResponse : ZJResponse

@property (nonatomic,retain) UserInfoObject *carInfoObject;    //车辆信息

@end

#pragma mark - LoginRequest

/*!
 @brief 用户登录
 */
@interface LoginRequest : ZJRequest

@property (nonatomic,copy) NSString *tel;//用户手机号

@property (nonatomic,copy) NSString *passwd;//密码

@end

@interface LoginResponse : ZJResponse

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

#pragma mark - GetCityInfoRequest

/*!
 @brief 获取窗口信息
 */
@interface GetCityInfoRequest : ZJRequest

@property (nonatomic,copy) NSString *current_city;//城市编码

@property (nonatomic,copy) NSString *dialog_id;//

@end

@interface CityInfoObject : NSObject

@property (nonatomic,copy) NSString *task_id; //任务id和 level是优先级，在首页显示的 顺序，相同值表示并列，

@property (nonatomic,copy) NSString *describe_id; //文本描述id

@property (nonatomic,copy) NSString *level; //任务id和 level是优先级，在首页显示的 顺序，相同值表示并列，

@property (nonatomic,copy) NSString *res_num;   //任务的资源总数

@property (nonatomic,copy) NSString *type;  //用来标记任务类型，1是侧滑展示任务 2是竖列满格任务 3是竖列并列任务

@property (nonatomic,copy) NSString *advertiser;  //

@property (nonatomic,copy) NSString *quantity;  //

@property (nonatomic,copy) NSString *colour;  //

@property (nonatomic,copy) NSString *brand;  //

@property (nonatomic,copy) NSString *model;  //

@property (nonatomic,copy) NSString *line;  //

@property (nonatomic,copy) NSString *cycle;  //

@property (nonatomic,copy) NSString *city;  //

@property (nonatomic,copy) NSString *reward;  //

@property (nonatomic,copy) NSString *status;  //

@property (nonatomic,copy) NSString *stime;  //

@property (nonatomic,copy) NSString *etime;  //
@end

@interface GetCityInfoResponse : ZJResponse

@property (nonatomic,retain) NSMutableArray *cityInfoArray;  //保存CityInfoObject对象

@end

#pragma mark - GetTaskResRequest

/*!
 @brief 获取资源
 */
@interface GetTaskResRequest : ZJRequest

@property (nonatomic,copy) NSString *task_id; //任务id和 level是优先级，在首页显示的 顺序，相同值表示并列，

@property (nonatomic,copy) NSString *describe_id; //文本描述id

@property (nonatomic,copy) NSString *res_id; //首页的 资源id都是0

@property (nonatomic,copy) NSString *type;  // 只有在res_id=0并且isimg:1	时请求首页资源图片有效。1是侧滑展示任务 2是竖列满格任务 3是竖列并列任务

@property (nonatomic,copy) NSString *isimg;   //isimg表示这个请求是 获取文本还是图片

@end

@interface GetTaskResResponse : ZJResponse

@property (nonatomic,retain) UIImage *image;   //获取的图片

@end

#pragma mark - GetUserResRequest
/*!
 @brief 获取用户资源接口
 */
@interface GetUserResRequest : ZJRequest

@property (nonatomic,copy) NSString *tel; //用户手机，

@property (nonatomic,copy) NSString *index; //对应上传用户图片的 index列表

@property (nonatomic,copy) NSString *type;  // 表示文件后缀。所有图片要求默认是png，非png可能会出错。

@end

@interface GetUserResResponse : ZJResponse

@property (nonatomic,retain) UIImage *image;   //获取的图片

@end

#pragma mark - GetTaskDetailRequest

/*!
 @brief 获取任务详情
 */
@interface GetTaskDetailRequest : ZJRequest

@property (nonatomic,copy) NSString *task_id; //任务id和 level是优先级，在首页显示的 顺序，相同值表示并列，

@end

@interface GetTaskDetailResponse : ZJResponse

@property (nonatomic,retain) NSMutableArray *cityInfoArray;  //保存CityInfoObject对象

@end

#pragma mark - GetUserTaskInfoRequest

/*!
 @brief 获取用户任务信息
 */
@interface GetUserTaskInfoRequest : ZJRequest

@property (nonatomic,copy) NSString *tel;//用户手机号

@property (nonatomic,copy) NSString *task_id;//task_id 要获取的任务id 0为不限

/*任务状态
 0	不限
 1	申请阶段
 2	审核阶段
 3	预约阶段
 4	执行阶段
 5	结算阶段
 -1	完结
*/
@property (nonatomic,copy) NSString *state;//state 任务的状态，0为不限。


@end

@interface GetUserTaskInfoResponse : ZJResponse

@property (nonatomic,retain) UserInfoObject *carInfoObject;    //车辆信息

@end

#pragma mark - ApplyTaskRequest

/*!
 @brief 申请任务接口
 */
@interface ApplyTaskRequest : ZJRequest

@property (nonatomic,copy) NSString *tel;//用户手机


/*
 0	成功
 -1	缺少加密验证信息
 -2	发起用户不存在
 -3	请求时间和服务器时间超过3分钟
 -4	请求json中参数不对
 -5	要获取的数据不存在
 -6	加密验证信息不匹配
 -7	请求类型不允许
 -8	json参数不存在
 -9	数据库操作错误
 -10	车辆已经登记
 -11	上传请求url中带的参数不对
 -12	当前用户有任务在身
 -13	用户和任务的要求不符合
 -14	任务不存在或者任务状态不对或者资格审核异常
 */
@property (nonatomic,copy) NSString *task_id;//要获取的任务id，接口会先判断车辆和任务情况，然后验证任务需求是否满足，都满足则进入申请阶段

@end

@interface ApplyTaskResponse : ZJResponse


@end

#pragma mark - LogoutRequest

/*!
 @brief 用户注销
 */
@interface LogoutRequest : ZJRequest


@end

@interface LogoutResponse : ZJResponse


@end

#pragma mark - VerifyCodeRequest

/*!
 @brief 请求短信验证码
 */
@interface VerifyCodeRequest : ZJRequest

@property (nonatomic,copy) NSString *phone;//用户手机号

@end


@interface VerifyCodeResponse : ZJResponse

@property (nonatomic,copy) NSString *reserve;//预留参数

@end

#pragma mark - UploadImageRequest

/*!
 @brief 上传图片
 */
@interface UploadImageRequest : ZJRequest

/*
 图片提交index
 1	头像
 2	车辆行驶证
 3	车外观前
 4	车外观后
 5	车外观左
 6	车外观右
 7	驾驶座仪表盘
 8	驾驶座视角
 11	当日任务开始仪表盘
 12	当日任务开始车辆位置环境
 13	当日任务结束仪表盘
 14	当日任务结束车辆位置环境
 15	传输任务轨迹文件
*/
@property (nonatomic,copy) NSString *index;//

@property (nonatomic,copy) NSString *task;//

@property (nonatomic,copy) NSString *tel;//

@property (nonatomic,strong) UIImage *image;//图片

@end


@interface UploadImageResponse : ZJResponse


@end

#pragma mark - DriverReportStatusRequest

/*!
 @brief 司机工作状态上报
 */
@interface DriverReportStatusRequest : ZJRequest

@property (nonatomic,copy) NSString *driverStatus;//司机工作状态(终端和服务器端统一使用一套枚举值)

@property (nonatomic,copy) NSString *driverStatusLon;//经度

@property (nonatomic,copy) NSString *driverStatusLat;//纬度


@end


@interface DriverReportStatusResponse : ZJResponse

@property (nonatomic,copy) NSString *reserve;//预留参数

@end

#pragma mark - DriverAuthRequest

/*!
 @brief 司机认证
 */
@interface DriverAuthRequest : ZJRequest

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


@interface DriverAuthResponse : ZJResponse

@property (nonatomic,copy) NSString *authStatus;//授权状态，例:STATUS_AUTH_WAITING

@end



