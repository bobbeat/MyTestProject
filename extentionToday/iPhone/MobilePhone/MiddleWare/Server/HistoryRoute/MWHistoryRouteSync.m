//
//  MWHistoryRouteSync.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-6.
//
//

#import "MWHistoryRouteSync.h"
#import "DDXML.h"
#import "XMLDictionary.h"
#import "JSON.h"

@implementation MWHistoryRouteSync

- (void)historyRouteSync
{
    NSString *postSting = [self getXMLString];
    
    NSString *signString = [[NSString stringWithFormat:@"%@%@@%@",KNetChannelID,UserID_Account,kNetSignKey] stringFromMD5];
    NSMutableDictionary *urlParams = [[NSMutableDictionary alloc] init];
    [urlParams setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kNetRequestStringBoundary] forKey:@"Content-Type"];
    [urlParams setValue:VendorID forKey:@"imei"];
    [urlParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [urlParams setValue:MapVersionNoV forKey:@"mapversion"];
    [urlParams setValue:deviceModel forKey:@"model"];
    [urlParams setValue:CurrentSystemVersion forKey:@"os"];
    [urlParams setValue:UserID_Account forKey:@"userid"];
    [urlParams setValue:KNetChannelID forKey:@"syscode"];
    [urlParams setValue:PID forKey:@"pid"];
    [urlParams setValue:signString forKey:@"sign"];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    
    condition.requestType = RT_HistoryRouteSync;
    condition.httpMethod = @"POST";
    condition.urlParams = nil;
    
    condition.bodyData = [postSting dataUsingEncoding:NSUTF8StringEncoding];
    condition.httpHeaderFieldParams = urlParams;
    condition.baceURL = KHistoryRouteSyncURL;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [urlParams release];
}

- (NSString *)getXMLString
{
    
    [self modifyAccount];
    
    NSString *_xmlString = nil;
    NSArray *historyRouteArray = [[MWHistoryRoute sharedInstance] MW_GetGuideRouteList];
    
    if (!historyRouteArray) {
        return nil;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddhhmmss"];
    NSString *dateString = [formatter stringFromDate: [NSDate date]];
    [formatter release];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    
    DDXMLElement*  opg = [DDXMLElement elementWithName: @"opg"];
    
    DDXMLElement*  activitycode = [DDXMLElement elementWithName: @"activitycode"];
    [activitycode setStringValue:@"0001"];
    [opg addChild:activitycode];
    
    DDXMLElement*  processtime =[DDXMLElement elementWithName: @"processtime"];
    [processtime setStringValue:dateString];
    [opg addChild:processtime];
    
    DDXMLElement*  actioncode =[DDXMLElement elementWithName: @"actioncode"];
    [actioncode setStringValue:@"0"];
    [opg addChild:actioncode];
    
    DDXMLElement*  version =[DDXMLElement elementWithName: @"version"];
    [version setStringValue:@"0"];
    [opg addChild:version];
    
    DDXMLElement*  svccont = [DDXMLElement elementWithName: @"svccont"];

    
    NSString *listString = [NSString stringWithFormat:@"%d",historyRouteArray.count];
    
    DDXMLNode *attribute = [DDXMLDocument attributeWithName:@"size" stringValue:listString];
    DDXMLElement*  list = [DDXMLElement elementWithName:@"list"];
    [list setAttributes:[NSArray arrayWithObjects:attribute, nil]];
    
    for (MWPathPOI *mData in historyRouteArray) {
        if([mData.userID isEqual:UserID_Account])
        {
            DDXMLElement*  road = [DDXMLElement elementWithName: @"road"];
            
            
            DDXMLElement*  userid = [DDXMLElement elementWithName: @"id"];
            [userid setStringValue:mData.userID];
            [road addChild:userid];
            
            DDXMLElement*  oprtimeElement = [DDXMLElement elementWithName: @"oprtime"];
            [oprtimeElement setStringValue:mData.operateTime];
            [road addChild:oprtimeElement];
            
            DDXMLElement*  oprtypeElement = [DDXMLElement elementWithName: @"oprtype"];
            [oprtypeElement setStringValue:[NSString stringWithFormat:@"%d",mData.operate]];
            [road addChild:oprtypeElement];
            
            DDXMLElement*  routetypeElement = [DDXMLElement elementWithName: @"routetype"];
            [routetypeElement setStringValue:[NSString stringWithFormat:@"%d",mData.rule]];
            [road addChild:routetypeElement];
            
            DDXMLElement*  nameElement = [DDXMLElement elementWithName: @"name"];
            [nameElement setStringValue:[NSString stringWithFormat:@"<![CDATA[%@]]>",mData.name]];
            [road addChild:nameElement];
            
            NSMutableDictionary *contentDic = [[NSMutableDictionary alloc] init];
            
            NSMutableArray *contentArray = [[NSMutableArray alloc] init];
            
            for (MWPoi *poi in mData.poiArray) {
                
                NSMutableDictionary *poiDic = [[NSMutableDictionary alloc] init];
                
                [poiDic setValue:poi.szName forKey:@"name"];
                [poiDic setValue:[NSString stringWithFormat:@"%ld",poi.longitude] forKey:@"x"];
                [poiDic setValue:[NSString stringWithFormat:@"%ld",poi.latitude] forKey:@"y"];
                [poiDic setValue:[NSString stringWithFormat:@"%d",poi.lNaviLon] forKey:@"offset_x"];
                [poiDic setValue:[NSString stringWithFormat:@"%d",poi.lNaviLat] forKey:@"offset_y"];
                
                [contentArray addObject:poiDic];
                
                [poiDic release];
            }
            
            [contentDic setValue:contentArray forKey:@"poilist"];
            [contentArray release];
            
            NSString *jsonString = [contentDic JSONRepresentation];
            
            DDXMLElement*  contentElement = [DDXMLElement elementWithName: @"content"];
            [contentElement setStringValue:[NSString stringWithFormat:@"<![CDATA[%@]]>",jsonString]];
            [road addChild:contentElement];
            
            [list addChild:road];
        }
    }
    
    [svccont addChild:list];
    [opg addChild:svccont];
    
    
    _xmlString = [[NSString alloc]initWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\" ?>%@",[opg XMLString]];
    [pool drain];
    
    NSString *temp = [[_xmlString stringByReplacingOccurrencesOfString:@"]]&gt;" withString:@"]]>"]
     stringByReplacingOccurrencesOfString:@"&lt;![CDATA" withString:@"<![CDATA"];
    
    [_xmlString release];
    NSLog(@"历史路线xml:%@",temp);
    
    return temp;
}

//如果历史路线保存账号字段为空，则把当前账号赋给它
- (void)modifyAccount
{
    NSMutableArray *historyRouteArray = [[MWHistoryRoute sharedInstance] MW_GetGuideRouteList];
    
    for (MWPathPOI* tmilData in historyRouteArray){
        if ([tmilData.userID isEqualToString:@""]) {
            tmilData.userID = UserID_Account;
        }
    }
    
}

#pragma mark - 请求回调
/*!
  @brief 请求应答成功回调
  */
- (void)request:(NetRequestExt *)request didFinishLoadingWithData:(NSData *)data
{
    if (data && [data length])
    {
        NSString *tmp = [[NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
        [tmp release];
        
        
        NSDictionary *requestDic = [NSDictionary dictionaryWithXMLData:data];
        
        if (requestDic) {
            
            NSDictionary *responseDic = [requestDic objectForKey:@"response"];
            
            if (responseDic && [[responseDic objectForKey:@"rspcode"] isEqualToString:@"0000"])
            {
                    
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(queue, ^{
                        
                        [self responseHandleWithDic:[requestDic objectForKey:@"svccont"]];
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            if ([_delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)])
                            {
                                [_delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFinishLoadingWithResult:nil];
                            }
                        });
                    });
                
                
            }
            else {
                if ([_delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
                {
                    [_delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
                }
            }
            
            
            
            
        }
        else{
            
            if ([_delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
            {
                [_delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
            }
        }
    }
    else {
        if ([_delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
        {
            [_delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
        }
    }
}
/*!
  @brief 请求失败回调
  */
- (void)request:(NetRequestExt *)request didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError..........");
	if ([_delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
    {
        [_delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
    }
    
}

- (void)responseHandleWithDic:(NSDictionary *)dic
{
    if (!dic) {
        return;
    }
    
    if ([[dic objectForKey:@"isreplace"] intValue] == 1) {//需要替换本地数据
        
        [[MWHistoryRoute sharedInstance] MW_RemoveAllGuideRoute];//清空本地数据
        
        NSDictionary *tempDic = [dic objectForKey:@"list"];
        id object = [tempDic objectForKey:@"road"];
        
        NSArray *roadArray = nil;
        if ([object isKindOfClass:[NSDictionary class]])
        {
            roadArray = [NSArray arrayWithObjects:object, nil];
        }
        else
        {
            roadArray = object;
        }
        if (roadArray && roadArray.count > 0) {
            
            for (NSDictionary *roadDic in roadArray) {
                
                MWPathPOI *pathPOI = [[MWPathPOI alloc] init];
                pathPOI.userID = [roadDic objectForKey:@"id"];
                pathPOI.operate = [[roadDic objectForKey:@"oprtype"] intValue];
                pathPOI.operateTime = [roadDic objectForKey:@"oprtime"];
                pathPOI.rule = [[roadDic objectForKey:@"routetype"] intValue];
                pathPOI.name = [roadDic objectForKey:@"name"];
                
                NSData* aData = [[roadDic objectForKey:@"content"] dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *requestDic = [NSJSONSerialization
                                            
                                            JSONObjectWithData:aData
                                            
                                            options:NSJSONReadingMutableLeaves
                                            
                                            error:nil];
                
                NSArray *poiArray = [requestDic objectForKey:@"poilist"];
                
                if (poiArray) {
                    
                    for (NSDictionary *poiDic in poiArray) {
                        
                        MWPoi *poi = [[MWPoi alloc] init];
                        poi.szName = [poiDic objectForKey:@"name"];
                        poi.longitude = [[poiDic objectForKey:@"x"] intValue];
                        poi.latitude = [[poiDic objectForKey:@"y"] intValue];
                        poi.lNaviLon = [[poiDic objectForKey:@"offset_x"] intValue];
                        poi.lNaviLat = [[poiDic objectForKey:@"offset_y"] intValue];
                        
                        [pathPOI.poiArray addObject:poi];
                        
                        [poi release];
                    }
                }
                
                [[MWHistoryRoute sharedInstance] MW_AddGuideRouteWithPathPOI:pathPOI];
                
                [pathPOI release];
            }
            
            [[MWHistoryRoute sharedInstance] storeRoute];
        }
        
    }
}

@end
