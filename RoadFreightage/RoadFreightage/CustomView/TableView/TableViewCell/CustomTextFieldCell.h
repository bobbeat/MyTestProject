//
//  CustomTextFieldCell.h
//  RoadFreightage
//
//  Created by mac on 15/6/6.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import "BaseCell.h"

typedef void (^ VerificationButtonPressedBlock)(id object);

@interface CustomTextFieldCell : BaseCell

@property (strong,nonatomic) UITextField *textField;
@property (strong,nonatomic) NSString *cellTitle;
@property (assign,nonatomic) BOOL isShowVerificationButton; //是否显示验证码按钮
@property (strong,nonatomic) VerificationButtonPressedBlock verificationBlock; //验证码按钮响应Block
@property (assign,nonatomic) BOOL isCountDown;          //验证码是否进入倒计时状态

@end
