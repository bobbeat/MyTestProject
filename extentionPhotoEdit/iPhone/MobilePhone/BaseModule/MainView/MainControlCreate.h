//
//  MainControlCreate.h
//  AutoNavi
//  
//  Created by bazinga on 14-8-29.
//  Copyright (c) 2014年 bazinga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainControlCreate : NSObject

#pragma  mark - ---  创建 Button  ---
+ (UIButton *) createButton;

/*!
  @brief    按钮，默认事件为点击事件
  @param
  @author   by bazinga
  */
+ (UIButton *) createButtonWithTitle:(NSString *)title
                         normalImage:(UIImage *)normalImage
                       heightedImage:(UIImage *)heightedImage
                                 tag:(NSInteger)tagN
                              target:(id)target
                              action:(SEL)action;
/*!
  @brief    按钮，可以设置响应事件
  @param
  @author   by bazinga
  */
+ (UIButton *) createButtonWithTitle:(NSString *)title
                         normalImage:(UIImage *)normalImage
                       heightedImage:(UIImage *)heightedImage
                                 tag:(NSInteger)tagN
                              target:(id)target
                              action:(SEL)action
                    forControlEvents:(UIControlEvents)controlEvents;


/*!
  @brief    具有字体位移的按钮
  @param
  @author   by bazinga
  */
+ (ANButton *)createANButtonWithTitle:(NSString *)title
								image:(UIImage *)image
						 imagePressed:(UIImage *)imagePressed
							 imageTop:(UIImage *)imageTop
								  tag:(NSInteger)tagN
                      textOffsetValue:(CGFloat)textOffsetValue
                               target:(id)target
                               action:(SEL)action;

#pragma  mark - ---  创建 UILabel  ---
+ (UILabel *)createLabelWithText:(NSString *)text
                        fontSize:(CGFloat)size
                   textAlignment:(UITextAlignment)textAlignment;

@end
