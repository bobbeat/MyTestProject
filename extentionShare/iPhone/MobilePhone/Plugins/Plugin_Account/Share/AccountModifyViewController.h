//
//  AccountModifyViewController.h
//  AutoNavi
//
//  Created by gaozhimin on 13-5-15.
//
//

#import <UIKit/UIKit.h>
#import "Plugin_Account_Globall.h"

@interface AccountModifyViewController : ANTableViewController<UITextFieldDelegate,UITextViewDelegate>

@property (nonatomic,copy) NSString *m_newPassWord;
@property (nonatomic,copy) NSString *m_oldPassWord;
@property (nonatomic,copy) NSString *m_confirmPassWord;
@property (nonatomic,copy) NSString *m_nickName;
@property (nonatomic,copy) NSString *m_telNumber;
@property (nonatomic,copy) NSString *m_check;
@property (nonatomic,copy) NSString *m_firstName;
@property (nonatomic,copy) NSString *m_signature;
- (id)initWithItemType:(GD_Account_ItemType)type;

@end
