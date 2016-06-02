//
//  WarningView.h
//  ImageTest
//
//  Created by gaozhimin on 13-9-14.
//  Copyright (c) 2013年 autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WarningLable;

@protocol warningLableDelegate <NSObject>

@optional
- (void)clickContentSuccessWith:(WarningLable*)label;

@end

@interface WarningLable : UILabel

- (id)initWithFrame:(CGRect)frame clickContent:(NSString *)content delegate:(id<warningLableDelegate>)delegate;
//获取文字行宽
- (CGFloat)boundingWidthForHeight;
//获取文字总高度
- (CGFloat)boundingHeightForWidth;
@end
