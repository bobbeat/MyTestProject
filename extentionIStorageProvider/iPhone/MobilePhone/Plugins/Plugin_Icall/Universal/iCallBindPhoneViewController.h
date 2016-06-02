//
//  Plugin_Account_RegistViewController.h
//  AutoNavi
//
//  Created by gaozhimin on 13-5-10.
//
//

#import <UIKit/UIKit.h>
#define Icall_Notify @"Icall_Notify"    //智驾绑定手机号 或者 修改手机号 成功通知

@interface iCallBindPhoneViewController : ANTableViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
@property(retain,nonatomic)NSString * identifyCode;//短信验证码
-(id)initWithType:(int)type;

@end
