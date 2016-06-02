//
//  UIImage+Category.m
//  RoadFreightage
//
//  Created by yu.liao on 15/6/3.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import "UIImage+Category.h"

@implementation UIImage (Category)

+ (UIImage *)getRoundImageWithImage:(UIImage *)image from:(int)startDegree to:(int)endDegree
{
    if (![image isKindOfClass:[UIImage class]])
    {
        return nil;
    }
    startDegree = startDegree - 90;
    endDegree = endDegree - 90;
    CGSize size = image.size;
    
    CGPoint center = CGPointMake(size.width/2, size.height/2);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, size.width/2, startDegree* M_PI / 180.0, endDegree* M_PI / 180.0, 0);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextTranslateCTM(context, 0,size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), image.CGImage);
    UIImage *changeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return changeImage;
}


+ (UIImage *)getStretchableImageWith:(UIImage *)image
{
    UIImage *stretchableButtonImageNormal = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
    return stretchableButtonImageNormal;
}

@end
