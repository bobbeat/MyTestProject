    //
//  Map_Upgrade.m
//  AutoNavi
//
//  Created by huang longfeng on 11-8-17.
//  Copyright 2011 autonavi. All rights reserved.
//

#import "Map_Download.h"
#import "UIApplication+Category.h"
#import "plugin-cdm-DownCityDataController.h"
#import "ControlCreat.h"
#import "DMDataDownloadManagerViewController.h"

@implementation Map_Download

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
	[ANParamValue sharedInstance].bSupportAutorate = YES;
    self.title = STR(@"CityDownloadManage_mapDownloadInstruction", Localize_CityDownloadManage);
		
	[self initControl];
		
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationItem.hidesBackButton = YES;
	if (Interface_Flag == 0) {
        [self changePortraitControlFrameWithImage];
	}
	else if(Interface_Flag == 1)
	{
		[self changeLandscapeControlFrameWithImage];
	}
}
- (void)initControl
{
    Button_continue = [UIButton buttonWithType:UIButtonTypeCustom];
	[Button_continue setFrame:CGRectMake(0.0f, 0.0f, 215.0f, 42.0f)];
	[Button_continue setCenter:CGPointMake(160.0f, 380.0f)];
	[Button_continue setBackgroundImage:[ IMAGE(@"CommonBtn1.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:8 topCapHeight:26] forState:UIControlStateNormal];
	[Button_continue setBackgroundImage:[ IMAGE(@"CommonBtn2.png", IMAGEPATH_TYPE_1)  stretchableImageWithLeftCapWidth:8 topCapHeight:26] forState:(UIControlState)UIControlStateHighlighted];
	Button_continue.titleLabel.font = [UIFont boldSystemFontOfSize:isiPhone?kSize2:27];
    [Button_continue setTitle:STR(@"CityDownloadManage_continueUpdateData",Localize_CityDownloadManage) forState:(UIControlState)UIControlStateNormal];
    [Button_continue setTitleColor:GETSKINCOLOR(@"SubmitButtonColor") forState:UIControlStateNormal];
	[Button_continue addTarget:self action:@selector(Upgrade_dataAction:)
              forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:Button_continue];
	Button_continue.hidden = NO;
    
    _labelGreenTip = [ControlCreat createLabelWithText:@"没有检测到有效地图数据，建议您通过以下方式下载："
                                              fontSize:22.0f
                                         textAlignment:NSTextAlignmentLeft];
    _labelGreenTip.textColor = RGBCOLOR(63.0f, 160.0f, 62.0f);
    _labelGreenTip.backgroundColor = [UIColor clearColor];
    _labelGreenTip.font = [UIFont boldSystemFontOfSize:isiPhone ? 15.0f : 22.0f];
    _labelGreenTip.numberOfLines = 0;
    NSString *tipString = [NSString stringWithFormat:@"1. 电脑下载地图，请访问：http://anav.com/data.html。\n2.手机直接下载地图，请点击下方“继续”按钮。"];
    _labelTip = [[ColorLable alloc]initWithFrame:CGRectZero ColorArray:@[[UIColor blackColor]]];
    _labelTip.textColor = [UIColor blackColor];
    _labelTip.font = [UIFont boldSystemFontOfSize:isiPhone ? 15.0f :22.0f];
    _labelTip.backgroundColor = [UIColor clearColor];
    _labelTip.text = tipString;
    _labelTip.lineSpace = isiPhone ? 3.0f : 12.0f;
    _labelTip.numberOfLines = 0;
    
    [self.view addSubview:_labelGreenTip];
    [self.view addSubview:_labelTip];
    
    _imageViewWarningBack = [[UIImageView alloc]init];
    UIImage *imageWarning = IMAGE(@"MapDownload_WarningBack.png", IMAGEPATH_TYPE_1);
    _imageViewWarningBack.image =  [imageWarning stretchableImageWithLeftCapWidth:imageWarning.size.width / 2
                                                                     topCapHeight:imageWarning.size.height / 2];
    [self.view addSubview:_imageViewWarningBack];
    [_imageViewWarningBack release];
    
    _imageViewWarning = [[UIImageView alloc]init];
    UIImage *imageIcon = IMAGE(@"MapDownload_WarningIcon.png", IMAGEPATH_TYPE_1);
    _imageViewWarning.image = imageIcon;
    [_imageViewWarning setFrame:CGRectMake(0, 0, imageIcon.size.width, imageIcon.size.height)];
    [_imageViewWarningBack addSubview:_imageViewWarning];
    [_imageViewWarning release];
    
    _labelWarning = [[ColorLable alloc]initWithFrame:CGRectZero ColorArray:@[[UIColor blackColor]]];
    _labelWarning.font = [UIFont boldSystemFontOfSize:isiPhone ? 12.0f :19.0f];
    _labelWarning.text = @"1. 地图下载完成前，您将无法使用本产品；\n2. 手机下载地图建议使用 WIFI 方式，若使用3G/2G 下载将产生流量费用。资费标准请咨询通讯运营商；\n3. 建议您通过电脑使用迅雷方式下载地图数据；";
    _labelWarning.backgroundColor = [UIColor clearColor];
    _labelWarning.textColor = [UIColor blackColor];
    _labelWarning.lineSpace = 12.0f;
    _labelWarning.numberOfLines = 0;
    
    [_imageViewWarningBack addSubview:_labelWarning];

}
-(void)Upgrade_dataAction:(id)sender
{
    DMDataDownloadManagerViewController *controll = [[DMDataDownloadManagerViewController alloc] initWithViewType:GDDownloadViewTypeList DataType:0 CityAdminCodeArray:nil];
    [self.navigationController pushViewController:controll animated:YES];
    [controll release];
    
}

-(void)changeLandscapeControlFrameWithImage//横屏
{
    float leftDiving = isiPhone ? 17.0f : 67.0f;
    float topDiving = isiPhone ? 10.0f :40.0f;
    float tipsDiving =isiPhone ? 2.0f : 30.0f;
    float backDiving = isiPhone ? 9.0f :9.0f;
    float backTopDiving =isiPhone ? 2.0f : 61.0f;
    float warningIconY  = isiPhone ? 20.0f :44.0f;
    float backTextDiving = isiPhone ? 8.0 :54.0f;
    float backHeight = isiPhone ? 140.0f :250.0f;
    float iconToText = isiPhone ? 1.0f :7.0f;
    float warningHeight =isiPhone ? 96.0f : 150.f;
    
    if (isPad) {
        [Button_continue setFrame:CGRectMake(0.0f, 0.0f, APPHEIGHT - 18, 65)];
        [Button_continue setCenter:CGPointMake(APPHEIGHT/2.0, CONTENTHEIGHT_H - 50)];
        
    }
    else{
        [Button_continue setFrame:CGRectMake(0.0f, 0.0f, APPHEIGHT - 18, 42.0f)];
        [Button_continue setCenter:CGPointMake(APPHEIGHT/2.0, CONTENTHEIGHT_H - 25.0)];
    }
    
    CGSize frameSize = [_labelGreenTip.text sizeWithFont:_labelGreenTip.font
                                       constrainedToSize:CGSizeMake(APPHEIGHT - 2 * leftDiving, APPWIDTH)
                                           lineBreakMode:NSLineBreakByWordWrapping];
    
    [_labelGreenTip setFrame:CGRectMake(leftDiving, topDiving, frameSize.width, frameSize.height)];
    
    frameSize =  CGSizeMake(APPHEIGHT - 2 * leftDiving,isiPhone ? 46.0f : 70.0f);
    
    [_labelTip setFrame:CGRectMake(leftDiving,
                                   _labelGreenTip.frame.origin.y + _labelGreenTip.frame.size.height + tipsDiving,
                                   frameSize.width,
                                   frameSize.height)];
    [_imageViewWarningBack setFrame:CGRectMake(backDiving,
                                               _labelTip.frame.origin.y + _labelTip.frame.size.height + backTopDiving,
                                               APPHEIGHT - backDiving * 2,
                                               backHeight)];
    [_imageViewWarning setCenter:CGPointMake(APPHEIGHT / 2, warningIconY)];
    
    frameSize = CGSizeMake(_imageViewWarningBack.frame.size.width - 2 * backTextDiving ,
                           warningHeight);
    
    [_labelWarning setFrame:CGRectMake(backTextDiving,
                                       _imageViewWarning.frame.origin.y + _imageViewWarning.frame.size.height + iconToText,
                                       frameSize.width,
                                       frameSize.height )];
    _labelWarning.lineSpace = isiPhone ? 8.0f : 12.f;
    

}
-(void)changePortraitControlFrameWithImage//竖屏
{
    float leftDiving = isiPhone ? 17.0f : 67.0f;
    float topDiving = isiPhone ? 21.0f :40.0f;
    float tipsDiving =isiPhone ? 7.0f : 30.0f;
    float backDiving = isiPhone ? 9.0f :9.0f;
    float backTopDiving =isiPhone ? 8.0f : 61.0f;
    float warningIconY  = isiPhone ? 30.0f :44.0f;
    float backTextDiving = isiPhone ? 12.0 :54.0f;
    float backHeight = isiPhone ? 170.0f :250.0f;
    float iconToText = isiPhone ? 3.0f :7.0f;
    float warningHeight =isiPhone ? 110.0f : 150.f;
    
    if (isPad) {
        [Button_continue setFrame:CGRectMake(0.0f, 0.0f, APPWIDTH - 18, 65)];
        [Button_continue setCenter:CGPointMake(APPWIDTH/2.0, CONTENTHEIGHT_V - 50)];

        }
    else{
        [Button_continue setFrame:CGRectMake(0.0f, 0.0f, APPWIDTH - 18, 42.0f)];
        [Button_continue setCenter:CGPointMake(APPWIDTH/2.0, CONTENTHEIGHT_V - 38.0)];
    }
    
    CGSize frameSize = [_labelGreenTip.text sizeWithFont:_labelGreenTip.font
                                       constrainedToSize:CGSizeMake(APPWIDTH - 2 * leftDiving, APPHEIGHT)
                                           lineBreakMode:NSLineBreakByWordWrapping];
    
    [_labelGreenTip setFrame:CGRectMake(leftDiving, topDiving, frameSize.width, frameSize.height)];
    
    frameSize =  CGSizeMake(APPWIDTH - 2 * leftDiving,isiPhone ? 100.0f : 70.0f);
    
    [_labelTip setFrame:CGRectMake(leftDiving,
                                   _labelGreenTip.frame.origin.y + _labelGreenTip.frame.size.height + tipsDiving,
                                   frameSize.width,
                                   frameSize.height)];
    [_imageViewWarningBack setFrame:CGRectMake(backDiving,
                                               _labelTip.frame.origin.y + _labelTip.frame.size.height + backTopDiving,
                                               APPWIDTH - backDiving * 2,
                                               backHeight)];
    [_imageViewWarning setCenter:CGPointMake(APPWIDTH / 2, warningIconY)];
    
    frameSize = CGSizeMake(_imageViewWarningBack.frame.size.width - 2 * backTextDiving ,
                           warningHeight);
    
    [_labelWarning setFrame:CGRectMake(backTextDiving,
                                       _imageViewWarning.frame.origin.y + _imageViewWarning.frame.size.height + iconToText,
                                       frameSize.width,
                                       frameSize.height )];
    _labelWarning.lineSpace = 12.0f;


}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
       [self changeLandscapeControlFrameWithImage];
    }
    else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        [self changePortraitControlFrameWithImage];
    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (!OrientationSwitch)
    {
        return (Orientation == interfaceOrientation);
    }
    return  YES;
    
}

- (void)didReceiveMemoryWarning {
		// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
 
    [super dealloc];
}


@end
