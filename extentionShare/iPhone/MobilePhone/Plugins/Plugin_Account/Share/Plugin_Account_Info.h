//
//  Plugin_Account_Info.h
//  AutoNavi
//
//  Created by gaozhimin on 12-12-18.
//
//

#import <Foundation/Foundation.h>


@interface Plugin_Account_Info : NSObject
{
    NSString *m_kAccount;		//帐号名
    
    NSString *m_USER_NAME;  
    NSString *m_PASSWORD;
    NSString *m_TOKEN_ID;
    NSString *m_UUID;
    NSString *m_nickName;
    UIImage *m_head;
    NSString *m_weiboUUID;
    NSString *m_tpusername;
}

@property (nonatomic,copy)  NSString *m_kAccount;   //账户名
@property (nonatomic,copy)  NSString *m_USER_NAME;  //账户名
@property (nonatomic,copy)  NSString *m_PASSWORD;   //密码
@property (nonatomic,copy)  NSString *m_TOKEN_ID;   
@property (nonatomic,copy)  NSString *m_UUID;       
@property (nonatomic,copy)  NSString *m_nickName;   //昵称
@property (nonatomic,copy)  NSString *m_tpusername; //第三方帐号名
@property (nonatomic,retain)  UIImage *m_head;      //头像
@property (nonatomic,copy)  NSString *m_weiboUUID;  //第三方UUID

+ (id)SharedGloballInstance;

@end

