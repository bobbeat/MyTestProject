//
//  NetOperation.h
//  AutoNavi
//
//  Created by gaozhimin on 13-7-24.
//
//

#import <Foundation/Foundation.h>
#import "NetBaseRequestCondition.h"

@protocol NetSynRequestExtDelegate;

@interface NetOperation : NSOperation
{
    NetBaseRequestCondition *_requestCondition;
    id<NetSynRequestExtDelegate>       _delegate;
}

@property (nonatomic, retain) NetBaseRequestCondition *requestCondition;
@property (nonatomic, assign) id<NetSynRequestExtDelegate>       delegate;

/*
 同步网络请求
 
 url:请求的url地址
 requestType:请求类型
 params:参数
 httpMethod:请求方式
 bodyData:http的body
 delegate ： 同步请求回调  具体请查看 NetSynRequestExtDelegate
 */
+ (NetOperation *)synRequestWithCondition:(NetBaseRequestCondition *)condition delegate:(id<NetSynRequestExtDelegate>)delegate;

@end
