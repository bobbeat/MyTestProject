//
//  AccountXmlParser.h
//  Plugin_Account
//
//  Created by y y on 11-12-12.
//  Copyright 2011年 autonavi.com. All rights reserved.//

#import <Foundation/Foundation.h>
#import "Account.h"

@interface AccountXmlParser : NSObject<NSXMLParserDelegate> {
   	BOOL isAuth;
	NSMutableString *contentOfCurrentProperty;
	AccountInfo *myAccountInfo;
    
    NSString *kResult;           	//解析结果,供返回结果参考
    NSString *kMessage;          	//解析错误描述,供返回结果参考
    NSString *kAuthenticate;			//解析是否认证通过,供返回结果参考
    NSString *kTimeStamp;        	//解析服务器时间戳,供返回结果参考
    NSString *kError;        	//解析服务器错误类型,供返回结果参考
    
    NSString *kText1;        	//任务栏文字1
    NSString *kText2;        	//任务栏文字2
    
    RequestType m_requestType;
}
@property(nonatomic,copy)NSString *kResult;
@property(nonatomic,copy)NSString *kMessage;
@property(nonatomic,copy)NSString *kAuthenticate;
@property(nonatomic,copy)NSString *kTimeStamp;
@property(nonatomic,copy)NSString *kError;
@property(nonatomic,copy)NSString *kText1;
@property(nonatomic,copy)NSString *kText2;

@property(nonatomic,retain)NSMutableString *contentOfCurrentProperty;
@property(nonatomic,readwrite)BOOL isAuth;
@property(nonatomic,retain)AccountInfo *myAccountInfo;
@property(nonatomic,retain)NSMutableDictionary *m_POI;  //存储服务器下发poi消息

+(AccountXmlParser*)instance;
//解析数据
-(NSDictionary *)GetOperationResultByData:(NSData *)data WithOperation:(id)op;
-(void)ClearAccountInfo;
-(void)Clear95190Info;

@end
