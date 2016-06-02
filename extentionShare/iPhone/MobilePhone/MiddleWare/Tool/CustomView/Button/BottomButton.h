//
//  BottomButton.h
//  AutoNavi
//
//  Created by jiangshu.fu on 13-9-9.
//
//

#import <UIKit/UIKit.h>

typedef void (^BottomButoonPress)(id);
typedef void (^BottomButoonPressCancel)(id);

@interface BottomButton : UIButton
{
}

@property (nonatomic, assign) CGFloat textOffsetValue;
@property (nonatomic, assign) CGFloat textRightsetValue;
@property (nonatomic, assign) CGRect imageRect;
@property (nonatomic, assign) CGFloat   textWidth;
@property (nonatomic, copy) BottomButoonPress buttonPress;
@property (nonatomic, copy) BottomButoonPressCancel buttonPressCancel;

@end

