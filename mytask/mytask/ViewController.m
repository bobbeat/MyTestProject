//
//  ViewController.m
//  mytask
//
//  Created by gaozhimin on 2/4/15.
//  Copyright (c) 2015 autonavi. All rights reserved.
//

#import "ViewController.h"
#import "ReservationTableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    ReservationTableViewController *ctl = [[ReservationTableViewController alloc] init];
    [self presentViewController:ctl animated:NO completion:nil];
    [ctl release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
