//
//  ColorLable.h
//  ColorLableTest
//
//  Created by gaozhimin on 12-9-18.
//  Copyright (c) 2012年 autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

@interface ColorLable : UILabel
{
    
}

@property (nonatomic,assign) int bTop;  //文字位置 0：中间 1：置顶
@property (nonatomic, assign) float lineSpace;  //行间距

/**
 *	用于渲染文字中的数字
 *
 *	@param	frame	lable大小
 *	@param	color_array	渲染数字的颜色，按照数字出现的顺序，创建相对应颜色，若数字的个数超过颜色数组，则再从颜色数组中遍历一次。
 *  例如 数字有五个。颜色只有2个（红，蓝），那么按照数字出现的顺序，颜色分别为，红蓝红蓝红。 不明白的欢迎咨询
 *
 *	@return	返回Lable对象
 */
- (id)initWithFrame:(CGRect)frame ColorArray:(NSArray *)color_array;
- (void)setColorText:(NSString *)text,...;
/*!
  @brief    添加一个参数，设置数字的字体大小~~~
  @param
  @author   by bazinga
  */
- (id)initWithFrame:(CGRect)frame ColorArray:(NSArray *)color_array TextFontArray:(UIFont *)numFont;

@end
