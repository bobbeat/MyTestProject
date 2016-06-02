//
//  LXActivity.h
//  LXActivityDemo
//
//  Created by lixiang on 14-3-17.
//  Copyright (c) 2014年 lcolco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LXActivityDelegate <NSObject>
/*
 "Share_Sms"="SMS";
 "Share_Friend"="Friends";
 "Share_Moments"="Moments";
 "Share_Sina"="Sina";
 */
/*
 1 短信 2 微信好友 3 微信朋友圈 4 新浪微博
 */
- (void)didClickOnImageIndex:(NSInteger )didSelect;
@optional
- (void)didClickOnCancelButton;
@end


@interface SociallShareManage : NSObject
/*
 tag 0->表示分享 1->表示其他
 */
+ (void)ShowViewWithDelegate:(id<LXActivityDelegate>)delegate andWithImage:(NSArray *)arrayImage andWithTitle:(NSArray *)titleArray;

+ (void)RemoveSocialWindow;

@end
