//
//  AccountRegistPasswordViewController.h
//  AutoNavi
//
//  Created by gaozhimin on 13-5-10.
//
//

#import <UIKit/UIKit.h>

@interface AccountRegistPasswordViewController : ANTableViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,copy) NSString *m_telPhone;
@property (nonatomic,copy) NSString *m_checkNum;
- (id)initWithType:(int)type;

@end
