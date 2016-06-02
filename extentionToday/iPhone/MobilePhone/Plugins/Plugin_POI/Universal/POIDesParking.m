//
//  POIDesParking.m
//  AutoNavi
//
//  Created by weisheng on 14-4-4.
//
//

#import "POIDesParking.h"
#import "MWNetSearchOption.h"
#import "MWNetSearchOperator.h"
#import "MWMapOperator.h"
#import "JSONKit.h"
#import "POIDataCache.h"
#import "MWPoiOperator.h"
#import "MWPoiOperator.h"
#import "POIDesParkObj.h"

@interface POIDesParking ()<NetReqToViewCtrDelegate,MWPoiOperatorDelegate>
{
    BOOL           _bNetWorking;//当前是不是正在进行网络检索
    BOOL            _firstTime;
    NSMutableArray * _desParkArray;
    MWPoiOperator *  _poiOperator;
}
@property(retain,nonatomic)NSString * keyWorld;
@end
@implementation POIDesParking
static POIDesParking *instance=nil;

+(POIDesParking*)sharedInstance
{
    @synchronized(self)
    {
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}
-(id)init
{
    self=[super init];
    if (self) {
        _desParkArray = [[NSMutableArray alloc]init];
        _poiOperator =[[MWPoiOperator alloc] initWithDelegate:self];
    }
    return self;
}
-(void)PDK_DestinationParking:(NSString *)keyWorld
{
    self.keyWorld=keyWorld;
    if ([[ANDataSource sharedInstance] isNetConnecting] == 0)   //无网络连接
    {
        NSLog(@"无网络连接,切换到本地检索");
        [self locationSearch:self.keyWorld];
    }
    else
    {
        _firstTime = YES;
        [self networkSearch:self.keyWorld];
    }
}

-(void)networkSearch:(NSString *)searchName
{
    MWNetParkStopSearchOption * arround=[[[MWNetParkStopSearchOption alloc]init]autorelease];
    GCOORD descoord;

    plugin_PoiNode * tmp = [MWJourneyPoint GetJourneyPointWithID:6];
    descoord.x = tmp.lLon;
    descoord.y = tmp.lLat;
    
    arround.cx=[NSString stringWithFormat:@"%f",descoord.x/1000000.0];
    arround.cy=[NSString stringWithFormat:@"%f",descoord.y/1000000.0];
    NSLog(@"+++++++++++++++++++++++++++++%@ %@",arround.cx,arround.cy);
    arround.range=1000;
    arround.search=searchName;
    arround.language=0;
    arround.size=5;
    if (_firstTime==YES) {
        [self performSelector:@selector(cancleLoading) withObject:nil afterDelay:5.0f];
    }
    [MWNetSearchOperator MWNetParkStopSearchWith:REQ_NET_SEARCH_PARKSTOP option:arround delegate:self];
}
-(void)locationSearch:(NSString *)searchName
{
    MWSearchOption * sOption=[[MWSearchOption alloc] init];
    sOption.sortType=1;
    GCOORD descoord;
    plugin_PoiNode * tmp = [MWJourneyPoint GetJourneyPointWithID:6];
    descoord.x = tmp.lLon;
    descoord.y = tmp.lLat;
    [ANParamValue sharedInstance].searchMapInfo = descoord;
    
    sOption.latitude= [ANParamValue sharedInstance].searchMapInfo.y;
    sOption.longitude= [ANParamValue sharedInstance].searchMapInfo.x;
    sOption.aroundRange=1000;
    sOption.operatorType=GSEARCH_TYPE_AROUND;
    sOption.keyWord=STR(@"Setting_POITypeParking",Localize_Setting);
    BOOL res=[_poiOperator poiLocalSearchWithOption:sOption];
    if (res) {
        _bNetWorking=NO;
    }
    
    [sOption release];
}
#pragma mark NetReqToViewCtrDelegate
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    [_desParkArray removeAllObjects];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancleLoading) object:nil];
    _bNetWorking = NO;
    _firstTime = NO;
    
        NSDictionary  * dicList=[result objectForKey:@"list"];
        if ([[dicList objectForKey:@"_size"] intValue]>0) {
            NSArray *poiArrayTmp = nil;
            id object=[dicList objectForKey:@"poi"];
            poiArrayTmp=object;
            if ([object isKindOfClass:[NSDictionary class]])
            {
                poiArrayTmp=[NSArray arrayWithObjects:object, nil];
            }
            for (id arr in poiArrayTmp) {
                POIDesParkObj * poi=[[POIDesParkObj alloc]init];
                poi.bParkDetail = NO;
                if ([[arr objectForKey:@"deepinfo"] length]>0) {
                    poi.bParkDetail = YES;
                    NSString  * string=[arr objectForKey:@"deepinfo"];
                    NSData * jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *parkDeep = [jsonData objectFromJSONData];
                    if ([[parkDeep objectForKey:@"charge"] length]>0) {
                        poi.charge = [parkDeep objectForKey:@"charge"];
                    }else
                    {
                        poi.charge = @"-1";
                    }
                    if ([[parkDeep objectForKey:@"prc_t_d_e"] length]>0 ) {
                        poi.prc_t_d_e = [[parkDeep objectForKey:@"prc_t_d_e"] intValue];
                    }else{
                        poi.prc_c_d_e = -1;
                    }
                    if ([[parkDeep objectForKey:@"prc_c_d_f"] length]>0 ) {
                        poi.prc_c_d_f = [[parkDeep objectForKey:@"prc_c_d_f"]intValue];
                    }else
                    {
                        poi.prc_c_d_f = -1;
                    }
                    if ([[parkDeep objectForKey:@"prc_c_d_e"] length]>0 ) {
                        poi.prc_c_d_e = [[parkDeep objectForKey:@"prc_c_d_e"]intValue];
                    }else
                    {
                        poi.prc_c_d_e = -1;
                    }
                    if ([[parkDeep objectForKey:@"prc_c_n_e"] length]>0 ) {
                        poi.prc_c_n_e=[[parkDeep objectForKey:@"prc_t_n_e"]intValue];
                    }else
                    {
                        poi.prc_c_n_e = -1;
                    }
                    if ([[parkDeep objectForKey:@"prc_t_n_e"] length]>0 ) {
                        poi.prc_t_n_e=[[parkDeep objectForKey:@"prc_t_d_e"]intValue];
                    }else
                    {
                        poi.prc_t_n_e = -1;
                    }
                    if ([[parkDeep objectForKey:@"prc_c_wd"] length]>0 ) {
                        poi.prc_c_wd=[[parkDeep objectForKey:@"prc_c_wd"] intValue];
                    }else
                    {
                        poi.prc_c_wd = -1;
                    }
                    if ([[parkDeep objectForKey:@"num_space"] length]>0 ) {
                        poi.num_space=[[parkDeep objectForKey:@"num_space"]intValue];
                        NSLog(@"++++++++%d",poi.num_space);
                    }else
                    {
                        poi.num_space = -1;
                    }
                    if ([[parkDeep objectForKey:@"time"] length]>0 ) {
                        poi.time=[parkDeep objectForKey:@"time"];
                        NSLog(@"%@",poi.time);
                    }else
                    {
                        poi.time = @"-1";
                    }
                }
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

                //计算两点的距离
                GCOORD coor1;
                GCOORD coor2;
                coor1.x=poi.longitude;
                coor1.y=poi.latitude;
                
                GCOORD descoord;
                plugin_PoiNode * tmp = [MWJourneyPoint GetJourneyPointWithID:6];
                descoord.x = tmp.lLon;
                descoord.y = tmp.lLat;
                coor2.x=descoord.x;
                coor2.y=descoord.y;
                int dances=   [MWEngineTools CalcDistanceFrom:coor2 To:coor1];
                poi.lDistance=dances>0?dances:1;
                NSLog(@"%d",dances);
                [_desParkArray addObject:poi];
                [poi release];
                
            }
            if (_desParkArray.count>=1) {
                NSLog(@"%@",_desParkArray);
                [self sortArray:_desParkArray];
            }
        }
        else
        {
             [self locationSearch:self.keyWorld];
            NSLog(@"搜索为空");
        }

}
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error//上层需根据error的值来判断网络连接超时还是网络连接错误
{
    [_desParkArray removeAllObjects];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancleLoading) object:nil];
    _bNetWorking = NO;
    _firstTime = NO;
    [self locationSearch:self.keyWorld];
}
-(void)sortArray:(NSMutableArray *)array//对数组进行排序
{
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lDistance" ascending:YES];
    NSArray * tempArray = [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [self searchSuccessArray:tempArray];
}
-(void)cancleLoading
{
    if(_bNetWorking)
    {
        _bNetWorking = NO;
        [MWNetSearchOperator MWCancelNetSearchWith: REQ_NET_SEARCH_PARKSTOP];
        [self locationSearch:self.keyWorld];
    }
}
#pragma mark MWPoiOperatorDelegaet
-(void)search:(id)poiOperatorOption Error:(NSError *)error
{
    [_desParkArray removeAllObjects];
    _firstTime = NO;
    [self searchError];
}

-(void)poiLocalSearch:(MWSearchOption*)poiSearchOption Result:(MWSearchResult *)result
{
    [_desParkArray removeAllObjects];
    _firstTime = NO;
    if (result.pois.count==0) {
        [self searchError];
    }
    else
    {//取本地停车场的前5个
        int Count=0;
        Count = result.pois.count > 5 ? 5 : result.pois.count;
        for (int i=0; i<Count; i++) {
            MWPoi * poi=[result.pois objectAtIndex:i];
            POIDesParkObj * obj=[[[POIDesParkObj alloc]init] autorelease];
            obj.bParkDetail=NO;
            obj.szName=poi.szName;
            obj.szAddr=poi.szAddr;
            obj.szTel=poi.szTel;
            obj.szTown=poi.szTown;
            obj.lAdminCode=poi.lAdminCode;
            obj.latitude=poi.latitude;
            obj.longitude=poi.longitude;
            obj.lCategoryID=poi.lCategoryID;
            NSLog(@"%d",poi.lDistance);
            //计算两点的距离
            GCOORD coor1;
            GCOORD coor2;
            coor1.x=poi.longitude;
            coor1.y=poi.latitude;
            GCOORD descoord;
            plugin_PoiNode * tmp = [MWJourneyPoint GetJourneyPointWithID:6];
            descoord.x = tmp.lLon;
            descoord.y = tmp.lLat;
            coor2.x=descoord.x;
            coor2.y=descoord.y;
            int dances=   [MWEngineTools CalcDistanceFrom:coor2 To:coor1];
            obj.lDistance=dances>0?dances:1;
            
            obj.lHilightFlag=poi.lHilightFlag;
            obj.lMatchCode=poi.lMatchCode;
            obj.stPoiId=poi.stPoiId;
            obj.lPoiIndex=poi.lPoiIndex;
            obj.Reserved=poi.Reserved;
            obj.lNaviLon=poi.lNaviLon;
            obj.lNaviLat=poi.lNaviLat;
            obj.ucFlag=poi.ucFlag;
            obj.usNodeId=poi.usNodeId;
            [_desParkArray addObject:obj];
        }
        [self sortArray:_desParkArray];
    }
}
-(void)searchSuccessArray:(NSArray * )array{
    id object=[POIDataCache sharedInstance].selectPOIDelegate;
    if (object && [object respondsToSelector:@selector(PoiDesParkingStopArray:)]) {
        [object PoiDesParkingStopArray:array];
    }
    [[POIDataCache sharedInstance] clearData];
    
}
-(void)searchError
{
    id object=[POIDataCache sharedInstance].selectPOIDelegate;
    if (object && [object respondsToSelector:@selector(PoiDesParkingStopArray:)]) {
        
        [object PoiDesParkingStopArray:nil];
    }
    [[POIDataCache sharedInstance] clearData];
}
-(void)dealloc
{
    [_desParkArray release];
    [_poiOperator release];
    self.keyWorld=nil;
    [super dealloc];
}
@end
