//
//  MWNetSearchOperator.m
//  AutoNavi
//
//  Created by gaozhimin on 14-2-25.
//
//

#import "MWNetSearchOperator.h"
#import "MWNetSearchListener.h"

@implementation MWNetSearchOperator

/**
 *	POI搜索、交叉路口搜索请求接口
 *	@param	type	请求类型
 *	@param	option	POI搜索、交叉路口搜索条件
 *	@param	delegate	回调委托
 *	@return 成功返回GD_ERR_OK, 失败返回对应出错码 
 */

+ (GSTATUS)MWNetKeywordSearchWith:(RequestType)type  option:(MWNetKeyWordSearchOption *)option delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = NetSearchURL;
    condition.requestType = type;
    condition.httpMethod = @"POST";
    condition.bodyData = [option getAllPropertiesAndVaulesData];
    NSLog(@"%@",[option getAllPropertiesAndVaulesData]);
    MWNetSearchListener * deal = [MWNetSearchListener  createListenerWith:type delegate:delegate];
    //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

/**
 *	周边搜索请求接口
 *
 *	@param	type	请求类型
 *	@param	option	周边搜索条件
 *	@param	delegate回调委托
 *
 *	@return 成功返回GD_ERR_OK, 失败返回对应出错码
 */

+ (GSTATUS)MWNetAroundSearchWith:(RequestType)type  option:(MWNetAroundSearchOption *)option delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = NetSearchURL;
    condition.requestType = type;
    condition.httpMethod = @"POST";
    condition.bodyData = [option getAllPropertiesAndVaulesData];
    
    MWNetSearchListener *deal = [MWNetSearchListener  createListenerWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}
+ (GSTATUS)MWNetLineArroundSearchWith:(RequestType)type
                               option:(MWNetLineSearchOption *)option
                             delegate:(id<NetReqToViewCtrDelegate>)delegate

{
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = NetSearchURLLineArround;
    condition.requestType = type;
    condition.httpMethod = @"POST";
    
    GGUIDEROADLIST *pList = NULL;
    GSTATUS  res = [MWRouteGuide GetGuideRoadList:NULL allRoad:Gtrue list:&pList];
    int N = pList->nNumberOfRoad;
    const char * xml_c = [[option getAllPropertiesAndVaulesData] bytes];
    int xml_length = [[option getAllPropertiesAndVaulesData] length];
    //将经纬度组装成字节
    int length = 1+(N)*16 + 4 + xml_length;
    char * buffer = malloc(length);
    char * pFirst = buffer;
    memset(buffer,0,length);
    Byte value = 0;
    memcpy(buffer, &value, sizeof(Byte));
    buffer ++;
    memcpy(buffer, &N, sizeof(int));
    buffer += sizeof(int);
    if (res==GD_ERR_OK) {
        for (int i=0; i<N; i++)
        {
            
            double x = (double)pList->pGuideRoadInfo[i].lLon/1000000.0;
            memcpy(buffer, &x, sizeof(double));
            buffer += sizeof(double);
            double y = (double)pList->pGuideRoadInfo[i].lLat/1000000.0;
            memcpy(buffer, &y, sizeof(double));
            buffer += sizeof(double);
        }
    }
    memcpy(buffer, xml_c, xml_length);
    NSData * data = [[[NSData alloc]initWithBytes:pFirst length:length] autorelease];
    NSLog(@"%@",data);
    free(pFirst);
    condition.httpHeaderFieldParams = [NSMutableDictionary dictionaryWithDictionary:[option getHttpHeader]];
    condition.bodyData = data;
    MWNetSearchListener * deal = [MWNetSearchListener  createListenerWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt * request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}
+ (GSTATUS)MWNetParkStopSearchWith:(RequestType)type  option:(MWNetParkStopSearchOption *)option delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = NetSearchURL;
    condition.requestType = type;
    condition.httpMethod = @"POST";
    condition.httpHeaderFieldParams=[NSMutableDictionary dictionaryWithDictionary: [option getHttpHeader] ];
    condition.bodyData = [option getAllPropertiesAndVaulesData];
    MWNetSearchListener *deal = [MWNetSearchListener  createListenerWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt * request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}
/**
 *	取消请求接口
 *
 *	@param	type	取消请求的类型
 *
 */
+ (void)MWCancelNetSearchWith:(RequestType)type
{
    [[NetExt sharedInstance] Net_CancelRequestWithType:type];
    [MWNetSearchListener  deleteListenerWith:type];
}

@end
