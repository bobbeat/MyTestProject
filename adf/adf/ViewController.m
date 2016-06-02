//
//  ViewController.m
//  adf
//
//  Created by gaozhimin on 14-7-24.
//  Copyright (c) 2014年 autonavi. All rights reserved.
//

#import "ViewController.h"
#import "zlib.h"
#include "GDBL_Interface.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"%s",zlibVersion());
    GSTATUS res = GDBL_SetAppPath((Gchar *)[[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents"] cStringUsingEncoding:NSUTF16StringEncoding], 256);
    GDBL_Startup(0);
    GDBL_CreateView();
    GDBL_ShowMapView(0, 0, 0, 0);
    GDBL_GetRoadInfoByCoord(NULL, NULL);
    NSLog(@"%s",zlibVersion());
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
