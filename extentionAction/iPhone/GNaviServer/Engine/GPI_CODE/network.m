//
//  network.mm
//  AutoNavi
//
//  Created by gaozhimin on 13-10-14.
//
//
#include "network.h"
#import "GPI_ANReachability.h"
#include "gpi_networkConnect.h"


@interface GPI_NETWORK : NSObject
{
    NSMutableDictionary *requests;
    pGPINetRecvDataCallback _pCallbackFunc;
}

@end
static GPI_NETWORK *g_gpi_network = nil;
@implementation GPI_NETWORK

- (id)init
{
    self = [super init];
    if (self)
    {
        requests = [[NSMutableDictionary alloc] init];
        _pCallbackFunc = NULL;
    }
    return self;
}

- (void)dealloc
{
    [requests release];
    requests = nil;
    [super dealloc];
}

+ (GPI_NETWORK *)NetInit
{
    if (g_gpi_network == nil)
    {
        g_gpi_network = [[GPI_NETWORK alloc] init];
    }
    return g_gpi_network;
}

+ (BOOL)NetUnInit
{
    if (g_gpi_network)
    {
        [g_gpi_network release];
        g_gpi_network = nil;
    }
    return YES;
}

- (void)GPI_NetSetResultCallback:(pGPINetRecvDataCallback)pCallbackFunc
{
    _pCallbackFunc = pCallbackFunc;
}

- (void)GPI_NetRequestWith:(gpi_networkCondition *)condition
{
    gpi_networkConnect *connect = [gpi_networkConnect requestWithCondition:condition target:self selector:@selector(requestDidFinish:)];
    [connect GPI_NetSetResultCallback:(void *)_pCallbackFunc];
    [requests setObject:connect forKey:[NSString stringWithFormat:@"%d",condition.nTaskID]];
    [connect connect];
}

- (void)GPI_NetStopRequest:(Gint32)nTaskID
{
    gpi_networkConnect *connect = [requests objectForKey:[NSString stringWithFormat:@"%d",nTaskID]];
    if (connect)
    {
        [connect disconnect];
        [requests removeObjectForKey:[NSString stringWithFormat:@"%d",nTaskID]];
        if (_pCallbackFunc)
        {
            _pCallbackFunc(NULL,0,TRANS_RESULT_STOP,nTaskID,NULL);
        }
    }
}

#pragma mark - Private methods

- (void)requestDidFinish:(NSString *)nTaskID
{
    [requests removeObjectForKey:nTaskID];
}

@end


/**********************************************************************
 *函数名称:GPI_NetInit
 *功能描述: 初始化
 *使用说明：程序初始化时调用
 *调用方式：同步（阻塞）
 *返回值：Gtrue成功Gfalse失败
 *其它说明:基本功能必须实现
 *修改日期		版本号		修改人		修改内容
 *---------------------------------------------------------------------
 *2013/08/13		1.0			许文渊
 **********************************************************************/
Gbool GPI_NetInit()
{
    NSLog(@"GPI_NetInit");
    if ([GPI_NETWORK NetInit])
    {
        return Gtrue;
    }
	return Gfalse;
}

/**********************************************************************
 *函数名称:GPI_NetUnInit
 *功能描述: 逆初始化
 *使用说明：程序退出前优先调用
 *调用方式：同步（阻塞）
 *返回值：Gtrue成功Gfalse失败
 *其它说明:基本功能必须实现
 *修改日期		版本号		修改人		修改内容
 *---------------------------------------------------------------------
 *2013/08/13		1.0			许文渊
 **********************************************************************/
Gbool GPI_NetUnInit()
{
    NSLog(@"GPI_NetUnInit");
    if ([GPI_NETWORK NetUnInit])
    {
        return Gtrue;
    }
	return Gfalse;
}

/**********************************************************************
 * 函数名称: GPI_NetSetResultCallback
 * 功能描述: 设置下载结果回调函数
 * 使用说明：程序初始化时调用
 * 调用方式：同步（阻塞）
 * 参数: pGPINetRecvDataCallback pCallbackFunc [IN] 函数指针，用于通知上层获取数据
 * 返 回 值：无
 * 其它说明: 基本功能必须实现
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2013/08/13		1.0			许文渊
 **********************************************************************/
void GPI_NetSetResultCallback(pGPINetRecvDataCallback pCallbackFunc)
{
    if (g_gpi_network)
    {
        NSLog(@"GPI_NetSetResultCallback");
        [g_gpi_network GPI_NetSetResultCallback:pCallbackFunc];
    }
}

/**********************************************************************
 *函数名称:GPI_NetStopRequest
 *功能描述:暂停TaskID对应的下载任务
 *调用方式：同步（阻塞）/异步（非阻塞）
 *参数:	param1:nTaskID[IN] 任务ID
 *		param2:bSync[IN] 是否同步标识
 Gtrue:同步模式,等待TaskID对应的下载线程结束才返回
 Gfalse:异步模式，发送消息通知TaskID对应的下载线程后，立即返回
 *返回值：Gtrue成功Gfalse失败
 *其它说明:基本功能必须实现
 *修改日期		版本号		修改人		修改内容
 *---------------------------------------------------------------------
 *2013/08/13		1.0			许文渊
 **********************************************************************/
Gbool GPI_NetStopRequest(Gint32 nTaskID,Gbool bSync)
{
    if (g_gpi_network)
    {
        [g_gpi_network GPI_NetStopRequest:nTaskID];
        return Gtrue;
    }
	return Gfalse;
}


/**********************************************************************
 *函数名称:GPI_NetUdpRequest
 *功能描述:UDP下载(异步）
 *调用方式：异步（非阻塞）
 *参数:	param1:Gint8 *pszUrl		[IN] 服务器端URL(如:trafficinfo.tinfochina.com:6666)
 param2:Gint8 *pszData		[IN] 请求数据
 param3:Gint32 nLen			[IN] 数据长度
 param4:Gint32 nTimeOut		[IN] 获取数据超时时间,单位“秒”（UDP比较特殊，超时时间可设置在10秒以内）
 param5:Gint32 nTaskID		[IN] 任务ID
 *返回值：Gtrue	成功	Gfalse	失败
 *其它说明1:	启动UDP下载，该函数内创建一个独立的线程，用于下载数据，服务器返回的数据通过函数指针pGPINetRecvDataCallback回传
 *其他说明2：部分项目中使用
 *修改日期		版本号		修改人		修改内容
 *---------------------------------------------------------------------
 *2013/08/13		1.0			许文渊
 **********************************************************************/
Gbool GPI_NetUdpRequest(Gint8 *pszUrl,		/*[IN]服务器端URL*/
                        Gint8 *pszData,	/*[IN]请求数据*/
                        Gint32 nLen,	/*[IN]数据长度*/
                        Gint32 nTimeOut,/*[IN]获取数据超时时间，单位“秒”*/
                        Gint32 nTaskID)/*[IN]任务ID*/

{
	return Gfalse;
}

/**********************************************************************
 *函数名称:GPI_NetGetHttpHeaders
 *功能描述:从句柄pstHeader中读取HTTP头部信息 （同步）
 *调用方式：同步（阻塞）
 *使用说明：pGPINetRecvDataCallback回调函数中调用
 *参数:	param1: void  *pstHeader		[IN]HTTP头句柄
 param2: Gint8 *pszName			[IN]头域
 param3: Gint8 *pszValue			[OUT]根据pszName读取指定头域内容
 *返回值：Gtrue成功	Gfalse失败
 *其他说明：部分项目中使用
 *修改日期		版本号		修改人		修改内容
 *---------------------------------------------------------------------
 *2013/08/13		1.0			许文渊
 **********************************************************************/
Gbool GPI_NetGetHttpHeaders(
                            void *pstHeader,		/*[IN]HTTP头句柄*/
                            Gint8 *pszName,			/*[IN]头域 (如："Accept-Encoding")*/
                            Gint8 *pszValue			/*[OUT]根据pszName读取指定头域内容(如:"gzip,deflate")*/
)
{
	return Gfalse;
}

/**********************************************************************
 *函数名称:GPI_NetGetHttpHeaderStatusCode
 *功能描述:从句柄pstHeader中读取HTTP头部信息状态码字段
 *调用方式：同步（阻塞）
 *使用说明：pGPINetRecvDataCallback回调函数中调用
 *参数:	param1: void  *pstHeader		[IN]HTTP头句柄
 *		param2: Gint8 *pszDestInfo		[OUT]状态码的描述信息（预留）
 *返回值：return 0: 获取失败。
 return >0:服务端回传的状态码。
 （如：200 successful
 401 Unauthorized
 403 Forbidden
 404 Not Found
 500 Internal Server Error
 501 Not Implemented
 502 Bad Gateway
 503 Service Unavailable
 504 Gateway Timeout）
 *其他说明：部分项目中使用
 *修改日期		版本号		修改人		修改内容
 *---------------------------------------------------------------------
 *2013/08/13		1.0			许文渊
 **********************************************************************/
Gint32 GPI_NetGetHttpHeaderStatusCode(void *pstHeader ,Gint8 *pszDestInfo)
{
	return 0;
}

/**********************************************************************
 *函数名称:	GPI_NetHttpRequestGET
 *功能描述:	最基本的 HTTP GET方式下载(异步）
 *调用方式：异步（非阻塞）
 *参数:
 *param1:Gint8 *pszUrl		[IN] 服务器端URL(如:http://trafficinfo.tinfochina.com:80/trafficplat/logonservice?provider=hxmsx)
 *param2:Gint32 nTimeOut		[IN] 获取数据超时时间,单位“秒”
 *param3:Gint32 nTaskID		[IN] 任务ID
 *param4:Gint8 *pstHeader	[IN] （可选）以\r\n为分割符的HTTP头信息，参数值通过解析库接口获取(格式如：Cookie: sessionid=8834956793409\r\nCache-Control: no-cache\r\nAccept-Encoding: gzip,deflate\r\n)
 *param5:void *pExt1			[IN] （可选）unused
 *返回值：Gtrue	成功	Gfalse	失败
 *其它说明1:	启动HTTP GET下载，该函数创建一个独立的线程，用于下载数据，服务器返回的数据通过函数指针pGPINetRecvDataCallback	回传
 *其它说明2：基本功能，涉及到HTTP协议的项目必须实现。
 
 *修改日期		版本号		修改人		修改内容
 *---------------------------------------------------------------------
 *2013/08/13		1.0			许文渊
 **********************************************************************/
Gbool GPI_NetHttpRequestGET(
                            Gint8 *pszUrl,			/*[IN]服务器端地址*/
                            Gint32 nTimeout,		/*[IN]超时时间,单位“秒”*/
                            Gint32 nTaskID,			/*[IN]任务ID*/
                            Gint8 *pstHeader,	/*[IN]（可选）“\r\n”为分割的HTTP头信息，参数值通过解析库接口获取*/
                            void *pExt1)		/*[IN]unused 扩展指针2，预留，各平台如有需要可使用*/
{
    if (g_gpi_network)
    {
        NSLog(@"GPI_NetHttpRequestGET");
        if(pszUrl == NULL)
        {
            return Gfalse;
        }
        gpi_networkCondition *condition = [[gpi_networkCondition alloc] init];
        if (pszUrl)
        {
            condition.pszUrl = [NSString stringWithUTF8String:(const char *)pszUrl];
        }
        condition.httpMethod = @"GET";
        condition.nTimeOut = nTimeout;
        condition.nTaskID = nTaskID;
        if (pstHeader)
        {
            condition.pstHeader = [NSString stringWithUTF8String:(const char *)pstHeader];
        }
        
        [g_gpi_network GPI_NetRequestWith:condition];
        [condition release];
        return Gtrue;
    }
	return Gfalse;
}


/**********************************************************************
 * 函数名称: GPI_NetHttpRequestPOST
 * 功能描述: 最基本的 HTTP POST方式下载(异步）
 * 调用方式：异步（非阻塞）
 * 参数: param1:Gint8 *pszUrl		[IN] 服务器端URL(如:http://trafficinfo.tinfochina.com:80)
 param2:Gint8 *pRequest		[IN] 请求数据
 param3:Gint32 nReqLen		[IN] pRequest数据长度
 param4:Gint32 nTimeOut		[IN] 获取数据超时时间，单位“秒”
 param5:Gint32 nTaskID		[IN] 任务ID
 param6:void *pstHeader		[IN] （可选）以\r\n为分割符的HTTP头信息，参数值通过解析库接口获取(格式如：Cookie: sessionid=8834956793409\r\nCache-Control: no-cache\r\nAccept-Encoding: gzip,deflate\r\n)
 param7:void *pExt1			[IN] （可选）unused
 * 返 回 值：无
 * 其它说明1: 启动HTTP POST方式下载，该函数创建一个独立的线程，用于下载数据，服务器返回的数据通过函数指针 pGPINetRecvDataCallback 回传，并将param5返回。
 * 其它说明2：基本功能，涉及到HTTP协议的项目必须实现。
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2013/08/13		1.0			许文渊
 **********************************************************************/
Gbool GPI_NetHttpRequestPOST(Gint8 *pszUrl,			/*[IN]服务器端地址*/
							 Gint8 *pRequest,		/*[IN]请求数据*/
							 Gint32 nReqLen,		/*[IN]数据长度*/
							 Gint32 nTimeout,		/*[IN]超时时间（单位“秒”）*/
							 Gint32 nTaskID,		/*[IN]任务ID*/
							 Gint8 *pstHeader,/*[IN]“\r\n”为分割的HTTP头信息（可选）*/
							 void *pExt1)	/*[IN]unused 扩展指针1，预留，各平台如有需要可使用*/

{
    if (g_gpi_network)
    {
        NSLog(@"GPI_NetHttpRequestPOST");
        if(pszUrl == NULL)
        {
            return Gfalse;
        }
        gpi_networkCondition *condition = [[gpi_networkCondition alloc] init];
        if (pszUrl)
        {
            condition.pszUrl = [NSString stringWithUTF8String:(const char *)pszUrl];
        }
        if (pRequest)
        {
            condition.pszData = [NSData dataWithBytes:(const char *)pRequest length:nReqLen];
//            NSLog(@"%@",[[NSString alloc] initWithData:condition.pszData encoding:NSUTF8StringEncoding]);
//            NSLog(@"%@",[[NSString alloc] initWithData:condition.pszData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]);
        }
        condition.httpMethod = @"POST";
        condition.nTimeOut = nTimeout;
        condition.nTaskID = nTaskID;
        if (pstHeader)
        {
            condition.pstHeader = [NSString stringWithUTF8String:(const char *)pstHeader];
        }
        
        
        [g_gpi_network GPI_NetRequestWith:condition];
        [condition release];
        return Gtrue;
    }
	return Gfalse;
}

/**********************************************************************
 * 函数名称:GPI_NetGetDevStatus
 * 功能描述:获取网络状态
 * 调用方式：同步（阻塞）
 * 使用说明：下载前调用
 * 返回值：
 NET_STATUS_UNKNOWN		-1	网络状态未知
 NET_STATUS_UNAVAILABLE  0	网络不可用
 NET_STATUS_AVAILABLE	1	网络可用
 NET_STATUS_SLOW			2	网络可用：低速（EDGE,GPRS,CDMA2000等）
 NET_STATUS_FAST			3	网络可用：高速（LAN/WIFI/3G/4G等）
 * 其他说明：无		
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2013/08/13		1.0			许文渊
 **********************************************************************/
Gint32 GPI_NetGetDevStatus()
{
    GPI_ANReachability *r = [GPI_ANReachability reachabilityForInternetConnection];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            // 没有网络连接
            return 0;
            break;
        case ReachableViaWWAN:
            // 使用3G网络
            return 3;
            break;
        case ReachableViaWiFi:
            // 使用WiFi网络
            return 3;
            break;
        default:
            return 1;
            break;
    }
    
	return -1;
}
