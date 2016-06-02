//
//  CustomNetWork.m
//  AutoNavi
//
//  Created by liyuhang on 13-5-6.
//
//

#import "CustomNetWork.h"

#import "ANParamValue.h"
#import "GDAlertView.h"
@interface CustomNetWork ()
//
/*
 property
 */
@property (nonatomic, retain) NSURL* psNetURL;
@property (nonatomic, retain) NSMutableURLRequest* psNetURLRequest;
@property (nonatomic, retain) NSURLConnection* psNetConnection;
@property (nonatomic, retain) NSData* psNetData;
@end

@implementation CustomNetWork
/*
 Synthesize
 */
@synthesize psNetURL = m_urlForNet;
@synthesize psNetConnection = m_connectionForNet;
@synthesize psNetData = m_mutableDataForNet;
@synthesize psNetURLRequest = m_mutableRequestForNet;

//
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    m_bShowTipForNet = TRUE;
    self.psNetData = [[[NSMutableData alloc] init] autorelease];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    self.psNetConnection = nil;
    self.psNetData = nil;
    self.psNetURL = nil;
    self.psNetURLRequest = nil;
	[super dealloc];
}
#pragma mark super class function
-(void)changeLandscapeControlFrameWithImage
{
    if (m_actIndicatorViewForNet) {
        [m_actIndicatorViewForNet setCenter:CGPointMake(APPHEIGHT/2, APPWIDTH/2)];
    }
    [super changeLandscapeControlFrameWithImage];
}
-(void)changePortraitControlFrameWithImage
{
    if (m_actIndicatorViewForNet) {
        [m_actIndicatorViewForNet setCenter:CGPointMake(APPWIDTH/2, APPHEIGHT/2)];
    }
    [super changePortraitControlFrameWithImage];
}
#pragma mark netWork
/*
 previously: check the net status
 */
-(BOOL)CtNetWorkPreviousCheckStatus:(BOOL)bShowAlert
{
    int nStatus = NetWorkType;
    if (nStatus==0) {
        if (bShowAlert) {
            [self CtNetWorkTipsForNetStatus:CST_NETWORK_NO_REACHABLE_0];
        }
        return NO;
    }
    return YES;
}
/*
 1 First Step: set the url, alloc location for data, the status of networking
 */
- (BOOL)CtNetWorkFirstInitWithString:(NSString *)urlString
{
	if (urlString&&m_bNetWorking)
	{
        self.psNetURL = [[NSURL alloc] initWithString:urlString];
        return YES;
	}
    return NO;
}

- (BOOL)CtNetWorkFirstInitWithUrl:(NSURL *)url
{
	if (url&&m_bNetWorking)
	{
        self.psNetURL = url;
        return YES;
	}
    return NO;
}

-(void)setNetWorkIsBusy:(BOOL)bBusy
{
    if (!m_actIndicatorViewForNet) {
        m_actIndicatorViewForNet = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [self.view addSubview:m_actIndicatorViewForNet];
        [m_actIndicatorViewForNet release];
    }
    if (bBusy) {
        m_bNetWorking = YES;
        if (Interface_Flag==0) {
            [m_actIndicatorViewForNet setCenter:CGPointMake(APPWIDTH/2, APPHEIGHT/2)];
        } else {
            [m_actIndicatorViewForNet setCenter:CGPointMake(APPHEIGHT/2, APPWIDTH/2)];
        }
        //
        [m_actIndicatorViewForNet startAnimating];
    } else {
        m_bNetWorking = NO;
        [m_actIndicatorViewForNet stopAnimating];
    }

}
/*
 2 Second Step: establish the connet
 */
- (void)CtNetWorkSecondSetConnection
{
    if (m_bNetWorking) {
        return;
    }
	self.psNetURLRequest = [[NSMutableURLRequest alloc] initWithURL:m_urlForNet];
    [m_mutableRequestForNet setTimeoutInterval:NET_TIMEOUT_ASYN];

	self.psNetConnection = [[NSURLConnection alloc] initWithRequest:m_mutableRequestForNet delegate:self];
	
    self.psNetURLRequest = nil;
    //
    [self setNetWorkIsBusy:YES];
}


- (void)CtNetWorkSecondSetGetConnection
{
    if (m_bNetWorking) {
        return;
    }
	self.psNetURLRequest = [[NSMutableURLRequest alloc] initWithURL:m_urlForNet];
	[m_mutableRequestForNet setHTTPMethod:@"GET"];
    [m_mutableRequestForNet setTimeoutInterval:NET_TIMEOUT_ASYN];
	
	self.psNetConnection = [[NSURLConnection alloc] initWithRequest:m_mutableRequestForNet delegate:self];
	
	self.psNetURLRequest = nil;
    
    [self setNetWorkIsBusy:YES];
}


- (void)CtNetWorkSecondSetPostConnectionWithBody:(NSData *)bodydata
{
    if (m_bNetWorking) {
        return;
    }
	self.psNetURLRequest = [[NSMutableURLRequest alloc] initWithURL:m_urlForNet];
	[m_mutableRequestForNet setHTTPMethod:@"POST"];
	[m_mutableRequestForNet setHTTPBody:bodydata];
    [m_mutableRequestForNet setTimeoutInterval:NET_TIMEOUT_ASYN];
    
	self.psNetConnection = [[NSURLConnection alloc] initWithRequest:m_mutableRequestForNet delegate:self];
	
	self.psNetURLRequest = nil;
    //
    /*
     在WWAN连接情况下，在设置了setHTTPBody之后，系统会默认修改timeoutInterval为240s，可能是因为在WWAN（连wifi测试后也一样...）连接时，一个太短的timeout可能会引起一些不必要的问题，所以apple强制把有body信息的post连接的timeout设定为240s
     */
    //自定义时间超时
    m_timerForTimeout = [NSTimer scheduledTimerWithTimeInterval:NET_TIMEOUT_ASYN target:self selector: @selector(handleTimeoutForPostRequest:) userInfo:m_connectionForNet repeats:NO];
    [self setNetWorkIsBusy:YES];
}

/*
 Setp 3: network callback
 */
- (void)SubClassConnectionDidFinishWithData:(NSData *)netData//通知客户，网络连接完毕
{
    
}
- (void)SubClassConnectiondidFailWithError:(NSError *)error//通知客户网络连接失败
{
    
}
#pragma mark NSURLConnection Delegate methods

- (void)connection:(NSURLConnection *)aconnection didReceiveResponse:(NSURLResponse *)response
{
	[m_mutableDataForNet setLength:0];
}


// 连接失败
- (void)connection:(NSURLConnection *)aconnection didFailWithError:(NSError *)error
{
	//发送失败消息委托
    if (m_timerForTimeout) {
        [m_timerForTimeout invalidate];
        m_timerForTimeout = nil;
    }
	[m_delegateForNet CtNetWorkConnectiondidFailWithError:error];
    [m_mutableDataForNet setLength:0];
    [self setNetWorkIsBusy:NO];
    [self CtNetWorkTipsForNetStatus:CST_NETWORK_FAILED_1];
}


// 接收数据
- (void)connection:(NSURLConnection *)aconnection didReceiveData:(NSData *)data
{
    
    [m_mutableDataForNet appendData:data];
    
}


// 接收数据完成，取消任务，准备解析xml
- (void)connectionDidFinishLoading:(NSURLConnection *)aconnection
{
    if (m_timerForTimeout) {
        [m_timerForTimeout invalidate];
        m_timerForTimeout = nil;
    }
    [aconnection cancel];
	[m_delegateForNet CtNetWorkConnectionDidFinishWithData:m_mutableDataForNet];
    [self setNetWorkIsBusy:NO];
    [self CtNetWorkTipsForNetStatus:CST_NETWORK_SUCCESS_3];
}
#pragma mark timeout for post request
-(void)handleTimeoutForPostRequest:(NSTimer *)timer
{
    m_timerForTimeout = nil;
    [m_mutableDataForNet setLength:0];
    NSURLConnection *aconnection = ( NSURLConnection *)timer.userInfo;
    if (aconnection) {
        [aconnection cancel];
    }
    [m_delegateForNet CtNetWorkConnectiondidFailWithError:nil];
}

#pragma tips for the net status
-(void)CtNetWorkTipsForNetStatus:(int)nStatus
{
    if (!m_bShowTipForNet) {
        return;
    }
    NSString* szButtonOK[3] = {@"确定",@"確定",@"OK"};
    NSString* szTitle[15] = {@"网络连接错误，请检查网络连接后重试",@"網絡連接出錯，請檢查網絡連接後重試",@"Network failure,please try again later",
                            @"网络连接错误，请检查网络连接后重试",@"網絡連接出錯，請檢查網絡連接後重試",@"Network failure,please try again later",
                            @"网络连接错误，请检查网络连接后重试",@"網絡連接出錯，請檢查網絡連接後重試",@"Network failure,please try again later",
                            @"提交成功",@"提交成功",@"Submit successfully",
                            @"网络请求失败",@"網絡請求失敗",@"Network failure"
                            };
    int nIndexForTitle = 0;
    switch (nStatus) {
        case CST_NETWORK_NO_REACHABLE_0:
            nIndexForTitle = 0;
            break;
        case CST_NETWORK_TIMEOUT_2:
            nIndexForTitle = 3;
            break;
        case CST_NETWORK_FAILED_1:
            nIndexForTitle = 6;
            break;
        case CST_NETWORK_SUCCESS_3:
            nIndexForTitle = 9;
            break;
        case CST_NETWORK_REQUEST_FAILED_4:
            nIndexForTitle = 12;
            break;
        default:
            break;
    }

    GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:szTitle[nIndexForTitle+fontType]];
    [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
    [Myalert_ext show];
    [Myalert_ext release];
}
#pragma mark network delegate
- (void)CtNetWorkConnectionDidFinishWithData:(NSData *)netData//通知客户，网络连接完毕
{
    
}
- (void)CtNetWorkConnectiondidFailWithError:(NSError *)error//通知客户网络连接失败
{
    
}
@end
