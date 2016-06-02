//
//  MWSkinAndCarListRequest.h
//  AutoNavi
//
//  Created by huang on 14-1-6.
//
//

#import <Foundation/Foundation.h>

#define kListErrorDomain            @"ListErrorDomain" //皮肤资源和车主服务列表错误码

@interface MWSkinAndCarListRequest : NSObject<NetRequestExtDelegate,NetSynRequestExtDelegate>
@property(nonatomic,assign)id<NetReqToViewCtrDelegate> delegate;
//-(void)Net_RequestImage:(NSString *)imageUrl  withRequest:(RequestType)type   withDelegate:(id <NetSynRequestExtDelegate>)delegate;
-(void)Net_RequestImage:(NSString *)imageUrl  withRequest:(RequestType)type;                        //返回图片不为nil表示从缓存中加载到的，
-(void)Net_SkinListRequest:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate;
-(void)Net_CarRequset:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate;
-(void)Net_NewRequest:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate;                 //获取新增new
@end
