//
//  Plugin_ColorTitleButton.h
//  AutoNavi
//
//  Created by gaozhimin on 12-12-19.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

@interface Plugin_ColorTitleButton : UIButton
{
    NSString *m_colorTitle;
    UIColor *m_color;
    int m_x;
    int m_y;
}

@property(copy,nonatomic)  NSString *m_colorTitle;
@property(retain,nonatomic)  UIColor *m_color;

@end
