//
//  ATSPInterfaceManager.h
//  ATSPDemo
//
//  Created by chenjie on 12/29/14.
//  Copyright (c) 2014 chenjie. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * atsp请求返回类型
 */
typedef NS_ENUM(NSInteger, ATSPResponseCode){
    //请求成功
    ATSP_RequestSuccess = 100,
    //请求失败
    ATSP_RequestFail = 101,
    //参数错误
    ATSP_ParamInvalid = 102,
    //无网络
    ATSP_NotNetWork = 103
};

@interface ATSPInterfaceManager : NSObject

+ (ATSPInterfaceManager*)shareInstance;

+ (void)releaseInstance;

/**
 *  设置服务器数据(第一步)
 *
 *  @param host 服务器地址
 *  @param port 端口号
 *
 *  @return YES 成功 NO 失败
 */
- (BOOL)setATSPHost:(NSString *)host port:(NSString *)port;

/**
 *  设置应用程序key值(第二步)
 *
 *  @param dataSetId 数据集
 *  @param appKey    应用程序key值
 */
- (void)setATSPDataSetId:(int)dataSetId AppKey:(NSString *)appKey;

/**
 *  发送需要收集的数据
 *
 *  @param atspDataArray   需要收集的数据，由Dictionary组成的NSArry，Dictionary由服务端定义的协议进行填充。
 *  @param atspCodeHandler 返回的类型
 */
- (void)sendATSPDataArray:(NSArray *)atspDataArray
          atspCodeHandler:(void(^)(ATSPResponseCode atspCode))atspCodeHandler;


@end
