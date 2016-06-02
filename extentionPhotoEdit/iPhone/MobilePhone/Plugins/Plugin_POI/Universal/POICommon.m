//
//  POICommon.m
//  AutoNavi
//
//  Created by huang on 13-8-21.
//
//

#import "POICommon.h"
#import "MWPoiOperator.h"
#import "ViewPOIController.h"
#import "GDAlertView.h"
#import "MWDefine.h"
#include <objc/runtime.h>
#import "VCCustomNavigationBar.h"
#import <AVFoundation/AVFoundation.h>
#import "CityDownLoadModule.h"
#import "CheckMapDataObject.h"
@implementation POICommon
+(NSArray*)getCollectList:(SEARCH_POI_TYPE)tag
{
    NSArray *array=[NSArray array];
    switch (tag) {
        case SEARCH_FAVORITES:
        {
            MWFavorite *favorite;
            GSTATUS gstatus=[MWPoiOperator getPoiListWith:GFAVORITE_CATEGORY_DEFAULT poiList:&favorite];
            if (gstatus==GD_ERR_OK) {
                array=favorite.pFavoritePOIArray;
            }
            
            
        }
            break;
        case SEARCH_RECENTDESTINATIONS:
        {
            MWFavorite *favorite;
            GSTATUS gstatus=[MWPoiOperator getPoiListWith:GFAVORITE_CATEGORY_HISTORY poiList:&favorite];
            if (gstatus==GD_ERR_OK) {
                array=favorite.pFavoritePOIArray;
            }
        }
            break;
        case SEARCH_CAMERA:
        {
            
            MWSmartEyes *smartEyes;
            GSTATUS gstatus= [MWPoiOperator getSmartEyesListWith:GSAFE_CATEGORY_ALL poiList:&smartEyes];
            if (gstatus==GD_ERR_OK) {
                array=smartEyes.smartEyesArray;
            }
        }
            break;
        case SEARCH_ADDRESSBOOK:
        {
            MWContact *contact;
            if([MWPoiOperator getContactList:&contact])
            {
                array=contact.contactArray;
            }
        }break;
        case SEARCH_HISTORYLINE:
        {
            array=[[MWHistoryRoute sharedInstance] MW_GetUserGuideRouteList];//历史路线
        }break;
        default:
            break;
    }

    return array;
}

+(BOOL)deleteOneCollect:(SEARCH_POI_TYPE)tag withIndex:(int)index  //删除一条收藏
{
    BOOL res=NO;
    switch (tag) {
        case SEARCH_FAVORITES:
        {
            // index 收藏的兴趣点的索引 (即 MWFavoritePoi 类中的 nIndex)
            GSTATUS gstatus = [MWPoiOperator deleteFavoriteWith:GFAVORITE_CATEGORY_DEFAULT index:index ];
            if (gstatus==GD_ERR_OK) {
                res=YES;
            }
        }break;
        case SEARCH_RECENTDESTINATIONS:
        {
            // index 收藏的兴趣点的索引 (即 MWFavoritePoi 类中的 nIndex)
            GSTATUS gstatus=[MWPoiOperator deleteFavoriteWith:GFAVORITE_CATEGORY_HISTORY index:index ];
            if (gstatus==GD_ERR_OK) {
                res=YES;
            }
        }break;
        case SEARCH_CAMERA:
        {
            //index 数组中的索引
            GSTATUS gstatus= [MWPoiOperator deleteSmartEyesWithIndex:index];
            if (gstatus==GD_ERR_OK) {
                res=YES;
            }
        }
            break;
        case SEARCH_HISTORYLINE://历史路线
        {
            NSArray * mArray=[[MWHistoryRoute sharedInstance] MW_GetUserGuideRouteList];
            MWPathPOI * path = [mArray caObjectsAtIndex:index];
            [[MWHistoryRoute sharedInstance]MW_RemoveGuideRouteWithTime:path.operateTime];
            
        }break;
        default:
            break;
    }
  
    return res;

}
+(BOOL)deleteCollectList:(SEARCH_POI_TYPE)tag
{
    BOOL res=NO;

    switch (tag) {
        case SEARCH_FAVORITES:
        {
           
            GSTATUS gstatus=[MWPoiOperator clearFavoriteWith:GFAVORITE_CATEGORY_DEFAULT ];
            if (gstatus==GD_ERR_OK) {
                res=YES;
            }
            
            
        }
            break;
        case SEARCH_RECENTDESTINATIONS:
        {
           
            GSTATUS gstatus=[MWPoiOperator clearFavoriteWith:GFAVORITE_CATEGORY_HISTORY ];
            if (gstatus==GD_ERR_OK) {
                res=YES;
            }
        }
            break;
        case SEARCH_CAMERA:
        {
            GSTATUS gstatus= [MWPoiOperator clearSmartEyesWith:GSAFE_CATEGORY_ALL ];
            if (gstatus==GD_ERR_OK) {
                res=YES;
            }
        }
            break;
        case SEARCH_HISTORYLINE:
        {//历史路线
            [[MWHistoryRoute sharedInstance]MW_RemoveAllGuideRoute];
        }break;
            
        default:
            break;
    }
   
    return res;
}

+(NSArray *)getFavorite:(GFAVORITECATEGORY)type
{
  
    MWFavorite *favorite;
    GSTATUS gst= [MWPoiOperator getPoiListWith:type poiList:&favorite];
    if (gst==GD_ERR_OK) {
        return favorite.pFavoritePOIArray;
    }
    return nil;

}
+(NSString*)getFavoriteAddress:(MWFavoritePoi*)favoritePoi
{
    NSString *address=nil;
    address =favoritePoi.szName;
    if (address.length<1) {
        MWAreaInfo * info = [MWAdminCode GetCurAdareaWith:favoritePoi.lAdminCode];
        if (info.szTownName != 0) {
            address = info.szTownName;
        }
        else
        {
            address= info.szCityName;
        }
    }
    return address;
}
+(NSString*)getPoiAddress:(MWPoi*)poi
{
    if (poi==nil) {
        return @"";
    }
    GCOORD coord ={0};
    coord.x = poi.longitude;
    coord.y = poi.latitude;
    int admincode = poi.lAdminCode?poi.lAdminCode:[MWAdminCode GetAdminCode:coord];
    MWAreaInfo * info = [MWAdminCode GetCurAdareaWith:admincode];
    NSString * szTown=nil;
    //modify by gzm for 若行政编码为0则不进行szTown赋值 at 2017-7-24
    if (admincode  != 0)
    {
        //获取区域
        if (poi.szTown.length >0) {
            szTown = poi.szTown;
        }else
        {
            if (info.szTownName.length>0)
            {
                szTown = info.szTownName;
            }
            else if (info.szCityName.length>0)
            {
                szTown =info.szCityName;
            }
            else
            {
                szTown = info.szProvName;
            }
        }
        //获取地址
        if (poi.szAddr.length==0)
        {
            poi.szAddr = [NSString stringWithFormat:@"%@%@",info.szProvName?info.szProvName:@"",info.szCityName?info.szCityName:@""];
        }
    }
    //如果地址包含前面的区名 去掉前面的区名
    if (poi.szAddr.length>0 && [szTown length] > 0)
    {
        NSRange foundObj=[poi.szAddr rangeOfString:szTown options:NSCaseInsensitiveSearch];
        if(foundObj.length>0)
        {
            return [NSString stringWithFormat:@"%@",poi.szAddr?poi.szAddr:@""];
        }
    }
    NSString * allAddr = [NSString stringWithFormat:@"%@ %@",szTown?szTown:@"",poi.szAddr?poi.szAddr:@""];
    return allAddr;
}
+(BOOL)deleteAddress:(BOOL)isHomeAddress                                //删除家跟公司的地址 0表示家地址 1表示公司地址
{
    GFAVORITECATEGORY type=isHomeAddress==1?GFAVORITE_CATEGORY_COMPANY:GFAVORITE_CATEGORY_HOME;
    NSArray *arr = [POICommon getFavorite:type];
    if(arr==nil||arr.count==0)
    {
        return NO;
    }

   return  [MWPoiOperator deleteFavoriteWith:type index:[[arr objectAtIndex:0] nIndex] ];

}
+(BOOL)collectFavorite:(BOOL)isHome withPOI:(MWFavoritePoi*)favoritePoi //收藏家或公司 0表示收藏家1表示收藏地址
{
    BOOL isSuccess;
    favoritePoi.eCategory = isHome==0?GFAVORITE_CATEGORY_HOME:GFAVORITE_CATEGORY_COMPANY;
    favoritePoi.eIconID=isHome==0?GFAVORITE_ICON_HOME:GFAVORITE_ICON_COMPANY;
    GSTATUS type = [MWPoiOperator collectPoiWith:favoritePoi];
    if (type == GD_ERR_OK) {
        isSuccess=YES;
    }
    return isSuccess;
}

+(NSString*)addressNameTransition:(NSString *)address withAdminCode:(int)adminCode
{
    if (address&&address.length<1) {
        MWAreaInfo * info = [MWAdminCode GetCurAdareaWith:adminCode];
        if (info.szTownName != 0) {
            address = info.szTownName;
        }
        else
        {
            address= info.szCityName;
        }
    }
    return address;
}

+(NSString*)getHomeAddress
{
    NSArray *arr = [POICommon getFavorite:GFAVORITE_CATEGORY_HOME];
    if(arr==nil||arr.count==0)
    {
        return nil;
    }
    return [POICommon getFavoriteAddress:[arr objectAtIndex:0]];

}
+(NSString*)getCompantAddress
{
    NSArray *arr = [POICommon getFavorite:GFAVORITE_CATEGORY_COMPANY];
    if(arr==nil||arr.count==0)
    {
        return nil;
    }
    return [POICommon getFavoriteAddress:[arr objectAtIndex:0]];
     [POICommon getFavorite:GFAVORITE_CATEGORY_COMPANY];
}
+(UIViewController*)intoPOIViewController:(UIViewController*)viewController withIndex:(int)index withViewFlag:(int)flag withPOIArray:(NSArray*)arr
{

    return [POICommon  intoPOIViewController:viewController withIndex:index withViewFlag:flag withPOIArray:arr withTitle:@""];
}
+(UIViewController*)intoPOIViewController:(UIViewController*)viewController withIndex:(int)index withViewFlag:(int)flag withPOIArray:(NSArray*)arr withTitle:(NSString*)title
{
    UIViewController * POIController;
    //截取数组中的数据 100个
    NSArray * newArray =[POICommon rangeArray:index withArray:arr];
    //检测当前POI点的城市有没有下载
    if (newArray.count>0) {
        MWPoi * poi = [newArray objectAtIndex:index%100];
        if (poi) {
            int check = [CheckMapDataObject CheckMapDataWith:poi cancelHandler:^(GDAlertView * alert)
                         {
                             UIViewController * Controller= [[ViewPOIController alloc] initWithIndex:index%100 ViewFlag:flag POI:newArray withTitle:title];
                             //解决导航条会闪一下
                             viewController.navigationController.navigationBarHidden = NO;
                             [viewController.navigationController pushViewController:Controller animated:YES];
                             [Controller release];
                         }];
            if (check == 0) {
                return nil;
            }
        }
    }
    POIController= [[ViewPOIController alloc] initWithIndex:index%100 ViewFlag:flag POI:newArray withTitle:title];
//    NSMutableArray * array = [NSMutableArray arrayWithArray:viewController.navigationController.viewControllers];
//    for (int i = 0 ; i <  array.count; i++)
//    {
//        NSRange rang ;
//
//        if ([[array objectAtIndex:i] isKindOfClass:[ViewPOIController class]])
//        {
//            rang.location = 1;
//            rang.length = i ;
//            [array removeObjectsInRange:rang];
//            [array addObject:POIController];
//            [viewController.navigationController setViewControllers:array];
//            [POIController release];
//            return POIController;
//        }
//    }
    //解决导航条会闪一下
    viewController.navigationController.navigationBarHidden = NO;
    [viewController.navigationController pushViewController:POIController animated:YES];
    [POIController release];
    return POIController;
    
}


+(void)showAutoHideAlertView:(NSString*)message
{
    [POICommon showAutoHideAlertView:message showTime:2];
}
+(void)showAutoHideAlertView:(NSString*)message showTime:(CGFloat)time
{
    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:message] autorelease];
    //[GDAlertView shouldAutorotate:NO];
    [alertView show];
}
+(void)copyWMPoiValutToSubclass:(MWPoi*)poi withPoiSubclass:(id)object
{
    
    if ([object isKindOfClass:[MWPoi class]]) {
        unsigned int outCount,i;
        //获取出该类的所有属性，并不能获取出其基类的所有属性
        objc_property_t *properties=class_copyPropertyList([MWPoi class],&outCount);
        for (i=0; i<outCount; i++) {
            objc_property_t property=properties[i];
            NSString *key=[[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            [object setValue:[poi valueForKey:key] forKey:key];
            [key release];
//            NSLog(@"key=%@, value=%@ poiNodeValue=%@",key,[object valueForKey:key],[poi valueForKey:key]);
        }
        free(properties); 
    }
    
    return;
}

+(NSString *)getCityName
{
    if ([ANParamValue sharedInstance].isSelectCity !=1)
    {    //modify by wws for 有路径下城市选择为 车位当前的城市 at 2014-8-11
        if ([ANParamValue sharedInstance].isPath)
        {
            GCARINFO carInfo = {0};
            [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carInfo];
            int adCode = [[MWAdminCode GetCityAdminCode:carInfo.Coord.x Lat:carInfo.Coord.y] intValue];
            NSString * cityName = [MWAdminCode GetCityNameWithAdminCode:adCode];
            [MWAdminCode SetCurAdarea:adCode];
            [ANParamValue sharedInstance].isSelectCity = 1;
            return cityName;
        }
        NSString * cityName;
        int adminCode = [MWAdminCode GetCurAdminCode]/10000;
        if (adminCode == 11 || adminCode == 81 || adminCode == 82 || adminCode == 50 || adminCode == 31 || adminCode == 12)
        {
            MWAreaInfo * areainfo = [MWAdminCode GetCurAdareaWith:[MWAdminCode GetCurAdminCode]];
            cityName = areainfo.szProvName;
        }
        //modify by wws for 如果移图到台湾则将台湾显示为全国（不然为空） at 2017-7-29
        else if(adminCode == 0||adminCode == 71)
        {
            
            cityName = STR(@"POI_Country", Localize_POI);
        }
        else
        {
            MWAreaInfo * areainfo = [MWAdminCode GetCurAdareaWith:[MWAdminCode GetCurAdminCode]];
            cityName = areainfo.szCityName;
        }
        return cityName;
    }
    else if([ANParamValue sharedInstance].isSelectCity==1)
    {
        NSString *townName = [NSString stringWithFormat:@"%@",[MWAdminCode GetAdareaName]];
        return townName;
    }
    return nil;

}
+ (int)convertToInt:(NSString*)strtemp {
    
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    int i=0;
    for (i; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
            
        }
    }
    return (strlength);
}

//+(NSString*)con

+ (BOOL)countCharacter:(NSString*)character withLimitCount:(int)count
{
    if([POICommon convertToInt:character]>count)
        return YES;
    return NO;
}
+(NSArray*)rangeArray:(int) index withArray:(NSArray*)array withRangeCount:(int)count      //截取数组中的数据
{
    NSMutableArray *newArray=[NSMutableArray array];
    
    int start = index/count;
    int totalCount;
    totalCount=(int)(array.count-(start+1)*count)>0?count:(array.count-start*count);
    
    for (int i=start*count; i<start*count+totalCount;i++)
    {
        [newArray addObject:[array objectAtIndex:i]];
    }
    return newArray;
}
+(NSArray*)rangeArray:(int) index withArray:(NSArray*)array                                //截取数组中的数据 100个
{
    return [POICommon rangeArray:index withArray:array withRangeCount:100];
}
+(NSString*)deleteMoreSpacing:(NSString*)string
{
    while ([string rangeOfString:@"  "].location!=NSNotFound) {
        string = [string stringByReplacingOccurrencesOfString:@"  " withString:@""];
    }
    return string;

}

+(UINavigationItem*)allocNavigationItem:(NSString*)title rightTitle:(NSString *)rightTitle
{
    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    
   
    int buttonWith = 0;
    
    if (rightTitle)
    {
        CGSize labelSize = [rightTitle sizeWithFont:[UIFont systemFontOfSize:kSize6]];
        
        if (isiPhone)
        {
            buttonWith = 85;
        }
        else
        {
            buttonWith = 135;
        }
        buttonWith = (labelSize.width + 30.0f > buttonWith)?buttonWith:labelSize.width + 30.0f;
    }
    
    float leftButtonWidth = 45;
    
    float maxWidth = buttonWith > leftButtonWidth?buttonWith:leftButtonWidth;
    
    float labelMaxWidth = SCREENWIDTH - 2*maxWidth;
    
    float lable_width = 0;
    float lable_height = 44;
    float offsetx = 0;
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:kSize1]];
    if (titleSize.width > labelMaxWidth)
    {
        lable_width = SCREENWIDTH - buttonWith - leftButtonWidth;
        offsetx = buttonWith - leftButtonWidth;
    }
    else
    {
        lable_width = labelMaxWidth;
    }
    
    UILabel *label;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    view.backgroundColor = [UIColor clearColor];
    
    UIFont *font=[UIFont systemFontOfSize:kSize1];
    label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, lable_width, lable_height)];
    label.center = CGPointMake(5 - offsetx/2, 5);
    label.backgroundColor=[UIColor clearColor];
    label.font = font;
    label.text=title;
    label.tag = 112;
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=NAVIGATIONBARTITLECOLOR;
    [view addSubview: label];
    [label release];
    
    navigationItem.titleView = view;
    [view release];
    
    return [navigationItem autorelease];
}

+(UINavigationBar*)allocNavigationBar:(NSString*)title
{
    VCCustomNavigationBar* _navigationBar = [[VCCustomNavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREENWIDTH, 44.0 + DIFFENT_STATUS_HEIGHT)];
    _navigationBar.isRotate=NO;
    UILabel *titeLable = [[UILabel alloc] initWithFrame:CGRectMake(100/2,
                                                                   DIFFENT_STATUS_HEIGHT,
                                                                   SCREENWIDTH - 100,
                                                                   44.0f)];
    titeLable.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    titeLable.textAlignment = UITextAlignmentCenter;
    titeLable.textColor = NAVIGATIONBARTITLECOLOR;
    titeLable.backgroundColor = [UIColor clearColor];
    titeLable.font = [UIFont systemFontOfSize:kSize1];
    titeLable.text = title;
    [_navigationBar addSubview:titeLable];
    [titeLable release];
    return [_navigationBar autorelease];
}

+(UINavigationBar*)allocNavigationBar:(NSString*)title withFrame:(CGRect)naviFrame
{
    VCCustomNavigationBar* _navigationBar = [[VCCustomNavigationBar alloc] initWithFrame:naviFrame];
    _navigationBar.isRotate = NO;
    UILabel *titeLable = [[UILabel alloc] initWithFrame:CGRectMake(100/2,
                                                                   DIFFENT_STATUS_HEIGHT,
                                                                   naviFrame.size.width - 100,
                                                                   naviFrame.size.height - DIFFENT_STATUS_HEIGHT)];
    titeLable.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    titeLable.textAlignment = UITextAlignmentCenter;
    titeLable.textColor = NAVIGATIONBARTITLECOLOR;
    titeLable.backgroundColor = [UIColor clearColor];
    titeLable.font = [UIFont systemFontOfSize:kSize1];
    titeLable.text = title;
    [_navigationBar addSubview:titeLable];
    [titeLable release];
    return [_navigationBar autorelease];
}


//中英文，获取关键字时，开头是否有"e"
+(NSString *)netGetKey:(NSString *)key
{
    if ([[MWPreference sharedInstance] getValue:PREF_UILANGUAGE] == 2)
    {
        return [NSString stringWithFormat:@"e%@",key];
    }
    return key;
}
/*
 对网络电话进行特殊处理
 获取前两个电话
 */
+(NSString *)netGetTel:(NSString *)string
{
    if ([string rangeOfString:@";"].location != NSNotFound)
    {
        NSArray * array = [string componentsSeparatedByString:@";"];
        if (array.count>2) {
            return  [[[array objectAtIndex:0] stringByAppendingString:@";"] stringByAppendingString:[array objectAtIndex:1]];
        }else
        {
            return string;
        }
    }
    else
    {
        return  string;
    }
    return nil;
}
//判断当前是不是符合语音输入的条件
+(BOOL)isCanVoiceInput
{
    if ( [[MWPreference sharedInstance] getValue:PREF_UILANGUAGE]!=0) {
        GDAlertView *alertView = [[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_VoiceUnavailable", Localize_POI)] autorelease];
        [alertView addButtonWithTitle:STR(@"POI_OK", Localize_POI) type:GDAlertViewButtonTypeCancel handler:nil];
        [alertView show];
        return NO;
    }
    __block BOOL isOpengranted=YES;
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
    {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            isOpengranted=granted;
            NSLog(@"granted = %d",granted);
        }];
        if (isOpengranted==NO) {
            
            GDAlertView *alertView=[[GDAlertView alloc] initWithTitle:nil andMessage:@"请打开系统设置中\"隐私→麦克风\"，允许\"高德导航\"访问您的麦克风。"];
            [alertView addButtonWithTitle:STR(@"POI_OK",Localize_POI) type:GDAlertViewButtonTypeDefault handler:nil];
            [alertView show];
            [alertView release];
            return NO;
        }
    }
    return YES;
}
//计算两点的距离 车位到POI点的距离
+(int)netCarToPOIDistance:(MWPoi*)poi
{
    if (!poi) {
        return 0;
    }
    GCOORD coor1;
    GCOORD coor2;
    coor1.x=poi.longitude;
    coor1.y=poi.latitude;
    //当前车位的点
    GCARINFO mapinfo = {0};
    [[MWMapOperator sharedInstance] GMD_GetCarInfo:&mapinfo];
    coor2.x=mapinfo.Coord.x;
    coor2.y=mapinfo.Coord.y;
    int dances= [MWEngineTools CalcDistanceFrom:coor1 To:coor2];
    return dances;
}
+(int)getPoiadCode:(MWPoi *)poi
{
    if (poi) {
        if (poi.lAdminCode>0) {
            return poi.lAdminCode;
        }else
        {
            GCOORD coor;
            coor.x = poi.longitude;
            coor.y = poi.latitude;
            return [MWAdminCode GetAdminCode:coor];
        }
    }
    return nil;
}

+(BOOL)isEqualToCompanyAndHome:(MWPoi *)poi
{
    if (poi) {
        if ([POICommon isEqualToCompany:poi]||[POICommon isEqualToHome:poi]) {
            return YES;
        }
        return NO;
    }
    return NO;
}
+(BOOL)isEqualToCompany:(MWPoi *)poi
{
    
    NSArray * companyArray = [POICommon getFavorite:GFAVORITE_CATEGORY_COMPANY];
    
    if(companyArray==nil||companyArray.count==0)
    {
        return NO;
    }
    MWPoi * compamyPoi = [[[MWPoi alloc]init] autorelease];
    [POICommon copyWMPoiValutToSubclass:[companyArray caObjectsAtIndex:0] withPoiSubclass:compamyPoi];
    if (poi.latitude==compamyPoi.latitude&&poi.longitude==compamyPoi.longitude) {
        return YES;
    }
    return NO;
}
+(BOOL)isEqualToHome:(MWPoi *)poi
{
    NSArray * homeArray = [POICommon getFavorite:GFAVORITE_CATEGORY_HOME];
    if(homeArray==nil||homeArray.count==0)
    {
        return NO;
    }
    MWPoi * homePoi =[[[MWPoi alloc]init] autorelease];
    [POICommon copyWMPoiValutToSubclass:[homeArray caObjectsAtIndex:0] withPoiSubclass:homePoi];
    if (poi.latitude==homePoi.latitude&&poi.longitude==homePoi.longitude) {
        return YES;
    }
    return NO;
}

@end
