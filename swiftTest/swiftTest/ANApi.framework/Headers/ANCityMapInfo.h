//
//  ANCityMapInfo.h
//  ApiDemoProject
//
//  Created by 陈江彬 on 14/10/20.
//  Copyright (c) 2014年 Autonavi. All rights reserved.
//

/**
 *  省市下载状态
 */
typedef NS_ENUM(NSUInteger, CityMapDownloadStatus){
    /**
     *  还没下载
     */
    MDS_NO_DOWNLOADED = 0,
    /**
     *  已经下载
     */
    MDS_HAS_DOWNLOADED = 1,
    /**
     *  正在下载
     */
    MDS_IS_DOWNLOADING = 2,
    /**
     *  等待下载
     */
    MDS_WAIT_FOR_DOWNLOADING = 3,
    /**
     *  暂停下载
     */
    MDS_PASUE_DOWNLOADING =4,
    /**
     *  有更新
     */
    MDS_HAVE_NEW_TO_DWONLOAD = 5,
};


/**
 *  城市地图信息
 */
@interface ANCityMapInfo : NSObject<NSCopying>

/**
 *  省市英文名
 */
@property (nonatomic, copy)     NSString *enName;

/**
 *  省市中文名
 */
@property (nonatomic, copy)     NSString *name;

/**
 *  省市繁体名
 */
@property (nonatomic, copy)     NSString *twName;

/**
 *  省市类型
 */
@property (nonatomic, assign)   int type;

/**
 *  数据大小
 */
@property (nonatomic, assign)   int size;

/**
 *  子城市数组
 */
@property (nonatomic, strong)   NSMutableArray *arrayOfSubCities;

/**
 *  是否有更新
 */
@property (nonatomic, assign)   BOOL isHasUpdateInfo;

/**
 *  城市编码
 */
@property (nonatomic, copy)     NSString *cityCode;

/**
 *  下载状态
 */
@property (nonatomic, assign)   CityMapDownloadStatus statusForDownload;

/**
 *  是否为省份
 */
@property (nonatomic, assign)   BOOL isProvince;

/**
 *  已经下载的数据大小
 */
@property (nonatomic, assign)   unsigned long long countOfHasDownloaded;


@end





