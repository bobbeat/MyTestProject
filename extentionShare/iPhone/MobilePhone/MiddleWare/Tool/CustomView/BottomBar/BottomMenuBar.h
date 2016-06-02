//
//  BottomMenuBar.h
//  testRightViewController
//
//  Created by bazinga on 13-8-26.
//  Copyright (c) 2013年 bazinga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottomButton.h"

typedef enum BottomMenuBarType
{
    BOTTOM_MENU_NO_HEADER,
    BOTTOM_MENU_HAS_HEADER
}BottomMenuBarType;

#pragma  mark - ---  BottomMenuInfo 对象  ---
/***
 ***
 * Bottom显示所需要的数据信息类
 ***
 * 有两项是要有数据的，否则，因为默认的值为0，修改都会在第一个位置
 * tag -- button的唯一标志符
 * index -- 表示button所放的位置
 ***/
@interface BottomMenuInfo : NSObject

@property (nonatomic, copy) NSString *title;                //标题
@property (nonatomic, retain) UIImage *image;               //图片
@property (nonatomic, retain) UIImage *highlightedImage;    //高亮图片
@property (nonatomic, assign) NSUInteger tag;                //button的tag
@property (nonatomic, assign) NSUInteger index;              //button所放位置的顺序 0 - _buttonNum
@property (nonatomic, copy) BottomButoonPress buttonPress;  //按钮的响应消息
@property (nonatomic, copy) BottomButoonPressCancel buttonPressCancel;  //取消点击的消息
@end

#pragma  mark - ---  BottomMenuBar 对象  ---

@interface BottomMenuBar : UIView
{
    int _buttonNum;
    CGFloat _fonsize;
    
    NSMutableArray *_images;
    NSMutableArray *_buttons;
    
    UIView *_viewHeader;
    UIImageView *_imageViewBack;
}

@property (nonatomic, assign) CGFloat textOffsetValue;
@property (nonatomic, assign) CGFloat textRightsetValue;
@property (nonatomic, assign) CGRect imageRect;
@property (nonatomic, assign) BottomMenuBarType bottomMenuBarType;
@property (nonatomic, assign) CGFloat textWidth;
//是否是竖着显示（默认是横着显示）
@property (nonatomic, assign) BOOL  isVertical;
/***
 * @name    初始化按钮底栏
 * @param   @frame 大小位置
 * @param   @buttonNum 按钮个数
 * @param   @images 背景图片 -- 传入nil 使用默认的背景图 
 * @author  by bazinga
 ***/
- (id) initWithFrame:(CGRect)frame
    withButtonNumber:(int) buttonNum
withButtonBackImages:(NSArray *)images;

//设置所有数据
- (BOOL) setButtonsTitle:(NSArray *)titles
                withIcon:(NSArray *)icons
     withHighlightedIcon:(NSArray *)highlightedIcon
             withOffset:(int)offset
       withTextFontSize:(CGFloat)fontsize
                withTag:(NSArray *)tags;

//设置单个数据
- (BOOL) setSingleButton:(NSString *)title
                withIcon:(UIImage *)icon
     withHighlightedIcon:(UIImage *)highlightedIcon
                 withTag:(int) tag
            withFontSize:(CGFloat)fontsize
               withIndex:(int)index;

//通过自定义的button对象设置button的数据
- (BOOL) setSingleByInfo:(BottomMenuInfo *)buttonInfo;
//通过一组自定义数据，设置数据
- (BOOL) SetButtonsByInfoes :(NSArray *)infoArray;

//设置某一个tag的button可以选中——一直处于高亮状态
//传入 -1 ，清除所有选中状态
- (void) selectTag :(int) tag;
//设置不同状态下，标题的颜色
- (void) setTitleColor:(UIColor *)color forState:(UIControlState)state;
//设置标题的字体
- (void) setTitleFont:(UIFont *)font;
//根据 tag 设置标题文字大小
- (void) setTitleFont:(UIFont *)font withTag:(int)tag;
//设置标题的对齐方式
- (void) setTextAlignment:(NSTextAlignment)textAlignment;
//返回button数组
- (NSMutableArray *)getButtonArray;
//设置 button 的 titleLabel 的现实方式
- (void) setButtonsType :(UILineBreakMode) lineBreakMode;
//返回button数组
- (int)getButtonCount;
//返回单个按钮的宽度
- (CGFloat) buttonWidth;
//设置背景图片
- (void) setBackImages: (NSArray *)images;
//设置按钮图片
- (void) setImages :(NSArray *)images  withState:(UIControlState) state;
//设置整体的背景图片
- (void) setBackgroundImage:(UIImage *) backImage;
@end


