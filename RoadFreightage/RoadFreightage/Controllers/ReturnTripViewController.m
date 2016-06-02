//
//  ReturnTripViewController.m
//  RoadFreightage
//
//  Created by gaozhimin on 15/6/9.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import "ReturnTripViewController.h"
#import "CustomCellData.h"
#import "UIImage+Category.h"

@interface ReturnTripViewController ()
{
    UIButton *_btnCommit;
    UIButton *_btnCancel;
}

@property (nonatomic,strong)  NSArray *cellDataObj;

@end

@implementation ReturnTripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    __block ReturnTripViewController *weakself = self;

    CustomCellData *start = [[CustomCellData alloc] init];
    start.text = @"出发地";
    start.cellActionBlock = ^(id object){
        
    };
    
    CustomCellData *end = [[CustomCellData alloc] init];
    end.text = @"目的地";
    end.cellActionBlock = ^(id object){
        
    };
    
    CustomCellData *time = [[CustomCellData alloc] init];
    time.text = @"时间";
    time.cellActionBlock = ^(id object){
        
    };
    
    self.cellDataObj = @[@[start,end,time]];
    
    _btnCommit = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnCommit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnCommit setBackgroundImage:[UIImage getStretchableImageWith:[UIImage imageNamed:@"wk_btn_background.png"]] forState:UIControlStateNormal];
    [_btnCommit setTitle:@"提交" forState:UIControlStateNormal];
    [_btnCommit addTarget:self action:@selector(commitAction) forControlEvents:UIControlEventTouchUpInside];
    
    _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnCancel setBackgroundImage:[UIImage getStretchableImageWith:[UIImage imageNamed:@"wk_btn_background.png"]] forState:UIControlStateNormal];
    [_btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [_btnCancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Action

- (void)commitAction
{
    
}

- (void)cancelAction
{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.cellDataObj count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.cellDataObj objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return HeightForHeader;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    float height = [self tableView:tableView heightForHeaderInSection:section];
//    UIView *view = nil;
//    view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([self.cellDataObj count] - 1 == section) {
        return 100;
    }
    return HeightForFooter;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    float height = [self tableView:tableView heightForFooterInSection:section];
    
    UIView *view = nil;
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];
    [view addSubview:_btnCommit];
    [view addSubview:_btnCancel];
    
    _btnCommit.bounds = CGRectMake(0, 0, view.bounds.size.width/2 - 10, BTN_Height);
    _btnCommit.center = CGPointMake(view.bounds.size.width/4, view.bounds.size.height/2);
    
    _btnCancel.bounds = CGRectMake(0, 0, view.bounds.size.width/2 - 10, BTN_Height);
    _btnCancel.center = CGPointMake(view.bounds.size.width*3/4, view.bounds.size.height/2);
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    CustomCellData *cellData = [[self.cellDataObj objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = cellData.text;
    cell.detailTextLabel.text = cellData.detailText;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCellData *cellData = [[self.cellDataObj objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (cellData.cellActionBlock)
    {
        cellData.cellActionBlock(nil);
    }
}

@end
