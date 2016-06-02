//
//  ANPoiPriority.h
//  ANApi
//
//  Created by autonavi\wang.weiyang on 14-10-16.
//  Copyright (c) 2014年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANPoiPriority : NSObject

@property (nonatomic) int priorityId;
@property (nonatomic) int index;
@property (nonatomic) BOOL isChecked;
@property (nonatomic, copy) NSString *name;

@end
