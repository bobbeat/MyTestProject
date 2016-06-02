//
//  DownloadTask.h
//  plugin-CityDataManager
//
//  Created by mark on 11-11-4.
//  Copyright (c) 2011年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "plugin-cdm-Task.h"

typedef enum DOWNLOADHANDLETYPE{
    DOWNLOADHANDLETYPE_URLREQUESTFAIL        = 0,  //url请求失败
    DOWNLOADHANDLETYPE_NONETWORK             = 1,  //无网络连接
    DOWNLOADHANDLETYPE_3GDOWNLOAD            = 2,  //3g下载
    DOWNLOADHANDLETYPE_NOSKINID              = 3,  //没有皮肤id
    DOWNLOADHANDLETYPE_CURRENTLAGERTOTAL     = 41, //实际下载大小大于服务器返回大小
    DOWNLOADHANDLETYPE_NOSPACE               = 42, //空间不足
    DOWNLOADHANDLETYPE_UPZIPFAIL             = 43, //解压失败
    DOWNLOADHANDLETYPE_CURRENTSMALLTOTAL     = 44, //实际下载大小小于服务器返回大小
    DOWNLOADHANDLETYPE_TOTALSIZEREQUESTERROR = 45, //服务器返回的数据总大小错误
    DOWNLOADHANDLETYPE_MD5NOMATCH            = 46, //文件md5校验失败
    DOWNLOADHANDLETYPE_URLERROR              = -1002,//URL链接失败
}DOWNLOADHANDLETYPE;

@interface DownloadTask : Task<NSCoding> 
{
    NSString* url;//下载地址
	
	NSURLConnection* URLConnection;
	NSOutputStream* fileStream;
	NSString* filePath;//文件路径
	NSString* filename;//文件名
	NSString* tmpPath;
	int flag;
	NSThread *mythread;
  
}

@property (nonatomic,copy)NSString* url;

@property (nonatomic, copy) NSString *zhname;
@property (nonatomic, copy) NSString *twname;
@property (nonatomic, copy) NSString *enname;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, assign) int updatetype;
@property (nonatomic, copy) NSString *all_suburl;
@property (nonatomic,assign) long long all_size;
@property (nonatomic,assign) long long all_unzipsize;
@property (nonatomic,copy) NSString *all_md5;
@property (nonatomic, copy) NSString *add_suburl;
@property (nonatomic,assign) long long add_size;
@property (nonatomic,assign) long long add_unzipsize;
@property (nonatomic,copy) NSString *add_md5;



- (long long)getNeedSize;//获取文件还未下载的大小，即所需空间大小

// 停止任务的实现
- (void)stopconnection;

// 获取文件名，从后往后找“/”定位
- (NSString *)getFilename;

-(void)DeleteTempFiles;
@end
