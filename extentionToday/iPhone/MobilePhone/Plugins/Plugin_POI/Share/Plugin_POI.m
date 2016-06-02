//
//  Plugin_POI.m
//  AutoNavi
//
//  Created by huang on 13-8-15.
//
//

#import "Plugin_POI.h"
#import "UMengEventDefine.h"
#import "POIWhereToGoViewController.h"
#import "POIAroundViewController.h"
#import "POISearchInputViewController.h"
#import "POIDataCache.h"
#import "POICameraEditViewController.h"
#import "PluginStrategy.h"
#import "SettingCollectViewController.h"
#import "POIDetailViewController.h"
#import "POILineSearch.h"
#import "POIDesParking.h"
#import "POIFavoritesEditViewController.h"
#import "POISearchDesViewController.h"
@implementation Plugin_POI
/*!
  @brief 相应模块调用该方法进入该模块
  @param param: NSDictionary 包含        key                 value
 navigationController      --   上一级导航页面
 type  0去哪里，1周边 2，附近，3输入搜索，4电子眼，5常用 6 POI详情
 data  数据NSDictionary           添加电子眼中，传入key“camera” value  MWSmartEyesItem  详情 key "poiInfo" value MWPoi
 
 type                   7 收藏点界面
 data   NSDictionary    key:@"searchPOIType"    VALUE:[NSNumber]
                        key:@"collectIntoType"  VALUE:[NSNumber]
 
 isBackSuperViewController                                   //是否返回当前进入界面   int  1表示返回原界面 ，不返回的
 layerSelectPOIDelegate   layerSelectPOIDelegate协议
 viewController UIViewController
  @return 0失败;1成功
  */

-(int) enter:(NSObject *)param
{
    if([param isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dic=(NSDictionary*)param;
        if ([[dic objectForKey:POI_NAVIGATIONCONTROLLER] isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *navigation=[dic objectForKey:POI_NAVIGATIONCONTROLLER];
            NSDictionary *data=[dic objectForKey:POI_DATA];
            navigation.navigationBarHidden=NO; /*为了解决ios7下，导航栏会闪一下的问题*/
            NSArray  * array = [dic objectForKey:@"POI_Array"];
            int whereGo = [[dic objectForKey:POI_WhereGo] intValue];
            int isBack = [[dic objectForKey:POI_ISBACKSUPERVIEWCONTROLLER] intValue];
            [POIDataCache sharedInstance].flag=isBack;
            [POIDataCache sharedInstance].selectPOIDelegate=[dic objectForKey:POI_DELEGATE];
            [POIDataCache sharedInstance].layerController=[dic objectForKey:POI_VIEWCONTROLLER];
            [POIDataCache sharedInstance].viewControllerLocation=navigation.viewControllers.count-1;
            switch ([[dic objectForKey:POI_TYPE] intValue]) {
                case 0://导航
                {
                    [MWAdminCode SetCurAdarea:[MWAdminCode GetCityAdminCodeWithAdminCode:[MWAdminCode GetCurAdminCode]]];
                    POIWhereToGoViewController * whereToGoController=[[POIWhereToGoViewController alloc] initWithArray:array];
                    whereToGoController.whereFromGo = whereGo;
                    [navigation pushViewController:whereToGoController animated:YES];
                    [whereToGoController release];
                }break;
                case 1://周边
                {
                    POIAroundViewController *aroundViewController=[[POIAroundViewController alloc] init];
                    [navigation pushViewController:aroundViewController animated:YES];
                    [aroundViewController release];
                    [MobClick event:UM_EVENTID_NEARBY_COUNT label:UM_LABEL_NEARBY_FROM_POI];
                }break;
                case 2://附近
                {
                    POIAroundViewController *aroundViewController=[[POIAroundViewController alloc] init];
                    aroundViewController.isNearBy=YES;
                    [navigation pushViewController:aroundViewController animated:YES];
                    [aroundViewController release];
                    [MobClick event:UM_EVENTID_NEARBY_COUNT label:UM_LABEL_NEARBY_FROM_MAIN];
                }break;
                case 3://搜索
                {
                    [ANParamValue sharedInstance].isSelectCity=0;
                    [MWAdminCode SetCurAdarea:[MWAdminCode GetCityAdminCodeWithAdminCode:[MWAdminCode GetCurAdminCode]]];
                    POISearchInputViewController *aroundViewController=[[POISearchInputViewController alloc] init];
                    [navigation pushViewController:aroundViewController animated:YES];
                    [aroundViewController release];
                    [MobClick event:UM_EVENTID_SEARCH_COUNT label:UM_LABEL_SEARCH_FROM_MAP];
                }break;
                case 4:
                {//添加电子眼
                    NSLog(@"添加电子眼");
                    POICameraEditViewController *cameraEdit=[[POICameraEditViewController alloc] init];
                    cameraEdit.smartEyesItem=[data objectForKey:@"camera"];
                    cameraEdit.isAdd=YES;
                    [navigation pushViewController:cameraEdit animated:YES];
                    [cameraEdit release];
                }break;
                
                case 6:
                {
                    //常用
                    POIDetailViewController *commonViewController=[[POIDetailViewController alloc] initWithPOI:[data objectForKey:@"poiInfo"]];
                    [navigation pushViewController:commonViewController animated:YES];
                    [commonViewController release];
                    
                }break;
                case 7:
                {
                    SettingCollectViewController *collect=[[SettingCollectViewController alloc] init];
                    collect.type= [[dic objectForKey:@"searchPOIType"] intValue];
                    collect.intoType = [[dic objectForKey:@"collectIntoType"] intValue];
                    collect.title= [dic objectForKey:@"title"];
                    [navigation pushViewController:collect animated:YES];
                    [collect release];
                }break;
                case 11:
                {
                    POIFavoritesEditViewController * fav = [[POIFavoritesEditViewController alloc]init];
                    fav.poi = [dic objectForKey:POI_PoiPoint];
                    [navigation pushViewController:fav animated:YES];
                    [fav release];
                    
                }break;
                    
                case 12:
                {
                    int admin = [MWAdminCode GetCityAdminCodeWithAdminCode:[MWAdminCode GetCurAdminCode]];
                    NSLog(@"%d",admin);
                    [MWAdminCode SetCurAdarea:[MWAdminCode GetCityAdminCodeWithAdminCode:[MWAdminCode GetCurAdminCode]]];
                    POISearchDesViewController * whereToGoController=[[POISearchDesViewController alloc] init];
                    [navigation pushViewController:whereToGoController animated:YES];
                    [whereToGoController release];
                }break;
                default:
                    break;
            }
        
            return YES;
        }
        
        if ([[dic objectForKey:POI_TYPE]intValue ]==8) {//沿途周边检索
            
            [POIDataCache sharedInstance].selectPOIDelegate=[dic objectForKey:POI_DELEGATE];
            int category=[[dic objectForKey:POI_CategoryID] intValue];
            [[POILineSearch sharedInstance] PLS_LineSearchKeyWorld:category];
        }
        else if ([[dic objectForKey:POI_TYPE]intValue]==9)
        {
            [POIDataCache sharedInstance].selectPOIDelegate=[dic objectForKey:POI_DELEGATE];
            [[POIDesParking sharedInstance]PDK_DestinationParking:@"停车场"];
            
        }
    }
    return NO;
    
}

// 导航模块调用该方法离开子模块（一般情况下，子模块是调用backToNavi回到导航主模块）
// 返回值：0失败；1成功
-(int) leave
{
    return 1;
}

// 导航模块调用该方法终止子模块（在导航模块因某种原因而需要退出程序，而此时子模块可能还处于执行中，此时导航模块将调用该方法）
// 返回值：0失败；1成功
-(int) exit
{
    return 1;
}

@end
