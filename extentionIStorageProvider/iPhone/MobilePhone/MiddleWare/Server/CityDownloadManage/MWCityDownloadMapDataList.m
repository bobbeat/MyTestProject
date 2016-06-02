//
//  MWCityDownloadMapDataList.m
//  AutoNavi
//
//  Created by yaying.xiao on 14-7-15.
//
//

#import "MWCityDownloadMapDataList.h"
#import "JSON.h"
#import "SectionInfo.h"
#import "Play.h"
#import "Quotation.h"
#import "zlib.h"
#import "plugin-cdm-TaskManager.h"
#import "plugin-cdm-DownloadTask.h"
#import "GDAlertView.h"
#import "CityDownLoadModule.h"
#import "CityDataManagerFirstViewController.h"



@implementation MWCityDownloadMapDataList

@synthesize ReqMapDataListDelegate,isLoading;


+ (MWCityDownloadMapDataList *)citydownloadMapDataList
{
    static MWCityDownloadMapDataList *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MWCityDownloadMapDataList alloc] init];
    });
	return instance;
}



- (id)init
{
	if (self = [super init])
	{
		mapdatalist = [[NSMutableArray alloc] init];
        tempdatalist = [[NSMutableArray alloc] init];
        nocrosslist = [[NSMutableArray alloc] init];
        isLoading = NO;
        isModifying = NO;
		
	}
	
	return self;
}

- (void)dealloc
{

    CRELEASE(mapdatalist);
    CRELEASE(tempdatalist);
    CRELEASE(nocrosslist);
	
    [super dealloc];
}

//json格式解析，存放在mapdatalist，按照SectionInfo的格式存放
- (void)responseHandleWithDic:(NSDictionary *)dic
{
     @synchronized(mapdatalist){
        if (!dic)
        {
            return;
        }
        
        [mapdatalist removeAllObjects];
         long long wholesize = 0;
         long long wholeunzipsize = 0;
        
        //解析公共字段
        NSString *mapv = [dic objectForKey:@"mapv"];
        int status = [[dic objectForKey:@"status" ] intValue];
        NSDictionary *updatedes = [dic objectForKey:@"updatedesc"];
        NSArray *nomatchs = [dic objectForKey:@"nomatchs"];
        NSArray *nocross = [dic objectForKey:@"nocross"];
        NSString *baseurl = [dic objectForKey:@"baseurl"];
        
        
        //解析基础资源
        SectionInfo *sectioninfo = [[SectionInfo alloc]init];
        sectioninfo.mapv = mapv;
        sectioninfo.status = status;
        sectioninfo.updatedes = updatedes;
        sectioninfo.nomatchs = nomatchs;
        sectioninfo.nocross = nocross;
        
        Play *playbaseres = [[Play alloc]init];
        NSDictionary *basedic = [dic objectForKey:@"baseres"];
        playbaseres.zhname = [basedic objectForKey:@"name_zh"];
        playbaseres.twname = [basedic objectForKey:@"name_ft"];
        playbaseres.enname = [basedic objectForKey:@"name_en"];
        playbaseres.status = [[basedic objectForKey:@"status"] intValue];
        playbaseres.updatedes = [basedic objectForKey:@"updatedesc"];
        playbaseres.version = [basedic objectForKey:@"version"];
        playbaseres.updatetype = [[basedic objectForKey:@"updatetype"] intValue];
        playbaseres.all_suburl = [basedic objectForKey:@"all_url"];
        playbaseres.all_size = [[basedic objectForKey:@"all_size"] longLongValue];
        playbaseres.all_unzipsize = [[basedic objectForKey:@"all_unzipsize"] longLongValue];
        playbaseres.all_md5 = [basedic objectForKey:@"all_md5"];
        playbaseres.add_suburl = [basedic objectForKey:@"add_url"];
        playbaseres.add_size = [[basedic objectForKey:@"add_size"] longLongValue];
        playbaseres.add_unzipsize = [[basedic objectForKey:@"add_unzipsize"] longLongValue];
        playbaseres.add_md5 = [basedic objectForKey:@"add_md5"];
        playbaseres.admincode = 0;//基础资源 adcode为0

        
        playbaseres.quotations = nil;
        wholeunzipsize += playbaseres.all_unzipsize;
         wholesize += playbaseres.all_size;
        
        sectioninfo.play = playbaseres;
        [mapdatalist addObject:sectioninfo];
        
        [playbaseres release];
        [sectioninfo release];
        
        
        //解析一级和二级城市列表
        NSArray *provinces = [dic objectForKey:@"provinces"];
        for (NSDictionary *playcitydic in provinces)
        {
            SectionInfo *sectioninfo = [[SectionInfo alloc]init];

            
            Play *playres = [[Play alloc]init];
            
            playres.zhname = [playcitydic objectForKey:@"name_zh"];
            playres.twname = [playcitydic objectForKey:@"name_ft"];
            playres.enname = [playcitydic objectForKey:@"name_en"];
            playres.version = [playcitydic objectForKey:@"version"];
            playres.updatetype = [[playcitydic objectForKey:@"updatetype"] intValue];
            playres.all_suburl = [playcitydic objectForKey:@"all_url"];
            playres.all_size = [[playcitydic objectForKey:@"all_size"] longLongValue];
            playres.all_unzipsize = [[playcitydic objectForKey:@"all_unzipsize"] longLongValue];
            playres.all_md5 = [playcitydic objectForKey:@"all_md5"];
            playres.add_suburl = [playcitydic objectForKey:@"add_url"];
            playres.add_size = [[playcitydic objectForKey:@"add_size"] longLongValue];
            playres.add_unzipsize = [[playcitydic objectForKey:@"add_unzipsize"] longLongValue];
            playres.add_md5 = [playcitydic objectForKey:@"add_md5"];
            playres.admincode = [[playcitydic objectForKey:@"adcode"] intValue];
            playres.size = [[playcitydic objectForKey:@"size"] longLongValue];
            playres.unzipsize = [[playcitydic objectForKey:@"unzip_size"] longLongValue];
            //拼接url
            if(playres.all_suburl)
            {
                playres.all_suburl = [baseurl stringByAppendingString:playres.all_suburl];
            }
            if(playres.add_suburl)
            {
                playres.add_suburl = [baseurl stringByAppendingString:playres.add_suburl];
            }
            wholeunzipsize += playres.all_unzipsize;
            wholesize += playres.all_size;
            
            NSArray *quotationslist = [playcitydic objectForKey:@"citys"];
            NSMutableArray *citys = [[NSMutableArray alloc] init];
            
            //添加全省下载
            if(quotationslist && [quotationslist count]>0)
            {
                Quotation *quotationres = [Quotation quotation];
                quotationres.zhname = playres.zhname ;
                quotationres.twname = playres.twname;
                quotationres.enname = playres.enname;
                
                quotationres.all_size = playres.size;
                quotationres.all_unzipsize = playres.unzipsize;
                
                quotationres.admincode = playres.admincode;
                [citys addObject:quotationres];
                wholeunzipsize += quotationres.all_unzipsize;
                wholesize += quotationres.all_size;
                
            }
            //解析各个城市
            for (NSDictionary *quotationsdic in quotationslist)
            {
                Quotation *quotationres = [Quotation quotation];
                quotationres.zhname = [quotationsdic objectForKey:@"name_zh"];
                quotationres.twname = [quotationsdic objectForKey:@"name_ft"];
                quotationres.enname = [quotationsdic objectForKey:@"name_en"];
                quotationres.version = [quotationsdic objectForKey:@"version"];
                quotationres.updatetype = [[quotationsdic objectForKey:@"updatetype"] intValue];
                quotationres.all_suburl = [quotationsdic objectForKey:@"all_url"];
                quotationres.all_size = [[quotationsdic objectForKey:@"all_size"] longLongValue];
                quotationres.all_unzipsize = [[quotationsdic objectForKey:@"all_unzipsize"] longLongValue];
                quotationres.all_md5 = [quotationsdic objectForKey:@"all_md5"];
                quotationres.add_suburl = [quotationsdic objectForKey:@"add_url"];
                quotationres.add_size = [[quotationsdic objectForKey:@"add_size"] longLongValue];
                quotationres.add_unzipsize = [[quotationsdic objectForKey:@"add_unzipsize"] longLongValue];
                quotationres.add_md5 = [quotationsdic objectForKey:@"add_md5"];
                quotationres.admincode = [[quotationsdic objectForKey:@"adcode"]intValue];
                //拼接url
                if(quotationres.all_suburl)
                {
                    quotationres.all_suburl = [baseurl stringByAppendingString:quotationres.all_suburl];
                }
                if(quotationres.add_suburl)
                {
                    quotationres.add_suburl = [baseurl stringByAppendingString:quotationres.add_suburl];
                }
                
                [citys addObject:quotationres];
            }
            if([citys count]==0)
            {
                playres.quotations = nil;
            }
            else{
                playres.quotations = citys;
            }
            
            sectioninfo.play = playres;
            [mapdatalist addObject:sectioninfo];
            
            [citys release];
            [playres release];
            [sectioninfo release];
       
        }
        //添加全国下载
         SectionInfo *wholemap = [[SectionInfo alloc]init];
         Play *wholeplayres = [[Play alloc]init];
         
         wholeplayres.zhname = @"全国";
         wholeplayres.twname =  @"全國";
         wholeplayres.enname =  @"China";
         wholeplayres.admincode = 86;

         wholeplayres.updatetype = 0;
         wholeplayres.size =wholesize;
         wholeplayres.unzipsize = wholeunzipsize;
         wholemap.play = wholeplayres;
         [mapdatalist addObject:wholemap];
         [wholeplayres release];
         [wholemap release];

        isModifying = YES;
        [tempdatalist removeAllObjects];
        for(int i = 0;i<[mapdatalist count];i++)
        {
            [tempdatalist addObject:[mapdatalist objectAtIndex:i]];
        }
        isModifying = NO;

    }
    
    //taskmanager检查更新及同步
    if([mapdatalist count]>0)
    {
        BOOL isupdate = [[TaskManager taskManager] getUpdateStatus];//检查是否有更新
        if(isupdate)
        {
            [[TaskManager taskManager] checkTaskInfo];//同步每个task的信息
        }
    }
    
}

//获取不匹配的版本信息
-(NSArray*)getNoMatchVersions
{
    @synchronized(mapdatalist){
    NSMutableArray *nomatchlist = [[[NSMutableArray alloc]init]autorelease];
    for(SectionInfo *sectioninfo in mapdatalist)
    {
        if(sectioninfo.play.admincode ==0)
        {
            NSArray *versionlist =sectioninfo.nomatchs;
            for(NSString *version in versionlist)
            {
                [nomatchlist addObject:version];
            }
            break;
        }
        
    }
    
    if([nomatchlist count] == 0)
    {
        return nil;
    }
    return nomatchlist;
    }
    
}

//获取不交叉的版本信息
-(NSArray*)getNoCrossVersions
{
    @synchronized(mapdatalist){
    [nocrosslist removeAllObjects];
    for(SectionInfo *sectioninfo in mapdatalist)
    {
        if(sectioninfo.play.admincode ==0)
        {
            NSArray *versionlist =sectioninfo.nocross;
            for(NSString *version in versionlist)
            {
                [nocrosslist addObject:version];
            }
            break;
        }
        
    }
    return nocrosslist;
    }
}

//获取地图下载列表信息
-(NSArray*)getMapDataList
{
    if((isModifying==NO) &&tempdatalist && [tempdatalist count]>0)
    {
        return tempdatalist;
    }
    else { return nil;}
    
    
}

//比较版本信息：输入adcode和已下载地图的version，同地图下载列表mapdatalist中最新的版本信息比较，一致返回NO（表示无更新），不一致返回YES（表示有更新）
-(BOOL) comperMapVersion:(int)adcode version:(NSString*)version
{
    if(version == nil || [version isKindOfClass:[NSString class]]==NO)
    {
        return NO;
    }
    @synchronized(mapdatalist){
        if([mapdatalist count] == 0 )
        {
            return NO;
        }
        for(SectionInfo *sectioninfo in mapdatalist)
        {
            if(sectioninfo.play.admincode == adcode)
            {
                return ([version compare:sectioninfo.play.version] != 0);

            }
            else if(sectioninfo.play.quotations && [sectioninfo.play.quotations count]>0)
            {
                for (Quotation *quotation in sectioninfo.play.quotations)
                {
                    if(quotation.admincode == adcode)
                    {
                        return ([version compare:quotation.version] != 0);

                    }
                }
            }
            
        }
        return NO;
    }
    
}

//gzip数据包解压
- (NSData *)gzipUnpack:(NSData *) data
{
    
    if ([data length] == 0) return nil;
    unsigned full_length = [data length];
    unsigned half_length = [data length] / 2;
  
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length +     half_length];
    BOOL done = NO;
    int status;
    z_stream strm;
    
    strm.next_in = (Bytef *)[ data bytes];
    strm.avail_in = [data length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done){
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy: half_length];
        
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = [decompressed length] - strm.total_out;
        
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) done = YES;
        else if (status != Z_OK) break;
        
    }
    
    if (inflateEnd (&strm) != Z_OK) return nil;
    
    if (done){
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    
    return nil;
    
}


-(SectionInfo *) GetBasicResourceSectionInfo
{
    [self getMapDataList];
    if(!tempdatalist || [tempdatalist count] == 0)
    {
        return nil;
    }
    
    SectionInfo *sectioninfo;
    int count = [tempdatalist count];
    int i=0;
    for(i=0;i<count;i++)
    {
        sectioninfo =[tempdatalist objectAtIndex:i];
        if(sectioninfo.play.admincode == 0)//找出基础资源
        {
            break;
        }
    }
    if(i==count) return nil;
    return sectioninfo;

}
-(int)checkBasicResourceUpdate:(SectionInfo*)sectioninfo
{
    if(sectioninfo.play.status ==1)
    {
        if(sectioninfo.play.updatetype == 1)
        {
            //强制增量
            return FOUNDATION_FORCE_UPDATE_PART;
        }
        else
        { //强制全量
            return FOUNDATION_FORCE_UPDATE_ALL;
        }
    }
    else
    {
        //判断基础资源是否有更新
        Task *task = [[TaskManager taskManager] getTaskWithTaskID:0];
        if(task.updated == NO)
        {
            return NO_UPDATE;
        }
        if(sectioninfo.play.updatetype == 1)
        {
            return FOUNDATION_UPDATE_PART;//非强制增量
        }
        else
        {
            return FOUNDATION_UPDATE_ALL;//非强制全量
        }
    }
}


//根据地图下载列表，判断地图数据更新类型；
//返回类型：强制更新基础资源和不匹配；强制更新基础资源；强制更新不匹配；只有基础资源有更新；基础资源和城市有更新；无更新
-(int)checkMapadataUpdate
{
    SectionInfo *basicSectionInfo = [self GetBasicResourceSectionInfo];
    if(!basicSectionInfo)
    {
        return NO_UPDATE;
    }
    
    BOOL isupdate = [[TaskManager taskManager] checkUpdate];//检查地图数据是否有更新
    int basicupdate = [self checkBasicResourceUpdate:basicSectionInfo];
    if(basicupdate == NO_UPDATE && isupdate)//基础资源无更新，除基础资源以外还有更新
    {
        return  MAPDATA_UPDATE;
    }
    return basicupdate;
    
 }

//根据下发的地图更新类型进行相应操作
-(void)processUpdate:(int)updateType
{
    SectionInfo *basicSectionInfo = [self GetBasicResourceSectionInfo];
    if(!basicSectionInfo) return;
    
    //判断是否有不匹配
    BOOL hasnomatch = NO;
    if(basicSectionInfo.status ==1)
    {
        hasnomatch = YES;
    }
    
    switch (updateType) {
         case FOUNDATION_FORCE_UPDATE_ALL:
        {
            NSString *strTitle = [basicSectionInfo.play.updatedes objectForKey:@"zw"];
            if(fontType ==1)
            {
                strTitle = [basicSectionInfo.play.updatedes objectForKey:@"ft"];
            }
            else if(fontType ==2)
            {
                strTitle = [basicSectionInfo.play.updatedes objectForKey:@"yw"];
            }
            
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:strTitle];
            [alertView addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                [[UIApplication sharedApplication] exitApplication];//退出导航
            }];
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                //关闭模拟导航
                if([[ANParamValue sharedInstance]isNavi])
                {
                    [MWRouteDemo StopDemo];
                }
                
                for(Task *task in [TaskManager taskManager].taskList)
                {
                    if(task.taskId ==0)
                    {
                        [task erase];//强制更新，需要先删除基础资源
                        break;
                    }
                }
                [[TaskManager taskManager] updatecity:0];//更新基础资源
                if(hasnomatch){
                    [[TaskManager taskManager] processNoMatchTask];//更新不匹配, 若没有不匹配不会做任何处理
                }
                [[TaskManager taskManager] updateAll];//全部更新
                //notice：全部更新之前需要先做不匹配更新，否则会导致不匹配没有先删除数据
                [[TaskManager taskManager] store];
                if (![self beInDataDownloadView]) {//判断当前页面不在地图下载页面，则跳转到地图下载页面
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDataDownload object:[NSNumber numberWithInt:2]];//到下载页面
                }
            
               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                   [[NSNotificationCenter defaultCenter] postNotificationName:kAddEarthquakesNotif object:[NSNumber numberWithInt:1]];//通知开始下载//延迟0.3s
                });
                [GDAlertView dismissAllAlertView];//强制更新的时候，销毁所有弹窗

                
            }];
            [alertView show];
            [alertView release];
        }
            break;
        case FOUNDATION_FORCE_UPDATE_PART:
        {
            NSString *strTitle = [basicSectionInfo.play.updatedes objectForKey:@"zw"];
            if(fontType ==1)
            {
                strTitle = [basicSectionInfo.play.updatedes objectForKey:@"ft"];
            }
            else if(fontType ==2)
            {
                strTitle = [basicSectionInfo.play.updatedes objectForKey:@"yw"];
            }
            
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:strTitle];
            [alertView addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                [[UIApplication sharedApplication] exitApplication];//退出导航
            }];
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                //关闭模拟导航
                if([[ANParamValue sharedInstance]isNavi])
                {
                    [MWRouteDemo StopDemo];
                }
                
                [[TaskManager taskManager] updatecity:0];//更新基础资源
                if(hasnomatch){
                    [[TaskManager taskManager] processNoMatchTask];//更新不匹配, 若没有不匹配不会做任何处理
                }
                [[TaskManager taskManager] updateAll];//全部更新
                [[TaskManager taskManager] store];
                if (![self beInDataDownloadView]) {//判断当前页面不在地图下载页面，则跳转到地图下载页面
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDataDownload object:[NSNumber numberWithInt:2]];//到下载页面
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAddEarthquakesNotif object:[NSNumber numberWithInt:1]];//通知开始下载
                });
                [GDAlertView dismissAllAlertView];//销毁所有弹窗
                
            }];
            [alertView show];
            [alertView release];
        }
            break;
        case FOUNDATION_UPDATE_ALL:
        {
            NSString *strTitle = STR(@"CityDownloadManage_updateFoundation", Localize_CityDownloadManage);
            if(hasnomatch)//有不匹配
            {
                strTitle = [basicSectionInfo.updatedes objectForKey:@"zw"];
                if(fontType ==1)
                {
                    strTitle = [basicSectionInfo.updatedes objectForKey:@"ft"];
                }
                else if(fontType ==2)
                {
                    strTitle = [basicSectionInfo.updatedes objectForKey:@"yw"];
                }
                
            }
            
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:strTitle];
            [alertView addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                if(hasnomatch){
                [[UIApplication sharedApplication] exitApplication];//退出导航
                }
                else
                {
                    //do nothing
                }
            }];
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                //关闭模拟导航
                if([[ANParamValue sharedInstance]isNavi])
                {
                    [MWRouteDemo StopDemo];
                }

                [[TaskManager taskManager] updatecity:0];//更新基础资源
                if(hasnomatch){
                    [[TaskManager taskManager] processNoMatchTask];//更新不匹配, 若没有不匹配不会做任何处理
                }
                [[TaskManager taskManager] updateAll];//全部更新
                [[TaskManager taskManager] store];
                if (![self beInDataDownloadView]) {//判断当前页面不在地图下载页面，则跳转到地图下载页面
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDataDownload object:[NSNumber numberWithInt:2]];//到下载页面
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAddEarthquakesNotif object:[NSNumber numberWithInt:1]];//通知开始下载
                });
            }];
            [alertView show];
            [alertView release];

            
        }
            break;
        case FOUNDATION_UPDATE_PART:
        {
            NSString *strTitle = STR(@"CityDownloadManage_updateFoundation", Localize_CityDownloadManage);
            if(hasnomatch)//有不匹配
            {
                strTitle = [basicSectionInfo.updatedes objectForKey:@"zw"];
                if(fontType ==1)
                {
                    strTitle = [basicSectionInfo.updatedes objectForKey:@"ft"];
                }
                else if(fontType ==2)
                {
                    strTitle = [basicSectionInfo.updatedes objectForKey:@"yw"];
                }

            }
            
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:strTitle];
            [alertView addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                if(hasnomatch){
                    [[UIApplication sharedApplication] exitApplication];//退出导航
                }
                else{}//不操作
            }];
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                //关闭模拟导航
                if([[ANParamValue sharedInstance]isNavi])
                {
                    [MWRouteDemo StopDemo];
                }
                
                [[TaskManager taskManager] updatecity:0];//更新基础资源
                if(hasnomatch){
                    [[TaskManager taskManager] processNoMatchTask];//更新不匹配, 若没有不匹配不会做任何处理
                }
                [[TaskManager taskManager] updateAll];//全部更新
                [[TaskManager taskManager] store];
                if (![self beInDataDownloadView]) {//判断当前页面不在地图下载页面，则跳转到地图下载页面
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDataDownload object:[NSNumber numberWithInt:2]];//到下载页面
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAddEarthquakesNotif object:[NSNumber numberWithInt:1]];//通知开始下载
                });
            }];
            [alertView show];
            [alertView release];

        }
            break;
        case MAPDATA_UPDATE://有不匹配或者不交叉，基础资源无更新
        {
            NSString *strTitle = STR(@"CityDownloadManage_updateMapdata", Localize_CityDownloadManage);
            if(hasnomatch)//有不匹配
            {
                strTitle = [basicSectionInfo.updatedes objectForKey:@"zw"];
                if(fontType ==1)
                {
                    strTitle = [basicSectionInfo.updatedes objectForKey:@"ft"];
                }
                else if(fontType ==2)
                {
                    strTitle = [basicSectionInfo.updatedes objectForKey:@"yw"];
                }
                
            }
            
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:strTitle];
            [alertView addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                if(hasnomatch){
                    [[UIApplication sharedApplication] exitApplication];//退出导航
                }
                else{}//不操作
            }];
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                //关闭模拟导航
                if([[ANParamValue sharedInstance]isNavi])
                {
                    [MWRouteDemo StopDemo];
                }
                
                BOOL  hasnocross = NO;
                NSArray *nomatchTasklist = [[TaskManager taskManager] getNoCrossTask];
                if(nomatchTasklist && [nomatchTasklist count]>0)
                {
                    hasnocross = YES;
                }
                
                if(hasnomatch){
                    [[TaskManager taskManager] processNoMatchTask];//更新不匹配, 若没有不匹配不会做任何处理
                }
                [[TaskManager taskManager] updateAll];//全部更新
                [[TaskManager taskManager] store];
                if (![self beInDataDownloadView]) {//判断当前页面不在地图下载页面，则跳转到地图下载页面
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDataDownload object:[NSNumber numberWithInt:2]];//到下载页面
                }

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAddEarthquakesNotif object:[NSNumber numberWithInt:1]];//通知开始下载
                });
                if(hasnomatch || hasnocross)
                {
                     [GDAlertView dismissAllAlertView];//销毁所有弹窗
                }
                
                
            }];
            [alertView show];
            [alertView release];

        }
            break;
        case NO_UPDATE:
        {
            
        }
            break;
            
        default:
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadUpdate] userInfo:nil];
}

//获取已下载的各个城市的版本信息
//返回排重后的版本列表
-(NSArray *) getLocalMapVersions
{
    NSMutableArray *localMapVerList  = [[[NSMutableArray alloc]init]autorelease];
    NSMutableSet *versionSet = [[NSMutableSet alloc]init];//采用集合set进行排重
    for(DownloadTask * task in [TaskManager taskManager].taskList)
    {
        if(task.status == TASK_STATUS_FINISH && task.taskId!=0){
            [versionSet addObject:task.version];
        }
    }
    
    for(NSString *version in versionSet)
    {
        if(version && [version isKindOfClass:[NSString class]] && version.length > 0)
        {
            [localMapVerList addObject:version];
        }
    }
    CRELEASE(versionSet);
    return localMapVerList;

}

//判断当前页面是否是地图下载页面
- (BOOL)beInDataDownloadView
{
    BOOL bDownloadView = NO;
    
    NSArray  *windows = [UIApplication sharedApplication].windows;
    UIWindow *window = [windows firstObject];
    UIViewController *controller = ((UINavigationController *)window.rootViewController).topViewController;
    
    if (controller) {
        
        NSString *stringClass = NSStringFromClass(controller.class);
        if (stringClass && [stringClass isEqualToString:@"DMDataDownloadManagerViewController"]) {
            bDownloadView = YES;
        }
    }
    
    return bDownloadView;
}

- (BOOL) GetBasicResourceStatus
{
    SectionInfo *sectioninfo = [self GetBasicResourceSectionInfo];
    if(!sectioninfo)
    {
        return NO;
    }
    if(sectioninfo.play.status == 1)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark NSURL  Parse

//网络请求数据下载列表
- (void)getMapDataListWithUrl:(NSString *)dataUrl
{
    @try {
    isLoading = YES;
    //本地城市版本列表，用数组表示
    NSArray *localMapVerList = [self getLocalMapVersions];
    
    NSMutableDictionary *urlParams = [[NSMutableDictionary alloc] init];
    [urlParams setValue:VendorID forKey:@"imei"];
    [urlParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [urlParams setValue:MapVersionNoV forKey:@"mapversion"];
    [urlParams setValue:deviceModel forKey:@"model"];
    [urlParams setValue:DeviceResolutionString forKey:@"resolution"];
//    [urlParams setValue:[NSString stringWithFormat:@"%d",[CurrentSystemVersion intValue]]  forKey:@"os"];
    [urlParams setValue:CurrentSystemVersion  forKey:@"os"];
    [urlParams setValue:UserID_Account forKey:@"userid"];
    [urlParams setValue:KNetChannelID forKey:@"syscode"];
    [urlParams setValue:PID forKey:@"pid"];
    
    NSMutableDictionary *svccountDic = [[NSMutableDictionary alloc] init];
    
    [svccountDic setValue:PID forKey:@"pid"];
    [svccountDic setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkv"];
    [svccountDic setValue:KNetChannelID forKey:@"syscode"];
    NSString *resv = @"";
    Task *basictask = [[TaskManager taskManager]getTaskWithTaskID:0];
    if(basictask)
    {
        resv = ((DownloadTask*)basictask).version;

    }

    [svccountDic setValue:resv forKey:@"resv"];
    [svccountDic setValue:localMapVerList forKey:@"mapvlist"];
    [svccountDic setValue:[NSString stringWithFormat:@"%@_%d",DeviceResolutionString,[CurrentSystemVersion intValue]]  forKey:@"resolution"];
    
    [svccountDic setValue:@"0" forKey:@"needtaiwan"];
    [svccountDic setValue:GDEngineNOVVersion forKey:@"enginev"];
    
    NSString *signString = [[NSString stringWithFormat:@"%@%@%@@%@",KNetChannelID,[NSString stringWithFormat:@"%d",SOFTVERSIONCODE],resv,kNetSignKey] stringFromMD5];
    [svccountDic setValue:signString forKey:@"sign"];
    
    
    NSMutableDictionary *bodydataDic = [[NSMutableDictionary alloc] init];
    [bodydataDic setValue:@"0001" forKey:@"activitycode"];
    [bodydataDic setValue:NetProcessTime forKey:@"processtime"];
    [bodydataDic setValue:@"1" forKey:@"protversion"];
    [bodydataDic setValue:[NSString stringWithFormat:@"%d",NetFontType] forKey:@"language"];
    [bodydataDic setValue:svccountDic forKey:@"svccont"];
    
    //dict--> json
    NSString *bodydata=[bodydataDic JSONRepresentation];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.requestType = REQ_GET_MapDataList;
    condition.httpHeaderFieldParams = urlParams;
    condition.httpMethod = @"POST";
    condition.bodyData = [bodydata dataUsingEncoding:NSUTF8StringEncoding];
    condition.urlParams = nil;
    condition.baceURL = dataUrl;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [urlParams release];
    [svccountDic release];
    [bodydataDic release];
    NSLog(@"地图数据下载列表请求参数：%@",bodydata);
    }
    @catch (NSException *exception) {
        NSLog(@"mapdatalist download error");
    }
    
}


#pragma mark - 请求回调
/*!
  @brief 请求应答成功回调
  */
- (void)request:(NetRequestExt *)request didFinishLoadingWithData:(NSData *)data1
{
    
    NSData *data = [self gzipUnpack:data1];
    if (data && [data length])
    {
        NSString *tmp = [[[NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        
        NSLog(@"地图数据下载列表结果：%@",tmp);
        if (request.requestCondition.requestType == REQ_GET_MapDataList)
        {
            isLoading = NO;
            NSDictionary *requestDic = [NSJSONSerialization
                                        
                                        JSONObjectWithData:data
                                        
                                        options:NSJSONReadingMutableLeaves
                                        
                                        error:nil];
            if (requestDic)
            {
                NSDictionary *responseDic = [requestDic objectForKey:@"response"];
                
                if (responseDic && [[responseDic objectForKey:@"rspcode"] isEqualToString:@"0000"])
                {
                    
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(queue, ^{
                        
                        [self responseHandleWithDic:[requestDic objectForKey:@"svccont"]];//解析，同步taskmanager
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            @try{
                            int updateType = [self checkMapadataUpdate];//判断更新类型
                            [self processUpdate:updateType];//处理更新//弹窗
                            }
                            @catch (NSException *exception) {
                                NSLog(@"mapdata update error");
                            }

                            if (ReqMapDataListDelegate && [ReqMapDataListDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)])
                            {
                                [ReqMapDataListDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFinishLoadingWithResult:nil];
                            }
                            

                        });
                    });
                    
                    
                }
                else//response 返回错误码
                {
                    if (ReqMapDataListDelegate && [ReqMapDataListDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
                    {
                        [ReqMapDataListDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
                    }
                }
            }
            else//requestDic为空
            {
                if (ReqMapDataListDelegate &&[ReqMapDataListDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
                {
                    [ReqMapDataListDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
                }
            }
            
        }//endof request type
    }// endof data && data length
    else
    {
        if (ReqMapDataListDelegate &&[ReqMapDataListDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
        {
             [ReqMapDataListDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
        }
    }
}
/*!
  @brief 请求失败回调
  */
- (void)request:(NetRequestExt *)request didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError..........");
    
    if (request.requestCondition.requestType == REQ_GET_MapDataList) {
        isLoading = NO;
        
        if (ReqMapDataListDelegate &&[ReqMapDataListDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
        {
            [ReqMapDataListDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:error];
        }
    }
    else{
        if (ReqMapDataListDelegate &&[ReqMapDataListDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
        {
            [ReqMapDataListDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:error];
        }
    }
	
    
}


@end
