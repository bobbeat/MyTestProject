//
//  ViewController.m
//  tableviewPlain
//
//  Created by gaozhimin on 15/1/28.
//  Copyright (c) 2015年 autonavi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //取消注销按钮
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    
//    return 20.0;
//}
//
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    //    return 150;
//    
//    return 30;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    float height = [self tableView:tableView heightForFooterInSection:section];
//    UILabel *view = nil;
//    view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];
//    view.text = [NSString stringWithFormat:@"Footer section = %d",section];
//    return view;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    float height = [self tableView:tableView heightForFooterInSection:section];
//    UILabel *view = nil;
//    view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];
//    view.text = [NSString stringWithFormat:@"Header section = %d",section];
//    return view;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Personal_CellIdentifier_0";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    
    // Configure the cell...
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundView = nil;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 48)];
    view.backgroundColor = [UIColor whiteColor];
    cell.backgroundView = view;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}


@end
