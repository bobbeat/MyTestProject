//
//  KeyWordLable.h
//  AutoNavi
//
//  Created by gaozhimin on 12-11-14.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

enum Color_Lable_Type
{
    Key_Lable = 0,
    Address_Lable = 1
};

@interface KeyWordLable : UILabel
{
    int m_HilightFlag;
    UIColor *m_hilightColor;
    enum Color_Lable_Type m_Lable_Type;
}

@property (nonatomic, assign) int m_HilightFlag;//匹配高亮显示，从低位到高位匹配名称字段，最多32位
@property (nonatomic, retain) UIColor *m_hilightColor; //高亮的rgb值;
@property (nonatomic, assign) enum Color_Lable_Type m_Lable_Type; //lable的类型，是关键字，还是门址

- (id)initWithType:(enum Color_Lable_Type)type;
@end
