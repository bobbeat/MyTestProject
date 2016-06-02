//
//  MWSkinAndCarListRequest.m
//  AutoNavi
//
//  Created by huang on 14-1-6.
//
//

#import "MWSkinAndCarListRequest.h"
#import "XMLDictionary.h"
#import "GDCacheManager.h"
//#import ""
#define SERVICE_REQUEST_URL     @"download_source/car_service/?"    //获取车主服务列表
#define SKIN_REQUEST_URL        @"download_source/skin/?"           //获取皮肤列表
#define SKIN_NEW_URL            @"download_source/skin_new/?"       //获取新增皮肤ID
#define SERVICE_NEW_URL         @"download_source/service_new/?"    //获取新增服务ID
#define SKIN_AND_CAR_REQUEST_ERROR_CODE      10010

#define DEVICE_IPHONE   @"iPhone"
#define DEVICE_NEWPAD   @"NewPad"
#define DEVICE_IPAD     @"iPad"
#define MWGET_DEVICE  [MWSkinAndCarListRequest getDevice]

@interface MWSkinAndCarListRequest()
{
    RequestType requestType;
    RequestType imageRequsetType;
}

@end

@implementation MWSkinAndCarListRequest
-(void)dealloc
{
    self.delegate=nil;
    [[NetExt sharedInstance] Net_CancelRequestWithType:requestType];
    [[NetExt sharedInstance] cancelOperationWithType:imageRequsetType];
    [super dealloc];
}

#pragma mark - public method

-(void)Net_SkinListRequest:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    
    NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:MWGET_DEVICE forKey:@"device"];
    
    [dic setObject:[NSString stringWithFormat:@"%.1f",SOFTVERSIONNUM] forKey:@"client"];
    
    NetBaseRequestCondition *requestCondition = [NetBaseRequestCondition requestCondition];
    requestCondition.baceURL = [kNetDomain stringByAppendingString:SKIN_REQUEST_URL];
    requestCondition.requestType = type;
    requestCondition.httpMethod = @"GET";
    requestCondition.urlParams=dic;
        
    [[NetExt sharedInstance] requestWithCondition:requestCondition delegate:self];
    self.delegate=delegate;
    requestType=type;
    
    
}
-(void)Net_CarRequset:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate
{
 
    NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:MWGET_DEVICE forKey:@"device"];
    [dic setObject:[NSString stringWithFormat:@"%.1f",SOFTVERSIONNUM] forKey:@"client"];
    NetBaseRequestCondition *requestCondition = [NetBaseRequestCondition requestCondition];
    requestCondition.baceURL = [kNetDomain stringByAppendingString:SERVICE_REQUEST_URL];
    requestCondition.requestType = type;
    requestCondition.httpMethod = @"GET";
    requestCondition.urlParams=dic;
        
    [[NetExt sharedInstance] requestWithCondition:requestCondition delegate:self];
    self.delegate=delegate;
    requestType=type;
   
}
-(void)Net_NewRequest:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate                 //获取新增new
{
    NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithCapacity:0];
    NSString *url=SKIN_NEW_URL;
    if(type==REQ_SKIN_NEW)
    {
        url=SKIN_NEW_URL;
    }
    else if(type==REQ_CAR_NEW)
    {
        url=SERVICE_NEW_URL;
    }
    
    [dic setObject:[NSString stringWithFormat:@"%.1f",SOFTVERSIONNUM] forKey:@"client"];
    NetBaseRequestCondition *requestCondition = [NetBaseRequestCondition requestCondition];
    requestCondition.baceURL = [kNetDomain stringByAppendingString:url];
    requestCondition.requestType = type;
    requestCondition.httpMethod = @"GET";
    requestCondition.urlParams=dic;
    
    [[NetExt sharedInstance] requestWithCondition:requestCondition delegate:self];
    self.delegate=delegate;
    requestType=type;

}
#pragma mark - NetRequestExtDelegate callback

- (void)request:(NetRequestExt *)request didFailWithError:(NSError *)error
{
  [self failedWithError:error withRequestType:request.requestCondition.requestType];
   

}
- (void)request:(NetRequestExt *)request didFinishLoadingWithData:(NSData *)data
{
    [self handleResponseData:data withRequestType:request.requestCondition.requestType];
   
}

#pragma mark -NetSynRequestExtDelegate callback
-(void)synRequest:(NetOperation *)operation didFailWithError:(NSError *)error
{
    
    error=[self errorWithCode:NetErrorLoadImageFail userInfo:nil];
    if ([self.delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)]) {
        [self.delegate requestToViewCtrWithRequestType:operation.requestCondition.requestType didFailWithError:error];
    }
    
}
-(void)synRequest:(NetOperation *)operation didFinishLoadingWithData:(NSData *)data
{
    UIImage *image=[UIImage imageWithData:data];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    if (image) {
        [[GDCacheManager globalCache] setImage:image forKey:operation.requestCondition.baceURL withTimeoutInterval:3600*24*30];
        [dic setObject:image forKey:operation.requestCondition.baceURL];
        if ([self.delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)]) {
            [self.delegate requestToViewCtrWithRequestType:operation.requestCondition.requestType didFinishLoadingWithResult:dic];
        }
    }
    
}

#pragma mark private methods
+(NSString*)getDevice
{
    NSString  *device=@"iPhone";
    if (isPad) {
        device=@"iPad";
        if (ISRETINA) {
            device=@"NewPad";
        }
    }
    else if (isiPhone)
    {
        device=@"iPhone";
    }
    return device;
}

-(void)Net_RequestImage:(NSString *)imageUrl  withRequest:(RequestType)type
{
     [self Net_RequestImage:imageUrl withRequest:type withDelegate:self];
}

-(void)Net_RequestImage:(NSString *)imageUrl  withRequest:(RequestType)type   withDelegate:(id <NetSynRequestExtDelegate>)delegate
{
    if (imageUrl&&[imageUrl isKindOfClass:[NSString class]] ) {
        if (imageUrl.length<1) {
            return ;
        }
        
        NetBaseRequestCondition *condition=[[NetBaseRequestCondition alloc] init];
        condition.baceURL=imageUrl;
        condition.requestType=type;
        imageRequsetType=type;
        [[NetExt sharedInstance] synRequestWithCondition:condition delegate:delegate];
        [condition release];
       
    }
  
}

-(void)failedWithError:(NSError *)error withRequestType:(RequestType)type
{
    if ([self.delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)]) {
        NETERROR code=error.code;
        if ([error.domain isEqualToString:KNetResponseErrorDomain]) {
           code=NetErrorServerCrash;
        }
        NSError *newError=[self errorWithCode:code userInfo:nil];
        [self.delegate requestToViewCtrWithRequestType:type didFailWithError:newError];
    }
}


-(void)handleResponseData:(NSData *)data withRequestType:(RequestType)type
{
     NSDictionary *dic=[NSDictionary dictionaryWithXMLData:data];
    if ([[dic objectForKey:@"Result"] isEqualToString:@"SUCCESS"]) {
        if (self.delegate) {
            NSMutableArray *array=[NSMutableArray array];
            if(type==REQ_SKIN_DATA)
            {
                NSArray *skinArr = [[dic objectForKey:@"skinList"] objectForKey:@"skin"];
                if (skinArr.count>0) {
                    for (NSDictionary *skinDic in skinArr) {
                        NSDictionary *newDic=[NSDictionary dictionaryWithDictionary:skinDic];
                        [array addObject:newDic];
                        NSString *imageUrl=[skinDic objectForKey:CONFIG_SKIN_SMALLPIC];
                        if (imageUrl) {
                            [self Net_RequestImage:imageUrl withRequest:REQ_SKIN_DATA  withDelegate:self];
                        }
//                        imageUrl=[skinDic objectForKey:CONFIG_SKIN_PORTRAIT_PIC];
//                        if (imageUrl) {
//                            [self Net_RequestImage:imageUrl withRequest:REQ_SKIN_DATA  withDelegate:self];
//                        }
//                        imageUrl=[skinDic objectForKey:CONFIG_SKIN_LANDSCAPE_PIC];
//                        if (imageUrl) {
//                           [self Net_RequestImage:imageUrl withRequest:REQ_SKIN_DATA  withDelegate:self];
//                        }
                    }
                }
            }
            else if (type==REQ_CAR_NEW||type==REQ_SKIN_NEW)
            {
                //当数据就只有一条的时候，获取出来的数组会变成字典
                id arr = [dic objectForKey:@"new_add"] ;
                if([arr isKindOfClass:[NSDictionary class]])
                {
                    NSArray *idArr=[arr objectForKey:@"id"];
                    if(idArr != nil)
                    {
                        if ([idArr isKindOfClass:[NSArray class]]) {
                            [array addObjectsFromArray:idArr];
                        }
                        else
                        {
                            [array addObject:idArr];
                        }
                    }
                    
                }
            }
            
            if ([self.delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)]) {
                [self.delegate requestToViewCtrWithRequestType:type didFinishLoadingWithResult:array];
            }
            
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)]) {
            
            NETERROR netError=NetErrotClientInvalid;
            NSString *errorSting=[dic objectForKey:@"Error"];
            if ([errorSting isEqualToString:@"CLIENT_INVALID"]) {           //软件版本号不合法
                netError=NetErrotClientInvalid;
            }
            else if ([errorSting isEqualToString:@"DEVICE_INVALID"])        //设备类型不合法
            {
                netError=NetErrotDeviceInvalid;
            }
            else if ([errorSting isEqualToString:@"FUNCTION_CLOSED"])       //该功能已关闭
            {
                netError=NetErrorFunctionClose;
            }
            else if ([errorSting isEqualToString:@"PARAMS_MISS"])           //缺少参数
            {
                netError=NetErrorParams_Miss;
            }
            
            NSError *error=[self errorWithCode:netError userInfo:nil];
            [self.delegate requestToViewCtrWithRequestType:type didFailWithError:error];
        }

    }
}
- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo
{
    return [NSError errorWithDomain:kListErrorDomain code:code userInfo:userInfo];
}



@end
