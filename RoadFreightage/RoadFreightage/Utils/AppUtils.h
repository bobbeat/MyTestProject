//
//  AppUtils.h
//  RoadFreightage
//
//  Created by yu.liao on 15/6/3.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppUtils : NSObject

/********************** System Utils ***********************/
//弹出UIAlertView
+ (void)showAlertMessage:(NSString *)msg;
//关闭键盘
+ (void)closeKeyboard;
//获取MD5加密后字符串
+ (NSString *)md5FromString:(NSString *)str;

/******* UITableView & UINavigationController Utils *******/
//返回View覆盖多余的tableview cell线条
+ (UIView *)tableViewsFooterView;
//返回UILabel作为UITableView的header
+ (UILabel *)tableViewsHeaderLabelWithMessage:(NSString *)message;
//获取没有文字的导航栏返回按钮
+ (UIBarButtonItem *)navigationBackButtonWithNoTitle;

/********************** NSDate Utils ***********************/
//根据指定格式将NSDate转换为NSString
+ (NSString *)stringFromDate:(NSDate *)date formatter:(NSString *)formatter;
//根据指定格式将NSString转换为NSDate
+ (NSDate *)dateFromString:(NSString *)dateString formatter:(NSString *)formatter;

/********************* Verification Utils **********************/
//验证手机号码合法性（正则）
+ (BOOL)checkPhoneNumber:(NSString *)phoneNumber;

@end
