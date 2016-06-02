//
//  POIVoiceSearch.m
//  AutoNavi
//
//  Created by huang on 13-9-3.
//
//

#import "POIVoiceSearch.h"
#import "MWVoiceResult.h"
#import "MWPoiOperator.h"
#import "MWMapOperator.h"
#import "POIDefine.h"
#import "POIVoiceSearchViewController.h"
#import "QLoadingView.h"
#import "POICommon.h"
#import "ControlCreat.h"
#import "POIDataCache.h"
#import <AVFoundation/AVFoundation.h>
@interface POIVoiceSearch()<MWPoiOperatorDelegate>
{
    UIViewController *_viewController;
}
@end

@implementation POIVoiceSearch
-(id)initWithViewController:(UIViewController*)viewController
{
    self=[super init];
    if (self) {
        _viewController = viewController;
        
    }
    return self;
}
-(void)startVoiceSearch
{
    if([NSStringFromClass( _viewController.class) isEqualToString:@"MainViewController"])
    {

        [ANParamValue sharedInstance].isSelectCity =0;
        [POIDataCache sharedInstance].flag=EXAMINE_POI_NO;
        [POIDataCache sharedInstance].selectPOIDelegate=nil;
        [POIDataCache sharedInstance].layerController=nil;
        [MWAdminCode SetCurAdarea:[MWAdminCode GetCityAdminCodeWithAdminCode:[MWAdminCode GetCurAdminCode]]];
    }
    if (![POICommon isCanVoiceInput]) {
        return;
    }
    GMAPCENTERINFO mapinfo = {0};
    [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:GMAP_VIEW_TYPE_MAIN mapCenterInfo:&mapinfo];

    int adminCode = [MWAdminCode GetCityAdminCodeWithAdminCode:[MWAdminCode GetCurAdminCode]];
    MWVoiceOption * option = [[MWVoiceOption alloc] init];
    option.longitude = mapinfo.CenterCoord.x;
    option.latitude  = mapinfo.CenterCoord.y;
    option.lAdminCode = adminCode;
    [ANParamValue sharedInstance].searchMapInfo=mapinfo.CenterCoord;
    
    MWPoiOperator * operator = [[MWPoiOperator alloc] initWithDelegate:self];
    [operator voiceSearchWith:option withSuperView:_viewController.view];
    [option release];
    [operator release];
    [MWPoiOperator setRecognizeViewCenter:CGPointMake((Interface_Flag==0?APPWIDTH:APPHEIGHT)/2.0f, (Interface_Flag==1?APPWIDTH:APPHEIGHT)/2.0f)];
   

}


#pragma mark -
#pragma mark 语音委托

- (void)voiceSearchResult:(MWVoiceResult *)result
{
    NSString * stringVoiceName  = nil;
    NSString * string1 = @"周边";
    if (result.cmdtxt.length > 0)
    {
        stringVoiceName = result.cmdtxt;
    }
    else
    {
        [POICommon showAutoHideAlertView:STR(@"POI_NoSearchResult",Localize_POI) ];
        return;
    }
    if (result.voiceDataType == MWVOICE_DATA_CMDERR)
    {
        POIVoiceSearchViewController * voice=[[POIVoiceSearchViewController alloc] init];
        if ([stringVoiceName hasPrefix:string1])
        {//去除周边
            stringVoiceName = [stringVoiceName stringByReplacingOccurrencesOfString:string1 withString:@""];
            voice.voiceType = MWVOICE_DATA_CMDID;
            voice.cmdtxt = stringVoiceName;
            voice.aroundFlag=1;
            //voice.progressFlag=1;
        }else
        {
            voice.voiceType = MWVOICE_DATA_CMDERR;
            voice.cmdtxt = stringVoiceName;
        }
         //modify by wws for 解决ios7 下导航条会闪一下 at 2017-7-26
        _viewController.navigationController.navigationBarHidden = NO;
        [_viewController.navigationController pushViewController:voice animated:YES];
        [voice release];
    }
   
}
-(void)voiceSearchFail:(int)errorCode
{
    if (errorCode==0) {
        return;
    }
    [POICommon showAutoHideAlertView:STR(@"POI_TheWordNotMatched",Localize_POI) ];

}

@end
