//
//  ANDownloadProtocol.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 12/17/14.
//  Copyright (c) 2014 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ANDownloadStatusProtocol;

/**
 *  下载状态
 */
typedef NS_ENUM(NSUInteger, ANDownloadItemStatus) {
    ANDownloadItemStatusNone,           ///< 未开始
    ANDownloadItemStatusDownloading,    ///< 正在下载
    ANDownloadItemStatusWaiting,        ///< 等待开始
    ANDownloadItemStatusConnecting,     ///< 正在连接
    ANDownloadItemStatusFinished,       ///< 完成
    ANDownloadItemStatusStopped,        ///< 停止
    ANDownloadItemStatusError,          ///< 错误
};
/**
 *  下载对象
 */
@protocol ANDownloadItem <NSObject>

/**
 *  下载代理
 */
@property (assign, nonatomic) id<ANDownloadStatusProtocol> downloadDelegate;

/**
 *  下载状态
 */
@property (nonatomic, readonly) ANDownloadItemStatus status;
/**
 *  数据大小
 */
@property (nonatomic, readonly) long dataSize;
/**
 *  已下载数据
 */
@property (nonatomic, readonly) long long downloadedSize;
/**
 *  开始
 */
-(void)start;
/**
 *  停止
 */
-(void)stop;
/**
 *  是否需要更新
 *
 *  @return 结果
 */
-(BOOL)needUpdate;

@end
/**
 *  下载协议
 */
@protocol ANDownloadStatusProtocol <NSObject>
/**
 *  下载状态变化
 *
 *  @param downloadItem 下载对象
 */
-(void)downloadItemDidChangeStatus:(id<ANDownloadItem>)downloadItem;
/**
 *  下载进度变化
 *
 *  @param downloadItem 下载对象
 *  @param percentage   进度
 */
-(void)downloadItem:(id<ANDownloadItem>)downloadItem didFinishWithPercent:(NSUInteger)percentage;

@end