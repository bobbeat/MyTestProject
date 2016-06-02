//
//  CheckMapDataObject.m
//  AutoNavi
//
//  Created by gaozhimin on 14-7-26.
//
//

#import "CheckMapDataObject.h"
#import "CityDownLoadModule.h"
#import "AppDelegate_iPhone.h"

static BOOL g_isTipNotFitCal = NO;  //是否提示为不合理路径规划

@interface CheckMapDataObject()
{
    
}

@end

@implementation CheckMapDataObject

/*
 * @brief 是否提示为不合理路径规划
 * @parm  isFit YES为不合理规划路径
 */
+ (void)setNotFitcal:(BOOL)isFit
{
    g_isTipNotFitCal = isFit;
}

/*
 * @brief 检测地图中心点是否有地图数据 用于移图时的检测 不会弹出提示框
 * @return -1:海 0:无数据区域 1:有数据
 */
+ (int)CheckMapData
{
    GCOORD coord = {-1,-1};
    NSArray *array = [MWAdminCode GetAdminCodeArray:coord];  //返回多个行政编码表示无数据
    if ([array count] >1)
    {
        return 0;
    }
    else if ([array count] == 0)
    {
        return -1;
    }
    int Admin_code = [[array caObjectsAtIndex:0] intValue];
    if (Admin_code == 0) //行政区域为0时，表示位置处于海，不需要提示。
    {
        return -1;
    }
    MWAreaInfo *info = [MWAdminCode GetCurAdareaWith:Admin_code];
    return info.bHasData;
}

/*
 * @brief 根据poi检测地图数据，用于查看poi，无数据时会弹出提示框
 * @return -1:海 0:无数据区域 1:有数据
 */
+ (int)CheckMapDataWith:(MWPoi *)poi cancelHandler:(GDAlertViewHandler)handler;
{
    GCOORD coord = {0};
    coord.x = poi.longitude;
    coord.y = poi.latitude;
    NSArray *array = [MWAdminCode GetAdminCodeArray:coord];
    int count = [array count];
    
    int *admincode = malloc(sizeof(int) * count);
    for (int i = 0; i < count; i++)
    {
        admincode[i] = [[array caObjectsAtIndex:i] intValue];
    }
    if (count == 0)
    {
        return -1;
    }
    else
    {
        [CheckMapDataObject TipTheMissingCity:admincode missingCount:count bRoute:NO cancelHandler:handler];
    }
    if (admincode)
    {
        free(admincode);
    }
    return 0;
}

/*
 * @brief 根据缺失城市行政编码，提示缺失城市，会弹出提示框
 * @parm missingCityAdmincode 缺失城市的行政编码
 * @parm missingCount 缺失城市的个数
 * @parm bRoute 是否为演算的缺失城市
 */
+ (void)TipTheMissingCity:(int *)missingCityAdmincode missingCount:(int)missingCount bRoute:(BOOL)bRoute cancelHandler:(GDAlertViewHandler)handler;
{
    NSMutableArray *array = [NSMutableArray array];
    int totalCount = missingCount;
    for (int i = 0; i < totalCount; i++)
    {
        int adminCode = missingCityAdmincode[i];
        
        MWAreaInfo *info = [MWAdminCode GetCurAdareaWith:adminCode];
        if (info.bHasData) //传入缺失城市的列表中若是有数据，则不加入下载列表。
        {
            missingCount--;
            continue;
        }
        else
        {
            if ((adminCode/10000 == 81)||(adminCode/10000 == 82)||(adminCode/10000 == 11)||(adminCode/10000 == 50)||(adminCode/10000 == 31)||(adminCode/10000 == 12)) //modify by gzm for 碰到直辖市，不要获取区的名称 at 2014-8-04
            {
                missingCityAdmincode[i] = (adminCode/100)*100;
                if (i > 0)
                {
                    if (missingCityAdmincode[i] == missingCityAdmincode[i-1]) //判断上一个行政编码是否属于同一个直辖市，若是则不添加
                    {
                        missingCount--;
                        continue;
                    }
                }
            }
        }
        
        [array addObject:[NSNumber numberWithInt:missingCityAdmincode[i]]];
    }
    
    if (missingCount == 0) //无缺失城市列表，返回
    {
        if (handler)
        {
            handler(nil);
        }
        return;
    }
    
    for (int i = 0; i < [array count]; i++)
    {
        missingCityAdmincode[i] = [[array objectAtIndex:i] intValue];
    }
    NSDictionary *missingDic = [NSDictionary dictionaryWithObject:array forKey:@"city"];
    if (!bRoute)
    {
        if (missingCount >= 1)
        {
            NSString *city = @"";
            for (int i = 0; i < missingCount; i++)
            {
                if (i == 3) //最多显示三个城市
                {
                    break;
                }
                MWAreaInfo *info = [MWAdminCode GetCurAdareaWith:missingCityAdmincode[i]];
                if (info && !info.bHasData)
                {
                    city = [city stringByAppendingFormat:@"%@%@,",info.szProvName,info.szCityName];
                }
            }
            if ([city length] > 0)
            {
                city = [city substringToIndex:[city length] - 1];
            }
            NSString *message = [NSString stringWithFormat:STR(@"Main_VisitCityNoData", Localize_Main),city];
            GDAlertView *alert = [[GDAlertView alloc] initWithTitle:nil andMessage:message];
            [alert addButtonWithTitle:STR(@"Universal_no", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:handler];
            [alert addButtonWithTitle:STR(@"Universal_yes", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView) {
                [CheckMapDataObject EnterLoadDataViewWith:missingDic];
            }];
            [alert show];
            [alert release];
        }
    }
    else
    {
        if (missingCount == 1)
        {
            MWAreaInfo *info = [MWAdminCode GetCurAdareaWith:missingCityAdmincode[0]];
            if (info && !info.bHasData)
            {
                NSString *city = [NSString stringWithFormat:@"%@",info.szCityName];
                if ([city length] == 0) {  //modify by gzm for 防止获取不到特别行政区名称 at 2014-11-18
                    city = info.szProvName;
                }
                NSString *message = nil;
                if (g_isTipNotFitCal == YES)
                {
                    g_isTipNotFitCal = NO;
                    message = [NSString stringWithFormat:STR(@"Main_RouteNoDataForOneFit", Localize_Main),city];
                }
                else
                {
                    message = [NSString stringWithFormat:STR(@"Main_RouteNoDataForOne", Localize_Main),city];
                }
                GDAlertView *alert = [[GDAlertView alloc] initWithTitle:nil andMessage:message];
                [alert addButtonWithTitle:STR(@"Universal_no", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView) {
                    [MWRouteCalculate setIsTipMissingCity:NO];
                    if (handler)
                    {
                        handler(nil);
                    }
                }];
                [alert addButtonWithTitle:STR(@"Universal_yes", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView) {
                    [CheckMapDataObject EnterLoadDataViewWith:missingDic];
                }];
                [alert show];
                [alert release];
            }
            else
            {
                if (handler)
                {
                    handler(nil);
                }
            }
        }
        else
        {
            NSString *city = @"";
            for (int i = 0; i < missingCount; i++)
            {
                if (i == 3) //最多显示三个城市
                {
                    break;
                }
                MWAreaInfo *info = [MWAdminCode GetCurAdareaWith:missingCityAdmincode[i]];
                if (info && !info.bHasData)
                {
                    NSString *cityName = info.szCityName;
                    if ([cityName length] == 0) {
                        cityName = info.szProvName;
                    }
                    city = [city stringByAppendingFormat:@"%@,",cityName];
                }
            }
            city = [city substringToIndex:[city length] - 1];
            NSString *message = nil;
            if (g_isTipNotFitCal == YES)
            {
                g_isTipNotFitCal = NO;
                message = [NSString stringWithFormat:STR(@"Main_RouteNoDataForManyFit", Localize_Main),city,missingCount];
            }
            else
            {
                message = [NSString stringWithFormat:STR(@"Main_RouteNoDataForMany", Localize_Main),city,missingCount];
            }
            GDAlertView *alert = [[GDAlertView alloc] initWithTitle:nil andMessage:message];
            [alert addButtonWithTitle:STR(@"Universal_no", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView) {
                [MWRouteCalculate setIsTipMissingCity:NO];
                if (handler)
                {
                    handler(nil);
                }
            }];
            [alert addButtonWithTitle:STR(@"Universal_yes", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView) {
                [CheckMapDataObject EnterLoadDataViewWith:missingDic];
            }];
            [alert show];
            [alert release];
        }
    }
    
}

#pragma mark -
#pragma mark private method

+ (void)popToRootControllerWith:(UIViewController *)ModalViewController animated:(BOOL)animated
{
    if (ModalViewController == nil)
    {
        return;
    }
    if ([[[ModalViewController class] description] isEqualToString:@"ParentViewController"])
    {
        return;
    }
    
    __block UIViewController *presentingViewController = ModalViewController.presentingViewController;
    [ModalViewController dismissViewControllerAnimated:NO completion:^{
        [self popToRootControllerWith:presentingViewController animated:animated];
    }];
}

/*
 * @brief 进入数据下载界面
 */
+ (void)EnterLoadDataViewWith:(NSDictionary *)missCityDic
{
    AppDelegate_iPhone *delegate = (AppDelegate_iPhone *)[UIApplication sharedApplication].delegate;
    UINavigationController *navigationController = (UINavigationController *)delegate.navigationController;
    if (navigationController.visibleViewController != navigationController.topViewController)
    {
        BOOL sing = YES;
        UIViewController *ctl = navigationController.visibleViewController;
        while (sing)
        {
            if (ctl.presentedViewController)
            {
                ctl = ctl.presentedViewController;
            }
            else
            {
                sing = NO;
            }
            NSLog(@"%@",[[ctl class] description]);
        }
        [CheckMapDataObject popToRootControllerWith:ctl animated:NO];
    }
    
    CityDownLoadModule *tempCityDown = [[CityDownLoadModule alloc] init];
    id<ModuleDelegate> module = tempCityDown;
    NSDictionary *param;
    param = [[NSDictionary alloc] initWithObjectsAndKeys:navigationController,@"controller",@"assignDownData",@"parma",missCityDic,@"cityAdmincode",nil];
    [module enter:param];
    [param release];
    [tempCityDown release];
}

+ (instancetype)SharedInstance
{
    static CheckMapDataObject *object = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object = [[CheckMapDataObject alloc] init];
    });
    return object;
}

@end
