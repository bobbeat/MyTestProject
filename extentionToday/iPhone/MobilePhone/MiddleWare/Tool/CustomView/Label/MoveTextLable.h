//
//  TextMovingLable.h
//  NewLableText
//
//  Created by gaozhimin on 12-9-26.
//  Copyright (c) 2012年 autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

@interface MoveTextLable : UILabel
{
    BOOL mMoving;
    BOOL mColor;
    //
    NSInteger m_nStart;             //染色位置
    NSInteger m_nLength;
    UIColor*    m_colorSpecial; 
}

@property(nonatomic,assign) BOOL mMoving;
@property(nonatomic,assign) BOOL mColor;

- (id)initLabelWithText:(NSString *)str fontSize:(CGFloat)size textAlignment:(UITextAlignment)textAlignment;
- (id)initWithFrame:(CGRect)frame delegate:(id)delegate selector:(SEL)selector;
// 设置某段字的颜色
- (void)setColor:(UIColor *)color fromIndex:(NSInteger)location length:(NSInteger)length;
- (void)ClearDelegate;
@end
