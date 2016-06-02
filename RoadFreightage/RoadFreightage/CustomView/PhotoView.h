//
//  PhotoView.h
//  RoadFreightage
//
//  Created by gaozhimin on 15/6/5.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoView : UIView


- (instancetype)initWithController:(UIViewController *)viewController;

@property (nonatomic,readonly) UILabel *informationlabel;

@property (nonatomic,readonly) UIImageView *imageView;

@end
