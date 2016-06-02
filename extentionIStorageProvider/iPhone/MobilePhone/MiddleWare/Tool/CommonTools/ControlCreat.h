//
//  ControlCreat.h
//  AutoNavi
//
//  Created by huang longfeng on 12-4-20.
//  Copyright 2012 autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANButton.h"
@class KLSwitch;

@interface ControlCreat : NSObject {

}
/***************************************************************************************************************
 * 函数名称: createButtonWithTitle:(NSString *)titleT normalImage:(NSString *)normalImage heightedImage:(NSString *)heightedImage tag:(NSInteger)tagN
 * 功能描述: 按钮初始化
 * 参    数: titleT：文字 normalImage：正常显示图片 heightedImage：高亮显示图片 tagN：标记
 * 返 回 值: UIButton
 * 其它说明: 子类实现按钮响应函数：- (void)buttonAction:(id)sender
 ****************************************************************************************************************/
+ (UIButton *)createButtonWithTitle:(NSString *)titleT normalImage:(NSString *)normalImage heightedImage:(NSString *)heightedImage tag:(NSInteger)tagN;

+ (UIButton *)createButtonWithTitle:(NSString *)titleT normalImage:(NSString *)normalImage heightedImage:(NSString *)heightedImage tag:(NSInteger)tagN withImageType:(IMAGEPATHTYPE)type;

/***************************************************************************************************************
 * 函数名称: createANButtonWithTitle:(NSString *)title
 image:(UIImage *)image
 imagePressed:(UIImage *)imagePressed
 imageTop:(UIImage *)imageTop
 tag:(NSInteger)tagN
 textOffsetValue:(CGFloat)textOffsetValue
 * 功能描述: 特殊按钮初始化（图片在按钮上方，文字在图片下面）
 * 参    数: title：文字 image：背景图片 imagePressed：高亮显示图片 imageTop：顶部图片 tagN：标记 textOffsetValue：文字距按钮顶部偏移量
 * 返 回 值: ANButton
 * 其它说明: 子类实现按钮响应函数：- (void)buttonAction:(id)sender
 ****************************************************************************************************************/
+ (ANButton *)createANButtonWithTitle:(NSString *)title
								image:(UIImage *)image
						 imagePressed:(UIImage *)imagePressed
							 imageTop:(UIImage *)imageTop
								  tag:(NSInteger)tagN
					  textOffsetValue:(CGFloat)textOffsetValue;

/***************************************************************************************************************
 * 函数名称: createButtonWithTitle:(NSString *)titleT normalImage:(NSString *)normalImage heightedImage:(NSString *)heightedImage tag:(NSInteger)tagN strechParamX:(NSInteger)xParam strechParamY:(NSInteger)yParam
 * 功能描述: 带拉伸参数的按钮初始化
 * 参    数: titleT：文字 normalImage：正常显示图片 heightedImage：高亮显示图片 tagN：标记 xParam：从x轴第几个像素开始拉伸
 yParam：从y轴第几个像素开始拉伸
 * 返 回 值: UIButton
 * 其它说明: 子类实现按钮响应函数：- (void)buttonAction:(id)sender
 ****************************************************************************************************************/
+ (UIButton*)createButtonWithTitle:(NSString *)titleT normalImage:(NSString *)normalImage heightedImage:(NSString *)heightedImage tag:(NSInteger)tagN strechParamX:(NSInteger)xParam strechParamY:(NSInteger)yParam;

+ (UIButton*)createButtonWithTitle:(NSString *)titleT normalImage:(NSString *)normalImage heightedImage:(NSString *)heightedImage tag:(NSInteger)tagN strechParamX:(NSInteger)xParam strechParamY:(NSInteger)yParam withType:(IMAGEPATHTYPE)type;
/***************************************************************************************************************
 * 函数名称: createActivityIndicatorViewWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style
 * 参    数: style：ActivityIndicatorView类型 － UIActivityIndicatorViewStyleWhiteLarge，UIActivityIndicatorViewStyleWhite
 UIActivityIndicatorViewStyleGray
 * 返 回 值: UIActivityIndicatorView
 * 其它说明:
 ****************************************************************************************************************/
+ (UIActivityIndicatorView *)createActivityIndicatorViewWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style;

/***************************************************************************************************************
 * 函数名称: createLabelWithText:(NSString *)text fontSize:(CGFloat)size textAlignment:(UITextAlignment)textAlignment
 * 功能描述: label创建
 * 参    数: text：文字 size：文字大小 textAlignment：文字对齐方式
 * 返 回 值: UILabel
 * 其它说明:
 ****************************************************************************************************************/
+ (UILabel *)createLabelWithText:(NSString *)text fontSize:(CGFloat)size textAlignment:(UITextAlignment)textAlignment;

/***************************************************************************************************************
 * 函数名称: createSearchBarWithPlaceholder:(NSString *)placeholder tag:(NSInteger)tag
 * 功能描述: 搜索控件创建
 * 参    数: placeholder：默认提示文字 tag：标记
 * 返 回 值: UISearchBar
 * 其它说明:
 ****************************************************************************************************************/
+ (UISearchBar *)createSearchBarWithPlaceholder:(NSString *)placeholder tag:(NSInteger)tag;

/***************************************************************************************************************
 * 函数名称: createActionSheetWithTitle:(NSString *)titleT
 cancelButtonTitle:(NSString *)cancelButtonTitle
 destructiveButtonTitle:(NSString *)destructiveButtonTitle
 otherButtonTitles:(NSArray *)otherButtonTitles
 tag:(NSInteger)tagN
 * 功能描述: ActionSheet控件创建
 * 参    数: titleT：文字 cancelButtonTitle：取消按钮文字 destructiveButtonTitle：文字 otherButtonTitles：其他按钮文字 tagN：标记
 * 返 回 值: UIActionSheet
 * 其它说明:
 ****************************************************************************************************************/
+ (GDActionSheet *)createGDActionSheetWithTitle:(NSString *)titleT
                                       delegate:(id<GDActionSheetDelegate>)delegate
                              cancelButtonTitle:(NSString *)cancelButtonTitle
                         destructiveButtonTitle:(NSString *)destructiveButtonTitle
                                            tag:(NSInteger)tagN
                              otherButtonTitles:(NSString*)other,...;

/***************************************************************************************************************
 * 函数名称: createGDActionSheetWithTitle:(NSString *)titleT
 delegate:(id<GDActionSheetDelegate>)delegate
 cancelButtonTitle:(NSString *)cancelButtonTitle
 destructiveButtonTitle:(NSString *)destructiveButtonTitle
 otherButtonTitles:(NSArray*)other
 tag:(NSInteger)tagN
 * 功能描述: ActionSheet控件创建(otherButtonTitles传入的是数组类型)
 * 参    数: titleT：文字 cancelButtonTitle：取消按钮文字 destructiveButtonTitle：文字 otherButtonTitles：其他按钮文字 tagN：标记
 * 返 回 值: UIActionSheet
 * 其它说明:
 ****************************************************************************************************************/
+ (GDActionSheet *)createGDActionSheetWithTitle:(NSString *)titleT
                                       delegate:(id<GDActionSheetDelegate>)delegate
                              cancelButtonTitle:(NSString *)cancelButtonTitle
                         destructiveButtonTitle:(NSString *)destructiveButtonTitle
                              otherButtonTitles:(NSArray*)other
                                            tag:(NSInteger)tagN;


/***************************************************************************************************************
 * 函数名称: createAlertViewWithTitle:(NSString *)titleT
 message:(NSString *)message
 delegate:(id)delegate
 cancelButtonTitle:(NSString *)cancelButtonTitle
 otherButtonTitles:(NSArray *)otherButtonTitles
 tag:(NSInteger)tagN
 * 功能描述: AlertView控件创建
 * 参    数: titleT：文字 message：详细信息 delegate：委托 cancelButtonTitle：取消按钮文字 otherButtonTitles：其他按钮文字 tagN：标记
 * 返 回 值: UIAlertView
 * 其它说明:
 ****************************************************************************************************************/
+ (GDAlertView *)createAlertViewWithTitle:(NSString *)titleT
                                 delegate:(id)delegate
								  message:(NSString *)message
						cancelButtonTitle:(NSString *)cancelButtonTitle
						otherButtonTitles:(NSArray *)otherButtonTitles
									  tag:(NSInteger)tagN;


/***************************************************************************************************************
 * 函数名称: createTextViewWithTitle:(NSString *)text fontSize:(CGFloat)size textAlignment:(UITextAlignment)textAlignment tag:            (NSInteger)tag
 * 功能描述: UITextView控件创建
 * 参    数: text：文字 size：文字大小 textAlignment：对齐方式 tag：标记
 * 返 回 值: UITextView
 * 其它说明:
 ****************************************************************************************************************/
+ (UITextView *)createTextViewWithTitle:(NSString *)text fontSize:(CGFloat)size textAlignment:(UITextAlignment)textAlignment tag:(NSInteger)tag;

/***************************************************************************************************************
 * 函数名称: createTextFieldWithPlaceholder:(NSString *)text fontSize:(CGFloat)size tag:(NSInteger)kViewTag
 * 功能描述: UITextField控件创建
 * 参    数: text：文字 size：文字大小  tag：标记
 * 返 回 值: UITextField
 * 其它说明:
 ****************************************************************************************************************/
+ (UITextField *)createTextFieldWithPlaceholder:(NSString *)text fontSize:(CGFloat)size tag:(NSInteger)kViewTag;
/***************************************************************************************************************
 * 函数名称: - (UISwitch *) creatSwitchWithFrame:(CGRect)frame tag:(NSInteger)kSwitchtag;
 * 功能描述: UISwitch控件创建
 * 参    数: frame : 控件的fram   kSwitchtag：标记
 * 返 回 值: UISwitch
 * 其它说明:
 ****************************************************************************************************************/
+ (UISwitch *) createSwitchWithFrame:(CGRect)frame tag:(NSInteger)kSwitchtag;

/***************************************************************************************************************
 * 函数名称: - (UISwitch *) creatSwitchWithFrame:(CGRect)frame tag:(NSInteger)kSwitchtag;
 * 功能描述: UISwitch控件创建
 * 参    数: frame : 控件的fram   kSwitchtag：标记      target:委托   selector:执行函数
 * 返 回 值: UISwitch
 * 其它说明:
 ****************************************************************************************************************/
+ (KLSwitch *) createKLSwitchWithTag:(NSInteger)kSwitchtag target:(id)target selector:(SEL)selector;

/***************************************************************************************************************
 * 函数名称: - (UISlider *) creatSliderWithFrame:(CGRect)frame minValue:(float)sliderMiniValue maxValue:(float)sliderMaxValue appearValue:(float)appearVlaue tag:(NSInteger)kSwitchtag;
 * 功能描述: UISlider控件创建
 * 参    数: frame : 控件的fram
 sliderMiniValue: 滑动最小值
 sliderMaxValue：滑动最大值
 appearVlaue ： 显示的值
 ktag：标记
 * 返 回 值: UISlider
 * 其它说明:
 ****************************************************************************************************************/
+ (UISlider *) createSliderWithFrame:(CGRect)frame
                            minValue:(float)sliderMiniValue
                            maxValue:(float)sliderMaxValue
                         appearValue:(float)appearVlaue
                                 tag:(NSInteger)ktag;

/***************************************************************************************************************
 * 函数名称: 创建自定UISlider控件
 * 功能描述: UISlider控件创建
 * 参    数: frame : 控件的fram
 leftTrack :滑动时，左边显示图片
 rightImage ：滑动是，右边显示的图片
 ballImage ： 滑动的小球图片
 sliderMiniValue: 滑动最小值
 sliderMaxValue：滑动最大值
 appearVlaue ： 显示的值
 ktag：标记
 * 返 回 值: UISlider
 * 其它说明:
 ****************************************************************************************************************/
+ (UISlider *) createCustomSliderWithFrame:(CGRect)frame
                                 leftTrack:(UIImage *)leftImage
                                rightTrack:(UIImage *)rightImage
                           silderBallImage:(UIImage *)ballImage
                                  minValue:(float)sliderMiniValue
                                  maxValue:(float)sliderMaxValue
                               appearValue:(float)appearVlaue
                                       tag:(NSInteger)ktag;

/***************************************************************************************************************
 * 函数名称: 创建自定UIProgressView控件
 * 功能描述: UIProgressView控件创建
 * 参    数: frame : 控件的fram
 viewProgressStyle :progressView的风格
 progressValue ： 创建时，显示的进度位置 0.0 .. 1.0
 ktag：标记
 * 返 回 值: UIProgressView
 * 其它说明:
 ****************************************************************************************************************/
+ (UIProgressView *) createProgressWithFrame:(CGRect)frame
                           viewProgressStyle:(UIProgressViewStyle) progressStyle
                               progressValue:(float) progress
                                         tag:(NSInteger)ktag;

/***************************************************************************************************************
 * 函数名称: 创建UIPickerView控件
 * 功能描述: UIPickerView控件创建
 * 参    数: frame : 控件的fram
 ktag：标记
 * 返 回 值: UIPickerView
 * 其它说明:
 ****************************************************************************************************************/
+ (UIPickerView *) createPickViewWithFrame: (CGRect) frame
                                       tag:(NSInteger)ktag;
/***************************************************************************************************************
 * 函数名称: 创建UIImageView控件
 * 功能描述: UIImageView控件创建
 * 参    数: frame : 控件的fram
 normalImage: 正常显示图片
 ktag：标记
 * 返 回 值: UIImageView
 * 其它说明:
 ****************************************************************************************************************/
+ (UIImageView *) createImageViewWithFrame: (CGRect) frame
                               normalImage:(UIImage *)normalImage
                                       tag:(NSInteger)ktag;

/***************************************************************************************************************
 * 函数名称: 创建UIWebView控件
 * 功能描述: UIWebView控件创建
 * 参    数: frame : 控件的fram
 ktag：标记
 * 返 回 值: UIWebView
 * 其它说明:
 ****************************************************************************************************************/
+ (UIWebView *) createWebViewWithFrame: (CGRect) frame
                                   tag:(NSInteger)ktag;

/***************************************************************************************************************
 * 函数名称: 创建UITableView控件
 * 功能描述: UITableView控件创建
 * 参    数: frame : 控件的fram
 style: tableview类型
 * 返 回 值: UITableView
 * 其它说明:
 ****************************************************************************************************************/
+ (UITableView *) createTableViewWithFrame:(CGRect)frame style:(UITableViewStyle)style;
@end
