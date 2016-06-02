//
//  ViewController.m
//  NetApiTest
//
//  Created by gaozhimin on 15/8/5.
//  Copyright (c) 2015年 autonavi. All rights reserved.
//

#import "ViewController.h"
#import "ZJNetAPI.h"
@interface ViewController ()
{
    ZJNetAPI *netapi;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    netapi = [[ZJNetAPI alloc] init];
    netapi.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = self.view.bounds;
    [button addTarget:self action:@selector(func) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)func
{
    NSLog(@"func");
//    RegitsterRequest *request = [[RegitsterRequest alloc] init];
//    request.tel = @"18359713441";
//    request.passwd = @"aaaaaa";
//    request.nickname = @"aa";
//    request.useraddr = @"xiamen";
//    [netapi registerAction:request];
    
    
//    GetUserInfoRequest *getUserInfo = [[GetUserInfoRequest alloc] init];
//    getUserInfo.tel = @"18359713441";
//    [netapi getUserInfoAction:getUserInfo];
    
//    AddCarInfoRequest *carInfo = [[AddCarInfoRequest alloc] init];
//    UserInfoObject *carobject = [[UserInfoObject alloc] init];
//    carobject.tel = @"18359713441";
//    carobject.car_num = @"闽D11121";
//    carobject.brand = @"1";
//    carobject.model = @"1";
//    carobject.colour = @"1";
//    carInfo.carInfoObject = carobject;
//    [netapi addCarInfoAction:carInfo];
    
//    UpdateCarInfoRequest *carInfo = [[UpdateCarInfoRequest alloc] init];
//    UserInfoObject *carobject = [[UserInfoObject alloc] init];
//    carobject.tel = @"18359713441";
//    carobject.car_num = @"闽D11121";
//    carobject.brand = @"2";
//    carobject.model = @"3";
//    carobject.colour = @"1";
//    carInfo.carInfoObject = carobject;
//    [netapi updateCarInfoAction:carInfo];
    
//    GetCarInfoRequest *getCarInfoRequest = [[GetCarInfoRequest alloc] init];
//    getCarInfoRequest.tel = @"18359713441";
//    [netapi getCarInfoAction:getCarInfoRequest];
    
//    LoginRequest *loginRequest = [[LoginRequest alloc] init];
//    loginRequest.tel = @"18359713441";
//    loginRequest.passwd = @"aaaaaa";
//    [netapi loginAction:loginRequest];
    
//    UpdateUserInfoRequest *updateRequest = [[UpdateUserInfoRequest alloc] init];
//    UserInfoObject *userInfoObject = [[UserInfoObject alloc] init];
//    userInfoObject.tel = @"18359713441";
//    userInfoObject.nickname = @"gao";
//    updateRequest.userInfoObject = userInfoObject;
//    [netapi updateUserInfoAction:updateRequest];
    
//    GetCityInfoRequest *cityinfoRequest = [[GetCityInfoRequest alloc] init];
//    cityinfoRequest.current_city = @"350200";
//    cityinfoRequest.dialog_id = @"1";
//    [netapi getCityInfoAction:cityinfoRequest];
    
//    GetTaskResRequest *resRequest = [[GetTaskResRequest alloc] init];
//    resRequest.isimg = @"1";
//    resRequest.describe_id = @"1";
//    resRequest.task_id = @"1";
//    resRequest.type = @"1";
//    resRequest.res_id = @"0";
//    [netapi getTaskResAction:resRequest];
    
//    GetTaskDetailRequest *taskDetailRequest = [[GetTaskDetailRequest alloc] init];
//    taskDetailRequest.task_id = @"1";
//    [netapi getTaskDetailAction:taskDetailRequest];
    
//    GetUserTaskInfoRequest *userTaskInfoRequest = [[GetUserTaskInfoRequest alloc] init];
//    userTaskInfoRequest.tel = @"18359713441";
//    userTaskInfoRequest.task_id = @"1";
//    userTaskInfoRequest.state = @"0";
//    [netapi getUserTaskInfoAction:userTaskInfoRequest];
    
//    ApplyTaskRequest *applyTaskRequest = [[ApplyTaskRequest alloc] init];
//    applyTaskRequest.tel = @"18359713441";
//    applyTaskRequest.task_id = @"1";
//    [netapi applyTaskAction:applyTaskRequest];
    
//    UploadImageRequest *uploadImageRequest = [[UploadImageRequest alloc] init];
//    uploadImageRequest.tel =  @"18359713441";
//    uploadImageRequest.index =  @"1";
//    uploadImageRequest.image = [UIImage imageNamed:@"111111"];
//    [netapi uploadImage:uploadImageRequest];
    
    GetUserResRequest *request = [[GetUserResRequest alloc] init];
    request.tel =  @"18359713441";
    request.type =  @"png";
    request.index =  @"1";
    [netapi getUserResAction:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*!
 @brief 登录的回调函数
 @param request 发起请求的请求选项(具体字段参考GetTaskResRequest类中的定义)
 @param response 请求结果(具体字段参考GetTaskResResponse类中的定义)
 */
- (void)onGetResDone:(GetTaskResRequest *)request response:(GetTaskResResponse *)response
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(00, 0, 200, 200)];
    imageView.image = response.image;
    [self.view addSubview:imageView];
}

/*!
 @brief 获取用户资源的回调函数
 @param request 发起请求的请求选项(具体字段参考GetUserResRequest类中的定义)
 @param response 请求结果(具体字段参考GetUserResResponse类中的定义)
 */
- (void)onGetUserResDone:(GetUserResRequest *)request response:(GetUserResResponse *)response
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(00, 0, 200, 200)];
    imageView.image = response.image;
    [self.view addSubview:imageView];
}
@end
