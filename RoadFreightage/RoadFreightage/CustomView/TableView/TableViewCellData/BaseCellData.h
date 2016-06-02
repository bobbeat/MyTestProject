//
//  BaseCellData.h
//  RoadFreightage
//
//  Created by yu.liao on 15/6/6.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BaseCellData : NSObject

@property (copy,nonatomic) NSString *text;                   //一级文本

@property (copy,nonatomic) NSString *detailText;             //二级文本

@property (strong,nonatomic) UIImage *image; //图片



@end
