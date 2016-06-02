//
//  UIImage+Category.h
//  RoadFreightage
//
//  Created by yu.liao on 15/6/3.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Category)

/**
 *	获取图片 扇形部分
 *
 *	@param	image	需要剪切的图片
 *	@param	startDegree	剪切的起始度数。以正北为基准 范围（0 - 360）
 *	@param	endDegree	剪切的结束度数。以正北为基准 范围（0 - 360）
 *
 *	@return	返回剪切后的扇形图片
 */
+ (UIImage *)getRoundImageWithImage:(UIImage *)image from:(int)startDegree to:(int)endDegree;

/**
 *	获取拉伸后的图片，从图片的中心点位置开始拉伸
 *
 *	@param	image	需要拉伸的图片
 *
 *	@return	返回拉伸后的图片
 */
+ (UIImage *)getStretchableImageWith:(UIImage *)image;

@end
