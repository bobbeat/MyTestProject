//
//  CarServiceJavascriptBridge.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-3-7.
//
//

#import "CarServiceJavascriptBridge.h"
#import "WebViewJavascriptBridge.h"
#import "ThreeDes.h"
#import "GDBL_Account.h"
#import "MWMapOperator.h"
#import "ANParamValue.h"

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

@interface CarServiceJavascriptBridge()
{
    WebViewJavascriptBridge* _bridge;
    BOOL _isRegister;
}

@end

@implementation CarServiceJavascriptBridge

- (void)dealloc
{
    self.webOpenUrl = nil;
    [_bridge setDelegateWith:nil];
    _bridge = nil;
}

- (id) initWithWebview:(UIWebView *)webView withwebViewDelegate:(id<UIWebViewDelegate>)webViewDelegate
{
    self = [super init];
    if(self)
    {
        //js 桥初始化
        [WebViewJavascriptBridge enableLogging];
        
        __weak CarServiceJavascriptBridge* myself = self;
        _bridge = [WebViewJavascriptBridge bridgeForWebView:webView
                                            webViewDelegate:webViewDelegate
                                                    handler:^(id data,WVJBResponseCallback callBack){
                                                        [myself bridgeAnalysis:data];
                                                    }];
    }
    return self;
}

- (void)setDelegateWith:(id)delege
{
    [_bridge setDelegateWith:delege];
}

- (void) bridgeAnalysis:(id) data
{
    //注册后退
    NSString *stringAction = [data objectForKey:@"action"] ;
    if([stringAction isEqualToString:@"triggerJS"])
    {
        if(self.webRegister)
        {
            self.webRegister();
        }
        [_bridge callHandler:@"webviewJsHandler" data:@{@"_action": @"triggerJS"}];
    }
    //获取用户信息
    else if([stringAction isEqualToString:@"getUserInfo"])
    {
        NSMutableDictionary *tempDic = [self getUserInfo];
        NSDictionary *registerDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"getUserInfo",@"_action",
                                            tempDic,@"userinfo",
                                            nil];
        [_bridge callHandler:@"webviewJsHandler" data:registerDictionary];
    }
    //浏览器打开、内置webview打开
    else if([stringAction isEqualToString:@"openUrl"])
    {
        NSDictionary *tempDict = [data objectForKey:@"data"];
        NSString *urlString = [tempDict objectForKey:@"url"];
        NSNumber *isOut = [tempDict objectForKey:@"isout"];
        NSString *title = [tempDict objectForKey:@"title"];
        id isBrowserType = [tempDict objectForKey:@"browserType"];
        
        if([[isOut stringValue] isEqualToString:@"0"])
        {
            if(self.webOpenUrl)
            {
                self.webOpenUrl(urlString,YES,[isBrowserType isEqualToString:@"1"],title);
            }
        }
        else
        {
            if(self.webOpenUrl)
            {
                if([isBrowserType isKindOfClass:[NSString class]])
                {
                    self.webOpenUrl(urlString,NO,[isBrowserType isEqualToString:@"1"],title);
                }
                else
                {
                    self.webOpenUrl(urlString,NO,[isBrowserType intValue] == 1,title);
                }
            }
        }
        [_bridge callHandler:@"webviewJsHandler" data:@{@"_action": @"openUrl"}];
    }
    //关闭webview
    else if([stringAction isEqualToString:@"triggerFeature"])
    {
        if (self.webCloseView) {
            self.webCloseView();
        }
        
        [_bridge callHandler:@"webviewJsHandler" data:@{@"_action": @"triggerFeature"}];
    }
    //显示toast消息
    else if([stringAction isEqualToString:@"alert"])
    {
        //        NSDictionary *tempDict = [data objectForKey:@"data"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                       message:[[data objectForKey:@"data"] objectForKey:@"message"]
                                                      delegate:nil
                                             cancelButtonTitle:STR(@"Universal_ok", Localize_Universal)
                                             otherButtonTitles:nil];
        [alert show];
        NSDictionary *dicionaryUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"alert",@"_action",
                                           [NSString stringWithFormat:@"%d",0],@"ecode",nil];
        [_bridge callHandler:@"webviewJsHandler" data:dicionaryUserInfo];
    }
    //调起导航
    else if([stringAction isEqualToString:@"navito"])
    {
        NSLog(@"调起导航");
//        NSDictionary *tempDict = [data objectForKey:@"des"];
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"type = %@",[tempDict objectForKey:@"type"]]
//                                                           message:[NSString stringWithFormat:@"lat = %@ , lon = %@",[tempDict objectForKey:@"lat"],[tempDict objectForKey:@"lon"]]
//                                                          delegate:nil
//                                                 cancelButtonTitle:[NSString stringWithFormat:@"desname = %@",[tempDict objectForKey:@"desname"]]
//                                                 otherButtonTitles: nil];
//        [alertView show];
        [_bridge callHandler:@"webviewJsHandler" data:@{@"_action": @"navito"}];
    }
    //更新标题
    else if([stringAction isEqualToString:@"updatetitle"])
    {
        if(self.webUpdateTitle)
        {
            self.webUpdateTitle([data objectForKey:@"title"]);
        }
        [_bridge callHandler:@"webviewJsHandler" data:@{@"_action": @"updatetitle"}];
    }
    //拨打电话
    else if([stringAction isEqualToString:@"phonecall"])
    {
        NSDictionary *dict = [data objectForKey:@"data"];
        NSString *phoneNumber = [dict objectForKey:@"number"];
        if ([[dict objectForKey:@"type"] integerValue] == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNumber ]]];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"tel://%@",phoneNumber ]
                                                           message:nil
                                                          delegate:self
                                                 cancelButtonTitle:STR(@"Setting_AlertBack", Localize_Setting)
                                                 otherButtonTitles:STR(@"Setting_AlertSure", Localize_Setting), nil];
            alert.tag = [phoneNumber integerValue];
            [alert show];
            
        }
        [_bridge callHandler:@"webviewJsHandler" data:@{@"_action": @"phonecall"}];
    }
    //重载页面
    else if([stringAction isEqualToString:@"reload"])
    {
        if(self.webReload)
        {
            self.webReload();
        }
        [_bridge callHandler:@"webviewJsHandler" data:@{@"_action": @"reload"}];
    }
    //上传沿途天气的~~~~
    else if([stringAction isEqualToString:@"getRouteCities"])
    {
        [self weatherAnalysis];
    }
    //测试
    else
    {
        NSDictionary *msg = [[NSMutableDictionary alloc] init];
        [msg setValue:@"response from ios" forKey:@"msg"];
        
        NSDictionary *dictonary = [[NSMutableDictionary alloc] init];
        [dictonary setValue:@"testAction" forKey:@"_action"];
        [dictonary setValue:@"testAction" forKey:@"action"];
        [dictonary setValue:msg forKey:@"data"];
        
        id data = @{@"data":@{ @"msg": @"response from ios" },@"action":@"testAction",@"_action":@"testAction"};
        
        
        [_bridge callHandler:@"webviewJsHandler" data:data];
    }
    
}
#pragma mark - ---  获取用户信息  ---
-(NSMutableDictionary *)getUserInfo
{
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    GCARINFO carInfo = {0};
    [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carInfo];

    [dic setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"version"];
    [dic setValue:PID forKey:@"pid"];
    [dic setValue:PformID forKey:@"pform"];
    [dic setValue:deviceTokenEx forKey:@"token"];
    [dic setValue:VendorID forKey:@"imei"];
    //+ (Gint32)GetAdminCode:(GCOORD)pCoord;
    GCOORD pcoord ={0};
    pcoord.x = carInfo.Coord.x;
    pcoord.y = carInfo.Coord.y;
    [dic setValue:[NSString stringWithFormat:@"%i",[MWAdminCode GetAdminCode:pcoord]] forKey:@"adcode"];
    [dic setValue:[NSString stringWithFormat:@"%lf",carInfo.Coord.x/1000000.0f] forKey:@"x"];
    [dic setValue:[NSString stringWithFormat:@"%lf",carInfo.Coord.y/1000000.0f] forKey:@"y"];
    NSArray *arr;
    GDBL_GetAccountInfo(&arr);
    int loginState=[[arr objectAtIndex:0] intValue];
    if (loginState==2) {
        //电话号码
        NSString *phone=[arr objectAtIndex:1];
        [dic setValue:[ThreeDes encrypt:phone] forKey:@"phone"];
    }
    [dic setValue:UserID_Account forKey:@"userid"];
    [dic setValue:KNetChannelID forKey:@"syscode"];
    
    return dic ;
}

- (void) weatherAnalysis
{
    if([ANParamValue sharedInstance].isPath)
    {
        GGUIDEROUTECITYINFO *gudiCityInfo = {0};
        [MWRouteGuide GetGuideRouteCityInfo:GGUIDEROUTE_TYPE_CARPOS citiInfo:&gudiCityInfo];
        NSMutableArray *cityArrays = [[NSMutableArray alloc]init];
        int num = gudiCityInfo->nNumberOfList;
        Gint32* list = gudiCityInfo->pAdminCodeList;
        
        if(list)
        {
            for (int i = 0; i < num; i++)
            {
                if(cityArrays.count > 9)//数量大于9个（10），就不再添加
                {
                    break;
                }
                BOOL canAdd = YES;    //除重复
                for (int j = i - 1 ; j >= 0 && j  < i; j--)
                {
                    if(list[i] == list[j])
                    {
                        canAdd = NO;
                        break;
                    }
                }
                NSLog(@"%d",list[i]);
                if (canAdd)
                {

                    [cityArrays addObject:[NSString stringWithFormat:@"%d",list[i]]];

                }
                

            }
        }
        
        NSDictionary *dicionaryUserInfo = @{@"cities": cityArrays};
        NSDictionary *registerDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"getRouteCities",@"_action",
                                            dicionaryUserInfo,@"data",
                                            nil];
        [_bridge callHandler:@"webviewJsHandler" data:registerDictionary];
    }
}

@end
