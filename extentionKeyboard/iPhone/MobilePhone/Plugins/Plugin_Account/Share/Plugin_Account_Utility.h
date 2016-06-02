//
//  Plugin_Account_Utility.h
//  Plugin_Account
//
//  Created by yang yi on 11-12-21.
//  Copyright 2011 autonavi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import <arpa/inet.h>

@interface Plugin_Account_Utility : NSObject {

}
#pragma mark Public
+(Plugin_Account_Utility*) shareInstance;

#pragma mark UI
/**
 * 设置界面上下移动效果,移动量根据各view计算得出(亦可扩展任意大小值),viewToSlide需非主view,若需移动主view待扩展 
 */
-(void)slideView:(UIView*)viewToSlide;
/**
 *计算UITableView中某个UITableViewCell所在高度(包含当前row)
 *参数:row 所在的行号,section: 所在分段 table 所属的UITableView
 */
-(int)calcHeightOfTableCell:(int)row Section:(int) section TableObject:(UITableView*) table;
/**
 *按运行设备类型设置UI模式
 *涉及到UITextField,UILabel样式及字体大小等,
 *扩展:iphone,ipad界面统一设计
 */
-(void) setUiTypeOfDevice:(int)type;
/**
 *敬告框模块(单按钮)
 *参数说明:
 *tipText: 敬告提示内容,btnContent:按钮名,target:Delegate来源,tags:可按事件定义扩展类型值
 */
-(void) UIAlertFormWithTip:(NSString *)tipText BtnText:(NSString*)btnContent Delegate:(id) target Tag:(int) tags;
-(void) UIAlertFormWithErrorType:(NSString *)ErrorType Delegate:(id)target Tag:(int) tags;
/**
 *创建label
 */
-(UILabel *)UILabelCreate;
/**
 *创建textfield,并设置target
 */
-(UITextField *)UITextFieldCreateByTarget:(id) target;
/**
 *判断邮箱字符串或密码是否为合法的格式
 */
-(BOOL)bCheckStrFormat:(NSString *)checkStr MatchStr:(NSString*) matchStr;
/**
 *判断邮箱字符串是否为合法的email格式
 *主要判断'@'及是否以'.com'或'.cn'或'.net'结尾
 */
-(BOOL)bCheckEmail:(NSString *)mail;
/**
 *判断手机号码是否为合法的格式
 *主要判断长度为11或为0 //及是否以'13'或'15'或'18'
 */
-(BOOL)bCheckPhone:(NSString *)phone;

-(NSString*)splitSpaceChar:(NSString*)originStr;

-(void)setButtonStyle:(UIButton*)button;



@end
