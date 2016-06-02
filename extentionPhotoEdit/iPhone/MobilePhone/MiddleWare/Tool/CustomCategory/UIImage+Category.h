//
//  UIImage+Category.h
//  AutoNavi
//
//  Created by huang longfeng on 13-3-1.
//
//

#import <UIKit/UIKit.h>
#import "MWTypedef.h"

@interface UIImage (Category)

//获取图片 name:图片名称 imagePathType:图片获取类型(1 从mainbundle中获取 2 区分白天黑夜的bundle)
+ (UIImage *)imageWithName:(NSString *)name pathType:(IMAGEPATHTYPE)imagePathType;

//设置白天黑夜模式
+ (void)setImageDayNightMode:(BOOL)dayNightMode;

//设置皮肤类型：NO 默认 YES 指定皮肤
+ (void)setImageSkinType:(BOOL)skinType SkinPath:(NSString *)skinPath;

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

@end
