    //
//  Map_Upgrade.m
//  AutoNavi－sj
//
//  Created by huang longfeng on 11-8-17.
//  Copyright 2011 autonavi. All rights reserved.
//

#import "Map_Upgrade.h"
#import "UIApplication+Category.h"
#import "GDAlertView.h"

extern void writeApplicationData(void);
@implementation Map_Upgrade

- (void)viewDidLoad {
    [super viewDidLoad];
	[GDAlertView shouldAutorotate:NO];
    self.title = STR(@"CityDownloadManage_upgradeMap", Localize_CityDownloadManage);
    self.navigationItem.leftBarButtonItem = [[[VCTranslucentBarButtonItem alloc] initWithType:VCTranslucentBarButtonItemTypeBackward title:nil target:self action:@selector(GoBack:)] autorelease];
	
    
	Button_continue = [UIButton buttonWithType:UIButtonTypeCustom];

    [Button_continue setBackgroundImage: [IMAGE(@"CommonBtn1.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:10] forState:UIControlStateNormal];
    [Button_continue setBackgroundImage:[IMAGE(@"CommonBtn2.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:10]  forState:(UIControlState)UIControlStateHighlighted];

	
	Button_continue.titleLabel.font = [UIFont boldSystemFontOfSize:kSize2];
    [Button_continue setTitle:STR(@"CityDownloadManage_deleteMap", Localize_CityDownloadManage) forState:(UIControlState)UIControlStateNormal];
	 [Button_continue setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[Button_continue addTarget:self action:@selector(Upgrade_dataAction:)
			 forControlEvents:UIControlEventTouchUpInside]; 
	
	[self.view addSubview:Button_continue];
	Button_continue.hidden = NO;
	
	background_img = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,APPWIDTH,350.0)];
	[background_img setImage:[IMAGE(@"sj-dt-s.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0]];
	background_img.userInteractionEnabled = NO; 
	[self.view addSubview:background_img];
	[background_img release];
    
}


-(void)Upgrade_dataAction:(id)sender
{
    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_deleteOldMap",Localize_CityDownloadManage)] autorelease];
    [alertView addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }];
    [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
        NSFileManager    *fileManager = [NSFileManager defaultManager];
        NSError * error = nil;
        
        NSString *data_path = [NSString stringWithFormat:@"%@/%s",document_path,FILE_NAME];
        NSString *GPSPath = [NSString stringWithFormat:@"%@/GPS",document_path];
        NSString *iphone_path = [NSString stringWithFormat:@"%s",g_data_path];
        if ([fileManager fileExistsAtPath:iphone_path]) {//删除iphone目录
            [fileManager removeItemAtPath:iphone_path error:&error];
        }
        if([fileManager fileExistsAtPath:data_path])
        {
            
            [fileManager removeItemAtPath:data_path error:&error];
        }
        if([fileManager fileExistsAtPath:GPSPath])
        {
            
            [fileManager removeItemAtPath:GPSPath error:&error];
        }
        [[MWPreference sharedInstance] setValue:PREF_NEWFUNINTRODUCE Value:0];//置为未查看新功能介绍
        [[UIApplication sharedApplication] exitApplication];
    }];
    [alertView show];
    
}

-(void)GoBack:(id)sender
{
	
	[self dismissModalViewControllerAnimated:YES];
}

-(void)changeLandscapeControlFrameWithImage
{
    if (isPad) {
        [background_img setFrame:CGRectMake(0.0f, 0.0f, APPHEIGHT, 465.0f)];
        if (fontType == 0)
        {
            [background_img setImage:[IMAGE(@"sj-dt-h_iPad.png", IMAGEPATH_TYPE_1)   stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0]];
        }
        else if (fontType == 1)
        {
            [background_img setImage:[IMAGE(@"sj-dt-h-ft_iPad.png", IMAGEPATH_TYPE_1)   stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0]];
        }
        else if (fontType == 2) {
            [background_img setImage:[IMAGE(@"sj-dt-h_iPad.png", IMAGEPATH_TYPE_1)    stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0]];
        }
        UIImage *image =  IMAGE(@"sj-H-1_ipad.png", IMAGEPATH_TYPE_1) ;
        self.view.layer.contents = (id) image.CGImage;
    }
    else{
        [background_img setFrame:CGRectMake(0.0f, 0.0f, APPHEIGHT, 218.0f)];
        if (fontType == 0)
        {
            [background_img setImage:[IMAGE(@"sj-dt-h.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0]];
        }
        else if (fontType == 1)
        {
            [background_img setImage: [ IMAGE(@"sj-dt-h-ft.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0]];
        }
        else if (fontType == 2)
        {
            [background_img setImage:[ IMAGE(@"sj-dt-h.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0]];
        }
        UIImage *image = IMAGE(@"sj-H-1.png", IMAGEPATH_TYPE_1);
        self.view.layer.contents = (id) image.CGImage;
    }
    Button_continue.frame=CGRectMake(10, 446, CCOMMON_APP_WIDTH-20, 60);
	
}
-(void)changePortraitControlFrameWithImage
{
    NSString *key=@"sj-dt-s";;
    NSString *isPadKey=isPad?@"_iPad":@"";
    NSString *imageName=[NSString stringWithFormat:@"%@%@.png",key,isPadKey];
    UIImage *image=IMAGE(imageName,IMAGEPATH_TYPE_1);
    background_img.image=image;
    background_img.frame=CGRectMake(10, 20,CCOMMON_APP_WIDTH-20, image.size.height/2);
	Button_continue.frame=CGRectMake(10, background_img.frame.size.height+42+background_img.frame.origin.y, CCOMMON_APP_WIDTH-20, 40);
    [Button_continue setTitleColor:GETSKINCOLOR(@"SubmitButtonColor") forState:UIControlStateNormal];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return  UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIDeviceOrientationPortrait);
    
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
    [GDAlertView shouldAutorotate:YES];
    [super dealloc];
}


@end
