//
//  Plugin_Account_RegistViewController.h
//  AutoNavi
//
//  Created by gaozhimin on 13-5-10.
//
//

#import <UIKit/UIKit.h>
@interface AccountRegistPhoneViewController : ANTableViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

-(id)initWithType:(int)type;

@end
