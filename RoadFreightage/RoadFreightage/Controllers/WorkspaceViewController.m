//
//  WorkspaceViewController.m
//  RoadFreightage
//
//  Created by yu.liao on 15/6/2.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import "WorkspaceViewController.h"
#import "SYNetAPI.h"
#import "LoginStorage.h"
#import "UIImage+Category.h"
#import <CoreText/CoreText.h>
#import "ReturnTripViewController.h"
#import "CityChooseViewController.h"

@interface WorkspaceViewController ()<SYNetDelegate>
{
    UIImageView *_imageViewUserHead;        //用户头像
    UILabel *_labelUserName;                //用户名称
    UILabel *_labelUserCarNumber;           //用户车牌号
    UIButton *_btnUserReportStatus;      //用户上报接单按钮
    UIButton *_btnReturnTrip;            //设置回程按钮
    UILabel *_labelTip;                  //回程设置提示信息
    
    LoginResponse *_userData;             //用户数据
    
    SYNetAPI * _syNet;
}

@end

@implementation WorkspaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _userData = [LoginStorage getUserData];
    
    _syNet = [[SYNetAPI alloc] init];
    _syNet.delegate = self;
    
    _imageViewUserHead = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [self.view addSubview:_imageViewUserHead];
    
    
    _labelUserName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
    _labelUserName.backgroundColor = [UIColor clearColor];
    _labelUserName.textColor = [UIColor blackColor];
    _labelUserName.textAlignment = NSTextAlignmentLeft;
    _labelUserName.font = [UIFont systemFontOfSize:16];
    _labelUserName.text = _userData.username;
    [self.view addSubview:_labelUserName];
    if ([_labelUserName.text length] == 0)
    {
        _labelUserName.text = @"暂无";
    }
    
    _labelUserCarNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
    _labelUserCarNumber.backgroundColor = [UIColor clearColor];
    _labelUserCarNumber.textColor = [UIColor blackColor];
    _labelUserCarNumber.textAlignment = NSTextAlignmentLeft;
    _labelUserCarNumber.font = [UIFont systemFontOfSize:16];
    _labelUserCarNumber.text = _userData.carName;
    [self.view addSubview:_labelUserCarNumber];
    if ([_labelUserCarNumber.text length] == 0)
    {
        _labelUserCarNumber.text = @"暂无";
    }
    
    _btnUserReportStatus = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnUserReportStatus setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnUserReportStatus setBackgroundImage:[UIImage getStretchableImageWith:[UIImage imageNamed:@"wk_btn_background.png"]] forState:UIControlStateNormal];
    [_btnUserReportStatus addTarget:self action:@selector(ActionReportStatus) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnUserReportStatus];
    
    
    _btnReturnTrip = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btnReturnTrip addTarget:self action:@selector(ActionSetReturnTrip) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnReturnTrip];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:@"设置回程"];
    NSRange strRange = {0,[attributedStr length]};
    [attributedStr addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                          value:[NSNumber numberWithInteger:kCTUnderlineStyleSingle] // 添加下化线
                          range:strRange];
    [attributedStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [_btnReturnTrip setAttributedTitle:attributedStr forState:UIControlStateNormal];
    
    _labelTip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
    _labelTip.backgroundColor = [UIColor clearColor];
    _labelTip.textColor = [UIColor grayColor];
    _labelTip.textAlignment = NSTextAlignmentCenter;
    _labelTip.font = [UIFont systemFontOfSize:13];
    _labelTip.text = @"设置回程信息,帮你准确找到回程货源哦!";
    [self.view addSubview:_labelTip];
    
    [self ActionGetHeadImage];
    [self UpdataButtonStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self SetSubViewLocation];
}
- (void)SetSubViewLocation
{
    CGSize size = self.view.bounds.size;
    
    _imageViewUserHead.center = CGPointMake(80, 70);
    _labelUserName.center = CGPointMake(size.width - 110, 40);
    _labelUserCarNumber.center = CGPointMake(size.width - 110, 100);
    
    _btnUserReportStatus.bounds = CGRectMake(0, 0, size.width - 20 , 45 );
    _btnUserReportStatus.center = CGPointMake(size.width /2, 180);
    
    _btnReturnTrip.bounds = CGRectMake(0, 0, 60 , 45 );
    _btnReturnTrip.center = CGPointMake(size.width /2, size.height - 90);
    
    _labelTip.center =  CGPointMake(size.width /2, size.height - 50);
}


- (void)UpdataButtonStatus
{
    if ([_userData.authStatus isEqualToString:SYDriverAuthStatusToString(STATUS_AUTH_NO_COMMIT)]) {
        
    }
    else if ([_userData.authStatus isEqualToString:SYDriverAuthStatusToString(STATUS_AUTH_WAITING)]) {
        
    }
    else if ([_userData.authStatus isEqualToString:SYDriverAuthStatusToString(STATUS_AUTH_NO_PASS)]) {
        
    }
    else if ([_userData.authStatus isEqualToString:SYDriverAuthStatusToString(STATUS_AUTH_PASS)]) {
        
    }
    [_btnUserReportStatus setTitle:@"开始接单" forState:UIControlStateNormal];
}

#pragma mark - getHeadImage

- (void)ActionSetReturnTrip
{
    ReturnTripViewController *ctl = [[ReturnTripViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)ActionGetHeadImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //获取头像
        static BOOL bGetHead = NO;
        if (bGetHead == NO)
        {
            if ([_userData.headIcon length] > 0)
            {
                NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:
                                                                                     [NSString stringWithFormat:@"%@",_userData.headIcon ]
                                                                                     ]
                                                                        cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                    timeoutInterval:10];
                
                [theRequest setHTTPMethod:@"GET"];
                NSURLResponse *theResponse = nil;
                NSError *error = nil;
                NSData *imageData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&theResponse error:&error];
                UIImage *headImage = [UIImage imageWithData:imageData];
                if (headImage) {
                    UIImage *roundImage = [UIImage getRoundImageWithImage:headImage from:0 to:360];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _imageViewUserHead.image = roundImage;
                    });
                }
            }
            else
            {
                UIImage *roundImage = [UIImage getRoundImageWithImage:[UIImage imageNamed:@"wk_appicon"] from:0 to:360];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _imageViewUserHead.image = roundImage;
                });
            }
        }
        
    });
}

#pragma mark - button action
- (void)ActionReportStatus
{
    CityChooseViewController *ctl = [[CityChooseViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:ctl animated:YES];
    return;
    [QLoadingView showDefaultLoadingView:nil];
    DriverReportStatusRequest *status = [[DriverReportStatusRequest alloc] init];
    status.requestType     = SYNetType_DriverReportStatus;
    status.sid             = _userData.sid;
    status.userid          = _userData.userid;
    status.usertype        = _userData.sid;
    status.platform        = @"IOS";
    status.driverStatus    = _userData.driverStatus;
    status.driverStatusLon = @"110.939393";
    status.driverStatusLat = @"45.82381";
    
    [_syNet driverReportStatus:status];
}

#pragma mark - SYNetDelegate

- (void)netRequest:(id)request didFailWithError:(NSError *)error;
{
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
    [QLoadingView hideWithAnimated:NO];
}

/*!
 @brief 司机工作状态上报
 @param request 发起请求的请求选项(具体字段参考DriverReportStatusRequest类中的定义)
 @param response 请求结果(具体字段参考DriverReportStatusResponse类中的定义)
 */
- (void)onDriverReportStatusDone:(DriverReportStatusRequest *)request response:(DriverReportStatusResponse *)response
{
    [QLoadingView hideWithAnimated:NO];
}
@end
