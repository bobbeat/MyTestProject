//
//  AccountLoginViewController.h
//  AutoNavi
//
//  Created by gaozhimin on 13-5-10.
//
//

#import <UIKit/UIKit.h>

@interface AccountLoginViewController : ANTableViewController<UITextFieldDelegate>

-(id)initWithAccountName:(NSString*)myAccountName Password:(NSString*)myPwd back:(BOOL)back;

@end 
