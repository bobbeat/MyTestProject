//
//  CustomCellDataContainTextField.h
//  RoadFreightage
//
//  Created by yu.liao on 15/6/6.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomCellData.h"

@interface CustomCellDataContainTextField : CustomCellData

@property (copy,nonatomic) NSString *cellFieldText;               //cell中UITextField的内容

@property (copy,nonatomic) NSString *placeholder;                 //cell中UITextField的占位符

@end
