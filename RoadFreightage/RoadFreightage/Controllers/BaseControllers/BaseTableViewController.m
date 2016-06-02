//
//  BaseTableViewController.m
//  RoadFreightage
//
//  Created by gaozhimin on 15/6/4.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import "BaseTableViewController.h"

#define RowHeight 50

@interface BaseTableViewController ()<UITableViewDataSource,UITableViewDelegate>


@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wk_banner"]];
    // Do any additional setup after loading the view.
 
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return RowHeight;
}

#pragma mark - SYNetDelegate

- (void)netRequest:(id)request didFailWithError:(NSError *)error;
{

    NSLog(@"\r\n%s: netRequest = %@, errInfo= %@\r\n", __func__, [request class], error);
    if ([error.domain isEqualToString:SYNetErrorDomain])
    {
        if (error.code == SYNetErrorParamCode)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:[NSString stringWithFormat:@"%@%d",[error.userInfo objectForKey:NSLocalizedDescriptionKey],[[error.userInfo objectForKey:SYNetErrorParamCodeKey] intValue] ] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
        }
    }
    
}

@end
