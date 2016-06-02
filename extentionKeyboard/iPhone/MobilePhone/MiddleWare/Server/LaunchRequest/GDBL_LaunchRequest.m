//
//  GDBL_LaunchRequest.m
//  AutoNavi
//
//  Created by huang longfeng on 13-5-24.
//
//

#import "GDBL_LaunchRequest.h"
#import "NetKit.h"
#import "NSString+Category.h"
#import "NetTypedef.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import"sys/utsname.h"
#import "MWMapOperator.h"
#import "GDCacheManager.h"
#import "MWUserDeviceURL.h"
#import "DDXML.h"
#import "JSON.h"
#import "MWCityDownloadMapDataList.h"

//开机网络请求相关-----------------------------------------------------------------------------------
#define kSoftWareVersionUpdateURL         @"iphonedata/getsoftversion_v2/"
#define kUserYawCountPostURL              @"iphonedata/upload_routeyaw/?out=xml"
#define kBackgroundSwitchOnOffURL         @"iphonedata/get_serviceonoff/"   //后来服务功能开关
#define kUserActionUploadURL              @"iphonedata/upload_useraction/"
#define kUploadToken                      @"iphonedata/collect_token_v2/"
#define HEAD_UpdateApp                    @"soft_update/iphone_soft_update_test/?"  //软件升级接口

#define LAUNCHIMAGE_TIMEOUT               2.0f
#define LAUNCHIMAGE_SHOWTIME              2.0f
#define DefaultBottomHeigh                108.

#pragma mark ---  backgroundXMLParse  ---
@interface BackgroundXMLParse :NSObject <NSXMLParserDelegate>
{
    NSMutableDictionary                *backgroundServiceSwitch;
    NSString                    *serviceName;
    NSString                    *serviceID;
    NSString                    *switchOnOff;
    NSString                    *nodeStirng;
}
@property (nonatomic,retain) NSMutableDictionary *backgroundServiceSwitch;
@property (nonatomic,copy) NSString *serviceName;
@property (nonatomic,copy) NSString *serviceID;
@property (nonatomic,copy) NSString *nodeString;
@property (nonatomic,copy) NSString *switchOnOff;

@end

@implementation BackgroundXMLParse

@synthesize backgroundServiceSwitch;
@synthesize serviceID;
@synthesize serviceName;
@synthesize nodeString;
@synthesize switchOnOff;

#pragma  mark ---  XML Parser Delegate  ---



//开始解析前，在这里可以做一些初始化工作
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    [backgroundServiceSwitch removeAllObjects];
    self.serviceName = nil;
    self.serviceID = nil;
    self.nodeString = nil;
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if(qName)
    {
        elementName = qName;
    }
    else if([elementName isEqualToString:@"archive"])
    {
        backgroundServiceSwitch = [[NSMutableDictionary alloc] init];
    }
    else if([elementName isEqualToString:@"serviceid"] ||
            [elementName isEqualToString:@"servicename"] ||
            [elementName isEqualToString:@"onoff"])
    {
        self.nodeString = elementName;
    }
    NSLog(@"didStartElement");
}
///接收数据
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(string == nil) return ;
    if([self.nodeString isEqualToString:@"serviceid"])
    {
        self.serviceID = string;
    }
    else if([self.nodeString isEqualToString:@"servicename"])
    {
        self.serviceName = string;
    }
    else if([self.nodeString isEqualToString:@"onoff"])
    {
        self.switchOnOff = string;
    }
    NSLog(@"string");
}

//解析XML结点尾标志
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"item"] && self.serviceID != nil &&  self.serviceName != nil && self.switchOnOff != nil)
    {
        //存储数据
        //数组中的存储的是获取的对象——index 0：开关的状态  index 1：功能名称
        NSArray *tmpArray  = [[NSArray alloc] initWithObjects:self.switchOnOff,self.serviceName, nil];
        [self.backgroundServiceSwitch setObject:tmpArray forKey:self.serviceID];
        self.serviceID = nil;
        self.serviceName = nil;
        self.switchOnOff = nil;
        [tmpArray release];
    }
}

-(void)dealloc
{
    if(serviceID != nil)
    {
        [serviceID release];
        serviceID = nil;
    }
    if(serviceName != nil)
    {
        [serviceName release];
        serviceName = nil;
    }
    
    if(switchOnOff != nil)
    {
        [switchOnOff release];
        switchOnOff = nil;
    }
    if(backgroundServiceSwitch != nil)
    {
        [backgroundServiceSwitch release];
        backgroundServiceSwitch = nil;
    }
    if (nodeString)
    {
        [nodeString release];
        nodeString = nil;
    }
    [super dealloc];
}

@end

#pragma mark ---  GDBL_LaunchRequest  ---
@interface GDBL_LaunchRequest()
{
    @private
    NSMutableDictionary *m_Control;
    id<NetReqToViewCtrDelegate> delegate;
    UIImageView                 *defaultImageView;
    UIImageView                 *defaultBottomImageView;

}

@property (nonatomic)  NSMutableDictionary *m_Control;
@property (nonatomic,assign) id<NetReqToViewCtrDelegate> delegate;

@end
@implementation GDBL_LaunchRequest

@synthesize m_Control,delegate;

static GDBL_LaunchRequest * instance = nil;

-(id) init
{
    self = [super init];
	if (self != nil) {
        m_Control = [[NSMutableDictionary alloc] init];
	}
	return self;
}

+ (GDBL_LaunchRequest *) sharedInstance
{
    if(instance == nil)
    {
        instance = [[GDBL_LaunchRequest alloc] init];
    }
    return instance;
}
#pragma mark private methods
- (void)handleResponseData:(NSData *)data withRequestType:(RequestType) type
{
    id result = nil;
    NSError *error = nil;
    switch (type) {
        case RT_LaunchRequest_UserYawUpload:
        {
            result = data;
        }
            break;
        case RT_LaunchRequest_UBC:
        {
            result = data;
        }
            break;
        case RT_LaunchRequest_SoftWareUpdate:
        {
            result = data;
        }
            break;
        case RT_Upload_Token_To_Autonavi:
        {
            result = data;
        }
            break;
        case RT_Background_SwitchOnOff:
        {
            NSString *tmp = [[NSString alloc] initWithData:((NSData *)data) encoding:NSUTF8StringEncoding];
            
            if([[tmp CutFromNSString:@"<Result>" Tostring:@"</Result>"] isEqualToString:@"FAIL"])
            {
                NSLog(@"网络后台开关：%@",tmp);
                error = [self errorWithCode:kLaunchRequestErrorCode_Background_SwitchOnOff userInfo:nil];
            }
            else if([[tmp CutFromNSString:@"<Result>" Tostring:@"</Result>"] isEqualToString:@"SUCCESS"])
            {
                
                NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
                BackgroundXMLParse *bgXMLParse = [[[BackgroundXMLParse alloc] init] autorelease];
                [parser setShouldProcessNamespaces:NO];
                [parser setShouldReportNamespacePrefixes:NO];
                [parser setShouldResolveExternalEntities:NO];
                [parser setDelegate:bgXMLParse];
                [parser parse]; //开始解析
                [parser release];
                
                result = bgXMLParse.backgroundServiceSwitch;
            }
            
            [tmp release];
        }
            break;
        case RT_PowerVoiceRequest:
        {
            result = data;
        }
            break;
        case RT_PowerVoiceDownload:
        {
            result = data;
        }
            break;
        case  REQ_NET_MARKET_BANNER:
        {
        }
            break;
        case RT_LaunchRequest_HandSoftWareUpdate:
        {
            result = data;
        }
            break;
        default:
            break;
    }
    if(error != nil)
    {
        [self failedWithError:error withRequestType:type];
    }
    else if ([delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)])
    {
        [delegate requestToViewCtrWithRequestType:type didFinishLoadingWithResult:result];
    }
}

- (void)failedWithError:(NSError *)error withRequestType:(RequestType) type
{    
    if ([delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)]) {
        [delegate requestToViewCtrWithRequestType:type didFailWithError:error];
    }
    
}

- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo
{
    return [NSError errorWithDomain:kLaunchRequestErrorDomain code:code userInfo:userInfo];
}


#pragma mark public methods


//软件版本升级
- (BOOL) Net_SoftWareVersionUpdateRequest:(id<NetReqToViewCtrDelegate>) control  withRequestType:(RequestType)type
{
    [m_Control setObject:control forKey:[NSNumber numberWithInt:type]];
    
    NSString *signString = [[NSString stringWithFormat:@"%@%d@%@",KNetChannelID,SOFTVERSIONCODE,kNetSignKey] stringFromMD5];
    
    NSMutableDictionary *urlParams = [[NSMutableDictionary alloc] init];
    
    [urlParams setValue:VendorID forKey:@"imei"];
    [urlParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [urlParams setValue:MapVersionNoV forKey:@"mapversion"];
    [urlParams setValue:deviceModel forKey:@"model"];
    [urlParams setValue:DeviceResolutionString forKey:@"resolution"];
    [urlParams setValue:CurrentSystemVersion forKey:@"os"];
    [urlParams setValue:UserID_Account forKey:@"userid"];
    [urlParams setValue:KNetChannelID forKey:@"syscode"];
    [urlParams setValue:PID forKey:@"pid"];
    [urlParams setValue:SID forKey:@"sid"];
    [urlParams setValue:signString forKey:@"sign"];
    
    
    NSString *bodyString = [self composeXMLWithRequestType:type];
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.httpHeaderFieldParams = urlParams;
    condition.baceURL = kSoftWareUpdateURL;
    condition.requestType = type;
    condition.httpMethod = @"POST";
    condition.urlParams = nil;
    condition.bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [urlParams release];
    return YES;
}

//网络地图的后台开关控制
- (BOOL) Net_NetWorkSwitchControlRequest:(id<NetReqToViewCtrDelegate>) control   withRequestType:(RequestType)type
{
    [m_Control setObject:control forKey:[NSNumber numberWithInt: RT_Background_SwitchOnOff]];
    NSMutableDictionary *urlParams = [[NSMutableDictionary alloc] init];
    [urlParams setObject: [[NSString stringWithFormat:@"V %@",MapVersionNoV] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                  forKey:@"dataversion"];
    [urlParams setObject:[NSString stringWithFormat:@"%.1f",SOFTVERSIONNUM] forKey:@"appversion"];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [kNetDomain stringByAppendingString:kBackgroundSwitchOnOffURL];
    condition.requestType = RT_Background_SwitchOnOff;
    condition.httpMethod = @"GET";
    condition.urlParams = urlParams;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [urlParams release];
    return YES;
}


//上传token至http://iphone.autonavi.com:8080/userToken/token

- (BOOL) Net_UploadTokenWithControl:(id<NetReqToViewCtrDelegate>)control uuid:(NSString *)uuid token:(NSString *)token  withRequestType:(RequestType)type
{
    [m_Control setObject:control forKey:[NSNumber numberWithInt:type]];
    
    NSString *strData = @"";
    strData = [strData stringByAppendingFormat:@"<udid>%@</udid><token>%@</token>", uuid,token];
    
    NSString *temp;
    temp = [self composeXML_GBK_ext2:strData activitycode:5];
    NSData *http_body = [temp dataUsingEncoding:0x80000632];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = @"http://iphone.autonavi.com:8080/userToken/token";
    condition.requestType = type;
    condition.httpMethod = @"POST";
    condition.bodyData = http_body;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    return YES;
}


/**
 *	软件升级接口
 *
 *	@param	control	控制器
 *	@param	type	请求类型
 *
 *	@return	成功 返回yes
 */

- (BOOL) Net_UpdateAppWithControl:(id<NetReqToViewCtrDelegate>)control withRequestType:(RequestType)type
{
    [m_Control setObject:control forKey:[NSNumber numberWithInt:type]];

     NSString *md5 = [[NSString stringWithFormat:@"%0.1f%@",SOFTVERSIONNUM,KEY_MD5] stringFromMD5];

    NSMutableDictionary *urlParams = [[[NSMutableDictionary alloc] init] autorelease];

    [urlParams setObject:[NSString stringWithFormat:@"%0.1f",SOFTVERSIONNUM] forKey:@"soft_version"];


    [urlParams setObject:md5 forKey:@"sign"];

    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_UpdateApp];
    condition.urlParams = urlParams;
    condition.requestType = type;
    condition.httpMethod = @"GET";
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    return YES;
}

/*
 @bief 检测动态闪屏屏幕方向
 */
- (void)CheckImageViewDirection:(CGSize)size
{
    if (defaultImageView)
    {
        if (size.width > size.height)
        {
            UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
            if (orientation == UIDeviceOrientationLandscapeRight)
            {
                CGFloat angle = (M_PI / 180.0) * 90;
                CGAffineTransform at =CGAffineTransformMakeRotation(angle);
                [defaultImageView setTransform:at];
                CGPoint point = {0};
                point.x = size.width/2;
                point.y = size.height/2;
                defaultImageView.center = point;
            }
            else  if (orientation == UIDeviceOrientationLandscapeLeft)
            {
                CGFloat angle = (M_PI / 180.0) * -90;
                CGAffineTransform at =CGAffineTransformMakeRotation(angle);
                [defaultImageView setTransform:at];
                CGPoint point = {0};
                point.x = size.width/2;
                point.y = size.height/2;
                defaultImageView.center = point;
            }
        }
    }
}

/**
 *	开机图片加载
 *  @param  window  父视图
 *
 */
- (void)NET_LaunchImage:(UIWindow *)window
{
    if (isPad || Interface_Flag == 1)
    {
        return;
    }
    
    window.windowLevel = 2000;
    
    defaultImageView = [[UIImageView alloc] initWithImage:[[ANDataSource sharedInstance] GMD_GetDefaultImage]];
    defaultImageView.frame = CGRectMake(0., 0., window.frame.size.width, window.frame.size.height);
    [window addSubview:defaultImageView];
    [defaultImageView release];

    defaultBottomImageView = [[UIImageView alloc] initWithImage:[ANDataSource GMD_GetDefaultBottomImage]];
    defaultBottomImageView.frame = CGRectMake(0., window.frame.size.height - defaultBottomImageView.image.size.height, window.frame.size.width, defaultBottomImageView.image.size.height);
    
    [defaultImageView addSubview:defaultBottomImageView];
    [defaultBottomImageView release];
    
    defaultImageView.hidden = YES;
    //请求开机图片
    if (NetWorkType == 0) {
        
        BOOL bExpired = [[GDCacheManager globalCache] hasCacheForKey:GDCacheType_LaunchImage];
        
        NSString *startTime = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_LaunchImageStartTime];
        NSComparisonResult comparisonResult = [[GDCacheManager globalCache] compareDateWithString:startTime];
        
        if (bExpired && (comparisonResult == NSOrderedAscending)) {
            
            [self Local_LaunchImage:window];
            
            return;
        }
        else
        {
            
            window.windowLevel = 0;
            
            if (defaultImageView) {
                defaultImageView.hidden = NO;
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (defaultImageView) {
                    [defaultImageView removeFromSuperview];
                    defaultImageView = nil;
                }
            });
        }
    }
    else{
       
        NSError *error = nil;
        
        NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_LaunchImageID];
        if (!version) {
            version = @"new";
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYYMMddhhmmss"];
        NSString *dateString = [formatter stringFromDate: [NSDate date]];
        [formatter release];
        
        
        NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary *svccont = [[NSMutableDictionary alloc] init];
        [svccont setValue:version forKey:@"version"];
        
        [postDictionary setValue:svccont forKey:@"svccont"];
        [svccont release];
        
        [postDictionary setValue:@"0001" forKey:@"activitycode"];
        [postDictionary setValue:dateString forKey:@"processtime"];
        [postDictionary setValue:[NSNumber numberWithInt:0] forKey:@"actioncode"];
        [postDictionary setValue:[NSString stringWithFormat:@"%d",NetFontType] forKey:@"language"];
        [postDictionary setValue:[NSNumber numberWithInt:0] forKey:@"protversion"];
        
        NSString *jsonString = [postDictionary JSONRepresentation];
        [postDictionary release];
        
        NSURL *imageUrl = [NSURL URLWithString:kLaunchImageURL];
        
        NSString *signString = [[NSString stringWithFormat:@"%@%@%@@%@",KNetChannelID,version,DeviceResolutionString,kNetSignKey] stringFromMD5];
        
        NSMutableURLRequest *imageUrlRequest = [[NSMutableURLRequest alloc]initWithURL:imageUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:LAUNCHIMAGE_TIMEOUT];
        [imageUrlRequest setValue:VendorID forHTTPHeaderField:@"imei"];
        [imageUrlRequest setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forHTTPHeaderField:@"apkversion"];
        [imageUrlRequest setValue:MapVersionNoV forHTTPHeaderField:@"mapversion"];
        [imageUrlRequest setValue:deviceModel forHTTPHeaderField:@"model"];
        [imageUrlRequest setValue:DeviceResolutionString forHTTPHeaderField:@"resolution"];
        [imageUrlRequest setValue:[NSString stringWithFormat:@"%f",IOS_VERSION] forHTTPHeaderField:@"os"];
        [imageUrlRequest setValue:UserID_Account forHTTPHeaderField:@"userid"];
        [imageUrlRequest setValue:KNetChannelID forHTTPHeaderField:@"syscode"];
        [imageUrlRequest setValue:PID forHTTPHeaderField:@"pid"];
        [imageUrlRequest setValue:signString forHTTPHeaderField:@"sign"];
        
        [imageUrlRequest setHTTPMethod:@"POST"];
        imageUrlRequest.HTTPBody = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSData *received = [NSURLConnection sendSynchronousRequest:imageUrlRequest returningResponse:nil error:&error];
        [imageUrlRequest release];
        
        NSString *tmp = [[NSString alloc] initWithData:received encoding:NSUTF8StringEncoding];
        NSLog(@"闪屏：%@",tmp);
        [tmp release];
        
        if (received) {
            
            NSDictionary *requestDic = [NSJSONSerialization
                                        
                                        JSONObjectWithData:received
                                        
                                        options:NSJSONReadingMutableLeaves
                                        
                                        error:nil];
            
            if (requestDic) {
                
                NSDictionary *responseDic = [requestDic objectForKey:@"response"];
                
                if (responseDic && [[responseDic objectForKey:@"rspcode"] isEqualToString:@"0000"])
                {
                    NSDictionary *svccontDic = [requestDic objectForKey:@"svccont"];
                    
                    if (svccontDic && (svccontDic.count > 0) && ![version isEqualToString:[svccontDic objectForKey:@"version"]]) {
                        
                        NSString *launchImageUrl = [svccontDic objectForKey:@"url"];
                        
                        if (launchImageUrl && [launchImageUrl length] > 0) {
                            
                            NSURL *url = [NSURL URLWithString:launchImageUrl];
                            NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:LAUNCHIMAGE_TIMEOUT];
                            NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
                            [request release];
                            
                            if (!error) {
                                
                                UIImage *image = [UIImage imageWithData:received];
                                
                                UIImageView *launchImageView;
                                
                                if (image) {
                                    
                                    [[NSUserDefaults standardUserDefaults] setValue:[svccontDic objectForKey:@"starttime"] forKey:USERDEFAULT_LaunchImageStartTime];
                                    [[NSUserDefaults standardUserDefaults] setValue:[svccontDic objectForKey:@"version"] forKey:USERDEFAULT_LaunchImageID];
                                    
                                    //保存到缓存中
                                    NSString *expired = [svccontDic objectForKey:@"endtime"];
                                    [[GDCacheManager globalCache] setData:received forKey:GDCacheType_LaunchImage withTimeoutString:expired];
                                    
                                    BOOL bExpired = [[GDCacheManager globalCache] isExpiredWithString:expired];
                                    
                                    NSComparisonResult comparisonResult = [[GDCacheManager globalCache] compareDateWithString:[svccontDic objectForKey:@"starttime"]];
                                    
                                    if (!bExpired && (comparisonResult == NSOrderedAscending)) {
                                        
                                        launchImageView = [[UIImageView alloc] initWithImage:image];
                                        [launchImageView setFrame:CGRectMake(0., 0., window.frame.size.width , window.frame.size.height)];
                                        [window addSubview:launchImageView];
                                        [window bringSubviewToFront:launchImageView];
                                        [launchImageView release];
                                        
                                        [launchImageView addSubview:defaultBottomImageView];
                                        
                                        //动画显示开机图片
                                        double delayInSeconds = LAUNCHIMAGE_SHOWTIME;
                                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                            
                                            window.windowLevel = 0;
                                            
                                            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                                launchImageView.alpha = 0;
                                            } completion:^(BOOL finished) {
                                                
                                                [launchImageView removeFromSuperview];
                                                
                                            }];
                                            
                                        });
                                        
                                        return;
                                    }
                                    
                                }
                            }
                            
                            
                        }
                    }
                    else {
                        
                        BOOL bExpired = [[GDCacheManager globalCache] hasCacheForKey:GDCacheType_LaunchImage];
                        
                        NSString *startTime = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_LaunchImageStartTime];
                        NSComparisonResult comparisonResult = [[GDCacheManager globalCache] compareDateWithString:startTime];
                        
                        if (bExpired && (comparisonResult == NSOrderedAscending)) {
                            
                            [self Local_LaunchImage:window];
                            
                            return;
                        }
                        else{
                            
                            window.windowLevel = 0;
                            
                            if (defaultImageView) {
                                defaultImageView.hidden = NO;
                            }
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                
                                if (defaultImageView) {
                                    [defaultImageView removeFromSuperview];
                                    defaultImageView = nil;
                                }
                            });
                        }
                    }
                    
                    
                }
                
                
            }
        }
        
        
        window.windowLevel = 0;
        
        if (defaultImageView) {
            defaultImageView.hidden = NO;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (defaultImageView) {
                [defaultImageView removeFromSuperview];
                defaultImageView = nil;
            }
            
            
        });
        
    }
    
}

- (void)Local_LaunchImage:(UIWindow *)window
{
    UIImage *localImage = [UIImage imageWithData:[[GDCacheManager globalCache] dataForKey:GDCacheType_LaunchImage]];
    if (localImage) {
        
        UIImageView *launchImageView = [[UIImageView alloc] initWithImage:localImage];
        [launchImageView setFrame:CGRectMake(0., 0., window.frame.size.width , window.frame.size.height)];
        [window addSubview:launchImageView];
        [launchImageView release];
        
        [launchImageView addSubview:defaultBottomImageView];
        
        //动画显示开机图片
       
        double delayInSeconds = LAUNCHIMAGE_SHOWTIME;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            window.windowLevel = 0;
            
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                launchImageView.alpha = 0;
            } completion:^(BOOL finished) {
                
                [launchImageView removeFromSuperview];
                
            }];
            
        });
       
        return;
    }
    else{
        
        window.windowLevel = 0;
        
        if (defaultImageView) {
            defaultImageView.hidden = NO;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (defaultImageView) {
                [defaultImageView removeFromSuperview];
                defaultImageView = nil;
            }
        });
        
    }
}


/**
 *	开机图片后台下载
 *
 *	@param	imageUrl 下载链接
 *	@param	type	请求类型
 *
 *	@return	成功 返回yes
 */
- (BOOL)NET_BackgroundLaunchImageDownload:(id<NetReqToViewCtrDelegate>)control WithRequestType:(RequestType)type DownloadUrl:(NSString *)imageUrl{
    
    [m_Control setObject:control forKey:[NSNumber numberWithInt:type]];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = imageUrl;
    condition.requestType = type;
    condition.httpMethod = @"GET";
    condition.urlParams = nil;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    return YES;
}

/**
 *	开机语音请求
 *
 *	@param	control	控制器
 *	@param	type	请求类型
 *
 *	@return	成功 返回yes
 */
- (BOOL)NET_PowerVoiceRequest:(id<NetReqToViewCtrDelegate>)control withRequestType:(RequestType)type
{
        
    [m_Control setObject:control forKey:[NSNumber numberWithInt:type]];
    
    
    NSString *signString = [[NSString stringWithFormat:@"%@%@%@@%@",KNetChannelID,UserID_Account,VendorID,kNetSignKey] stringFromMD5];
    
    NSMutableDictionary *urlParams = [[NSMutableDictionary alloc] init];
    
    [urlParams setValue:VendorID forKey:@"imei"];
    [urlParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [urlParams setValue:MapVersionNoV forKey:@"mapversion"];
    [urlParams setValue:deviceModel forKey:@"model"];
    [urlParams setValue:DeviceResolutionString forKey:@"resolution"];
    [urlParams setValue:CurrentSystemVersion forKey:@"os"];
    [urlParams setValue:UserID_Account forKey:@"userid"];
    [urlParams setValue:KNetChannelID forKey:@"syscode"];
    [urlParams setValue:PID forKey:@"pid"];
    [urlParams setValue:signString forKey:@"sign"];
    
    NSString *bodyString = [self composeXMLWithRequestType:RT_PowerVoiceRequest];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = kPowerVoiceRequestURL;
    condition.requestType = type;
    condition.httpMethod = @"POST";
    condition.urlParams = nil;
    condition.httpHeaderFieldParams = urlParams;
    condition.bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [urlParams release];
    
    return YES;
    

}

/**
 *	开机语音下载
 *
 *	@param	voiceUrl 下载链接
 *	@param	type	请求类型
 *
 *	@return	成功 返回yes
 */
- (BOOL)NET_PowerVoiceDownload:(id<NetReqToViewCtrDelegate>)control WithRequestType:(RequestType)type DownloadUrl:(NSString *)voiceUrl
{
    [m_Control setObject:control forKey:[NSNumber numberWithInt:type]];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = voiceUrl;
    condition.requestType = type;
    condition.httpMethod = @"GET";
    condition.urlParams = nil;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    return YES;
}

/***
 * @name    市场的统计设备信息上传
 * @param	control	控制器
 * @param	type	请求类型
 * @author  by bazinga
 ***/
- (BOOL) Net_MarketBanner
{
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [[MWUserDeviceURL userDeviceInfoURL:marketBannerBaseURL] absoluteString];
    condition.requestType = REQ_NET_MARKET_BANNER;
    condition.httpMethod = @"GET";
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    return YES;
}

//@add start by ly for push 10.11.21
-(NSString *)composeXML_GBK_ext2:(NSString *)content activitycode:(int)code
{
	NSString *strData = @"";
	strData = @"<?xml version=\"1.0\" encoding=\"GBK\"?>"
	"<opg>"
    "<activitycode>000";
	strData = [strData stringByAppendingFormat:@"%d", code];
	strData = [strData stringByAppendingString:@"</activitycode>""<processtime>"];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddhhmmss"];
    NSString *locationString=[formatter stringFromDate: [NSDate date]];
    [formatter release];
	strData = [strData stringByAppendingString:locationString];
	strData = [strData stringByAppendingString:@"</processtime>""<actioncode>0</actioncode>""<svccont>"];
	strData = [strData stringByAppendingString:content];
	strData	= [strData stringByAppendingString:@"</svccont>""</opg>"];
	//NSLog(strData);
	return strData;
}

//取消所有请求
- (BOOL)Net_CancelAllRequest
{
    [[NetExt sharedInstance] cancelAllRequests];
    return YES;
}
//取消某个类型的请求
- (BOOL)Net_CancelRequestWithType:(RequestType)requestType
{
    [[NetExt sharedInstance] Net_CancelRequestWithType:requestType];
    return YES;
}

#pragma mark 请求xml组装

- (NSString *)composeXMLWithRequestType:(RequestType)type
{
    NSString *_xmlString = nil;
    
    if (RT_LaunchRequest_SoftWareUpdate == type || RT_LaunchRequest_HandSoftWareUpdate == type)
    {
        NSString *signString = [[NSString stringWithFormat:@"%@%d@%@",KNetChannelID,SOFTVERSIONCODE,kNetSignKey] stringFromMD5];
        
        NSString *tmp = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_MWSoftWareUpdateReminderKey] ? [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_MWSoftWareUpdateReminderKey] : @"";
        NSString *controlver = [NSString stringWithFormat:@"%@",tmp];
        if (!controlver || (controlver.length == 0)) {
            controlver = [NSString stringWithFormat:@"%d",SOFTVERSIONCODE];
        }
        if (RT_LaunchRequest_HandSoftWareUpdate == type) {
            controlver = @"";
        }
        
        NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
        [bodyDic setValue:KNetChannelID forKey:@"syscode"];
        [bodyDic setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkv"];
        [bodyDic setValue:signString forKey:@"sign"];
        [bodyDic setValue:[[MWCityDownloadMapDataList citydownloadMapDataList] getLocalMapVersions] forKey:@"mapvlist"];
        [bodyDic setValue:[ANDataSource getNaviVersion] forKey:@"resv"];
        [bodyDic setValue:VendorID forKey:@"imei"];
        [bodyDic setValue:[NSString stringWithFormat:@"%d",NetFontType] forKey:@"language"];
        [bodyDic setValue:controlver forKey:@"controlv"];
        [bodyDic setValue:[NSString stringWithFormat:@"%@_%d",DeviceResolutionString,[CurrentSystemVersion intValue]] forKey:@"resolution"];
        [bodyDic setValue:[NSString stringWithFormat:@"%d",[CurrentSystemVersion intValue]] forKey:@"osv"];
        [bodyDic setValue:PID forKey:@"pid"];
    
        
        _xmlString = [bodyDic JSONRepresentation];
        [bodyDic release];
    }
    else if (RT_PowerVoiceRequest == type)
    {
        DDXMLElement*  opg = [DDXMLElement elementWithName: @"opg"];
        DDXMLElement*  activitycode = [DDXMLElement elementWithName: @"activitycode"];
        [activitycode setStringValue:@"0001"];
        [opg addChild:activitycode];
        
        DDXMLElement*  processtime =[DDXMLElement elementWithName: @"processtime"];
        [processtime setStringValue:NetProcessTime];
        [opg addChild:processtime];
        
        DDXMLElement*  actioncode =[DDXMLElement elementWithName: @"actioncode"];
        [actioncode setStringValue:@"0"];
        [opg addChild:actioncode];
        
        DDXMLElement*  protversion =[DDXMLElement elementWithName: @"protversion"];
        [protversion setStringValue:@"2"];
        [opg addChild:protversion];
        
        DDXMLElement*  language =[DDXMLElement elementWithName: @"language"];
        [language setStringValue:[NSString stringWithFormat:@"%d",NetFontType]];
        [opg addChild:language];
        
        DDXMLElement*  svccont = [DDXMLElement elementWithName:@"svccont"];

        NSString *adcodeString = [NSString stringWithFormat:@"%d",[MWAdminCode GetCurAdminCode]];
        DDXMLElement*  adcode = [DDXMLElement elementWithName:@"adcode"];
        [adcode setStringValue:adcodeString];
        [svccont addChild:adcode];
        
        [opg addChild:svccont];
        
        _xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\" ?>%@",[opg XMLString]];
    }
    
    return _xmlString;
}
#pragma mark NetRequestExtDelegate
- (void)request:(NetRequestExt *)request didFailWithError:(NSError *)error{
    delegate = [self.m_Control objectForKey:[NSNumber numberWithInt:request.requestCondition.requestType]];
    [self failedWithError:error withRequestType:request.requestCondition.requestType];
    [self.m_Control removeObjectForKey:[NSNumber numberWithInt:request.requestCondition.requestType]];
}
- (void)request:(NetRequestExt *)request didFinishLoadingWithData:(NSData *)data{
    delegate = [self.m_Control objectForKey:[NSNumber numberWithInt:request.requestCondition.requestType]];
    [self handleResponseData:data withRequestType:request.requestCondition.requestType];
    [self.m_Control removeObjectForKey:[NSNumber numberWithInt:request.requestCondition.requestType]];
}

@end


























