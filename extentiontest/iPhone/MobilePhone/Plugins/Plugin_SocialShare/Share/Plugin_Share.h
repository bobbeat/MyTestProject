//
//  Plugin_Share.h
//  AutoNavi
//
//  Created by gaozhimin on 13-8-14.
//
//

#import <Foundation/Foundation.h>
#import "ModuleDelegate.h"


typedef enum Share_Type
{
    Share_Sina = 0,     //新浪
    Share_Tencent,      //腾讯
    Share_Mail,         //邮件
    Share_Message,      //短信
    Share_Box,          //消息盒子
    Share_WeChat,       //微信
    //里程分享
    Share_mileage_Message,//短信
    Share_mileage_Friend,//朋友圈
    Share_mileage_WeChat,//微信
    Share_mileage_SinaWeiBo,//新浪微博
    
}Share_Type;

@interface Plugin_Share : NSObject<ModuleDelegate>
/*
 1 短信 
 2 新浪微博
 3 － 4 微信
 */

/**
 *	推送点击按钮进入消息盒子
 *
 *	@param	navigationController	视图控制器
 */
+ (void)enterBoxWith:(UINavigationController *)navigationController;

@end
