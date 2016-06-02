//
//  DriverAuthController.m
//  RoadFreightage
//
//  Created by yu.liao on 15/6/3.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import "DriverAuthViewController.h"
#import "CustomCellDataContainTextField.h"
#import "CustomTextFieldCell.h"
#import "PhotoView.h"
#import "UIImage+Category.h"
#import "SYNetAPI.h"
#import "LoginStorage.h"
#import "QLoadingView.h"

@interface DriverAuthViewController ()<UITextFieldDelegate>
{
    UIButton *_btnCommit;
    SYNetAPI * _syNet;
    LoginResponse *_userData;             //用户数据
    PhotoView   *_viewDriverlicense;        //驾驶证
    PhotoView   *_viewDrivinglicense;        //行驶证
    PhotoView   *_viewCar;                  //驾驶证
}

@property (nonatomic,strong) NSMutableArray *cellDataArray;

@property (nonatomic,strong) NSArray *viewArray;

@end

@implementation DriverAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _userData = [LoginStorage getUserData];
    
    _syNet = [[SYNetAPI alloc] init];
    _syNet.delegate = self;
    
    self.cellDataArray = [[NSMutableArray alloc] init];
    
    CustomCellDataContainTextField *cellData = [[CustomCellDataContainTextField alloc] init];
    cellData.text = @"姓名";
    cellData.placeholder = @"请输入";
    cellData.cellFieldText = _userData.username;
    [self.cellDataArray addObject:cellData];
    
    cellData = [[CustomCellDataContainTextField alloc] init];
    cellData.text = @"物流公司";
    cellData.placeholder = @"请输入";
    cellData.cellFieldText = _userData.corpName;
    [self.cellDataArray addObject:cellData];
    
    cellData = [[CustomCellDataContainTextField alloc] init];
    cellData.text = @"车辆类型";
    cellData.placeholder = @"请输入";
    cellData.cellFieldText = _userData.carType;
    [self.cellDataArray addObject:cellData];
    
    cellData = [[CustomCellDataContainTextField alloc] init];
    cellData.text = @"长(米)";
    cellData.placeholder = @"请输入";
    cellData.cellFieldText = [NSString stringWithFormat:@"%.0lf",_userData.carLength];
    [self.cellDataArray addObject:cellData];
    
    cellData = [[CustomCellDataContainTextField alloc] init];
    cellData.text = @"宽(米)";
    cellData.placeholder = @"请输入";
    cellData.cellFieldText = [NSString stringWithFormat:@"%.0lf",_userData.carWidth];
    [self.cellDataArray addObject:cellData];
    
    cellData = [[CustomCellDataContainTextField alloc] init];
    cellData.text = @"高(米)";
    cellData.placeholder = @"请输入";
    cellData.cellFieldText = [NSString stringWithFormat:@"%.0lf",_userData.carHeight];
    [self.cellDataArray addObject:cellData];
    
    cellData = [[CustomCellDataContainTextField alloc] init];
    cellData.text = @"载重量(吨)";
    cellData.placeholder = @"请输入";
    cellData.cellFieldText = [NSString stringWithFormat:@"%.0lf",_userData.carLoad];
    [self.cellDataArray addObject:cellData];
    
    cellData = [[CustomCellDataContainTextField alloc] init];
    cellData.text = @"车牌号";
    cellData.placeholder = @"请输入";
    cellData.cellFieldText = _userData.carNum;
    [self.cellDataArray addObject:cellData];
    
    cellData = [[CustomCellDataContainTextField alloc] init];
    cellData.text = @"车辆名称";
    cellData.placeholder = @"请输入";
    cellData.cellFieldText = _userData.carName;
    [self.cellDataArray addObject:cellData];
    
    NSMutableArray *photoViewArray1 = [[NSMutableArray alloc] init];
    _viewDriverlicense = [[PhotoView alloc] initWithController:self];
    _viewDriverlicense.informationlabel.text = @"驾驶证";
    [photoViewArray1  addObject:_viewDriverlicense];
    
    NSMutableArray *photoViewArray2 = [[NSMutableArray alloc] init];
    _viewDrivinglicense = [[PhotoView alloc] initWithController:self];
    _viewDrivinglicense.informationlabel.text = @"行驶证";
    [photoViewArray2  addObject:_viewDrivinglicense];
    
    NSMutableArray *photoViewArray3 = [[NSMutableArray alloc] init];
    _viewCar = [[PhotoView alloc] initWithController:self];
    _viewCar.informationlabel.text = @"车辆";
    [photoViewArray3  addObject:_viewCar];
    
    self.viewArray =@[self.cellDataArray,photoViewArray1,photoViewArray2,photoViewArray3];
    
    _btnCommit = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnCommit setBackgroundImage:[UIImage getStretchableImageWith:[UIImage imageNamed:@"wk_btn_background.png"]] forState:UIControlStateNormal];
    [_btnCommit setTitle:@"提交" forState:UIControlStateNormal];
    [_btnCommit addTarget:self action:@selector(commitAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
#pragma mark - Action Handle

- (void)commitAction
{
    UploadImageRequest *imageDriverlicense = [[UploadImageRequest alloc] init];
    imageDriverlicense.requestType     = SYNetType_UploadImage;
    imageDriverlicense.sid             = _userData.sid;
    imageDriverlicense.userid          = _userData.userid;
    imageDriverlicense.usertype        = _userData.usertype;
    imageDriverlicense.platform        = @"IOS";
    imageDriverlicense.imgType         = @"driver_license_img";
    imageDriverlicense.image           = _viewDriverlicense.imageView.image;
    [_syNet uploadImage:imageDriverlicense];
    
    [QLoadingView showDefaultLoadingView:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.viewArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [[self.viewArray objectAtIndex:section] count];;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HeightForHeader;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    float height = [self tableView:tableView heightForHeaderInSection:section];
//    UIView *view = nil;
//    if (section == 0)
//    {
//        view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];
//    }
//    else
//    {
//        view = [_photoViewArray objectAtIndex:section - 1];
//    }
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([self.viewArray count] - 1 == section) {
        return 100;
    }
    return HeightForFooter;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    float height = [self tableView:tableView heightForFooterInSection:section];
    
    UIView *view = nil;
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];
    if (section == [self.viewArray count] - 1) {
        UIView *subView = _btnCommit;
        [view addSubview:subView];
        subView.bounds = CGRectMake(0, 0, view.bounds.size.width - 20, BTN_Height);
        subView.center = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
        
    }
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        static NSString *cellIdentifier = @"cellIdentifier";
        
        CustomTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil )
        {
            cell = [[CustomTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        CustomCellDataContainTextField *cellData = [self.cellDataArray objectAtIndex:indexPath.row];
        cell.cellTitle = cellData.text;
        cell.textField.delegate = self;
        cell.textField.tag = indexPath.row;
        cell.textField.text = cellData.cellFieldText;
        cell.textField.placeholder = cellData.placeholder;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else
    {
        static NSString *cellIdentifier = @"cellIdentifier1";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil )
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        UIView *view = [cell viewWithTag:100];
        if (view) {
            [view removeFromSuperview];
        }
        view = [[self.viewArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row ];
        [cell.contentView addSubview:view];
        view.frame = cell.bounds;
        view.tag = 100;

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCellData *cellData = [_cellDataArray objectAtIndex:indexPath.row];
    
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
        CustomCellDataContainTextField *cellData = [_cellDataArray objectAtIndex:textField.tag];
        cellData.cellFieldText = textField.text;
        
        NSInteger tag = textField.tag;
        switch (tag) {
            case 0:
                _userData.username = textField.text;
                break;
            case 1:
                _userData.corpName = textField.text;
                break;
            case 2:
                _userData.carType = textField.text;
                break;
            case 3:
                _userData.carLength = [textField.text doubleValue];
                break;
            case 4:
                _userData.carWidth = [textField.text doubleValue];
                break;
            case 5:
                _userData.carHeight = [textField.text doubleValue];
                break;
            case 6:
                _userData.carLoad = [textField.text doubleValue];
                break;
            case 7:
                _userData.carNum = textField.text;
                break;
            case 8:
                _userData.carName = textField.text;
                break;
            default:
                break;
        }
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
    [super netRequest:request didFailWithError:error];
}

/*!
 @brief 司机认证
 @param request 发起请求的请求选项(具体字段参考DriverReportStatusRequest类中的定义)
 @param response 请求结果(具体字段参考DriverReportStatusResponse类中的定义)
 */
- (void)onDriverAuthDone:(DriverAuthRequest *)request response:(DriverAuthResponse *)response
{
    [QLoadingView hideWithAnimated:NO];
    _userData.authStatus = response.authStatus;
    [LoginStorage saveUserData:_userData];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"认证成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

/*!
 @brief 图片上传
 @param request 发起请求的请求选项(具体字段参考UploadImageRequest类中的定义)
 @param response 请求结果(具体字段参考UploadImageResponse类中的定义)
 */
- (void)onUploadImageDone:(UploadImageRequest *)request response:(UploadImageResponse *)response
{
    if ([response.imgType isEqualToString:@"driver_license_img"])
    {
        _userData.driverLicenseImg = response.imgUrl;
        
        UploadImageRequest *imageDrivinglicense = [[UploadImageRequest alloc] init];
        imageDrivinglicense.requestType     = SYNetType_UploadImage;
        imageDrivinglicense.sid             = _userData.sid;
        imageDrivinglicense.userid          = _userData.userid;
        imageDrivinglicense.usertype        = _userData.usertype;
        imageDrivinglicense.platform        = @"IOS";
        imageDrivinglicense.imgType         = @"driving_license_img";
        imageDrivinglicense.image           = _viewDrivinglicense.imageView.image;
        [_syNet uploadImage:imageDrivinglicense];
    }
    else if ([response.imgType isEqualToString:@"driving_license_img"])
    {
        _userData.drivingLicenseImg = response.imgUrl;
        
        UploadImageRequest *imageCar = [[UploadImageRequest alloc] init];
        imageCar.requestType     = SYNetType_UploadImage;
        imageCar.sid             = _userData.sid;
        imageCar.userid          = _userData.userid;
        imageCar.usertype        = _userData.usertype;
        imageCar.platform        = @"IOS";
        imageCar.imgType         = @"car_positive_img";
        imageCar.image           = _viewCar.imageView.image;
        [_syNet uploadImage:imageCar];
    }
    else if ([response.imgType isEqualToString:@"car_positive_img"])
    {
        _userData.carPositiveImg = response.imgUrl;
        
        DriverAuthRequest *auth = [[DriverAuthRequest alloc] init];
        auth.requestType       = SYNetType_DriverAuth;
        auth.sid               = _userData.sid;
        auth.userid            = _userData.userid;
        auth.usertype          = _userData.usertype;
        auth.platform          = @"IOS";
        auth.username          = _userData.username;
        auth.corpId            = _userData.corpCode;
        auth.carType           = _userData.carType;
        auth.carLength         = _userData.carLength;
        auth.carWidth          = _userData.carWidth;
        auth.carHeight         = _userData.carHeight;
        auth.carLoad           = _userData.carLoad;
        auth.carNum            = _userData.carNum;
        auth.carName           = _userData.carName;
        auth.driverLicenseImg  = _userData.driverLicenseImg;
        auth.drivingLicenseImg = _userData.drivingLicenseImg;
        auth.carPositiveImg    = _userData.carPositiveImg;
        [_syNet driverAuth:auth];
    }
}

@end
