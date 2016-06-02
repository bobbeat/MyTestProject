//
//  MoreViewController.m
//  RoadFreightage
//
//  Created by yu.liao on 15/6/2.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import "MoreViewController.h"
#import "CustomCellData.h"
#import "DriverAuthViewController.h"
#import "UIImage+Category.h"
#import "LoginStorage.h"
#import "LoginViewController.h"

@interface MoreViewController ()<SYNetDelegate>
{
    UIButton *_logoutButton;
    SYNetAPI * _syNet;
}

@property (nonatomic,strong)  NSArray *cellDataObj;

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _syNet = [[SYNetAPI alloc] init];
    _syNet.delegate = self;
    
    _logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_logoutButton setBackgroundImage:[UIImage getStretchableImageWith:[UIImage imageNamed:@"wk_btn_background.png"]] forState:UIControlStateNormal];
    [_logoutButton setTitle:@"注销" forState:UIControlStateNormal];
    [_logoutButton addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
    
    CustomCellData *cellData = [[CustomCellData alloc] init];
    cellData.text = @"车辆认证";
    __block MoreViewController *weakself = self;
    cellData.cellActionBlock = ^(id object){
        DriverAuthViewController *ctl = [[DriverAuthViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [weakself.navigationController pushViewController:ctl animated:YES];
    };
    
    CustomCellData *feedBackData = [[CustomCellData alloc] init];
    feedBackData.text = @"问题反馈";
    feedBackData.cellActionBlock = nil;
    
    CustomCellData *rateData = [[CustomCellData alloc] init];
    rateData.text = @"去评分";
    rateData.cellActionBlock = nil;
    
    CustomCellData *aboutData = [[CustomCellData alloc] init];
    aboutData.text = @"关于";
    aboutData.cellActionBlock = nil;
    
    self.cellDataObj = @[@[cellData],@[feedBackData,rateData,aboutData]];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.tableView.frame = self.view.bounds;
}

#pragma mark - Action Handle

- (void)logoutAction
{
    [QLoadingView showDefaultLoadingView:@"加载中"];
    
    LoginResponse *data = [LoginStorage getUserData];
    
    LogoutRequest *logoutObj = [[LogoutRequest alloc] init];
    logoutObj.requestType       = SYNetType_Logout;
    logoutObj.sid               = data.sid;
    logoutObj.userid            = data.userid;
    logoutObj.usertype          = @"driver";
    logoutObj.platform          = @"IOS";
    
    [_syNet logout:logoutObj];
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
    if (section == [self.cellDataObj count] - 1) {
        [view addSubview:_logoutButton];
        _logoutButton.bounds = CGRectMake(0, 0, view.bounds.size.width - 20, BTN_Height);
        _logoutButton.center = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);

    }
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

#pragma mark - SYNetDelegate

/*!
 @brief 当请求发生错误时，会调用代理的此方法.
 @param request 发生错误的请求.
 @param error   返回的错误.
 */
- (void)netRequest:(id)request didFailWithError:(NSError *)error;
{
    [QLoadingView hideWithAnimated:NO];
    
    [super netRequest:request didFailWithError:error];
}

/*!
 @brief 注销的回调函数
 @param request 发起请求的请求选项(具体字段参考LogoutRequest类中的定义)
 @param response 请求结果(具体字段参考LogoutResponse类中的定义)
 */
- (void)onLogoutDone:(LogoutRequest *)request response:(LogoutResponse *)response
{
    [QLoadingView hideWithAnimated:NO];

    LoginViewController *ctl = [[LoginViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.navigationController.viewControllers = @[ctl];
    
    [LoginStorage deleteLocalUserData];
}

@end
