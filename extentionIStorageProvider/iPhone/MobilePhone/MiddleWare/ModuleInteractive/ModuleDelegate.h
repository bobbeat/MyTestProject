//
//  ModuleDelegate.h
//  AutoNavi
//
//  Created by yu.liao on 11-12-17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ModuleDelegate

// 导航模块调用该方法进入子模块	
// 返回值：0失败；1成功
-(int) enter:(NSObject *)param;

// 导航模块调用该方法离开子模块（一般情况下，子模块是调用backToNavi回到导航主模块）
// 返回值：0失败；1成功
-(int) leave;

// 导航模块调用该方法终止子模块（在导航模块因某种原因而需要退出程序，而此时子模块可能还处于执行中，此时导航模块将调用该方法）
// 返回值：0失败；1成功
-(int) exit;

@end
