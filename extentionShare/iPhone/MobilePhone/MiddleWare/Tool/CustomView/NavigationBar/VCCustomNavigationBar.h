//
//  VCCustomNavigationBar.h
//  Custom NavBar
//
//  Created by ljj on 12-7-16.
//  Copyright (c) 2012年 autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCCustomNavigationBar : UINavigationBar
@property (nonatomic, strong) UIImage *navigationBarBackgroundImage;
@property (nonatomic, strong) UIImage *landscapeBarBackground;
@property (nonatomic, strong) UIImage *portraitBarBackground;
@property(nonatomic)BOOL isRotate;
- (void)setBackgroundForDeviceOrientation:(UIDeviceOrientation)orientation;
- (void)clearBackground;
- (void)refeshBackground;
@end
