//
//  AccountPersonalData.h
//  AutoNavi
//
//  Created by gaozhimin on 13-5-15.
//
//

#import <Foundation/Foundation.h>
#import "GDBL_SinaWeibo.h"
#import "GDBL_TCWeibo.h"


#define ACCOUNT_RELOAD_TABLEVIEW @"ACCOUNT_RELOAD_TABLEVIEW"
#define ACCOUNT_DETAIL_COLOR TEXTDETAILCOLOR
#define ACCOUNT_DETAIL_FONT [UIFont systemFontOfSize:15];
#define ACCOUNT_TEXTLABLE_FONT [UIFont systemFontOfSize:18];
#define ACCOUNT_HEAD_SIZE 60
typedef enum ACCOUNT_MODIFY_TYPE
{
    ACCOUNT_MODIFY_NON = 0,
    ACCOUNT_MODIFY_URL = 1,
    ACCOUNT_MODIFY_SEX = 2,
    ACCOUNT_MODIFY_NICK,
    ACCOUNT_MODIFY_REGION,
    ACCOUNT_MODIFY_AGE,
    ACCOUNT_MODIFY_SIGN,
    ACCOUNT_MODIFY_FIRST_NAME,
    ACCOUNT_MODIFY_TXINFO,
    ACCOUNT_MODIFY_XLINFO,
}ACCOUNT_MODIFY_TYPE;

@interface AccountPersonalData : NSObject<GDBL_SinaWeiboDelegate,GDBL_TCWeiboDelegate,UIAlertViewDelegate>

@property (nonatomic,assign) ACCOUNT_MODIFY_TYPE m_modifyType; //当前修改的资料
@property (nonatomic,assign) BOOL bDefaultHead; //是否为默认的头像
@property (nonatomic,assign) BOOL bTip; //修改头像是否需要提示
@property (nonatomic,assign) BOOL bUploadTX; //是否上传腾讯第三方账户信息
@property (nonatomic,assign) BOOL bUploadXL; //是否上传新浪第三方账户信息
@property (nonatomic,assign) BOOL bThirdToGD; //是否为第三方帐号转换成高德帐号
@property (nonatomic,assign) int isGetUserInfo; //获取用户资料状态 0 未获取 1 正在获取 2 已获取
@property (nonatomic,retain) NSDictionary *m_TX_Info; //腾讯信息
@property (nonatomic,retain) NSDictionary *m_XL_Info; //新浪信息

/* 个人资料 */
@property (nonatomic,retain) UIImage *m_profileHead; //头像
@property (nonatomic,copy) NSString *m_profileHeadUrl; //头像url
@property (nonatomic,copy) NSString *m_profileNickName; //昵称
@property (nonatomic,copy) NSString *m_profileCountry; //国家
@property (nonatomic,copy) NSString *m_profileProvince; //省份
@property (nonatomic,copy) NSString *m_profileCity; //城市
@property (nonatomic,copy) NSString *m_profileSignature; //签名
@property (nonatomic,copy) NSString *m_profileCode; //地区编码
@property (nonatomic,copy) NSString *m_profileLocation; //位置
@property (nonatomic,assign) int m_profileSex; //性别 1 男 2 女 0 未知
@property (nonatomic,assign) int m_profileAge;  //年龄
@property (nonatomic,assign) int m_profileYear; //年
@property (nonatomic,assign) int m_profileMonth; //月
@property (nonatomic,assign) int m_profileDay; //日


/*上传时的记录*/
@property (nonatomic,retain) UIImage *p_profileHead; //头像
@property (nonatomic,copy) NSString *p_profileNickName; //昵称
@property (nonatomic,copy) NSString *p_profileCountry; //国家
@property (nonatomic,copy) NSString *p_profileProvince; //省份
@property (nonatomic,copy) NSString *p_profileCity; //城市
@property (nonatomic,copy) NSString *p_profileSignature; //签名
@property (nonatomic,copy) NSString *p_profileCode; //地区编码
@property (nonatomic,copy) NSString *p_profileLocation; //位置
@property (nonatomic,assign) int p_profileSex; //性别 1 男 2 女 0 未知
@property (nonatomic,assign) int p_profileAge;  //年龄
@property (nonatomic,assign) int p_profileYear; //年
@property (nonatomic,assign) int p_profileMonth; //月
@property (nonatomic,assign) int p_profileDay; //日
@property (nonatomic,copy) NSString *p_icallFirstName; //姓氏

/* 我的帐号 */
@property (nonatomic,copy) NSString *m_accountNickNmae;//昵称
@property (nonatomic,copy) NSString *m_accountEmail; //邮箱
@property (nonatomic,copy) NSString *m_accountPhoneNumber; //手机号码
@property (nonatomic,copy) NSString *m_accountXLWBName; //新浪微博帐号名
@property (nonatomic,copy) NSString *m_accountTXWBName; //腾讯微博帐号名
@property (nonatomic,copy) NSString *m_accountXLWBuuid; //新浪唯一标识
@property (nonatomic,copy) NSString *m_accountTXWBuuid; //腾讯唯一标识


/* 智驾服务 */
@property (nonatomic,copy) NSString *m_icallRemainDay; //剩余天数
@property (nonatomic,copy) NSString *m_icallPhoneNumber; //智驾手机号
@property (nonatomic,copy) NSString *m_icallFirstName; //姓氏
@property (nonatomic,copy) NSString *m_icallOrder;		//免费用户or订购用户
@property (nonatomic,assign) int m_icallSex; //称谓

+ (AccountPersonalData *)SharedInstance;
- (void)AccountClearProfile;
- (void)AccountClearAccount;
- (void)AccountClearIcall;
- (void)AccountClearAll;
//图片缩放到指定大小尺寸
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size changeRect:(CGRect)changRect;
- (void)UploadTXInfo:(NSDictionary *)userInfo;  //上传腾讯用户信息
- (void)UploadXLInfo:(NSDictionary *)newuserInfo; //上传新浪用户信息
- (void)Account_GetUserinfo;
- (void)Account_GetTXinfoWith:(id<NetReqToViewCtrDelegate>)delegate;
- (void)Account_GetXLinfoWith:(id<NetReqToViewCtrDelegate>)delegate;
- (void)Account_ThirdLoginWith:(NSString *)uuid tpusername:(NSString *)tpusername type:(int)type;


- (void)GetImageWithURL:(NSString *)str_url;
@end
