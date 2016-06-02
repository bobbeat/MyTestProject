//
//  launchRequest.m
//  AutoNavi
//
//  Created by huang longfeng on 13-5-24.
//
//

#import "launchRequest.h"
#import "GDBL_LaunchRequest.h"
#import "ANParamValue.h"
#import "GDBL_LaunchRequest.h"
#import "ANDataSource.h"
#import "NSString+Category.h"
#import "ANOperateMethod.h"
#import "GDAlertView.h"
#import "ControlCreat.h"
#import "UMengEventDefine.h"
#import "GDCacheManager.h"
#import "MWDialectDownloadManage.h"
#import "MileRecordDataControl.h"
#import "MWSkinAndCarListRequest.h"
#import "NewRedPointData.h"
#import "XMLDictionary.h"
#import "plugin-cdm-TaskManager.h"
#import "NSObject+Category.h"
#import "MWCityDownloadMapDataList.h"

static launchRequest* instance;


@interface launchRequest()
{
    MWSkinAndCarListRequest* _skinAndCarRequest;
}

@property (nonatomic,copy) NSString *powerVoiceExpired;
@property (nonatomic,copy) NSString *launchImageExpired;
@property (nonatomic,assign) int powerVoiceID;

@end

@implementation launchRequest

@synthesize powerVoiceExpired,powerVoiceID,launchImageExpired;

- (id)init
{
    if (self == [super init]) {
        _skinAndCarRequest = [[MWSkinAndCarListRequest alloc] init] ;
    }
    return self;
}
+ (launchRequest *)shareInstance
{
    if (instance == nil) {
        instance = [[launchRequest alloc] init];
    }
    return instance;
}

- (void)launchRequest
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self UserBehaviorCountRequest];   //用户行为统计上传
    });
    
    [self PowerVoiceRequest];   //开机语音请求
    
    [self mileagePost];//里程上传
    
    [self requestRedPoint];     //红点请求
    
     [[GDBL_LaunchRequest sharedInstance] Net_MarketBanner]; //用户设备信息上报
    
}

//软件版本升级检测
- (void)softWareVersionUpdateRequest
{
    
    [[GDBL_LaunchRequest sharedInstance] Net_SoftWareVersionUpdateRequest:self  withRequestType:RT_LaunchRequest_SoftWareUpdate];
    
    
}
#pragma mark request method


- (void)UserBehaviorCountRequest
{
    //上传用户行为统计数据
//    [GDBL_UserBehaviorCountNew shareInstance].openNavigation ++;//用户数据上传比函数applicationDidBecomeActive更快，因此会造成刚进程序的那一次无法统计
    [[GDBL_UserBehaviorCountNew shareInstance] timeCount];
    if([GDBL_UserBehaviorCountNew shareInstance].openNavigation == 0)
    {
        return ;
    }
    //统计时间
    //导航
    if ([GDBL_UserBehaviorCountNew shareInstance].northUpViewSeconds_InPath != 0) {
        [MobClick event:UM_EVENTID_NAVI_VIEW_TIME label:UM_LABEL_NORTH_UP durations:([GDBL_UserBehaviorCountNew shareInstance].northUpViewSeconds_InPath * 60 * 1000)];
    }
    if([GDBL_UserBehaviorCountNew shareInstance].upViewSeconds_InPath != 0)
    {
        [MobClick event:UM_EVENTID_NAVI_VIEW_TIME label:UM_LABEL_HEADING durations:([GDBL_UserBehaviorCountNew shareInstance].upViewSeconds_InPath * 60 * 1000)];
    }
    if ([GDBL_UserBehaviorCountNew shareInstance].car3DViewSeconds_InPath != 0) {
        [MobClick event:UM_EVENTID_NAVI_VIEW_TIME label:UM_LABEL_3D durations:([GDBL_UserBehaviorCountNew shareInstance].car3DViewSeconds_InPath * 60 * 1000)];
    }

    //巡航
    if([GDBL_UserBehaviorCountNew shareInstance].northUpViewSeconds != 0)
    {
        [MobClick event:UM_EVENTID_CRUISE_VIEW_TIME label:UM_LABEL_NORTH_UP durations:([GDBL_UserBehaviorCountNew shareInstance].northUpViewSeconds * 60 * 1000)];
    }
    if ([GDBL_UserBehaviorCountNew shareInstance].upViewSeconds != 0) {
        [MobClick event:UM_EVENTID_CRUISE_VIEW_TIME label:UM_LABEL_HEADING durations:([GDBL_UserBehaviorCountNew shareInstance].upViewSeconds * 60 * 1000)];
    }
    if ([GDBL_UserBehaviorCountNew shareInstance].car3DViewSeconds != 0) {
        [MobClick event:UM_EVENTID_CRUISE_VIEW_TIME label:UM_LABEL_3D durations:([GDBL_UserBehaviorCountNew shareInstance].car3DViewSeconds * 60 * 1000)];
    }
    if([GDBL_UserBehaviorCountNew shareInstance].TMCTime != 0)
    {
        [MobClick event:UM_EVENTID_TRAFFIC_TIME durations:([GDBL_UserBehaviorCountNew shareInstance].TMCTime * 1000)];
    }
    [[GDBL_UserBehaviorCountNew shareInstance] resetData];//如果上传成功重置数据
    [[GDBL_UserBehaviorCountNew shareInstance] saveData];
}



- (void)UploadTokenToAutonavi:(NSString *)token
{
    NSNumber *sign = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_MWUploadTokenAutoNaviSuccess];
    if (![sign boolValue])
    {
        [[GDBL_LaunchRequest sharedInstance] Net_UploadTokenWithControl:self uuid:deviceID token:token withRequestType:RT_Upload_Token_To_Autonavi];
    }
}

- (void)PowerVoiceRequest
{
    [[GDBL_LaunchRequest sharedInstance] NET_PowerVoiceRequest:self withRequestType:RT_PowerVoiceRequest];
}

- (void)mileagePost
{
    if ([[Plugin_Account getAccountInfoWith:1]intValue]!=0)
    {
        [[MileRecordDataControl sharedInstance] mileageRequestWithType:RT_MileageStartUpRequest];
    }
    
}

/*!
  @brief    红点引导数据请求
  @param
  @author   by bazinga
  */
- (void) requestRedPoint
{
    [[NewRedPointData sharedInstance] RequestRedPointURL];
    [NewRedPointData sharedInstance].redRequestSuccess = ^(){
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdata_RedPointUpdate] userInfo:nil];
    };
    [NewRedPointData sharedInstance].redRequestFail = ^(){
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdata_RedPointUpdate] userInfo:nil];
    };

}

/*!
  @brief    地图数据更新
  @param
  @author   by hlf
 .@a地图数据升级放在软件升级检测之后
  */
- (void)mapDataUpdate
{
    [[MWCityDownloadMapDataList citydownloadMapDataList] getMapDataListWithUrl:kMapdataRequestURL];//地图数据列表下载
}

#pragma mark -
#pragma mark ==NetReqToViewCtrDelegate request===
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result{
    if (!result) {
        return;
    }
    if (RT_Upload_Token_To_Autonavi == requestType)
    {
        NSString *tmp = [[NSString alloc] initWithData:result encoding:0x80000632];
        if ([tmp rangeOfString:@"<rsptype>OK</rsptype>"].length > 0 || [tmp rangeOfString:@"<rspcode>1011</rspcode>"].length > 0)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:USERDEFAULT_MWUploadTokenAutoNaviSuccess];
        }
        [tmp release];
    }
    else if (RT_LaunchRequest_SoftWareUpdate == requestType)//软件版本升级
    {
        NSString *tmp = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"软件升级：%@",tmp);
        [tmp release];
        
        __block launchRequest *weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSDictionary *softWareDic = [result JSONParse];
            
            if (softWareDic) {
                
                
                NSString *string = [softWareDic objectForKey:@"respcode"];
                
                if (string && [string isEqualToString:@"0000"]) {
                    
                   
                    NSString *update = [softWareDic objectForKey:@"update"];
                    
                    if (update && ([update intValue] == 1) ) { //有新版本
                        
                        NSString *status = [softWareDic objectForKey:@"status"];
                        NSString *updateDesc = [softWareDic objectForKey:@"updatedesc"];
                        NSArray *mapNotMatch = [NSArray arrayWithArray:[softWareDic objectForKey:@"mapnotmatch"]];
                        NSString *mapMatchDesc = [softWareDic objectForKey:@"mapmatchdesc"];
                        NSString *resNotMatch = [softWareDic objectForKey:@"resnotmatch"];
                        NSString *resmatchdesc = [softWareDic objectForKey:@"resmatchdesc"];
                        NSString *apkvString = [softWareDic objectForKey:@"apkv"];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            
                            if (status && [status intValue] == 1) {//强制升级
                                
                                GDAlertView *alertView1 = [[GDAlertView alloc] initWithTitle:STR(@"Setting_NewVersion",Localize_Setting) andMessage:updateDesc];
                                [alertView1 addButtonWithTitle:STR(@"Setting_UpdateCancel",Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                                    
                                    [[UIApplication sharedApplication] exitApplication];//退出导航
                                    
                                }];
                                [alertView1 addButtonWithTitle:STR(@"Setting_UpdateSure",Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                                    
                                
                                    [ANOperateMethod rateToAppStore:0];
                                    [[UIApplication sharedApplication] exitApplication];//退出导航
                                    
                                }];
                                [alertView1 show];
                                [alertView1 release];
                            }
                            else{
                                GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:STR(@"Setting_NewVersion",Localize_Setting) andMessage:updateDesc];
                                
                                
                                [alertView addButtonWithTitle:STR(@"Setting_UpdateSure",Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                                    
                                    if (resNotMatch && [resNotMatch intValue] == 1) {//基础资源不匹配
                                        
                                        GDAlertView *alertView1 = [[GDAlertView alloc] initWithTitle:STR(@"Setting_NewVersion",Localize_Setting) andMessage:resmatchdesc];
                                        [alertView1 addButtonWithTitle:STR(@"Setting_UpdateCancel",Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                                        }];
                                        [alertView1 addButtonWithTitle:STR(@"Setting_UpdateSure",Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                                            //add by hlf for 先删除其他城市数据，再删除基础资源，否则，基础资源删除后，调用引擎的接口获取不出数据目录
                                            if (mapNotMatch && mapNotMatch.count > 0) {//删除不兼容城市数据
                                                [[TaskManager taskManager] removeNotMatchTaskWithArray:mapNotMatch];
                                            }
                                            
                                            [[TaskManager taskManager] removeTaskId:0];//删除基础资源
                                            
                                            [[TaskManager taskManager] updatecity:0];//添加基础资源
                                            
                                            [ANOperateMethod rateToAppStore:0];
                                            [[UIApplication sharedApplication] exitApplication];//退出导航
                                            
                                        }];
                                        [alertView1 show];
                                        [alertView1 release];
                                    }
                                    else if (mapNotMatch && mapNotMatch.count > 0)//城市数据不匹配
                                    {
                                        GDAlertView *alertView2 = [[GDAlertView alloc] initWithTitle:STR(@"Setting_NewVersion",Localize_Setting) andMessage:mapMatchDesc];
                                        [alertView2 addButtonWithTitle:STR(@"Setting_UpdateCancel",Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                                        }];
                                        [alertView2 addButtonWithTitle:STR(@"Setting_UpdateSure",Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                                            
                                            [[TaskManager taskManager] removeNotMatchTaskWithArray:mapNotMatch];
                                            [ANOperateMethod rateToAppStore:0];
                                            
                                        }];
                                        [alertView2 show];
                                        [alertView2 release];
                                        
                                    }
                                    else
                                    {
                                       
                                        [weakSelf mapDataUpdate];
                                        
                                        [ANOperateMethod rateToAppStore:0];
                                    }
                                    
                                    
                                }];
                                [alertView addButtonWithTitle:STR(@"Setting_NoPrompt", Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView* alertView){
                                    
                                    
                                    [weakSelf mapDataUpdate];
                                    
                                    [[NSUserDefaults standardUserDefaults] setValue:(apkvString ? apkvString : @"") forKey:USERDEFAULT_MWSoftWareUpdateReminderKey];
                                    
                                    [[NSUserDefaults standardUserDefaults] synchronize];//add by hlf for 立即保存 at 2014.08.22
                                    
                                }];
                                [alertView addButtonWithTitle:STR(@"Setting_RemindMeLater",Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                                    
                                   
                                    [weakSelf mapDataUpdate];
                               
                                }];
                                [alertView show];
                                [alertView release];
                            }
                            
                        });
                        
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf mapDataUpdate];
                        });
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf mapDataUpdate];
                    });
                }
            }
            else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf mapDataUpdate];
                });
            }
            
            
        });
        
        
    }
    else if (requestType == RT_PowerVoiceRequest)
    {
        NSDictionary *resultDic = [NSDictionary dictionaryWithXMLData:result];
        NSDictionary *response = [resultDic objectForKey:@"response"];
        if (response && [[response objectForKey:@"rspcode"] isEqualToString:@"0000"]) {
            NSDictionary *msg = [response objectForKey:@"msg"];
            
            if (msg) {
                
                id item = [msg objectForKey:@"item"];
                
                if ([item isKindOfClass:[NSString class]]) {
                    
                    NSData* aData = [item dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *requestDic = [NSJSONSerialization
                                                
                                                JSONObjectWithData:aData
                                                
                                                options:NSJSONReadingMutableLeaves
                                                
                                                error:nil];
                    
                    if (requestDic && ([[requestDic objectForKey:@"rdtype"] intValue] == 1)) {
                        self.powerVoiceExpired = [requestDic objectForKey:@"endtime"];
                        self.powerVoiceID = [[requestDic objectForKey:@"id"] intValue];
                        
                        NSString *voiceURL = [requestDic objectForKey:@"url"];
                        if (voiceURL && [[MWPreference sharedInstance] getValue:PREF_POWERVOICEID] != self.powerVoiceID) {
                            [[GDBL_LaunchRequest sharedInstance] NET_PowerVoiceDownload:self WithRequestType:RT_PowerVoiceDownload DownloadUrl:voiceURL];
                        }
                    }
                    
                    
                }
                else if ([item isKindOfClass:[NSArray class]])
                {
                    for (NSString *string in item) {
                        
                        NSData* aData = [string dataUsingEncoding:NSUTF8StringEncoding];
                        NSDictionary *requestDic = [NSJSONSerialization
                                                    
                                                    JSONObjectWithData:aData
                                                    
                                                    options:NSJSONReadingMutableLeaves
                                                    
                                                    error:nil];
                        
                        if (requestDic && ([[requestDic objectForKey:@"rdtype"] intValue] == 1)) {
                            
                            self.powerVoiceExpired = [requestDic objectForKey:@"endtime"];
                            self.powerVoiceID = [[requestDic objectForKey:@"id"] intValue];
                            
                            NSString *voiceURL = [requestDic objectForKey:@"url"];
                            if (voiceURL && [[MWPreference sharedInstance] getValue:PREF_POWERVOICEID] != self.powerVoiceID) {
                                [[GDBL_LaunchRequest sharedInstance] NET_PowerVoiceDownload:self WithRequestType:RT_PowerVoiceDownload DownloadUrl:voiceURL];
                            }
                            
                            break;
                        }
                    }
                }
            }
        }
        
    }
    else if (requestType == RT_PowerVoiceDownload)
    {
        [[MWPreference sharedInstance] setValue:PREF_IS_POWERVOICE_PLAY Value:NO];
        [[MWPreference sharedInstance] setValue:PREF_POWERVOICEID Value:self.powerVoiceID];
        
        [[GDCacheManager globalCache] setData:result forKey:GDCacheType_PowerVoice withTimeoutString:self.powerVoiceExpired];
    }
//    else if(requestType == REQ_SKIN_NEW)    //皮肤new请求类型
//    {
//        NSArray *array = (NSArray *)result;
//        [[GDNewJudge sharedInstance] addObjectWithType:NEW_JUDGE_SKIN_TYPE withArray:array];
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_SkinNew] userInfo:nil];
//    }
//    else if(requestType == REQ_CAR_NEW)
//    {
//        NSArray *array = (NSArray *)result;
//        [[GDNewJudge sharedInstance] addObjectWithType:NEW_JUDGE_CAR_TYPE withArray:array];
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_CarNew] userInfo:nil];
//    }
    
}

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error{
    
    if (RT_LaunchRequest_SoftWareUpdate == requestType)//软件版本升级
    {
        [self mapDataUpdate];
    }
}

#pragma  mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
            
        default:
            break;
    }
    
    
}

@end
