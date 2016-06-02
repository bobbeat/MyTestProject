//
//  POIShowObject.m
//  AutoNavi
//
//  Created by jiangshu.fu on 13-10-29.
//
//

#import "POIShowObject.h"
#import "MWPoiOperator.h"

@interface POIShowObject()
{
    BOOL isShowNetPoi;
    BOOL cancel;
    MWPoiOperator *poiOperator;
}

@end

@implementation POIShowObject
@synthesize coord = _coord;
@synthesize popPoi = _popPoi;
@synthesize delegate = _delegate;
@synthesize mapType = _mapType;
@synthesize poiType = _poiType;
- (id) init
{
    self =[super init];
    if(self)
    {
        _mapType = GMAP_VIEW_TYPE_MAIN;
        isShowNetPoi = YES;
        _poiType = ViewPOIType_Detail;
        poiOperator = [[MWPoiOperator alloc] initWithDelegate:self];
    }
    return self;
}

- (id) initwithPopPoi:(GDPopPOI *)popPoi withCenter:(GCOORD)coord
{
    self = [self init];
    if(self)
    {
        _popPoi = popPoi;
        _coord = coord;
    }
    return self;
}

- (void) show
{
    [_popPoi setHidden:YES];
    cancel=NO;
    isShowNetPoi = YES;
    [poiOperator poiNearestSearchWithCoord:_coord];
    _popPoi.isShow = YES;
}
-(void)cancel
{
    cancel=YES;
    [_popPoi setHidden:YES];
}

- (void) showPOI:(MWPoi*) poi
{
    isShowNetPoi = NO;
    [_popPoi setHidden:YES];
    _popPoi.favoriteState = [MWPoiOperator isCollect:poi];
    [_popPoi setStringAtPos:poi withMapType:_mapType];
    [_popPoi startAnimate:0.4];
    [_popPoi setHidden:NO];
    
    if(_delegate && [_delegate respondsToSelector:@selector(afterSuccessSearch)])
    {
        [_delegate afterSuccessSearch];
    }
}

/*!
 @brief 当前点最近的POI点查询回调函数
 @param coord 发起POI查询的查询选项(具体字段参考GCOORD类中的定义)
 @param result 查询结果(具体字段参考MWPoi类中的定义)
 */
-(void)poiNearestSearch:(GCOORD)coord Poi:(MWPoi *)poi
{
    if(isShowNetPoi)
    {
        if ([MWAdminCode checkIsExistDataWithCoord:coord] == 0) {
            
            return;
        }
        
        NSLog(@"%@",poi.szName);
        poi.szName = [NSString stringWithFormat:STR(@"Main_NearBy", Localize_Main),poi.szName];
        GMAPCENTERINFO mapCenter = {0};
        GHMAPVIEW phMapView;
        GDBL_GetMapViewHandle(GMAP_VIEW_TYPE_MAIN, &phMapView);
        GDBL_GetMapViewCenterInfo(phMapView, &mapCenter);
        
        GROADINFO pRoadInfo = {0};
        GDBL_GetRoadInfoByCoord(&coord, &pRoadInfo);
        
        if (coord.x == mapCenter.CenterCoord.x && coord.y == mapCenter.CenterCoord.y && pRoadInfo.nDistance < poi.lDistance) {
            poi.szName = [NSString stringWithFormat:STR(@"Main_NearBy", Localize_Main),[NSString chinaFontStringWithCString:mapCenter.szRoadName]];
            
            NSString *cityName = [MWAdminCode GetCityNameWithAdminCode:poi.lAdminCode];
            if (!cityName || [cityName length] == 0) {
                cityName = @"";
            }
            MWAreaInfo * info = [MWAdminCode GetCurAdareaWith:poi.lAdminCode];
            poi.szAddr = [NSString stringWithFormat:@"%@%@",info.szProvName,info.szCityName];
            NSString *townName =info.szTownName;
            if (!townName || [townName length] == 0) {
                townName = @"";
            }
            poi.szAddr = [NSString stringWithFormat:@"%@%@",cityName,townName];
            
            poi.szTel = @"";
        }
        else {
            if (poi.szAddr && [poi.szAddr length] == 0) {
                
                NSString *cityName = [MWAdminCode GetCityNameWithAdminCode:poi.lAdminCode];
                if (!cityName || [cityName length] == 0) {
                    cityName = @"";
                }
                MWAreaInfo * info = [MWAdminCode GetCurAdareaWith:poi.lAdminCode];
    
                NSString *townName =info.szTownName;
                if (!townName || [townName length] == 0) {
                    townName = @"";
                }
                poi.szAddr = [NSString stringWithFormat:@"%@%@",cityName,townName];
            }
        
        }
        GCARINFO carInfo = {0};
        GDBL_GetCarInfo(&carInfo);
        GCOORD startCoord = {0};
        GCOORD desCoord = {0};
        startCoord.x = poi.longitude;
        startCoord.y = poi.latitude;
        desCoord.x =carInfo.Coord.x;
        desCoord.y =carInfo.Coord.y;
        int distance=   [MWEngineTools CalcDistanceFrom:coord  To:desCoord];
        poi.lDistance = distance;
        poi.longitude = coord.x;
        poi.latitude = coord.y;
        poi.lNaviLat = 0;
        poi.lNaviLon = 0;
        [_popPoi setPopPOIType:_poiType];
        _popPoi.favoriteState = [MWPoiOperator isCollect:poi];
        [_popPoi setStringAtPos:poi withMapType:_mapType];
        [_popPoi startAnimate:0.4];
        [_popPoi setHidden:NO];
        if(_delegate && [_delegate respondsToSelector:@selector(afterSuccessSearch)])
        {
            [_delegate afterSuccessSearch];
        }
    }
}

/*!
 @brief 通知查询成功或失败的回调函数
 @param poiOperatorOption 发起查询的查询选项
 @param errCode 错误码 \n
 */
-(void)search:(id)poiOperatorOption Error:(NSError *)error
{
    if(isShowNetPoi)
    {
        //点击车位获取附近点详情弹出框
        MWSearchOption *poiInfo = (MWSearchOption *)poiOperatorOption;
        if (poiInfo.longitude == 0 || poiInfo.latitude == 0)
        {
            if(_delegate && [_delegate respondsToSelector:@selector(afterFailSearch)])
            {
                [_delegate afterFailSearch];
            }
            return;
        }

        GCOORD pcoord ={0};
        pcoord.x = poiInfo.longitude;
        pcoord.y = poiInfo.latitude;
        if ([MWAdminCode checkIsExistDataWithCoord:pcoord] == 0 )
        {
            if(_delegate && [_delegate respondsToSelector:@selector(afterFailSearch)])
            {
                [_delegate afterFailSearch];
            }
            return;
        }
        [_popPoi setHidden:YES];
        if(_delegate && [_delegate respondsToSelector:@selector(afterSuccessSearch)])
        {
            [_delegate afterSuccessSearch];
        }
        MWPoi *poi = [[MWPoi alloc] init];
        poi.longitude=poiInfo.longitude;
        poi.latitude=poiInfo.latitude;
    
        
        GCOORD pcood={0};
        pcood.x = poiInfo.longitude;
        pcood.y = poiInfo.latitude;
        MWAreaInfo * info = [MWAdminCode GetCurAdareaWith:[MWAdminCode GetAdminCode:pcood]];
        int adminCode =[MWAdminCode GetAdminCode:pcood];
        NSString * cityName = [MWAdminCode GetCityNameWithAdminCode:adminCode];
        NSString * townName = @"";
        if (info.szTownName && [info.szTownName length] > 0)
        {
            townName = info.szTownName;
        }
        NSString *poiName;
        //获取不到最近的POI点信息 组装成 城市 ＋ 地区
        if(cityName.length > 0 || townName.length > 0)
        {
            poiName = [NSString stringWithFormat:@"%@%@",cityName,townName];
        }
        else
        {
            poiName = @"";
        }
        if (poiName && [poiName length] > 0)
        {
            poi.szName = poiName;
        }
        else
        {
            poi.szName = STR(@"Main_unNameRoad", Localize_Main);
        }
        //modify by wws for 解决收藏点没有地址的bug at 2017-7-31
        poi.lAdminCode = adminCode;
        GCARINFO carInfo = {0};
        GDBL_GetCarInfo(&carInfo);
        GCOORD startCoord = {0};
        GCOORD desCoord = {0};
        startCoord.x = poi.longitude;
        startCoord.y = poi.latitude;
        desCoord.x =carInfo.Coord.x;
        desCoord.y =carInfo.Coord.y;
        int distance=   [MWEngineTools CalcDistanceFrom:startCoord  To:desCoord];
        poi.lDistance = distance;
    
        poi.longitude = poiInfo.longitude;
        poi.latitude = poiInfo.latitude;
        [_popPoi setPopPOIType:_poiType];
        _popPoi.favoriteState = [MWPoiOperator isCollect:poi];
        [_popPoi setStringAtPos:poi withMapType:GMAP_VIEW_TYPE_MAIN];
        [_popPoi startAnimate:0.4];
        [_popPoi setHidden:NO];
        [poi release];
    }
}

- (void) dealloc
{
    if (poiOperator) {
        poiOperator.poiDelegate=nil;
        [poiOperator release];
    }
    
    [super dealloc];
}


@end
