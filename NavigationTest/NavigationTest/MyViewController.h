//
//  MyViewController.h
//  NavigationTest
//
//  Created by gaozhimin on 14-8-28.
//  Copyright (c) 2014年 autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>

extern UIDeviceOrientation g_lastDeviceOriention;
extern UIDeviceOrientation g_normalDeviceOriention;

typedef enum supportInterface
{
    All_Interface = 0,
    Only_Portrait = 1,
    Only_Landscape = 2,
}supportInterface;

@interface MyViewController : UIViewController

@property (nonatomic,assign) supportInterface supportInterface;
@property (nonatomic,assign) BOOL forcedOrientations;

@end
