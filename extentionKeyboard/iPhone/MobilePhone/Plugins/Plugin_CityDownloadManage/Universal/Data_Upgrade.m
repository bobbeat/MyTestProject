//
//  Data_Upgrade.m
//  AutoNavi
//
//  Created by huang longfeng on 11-8-11.
//  Copyright 2011 autonavi. All rights reserved.
//

#import "Data_Upgrade.h"
#import <QuartzCore/QuartzCore.h>
#import "ANDataSource.h"
#import "launchRequest.h"
#import "GDAlertView.h"
#import "PluginFactory.h"

@implementation Data_Upgrade

#define kSwitchButtonWidth		94.0
#define kSwitchButtonHeight		27.0

@synthesize updateUrl;
- (id)initWithUpdateURL:(NSString *)updateURL
{
    self = [super init];
    if(self){
        self.updateUrl = updateURL;
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = STR(@"CityDownloadManage_updateMapData", Localize_CityDownloadManage);
    self.navigationItem.leftBarButtonItem = [[[VCTranslucentBarButtonItem alloc] initWithType:VCTranslucentBarButtonItemTypeBackward title:STR(@"CityDownloadManage_updateMapData", Localize_CityDownloadManage) target:self action:@selector(GoBack:)] autorelease];			
	
    
    
	detail_scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(15.0f, 80.0f, 290.0f,245.0f)];
	detail_scroll.pagingEnabled = NO;
	detail_scroll.bounces = NO;
	detail_scroll.backgroundColor = [UIColor clearColor];
	detail_scroll.clipsToBounds = YES;	
	detail_scroll.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	detail_scroll.showsHorizontalScrollIndicator = NO;
	detail_scroll.showsVerticalScrollIndicator = NO;
	[detail_scroll setScrollEnabled:YES];
	detail_scroll.delegate = self;
	detail_scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:detail_scroll];
	[detail_scroll release];
	detail_scroll.hidden = NO;
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(8.0, 15.0, 304.0, 255.0)];
    [[webView layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[webView layer] setBorderWidth:0.5];
    [[webView layer] setCornerRadius:11.0];
    [[webView layer] setMasksToBounds:YES];
    webView.backgroundColor = [UIColor clearColor];
    [webView setOpaque:NO];
    webView.scalesPageToFit = YES;
    webView.autoresizesSubviews = YES;
    webView.clipsToBounds = YES;
    webView.delegate = self;
    [self.view addSubview:webView];
    [webView release];
    int current_city_num;
    
    NSString * localVersion = [MWEngineTools GetMapVersion];//获取本地地图数据版本
    long k = [MWAdminCode GetCurAdminCode];
    current_city_num = k / 100 * 100;
    
    NSString *tem = [NSString stringWithFormat:@"%@",[localVersion CutFromNSString:@"V "]];
    NSString *str = [NSString stringWithFormat:@"%@?province=%d&version=V%@",self.updateUrl,current_city_num,tem];
    
    NSURL *url=[NSURL URLWithString:str];
    NSURLRequest *resquestobj=[NSURLRequest requestWithURL:url];
    
    [webView loadRequest:resquestobj];
	
	Button_Upgrade = [UIButton buttonWithType:UIButtonTypeCustom]; 
	[Button_Upgrade setBackgroundImage:[IMAGE(@"CommonBtn1.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5. topCapHeight:5.] forState:UIControlStateNormal];
    [Button_Upgrade setBackgroundImage:[IMAGE(@"CommonBtn2.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5. topCapHeight:5.] forState:UIControlStateHighlighted];
	Button_Upgrade.titleLabel.font = [UIFont boldSystemFontOfSize:kSize2];
	[self.view addSubview:Button_Upgrade];
    [Button_Upgrade setTitle:STR(@"CityDownloadManage_beginUpgradeMap", Localize_CityDownloadManage) forState:(UIControlState)UIControlStateNormal];
    
    [Button_Upgrade addTarget:self action:@selector(Upgrade_dataAction:)
             forControlEvents:UIControlEventTouchUpInside];

	
	[self create_UIActivityIndView:UIActivityIndicatorViewStyleWhite];
    [detail_scroll addSubview:progressInd];
	
	
}


- (void)create_UIActivityIndView:(UIActivityIndicatorViewStyle)style
{
	CGRect frame;
	if(1 == Interface_Flag)
	{
		frame = CGRectMake(0.0, 0.0, 80, 80);
		progressInd = [[UIActivityIndicatorView alloc] initWithFrame:frame];
		[progressInd setCenter:CGPointMake(200,150)];
	}
	else if(0 == Interface_Flag)
	{
		frame = CGRectMake(0.0, 0.0, 80, 80);
		progressInd = [[UIActivityIndicatorView alloc] initWithFrame:frame];
		[progressInd setCenter:CGPointMake(160,200)];
	}
	
	
	progressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[progressInd sizeToFit];
#if 0
	progressInd.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
									UIViewAutoresizingFlexibleRightMargin |
									UIViewAutoresizingFlexibleTopMargin |
									UIViewAutoresizingFlexibleBottomMargin);
#endif
}


-(void)Upgrade_dataAction:(id)sender
{
    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_deleteDataAlert",Localize_CityDownloadManage)] autorelease];
    [alertView addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
    [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
        //
        UINavigationController *navigationView=[PluginFactory allocNavigationController:@"Map_Upgrade"];

        [self presentModalViewController:navigationView animated:YES];
    }];
    [alertView show];
    
}

-(void)GoBack:(id)sender
{
	if (downloadVersion_timer != nil) 
	{
		[downloadVersion_timer invalidate];
		downloadVersion_timer = nil;
		
	}
	if ([progressInd isAnimating])
	{
		[progressInd stopAnimating];
	}
	[self.navigationController popViewControllerAnimated:YES];
}
-(void)set_HV:(int)flag
{
    
	if (flag == 0) {
        if (isPad) {
            [webView setFrame:CGRectMake(45.0, 99.0, APPWIDTH-88.0, APPHEIGHT/2.0-52.0)];
			
			[Button_Upgrade setFrame:CGRectMake(0.0f, 0.0f, APPWIDTH-78.0, kHeight2 + 10)];
			[Button_Upgrade setCenter:CGPointMake(APPWIDTH/2.0, APPHEIGHT/2.0+190.0)];
            
			[progressInd setCenter:CGPointMake(APPWIDTH/2.0-54.0,250)];
			
			CGSize size = CGSizeMake(APPWIDTH-90.0,800);
			labelsize = [s sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
			
        }
        else{
            
            [webView setFrame:CGRectMake(8.0, 15.0, APPWIDTH-16.0, APPHEIGHT-150.0)];
            [Button_Upgrade setFrame:CGRectMake(0.0f, 0.0f, APPWIDTH-20.0, kHeight2 + 10)];
            [Button_Upgrade setCenter:CGPointMake(APPWIDTH/2.0, APPHEIGHT-90.0)];
            
            [progressInd setCenter:CGPointMake(APPWIDTH/2.0-10.0,100)];
            [detail_scroll setFrame:CGRectMake(15.0f, 80.0f, APPWIDTH-20.0,APPHEIGHT-215.0)];
            [detail_scroll setContentSize:CGSizeMake(APPWIDTH-20.0, APPHEIGHT-207.0)];
        }
        
		

	}
	else if(flag == 1)
	{
        if (isPad)
        {
            [webView setFrame:CGRectMake(45.0, 99.0, APPHEIGHT-90.0, APPWIDTH/2.0 + 90)];
            
            [Button_Upgrade setFrame:CGRectMake(0.0f, 0.0f, APPHEIGHT-74.0, kHeight2 + 10)];
            [Button_Upgrade setCenter:CGPointMake(APPHEIGHT/2.0+3.0, APPWIDTH-100.0)];
            
            [progressInd setCenter:CGPointMake(APPHEIGHT/2.0-62.0,250)];
            
            CGSize size = CGSizeMake(APPHEIGHT-84.0,600);
            labelsize = [s sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
            
        }
        else{
           
            [webView setFrame:CGRectMake(8.0, 15.0, APPHEIGHT-16.0, APPWIDTH-110.0)];
            [Button_Upgrade setFrame:CGRectMake(0.0f, 88.0f, APPHEIGHT-10.0, kHeight2 + 10)];
            [Button_Upgrade setCenter:CGPointMake(APPHEIGHT/2.0, CONTENTHEIGHT_H-30.0)];
            
            [progressInd setCenter:CGPointMake(APPHEIGHT/2.0-20.0,50)];
            [detail_scroll setFrame:CGRectMake(15.0f, 80.0f, APPHEIGHT-20.0,APPWIDTH-175.0)];
            [detail_scroll setContentSize:CGSizeMake(APPHEIGHT-20.0, APPWIDTH-167.0)];
        }
		
		

	}
    if (![webView isLoading])
    {
        [webView reload];
    }
}

- (void)viewWillAppear:(BOOL)animated 
{
    // listen for keyboard hide/show notifications so we can properly adjust the table's height
	[super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    if (Interface_Flag == 1) {
		[self set_HV:1];
		
	} 
	else if(Interface_Flag == 0){
		[self set_HV:0];
	}
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    webView.delegate = nil;
    if ([webView isLoading]) {
        [webView stopLoading];
    }
    if (updateUrl) {
        [updateUrl release];
        updateUrl = nil;
    }
	[progressInd release];
	[super dealloc];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
		[self set_HV:1];
	}
	else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		[self set_HV:0];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (!OrientationSwitch) 
    {
        return (Orientation == interfaceOrientation);
    }
	return  YES;
    
}
#pragma mark
#pragma mark UIWebView delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	
	if (![progressInd isAnimating] ) 
	{
		[progressInd startAnimating];
	}
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.navigationController.topViewController != self) {
        return;
    }
	if ([progressInd isAnimating] ) 
	{
		[progressInd stopAnimating];
	}
		
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	
    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_faileToLoad",Localize_CityDownloadManage)] autorelease];
    
    [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
    [alertView show];
}

@end
