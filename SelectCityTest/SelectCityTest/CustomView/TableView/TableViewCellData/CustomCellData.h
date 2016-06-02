//
//  CustomCellData.h
//  RoadFreightage
//
//  Created by gaozhimin on 15/6/4.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseCellData.h"

typedef void (^ CellActionBlock)(id object);

@interface CustomCellData : BaseCellData


@property (strong,nonatomic) CellActionBlock cellActionBlock;    //cell 点击事件

@end
