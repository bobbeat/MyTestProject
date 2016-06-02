//
//  POILineSearch.m
//  AutoNavi
//
//  Created by weisheng on 14-4-4.
//
//

#import "POILineSearch.h"
#import "MWNetSearchOption.h"
#import "MWNetSearchOperator.h"
#import "MWMapOperator.h"
#import "JSONKit.h"
#import "POIDataCache.h"
#import "MWPoiOperator.h"
static POILineSearch *instance=nil;
@implementation POILineSearch
@synthesize guideRouteHandle;
@synthesize poiLineArray;

-(id)init
{
    self=[super init];
    if (self) {
        poiLineArray=[[NSMutableArray alloc]init];
        poiOperator =[[MWPoiOperator alloc] initWithDelegate:self];
    }
    return self;
}
+(POILineSearch*)sharedInstance
{
    @synchronized(self)
    {
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}
-(void)PLS_LineSearchKeyWorld:(int)CategoryID
{
    self.CategoryID = CategoryID;
    if ([[ANDataSource sharedInstance] isNetConnecting] == 0)   //无网络连接
    {
        NSLog(@"无网络连接,切换到本地检索");
        [self locationSearch:CategoryID];
    }
    else
    {
        _firstTime = YES;
        [self netSearchLine:CategoryID];
    }
}
-(void)cancleLoading
{
    if(_bNetWorking)
    {
        _bNetWorking = NO;
        [MWNetSearchOperator MWCancelNetSearchWith: REQ_NET_SEARCH_ARROUND_LINE];
        [self locationSearch:self.CategoryID];
    }
}
-(void)netSearchLine:(int) CategoryID //网络沿线周边
{
    MWNetLineSearchOption  * arround=[[[MWNetLineSearchOption alloc]init]autorelease];
    
    GCOORD descoord;
    plugin_PoiNode * tmp = [MWJourneyPoint GetJourneyPointWithID:6];
    descoord.x = tmp.lLon;
    descoord.y = tmp.lLat;
    
    arround.cx=[NSString stringWithFormat:@"%f",descoord.x/1000000.0];
    arround.cy=[NSString stringWithFormat:@"%f",descoord.y/1000000.0];
    arround.range=500;
    //arround.category=[MWPoiOperator getNetCategaryStringWithLocalID:CategoryID];
    arround.category = [self netSearchTo:CategoryID];
    GSTATUS res = [MWNetSearchOperator MWNetLineArroundSearchWith:REQ_NET_SEARCH_ARROUND_LINE
                                             option:arround
                                           delegate:self];
    if (_firstTime==YES) {
        [self performSelector:@selector(cancleLoading) withObject:nil afterDelay:5.0f];
    }
    if (res==GD_ERR_OK) {
        _bNetWorking=YES;
    }
    
}
-(NSArray *)getLocalCategory:(int)Category
{
    NSMutableArray * arrayCategory = [NSMutableArray array];
    NSMutableArray *infoArray = [[NSMutableArray alloc] init];
        //获取周边搜索关键字
        MWPoiCategoryList *poiCategoryList=[[[MWPoiCategoryList alloc] init] autorelease];
        BOOL category =  [poiOperator getAroundListWith:0 list:&poiCategoryList];
        if (category) {
          
            for (int i=0;i<poiCategoryList.pCategoryArray.count;i++) {
                
                MWPoiCategory * object = [poiCategoryList.pCategoryArray objectAtIndex:i];
                [infoArray addObject:object];
            }

        }
    switch (Category) {
        case 10000:
        {
            if ([infoArray objectAtIndex:0]) {
                MWPoiCategory * ca = [infoArray objectAtIndex:0];
                arrayCategory =ca.pnCategoryID;
            }
        }
            break;
        case 40000:
        {
            if ([infoArray objectAtIndex:2]) {
                MWPoiCategory * ca = [infoArray objectAtIndex:2];
                arrayCategory =ca.pnCategoryID;
            }
        }break;
        case 50000:
        {
            if ([infoArray objectAtIndex:3]) {
                MWPoiCategory * ca = [infoArray objectAtIndex:3];
                arrayCategory =ca.pnCategoryID;
            }
        }break;
        case 70000:
        {
            if ([infoArray objectAtIndex:6]) {
                MWPoiCategory * ca = [infoArray objectAtIndex:6];
                arrayCategory =ca.pnCategoryID;
            }
        }break;
        case 150400:
        {
//            MWPoiCategory * ca = [infoArray objectAtIndex:0];
//            arrayCategory =ca.pnCategoryID;
        }break;
            
        default:
            break;
    }
    [infoArray release];
    return arrayCategory;
}
-(NSString *)netSearchTo:(NSInteger )CategoryID
{
    NSString * stringName = nil;
    switch (CategoryID) {
        case 10000:
        {
            stringName = @"加油站";
        }
            break;
        case 40000:
        {
            stringName = @"餐饮美食";
        }break;
        
        case 50000:
        {
            stringName = @"酒店住宿";
        }break;
        case 70000:
        {
            stringName = @"风景名胜";
        }break;
        case 150400:
        {
            
            stringName = @"公共厕所";
        }break;
        default:
            break;
    }
    return stringName;
}
-(void)locationSearch:(int )CategoryID//本地沿线周边
{
    MWSearchOption * sOption=[[MWSearchOption alloc] init];
    sOption.sortType=1;
    GCOORD descoord;
    plugin_PoiNode *tmp = [MWJourneyPoint GetJourneyPointWithID:6];
    descoord.x = tmp.lLon;
    descoord.y = tmp.lLat;
    [ANParamValue sharedInstance].searchMapInfo = descoord;
    sOption.latitude= [ANParamValue sharedInstance].searchMapInfo.y;
    sOption.longitude= [ANParamValue sharedInstance].searchMapInfo.x;
    sOption.aroundRange=500;
    NSArray * array = [self getLocalCategory:CategoryID];
//    GPOICATCODE stcatcode = {0};
//    stcatcode.vnCatCodeCnt[0] = 1;
//    stcatcode.vnCatCode[0] = CategoryID;
//    sOption.stCatCode = stcatcode;
    
    GPOICATCODE stcatcode = {0};
    stcatcode.vnCatCodeCnt[0] = array.count;
    for (int i = 0; i < [array count]; i++)
    {
        stcatcode.vnCatCode[i] = [[array objectAtIndex:i] intValue];
    }
    sOption.stCatCode = stcatcode;
    sOption.operatorType=GSEARCH_TYPE_ROUTEPOI;
    sOption.routePoiTpe=GROUTEPOI_TYPE_ALL;
    
    BOOL res=[poiOperator poiLocalSearchWithOption:sOption];
    if (res) {
        _bNetWorking=NO;
    }
    [sOption release];
}
#pragma mark --NetReqToViewCtrDelegate
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    [poiLineArray removeAllObjects];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancleLoading) object:nil];
    _firstTime=NO;
    _bNetWorking=NO;
    switch (requestType) {
        case REQ_NET_SEARCH_ARROUND_LINE:
        {
            if ([[result objectForKey:@"count"] intValue]>0)
            {
                NSArray * poiArrayTmp = nil;
                NSDictionary  * dicList=[result objectForKey:@"list"];
                id object=[dicList objectForKey:@"poi"];
                poiArrayTmp=object;
                if ([object isKindOfClass:[NSDictionary class]])
                {
                    poiArrayTmp=[NSArray arrayWithObjects:object, nil];
                }
                
                for (id arr in poiArrayTmp) {
                    MWPoi * poi=[[MWPoi alloc]init];
                    poi.szName=[arr objectForKey:[POICommon netGetKey:@"name"]];
                    poi.szAddr=[arr objectForKey:[POICommon netGetKey:@"address"]];
                    if ([poi.szAddr length] == 0)
                    {
                        MWAreaInfo * info = [MWAdminCode GetCurAdareaWith:[[arr objectForKey:@"adcode"] intValue]];
                        poi.szAddr = [NSString stringWithFormat:@"%@%@",info.szProvName,info.szCityName];
                    }
                    poi.szTel = [POICommon netGetTel:[arr objectForKey:@"tel"]];
                    poi.szTown= [arr objectForKey:[POICommon netGetKey:@"dname"]];
                    poi.latitude=[[arr objectForKey:@"y"] floatValue] * 1000000;
                    poi.longitude=[[arr objectForKey:@"x"] floatValue] *1000000;
                    poi.lAdminCode=[[arr objectForKey:@"adcode"] intValue] ;
                    int dances = [POICommon netCarToPOIDistance:poi];
                    poi.lDistance=dances;
                    [poiLineArray addObject:poi];
                    [poi release];
                    
                }
                if (poiLineArray.count>=1) {
                        [self notifictionSuccessArray:poiLineArray];
                }
                else
                {
                    [self notifictionErrorArray];
                }
              
            }
            else
            {
                [self notifictionErrorArray];
            }
            
        }
            break;
      
        default:
            break;
    }
    
}
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error//上层需根据error的值来判断网络连接超时还是网络连接错误
{
    [poiLineArray removeAllObjects];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancleLoading) object:nil];
    _firstTime=NO;
    _bNetWorking=NO;
    [self notifictionErrorArray];
}

#pragma mark MWPoiOperatorDelegaet
-(void)search:(id)poiOperatorOption Error:(NSError *)error
{
    NSLog(@"%@",error);
     _firstTime=NO;
    [poiLineArray removeAllObjects];
    if ([[ANDataSource sharedInstance] isNetConnecting] == 0)
    {
        [self notifictionErrorArray];
    }else
    {
        [self netSearchLine:self.CategoryID];
    }
}
/*!
 @brief 本地POI查询回调函数
 @param poiSearchOption 发起POI查询的查询选项(具体字段参考MWSearchOption类中的定义)
 @param result 查询结果(具体字段参考MWSearchResult类中的定义)
 */
-(void)poiLocalSearch:(MWSearchOption*)poiSearchOption Result:(MWSearchResult *)result
{
    _firstTime=NO;
    [poiLineArray removeAllObjects];
    if (result.pois.count == 0) {
        if ([[ANDataSource sharedInstance] isNetConnecting] == 0)
        {
            [self notifictionErrorArray];
        }else
        {
            [self netSearchLine:self.CategoryID];
        }
            
    }else
    {
        [poiLineArray addObjectsFromArray:result.pois];
        [self notifictionSuccessArray:poiLineArray];
    }
}

-(void)notifictionSuccessArray:(NSArray * )array
{
    id object=[POIDataCache sharedInstance].selectPOIDelegate;
    if (object && [object respondsToSelector:@selector(selectPoiWithArray:withIndex:)]) {
        
        [object selectPoiWithArray:poiLineArray withIndex:nil];
    }
    [[POIDataCache sharedInstance]clearData];
}
-(void)notifictionErrorArray
{
    id object=[POIDataCache sharedInstance].selectPOIDelegate;
    if (object && [object respondsToSelector:@selector(selectPoiWithArray:withIndex:)]) {
        [object selectPoiWithArray:nil withIndex:nil];
    }
    [[POIDataCache sharedInstance]clearData];
}
-(void)dealloc
{
    [poiLineArray release];
    [poiOperator release];
    [super dealloc];
}
@end
