//
//  SelectCityViewController.m
//  SelectCityTest
//
//  Created by gaozhimin on 15/7/20.
//  Copyright (c) 2015年 autonavi. All rights reserved.
//

#import "SelectCityViewController.h"
#import "CustomCellDataContainTextField.h"
#import "UIImage+Category.h"
#import "CustomTextFieldCell.h"
#import "LoginStorage.h"
#import "MainTabBarController.h"

@interface SelectCityViewController ()<UITextFieldDelegate>
{
    UIImageView *_logoImageView;
    UIImageView *_logoTextImageView;
    
    UIButton *_loginButton;
    
    CustomTextFieldCell *_verificationCell;
}

@property (nonatomic,strong)  NSArray *cellDataObj;


@end

@implementation SelectCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _syNet = [[SYNetAPI alloc] init];
    _syNet.delegate = self;
    
    _logoImageView = [[UIImageView alloc] init];
    _logoImageView.image = [UIImage imageNamed:@"wk_appicon"];
    _logoImageView.bounds = CGRectMake(0, 0, _logoImageView.image.size.width, _logoImageView.image.size.height);
    
    _logoTextImageView = [[UIImageView alloc] init];
    _logoTextImageView.image = [UIImage imageNamed:@"wk_banner"];
    _logoTextImageView.bounds = CGRectMake(0, 0, _logoTextImageView.image.size.width, _logoTextImageView.image.size.height);
    
    _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_loginButton setBackgroundImage:[UIImage getStretchableImageWith:[UIImage imageNamed:@"wk_btn_background.png"]] forState:UIControlStateNormal];
    [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableArray *sectionArray = [NSMutableArray array];
    CustomCellDataContainTextField *cellData = [[CustomCellDataContainTextField alloc] init];
    cellData.placeholder = @"请输入";
    cellData.text = @"手机号";
    [sectionArray addObject:cellData];
    
    cellData = [[CustomCellDataContainTextField alloc] init];
    cellData.placeholder = @"请输入";
    cellData.text = @"验证码";
    [sectionArray addObject:cellData];
    
    self.cellDataObj = @[sectionArray];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.tableView.scrollEnabled = NO;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(textFieldDidChange:) name: UITextFieldTextDidChangeNotification object: nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  Action Handle

- (void)getVerificationCodeAction
{
    [QLoadingView showDefaultLoadingView:@"加载中"];
    
    CustomCellDataContainTextField *cellData = [[self.cellDataObj objectAtIndex:0] objectAtIndex:0];
    NSString *phone = cellData.cellFieldText;
    VerifyCodeRequest *verifyCode = [[VerifyCodeRequest alloc] init];
    verifyCode.requestType  = SYNetType_VerifyCode;
    verifyCode.sid          = @"";
    verifyCode.userid       = 0;
    verifyCode.usertype     = @"driver";
    verifyCode.platform     = @"IOS";
    verifyCode.phone        = phone;
    
    [_syNet getVerifyCode:verifyCode];
}

- (void)loginAction
{
    [QLoadingView showDefaultLoadingView:@"加载中"];
    
    CustomCellDataContainTextField *cellData = [[self.cellDataObj objectAtIndex:0] objectAtIndex:0];
    NSString *phone = cellData.cellFieldText;
    
    cellData = [[self.cellDataObj objectAtIndex:0] objectAtIndex:1];
    NSString *code = cellData.cellFieldText;
    
    LoginRequest *loginObj = [[LoginRequest alloc] init];
    loginObj.requestType  = SYNetType_Login;
    loginObj.sid          = @"";
    loginObj.userid       = 0;
    loginObj.usertype     = @"driver";
    loginObj.platform     = @"IOS";
    loginObj.phone        = phone;
    loginObj.code         = code;
    [_syNet login:loginObj];
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
    return 170.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    float height = [self tableView:tableView heightForHeaderInSection:section];
    
    UIView *view = nil;
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [view addSubview:_logoImageView];
    [view addSubview:_logoTextImageView];
    
    int length = _logoImageView.image.size.height + _logoTextImageView.image.size.height;
    
    _logoImageView.center = CGPointMake(view.bounds.size.width/2, (view.bounds.size.height-length)/2 + _logoImageView.image.size.height/2);
    _logoTextImageView.center = CGPointMake(view.bounds.size.width/2,CGRectGetMaxY(_logoImageView.frame)+_logoTextImageView.image.size.height/2+10);
    
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    float height = [self tableView:tableView heightForFooterInSection:section];
    
    UIView *view = nil;
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [view addSubview:_loginButton];
    
    _loginButton.bounds = CGRectMake(0, 0, view.bounds.size.width - 20, BTN_Height);
    _loginButton.center = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    CustomTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[CustomTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    CustomCellDataContainTextField *cellData = [[self.cellDataObj objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.cellTitle = cellData.text;
    cell.textField.placeholder = cellData.placeholder;
    cell.textField.delegate = self;
    cell.textField.tag = indexPath.row;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0)
    {
        cell.isShowVerificationButton = NO;
    }
    else
    {
        _verificationCell = cell;
        __block LoginViewController *weakself = self;
        cell.isShowVerificationButton = YES;
        cell.verificationBlock = ^(id object)
        {
            [weakself getVerificationCodeAction];
        };
    }
    
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

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidChange:(NSNotification *)notification
{
    UITextField *textField = nil;
    
    NSObject* obj = [notification object];
    if ([obj isKindOfClass:[UITextField class]])
    {
        textField = (UITextField*)obj;
        
    }
    if (textField)
    {
        CustomCellDataContainTextField *cellData = [[self.cellDataObj objectAtIndex:0] objectAtIndex:textField.tag];
        cellData.cellFieldText = textField.text;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - SYNetDelegate

- (void)netRequest:(id)request didFailWithError:(NSError *)error;
{
    [QLoadingView hideWithAnimated:NO];
    
    [super netRequest:request didFailWithError:error];
}

- (void)onVerifyCodeDone:(VerifyCodeRequest *)request response:(VerifyCodeResponse *)response
{
    [QLoadingView hideWithAnimated:NO];
    
    _verificationCell.isCountDown = YES;
    
    NSLog(@"\r\n%s: netRequest = %@, resoponse= %@\r\n", __func__, [request class], response);
}

- (void)onLoginDone:(LoginRequest *)request response:(LoginResponse *)response
{
    [QLoadingView hideWithAnimated:NO];
    
    MainTabBarController *ctl = [[MainTabBarController alloc] init];
    self.navigationController.viewControllers = @[ctl];
    
    [LoginStorage saveUserData:response];
    
    NSLog(@"\r\n%s: netRequest = %@, resoponse= %@\r\n", __func__, [request class], response);
    
}

@end
