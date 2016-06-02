//
//  ANMapDataDownloadManager.h
//  ProjectDemoOnlyCode
//
//  Created by liyuhang on 14-11-5.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

/**
 *  !!!!!!!支持城市或直辖市下载,省的话要一个城市一个城市下载!!!!!!
 *
 *
 *  首先要使用  - (void)getCitiesListFromServer:(void(^)(NSArray* arrayOfCitiesList))blockForGetList;获取省市列表
 *
 *  接着使用   - (void)downLoadCityData:(CityMapInfo *)cityInfo;下载某一地区
 *
 *
 *  downloadReceiveDataBlock已下载的数据大小放在CityMapInfo.nCountOfHasDownloaded里头，下载过程中每接到数据都会把数据量放到CityMapInfo.nCountOfHasDownloaded里
 *
 */

#import <Foundation/Foundation.h>

#ifdef MacroFoFramework
    #import <ANApi/ANCityMapInfo.h>
#else
    #import "ANCityMapInfo.h"
#endif


#define CONCURRENTMAXLINES  5 //允许同时下载的最大条数


typedef void (^mapDownloadBlock)(ANCityMapInfo *cityinfo);

/**
 *  地图下载代理
 */
@protocol MapDownloadDelegate <NSObject>
/**
 *  下载成功代理
 *
 *  @param cityinfo 省市对象
 */
-(void)mapDownloadSuccess:(ANCityMapInfo *)cityinfo;

/**
 *  下载过程中接收到数据
 *
 *  @param cityinfo 省市对象
 */
-(void)mapDownloadReceiveData:(ANCityMapInfo *)cityinfo;

/**
 *  下载失败
 *
 *  @param cityinfo 省市对象
 */
-(void)mapDownloadFail:(ANCityMapInfo *)cityinfo;

@end


/**
 *  数据下载器
 */
@interface ANMapDataDownloadManager : NSObject
/**
 *  省市列表
 */
@property (nonatomic, strong) NSMutableArray *arrayCitiesListFromServer;

/**
 *  正在下载的省市列表
 */
@property (nonatomic, strong) NSMutableArray *arrayDownloadingList;

/**
 *  已经下载的省市列表
 */
@property (nonatomic, strong) NSMutableArray *arrayDownloadedList;

/**
 *  下载代理
 */
@property (nonatomic, assign) id<MapDownloadDelegate> delegateOfMapDownload;


/**fun
 * @brief: 单例
 * @return:
 */
+ (instancetype)shareInstance;
+ (void)releaseInstance;


#pragma mark -
#pragma mark autonavi server

/**
 *  get cities list from server
 *
 *  @param blockForGetList block
 */
- (void)getCitiesListFromServer:(void(^)(NSArray* arrayOfCitiesList))blockForGetList;

/**
 *  检查是否有基础数据
 *
 *  @return 是否存在
 */
- (BOOL)isHasBaseMapData;

/**
 *  传入arrayCitiesListFromServer中的数据,进行下载
 *
 *  @param cityInfo 城市信息
 */
- (void)downLoadCityData:(ANCityMapInfo *)cityInfo;

/**
 *  传入arrayDownloadingList中的数据，暂停某个下载
 *
 *  @param cityInfo 城市信息
 */
- (void)pauseDataDownload:(ANCityMapInfo *)cityInfo;

/**
 *  传入arrayDownloadingList中的数据，恢复某个下载
 *
 *  @param cityInfo 城市信息
 */
- (void)resumeDataDownload:(ANCityMapInfo *)cityInfo;

/**
 *  传入arrayDownloadingList中的数据，停止某个下载
 *
 *  @param cityInfo 城市信息
 */
- (void)stopDataDownload:(ANCityMapInfo *)cityInfo;

/**
 *  传入arrayDownloadedList中的数据，删除某个已下载的数据文件
 *
 *  @param cityInfo 城市信息
 */
- (void)deleteDownloadedFileData:(ANCityMapInfo *)cityInfo;


@end





