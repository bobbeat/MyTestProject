//
//  Plugin_Account_TimeButton.h
//  AutoNavi
//
//  Created by gaozhimin on 13-5-10.
//
//

#import <UIKit/UIKit.h>

typedef enum TIME_BUTTON_VIEW_TYPE
{
    REGIST_VIEW = 0,
    PHONE_CHECK_VIEW,
    FIND_PSW_VIEW,
    BIND_PHONE_VIEW
    
}TIME_BUTTON_VIEW_TYPE;

@interface AccountTimeButton : UIButton

- (id)initWithFrame:(CGRect)frame countDown:(int)countDown;

- (id)initWithFrame:(CGRect)frame countDown:(int)countDown viewType:(TIME_BUTTON_VIEW_TYPE)type;

- (void)ButtonPressd;
- (void)ButtonActive:(TIME_BUTTON_VIEW_TYPE)viewType;

@end
