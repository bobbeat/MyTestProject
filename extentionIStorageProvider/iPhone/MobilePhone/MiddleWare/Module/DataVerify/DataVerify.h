//
//  DataVerify.h
//  New_GNaviServer
//
//  Created by yang yi on 12-3-31.
//  Copyright 2012 autonavi.com. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum DATAVERIFYRESULT {
    
    DATAVERITY_CHECK_SUCCESS	            = 0,   //数据检测成功
	DATAVERITY_UNCOMPRESS_CITYS_ZLIB,              //有压缩包存在
	DATAVERITY_BASE_ROAD_DATA_DOWNLAODING,         //基础资源下载中
	DATAVERITY_BASE_ROAD_DATA_NOT_EXIST,           //基础资源不存在
    
}DATAVERIFYRESULT;

@interface DataVerify : NSObject {
	
    NSArray  *zlibCitysList;           //压缩包数组
    
    BOOL isZlibOfCitysExist;           //是否有分城市压缩包
    BOOL isBaseRoadDataExist;          //是否有基础路网数据
    int  compareEngineWithMapVersion;  //比较引擎版本号与地图版本号
    BOOL isCheckFinish;                //数据检测结束
    
	DATAVERIFYRESULT dataVerifyResult; //数据检测结果
}
@property (nonatomic, retain) NSArray* zlibCitysList;

-(id)init;
#pragma mark public out 
/**进入导航程序*/
-(void) handlerEntryNaviApp;
/**继续下载数据 0:第一次进入下载 1:未下载完成在次进入下载*/
-(void) handerContinuedownLoadState:(int)mapDownState;
/**退出导航程序*/
-(void) handerQuitApplication;

#pragma mark Private 供内部调用方法
/**检测数据版本主流程*/
-(int) runCheckData;

/**验证本地是否有分城市压缩包*/
-(BOOL) checkZlibOfCitysExist;

/**验证本地是否有基础路网*/
-(BOOL) checkBaseRoadDataExist;

/**
 *获取目录下所有文件
 *rootPath:要查找的路径名称(尾部无需/),matchName:要匹配的结尾名称,nil或""则不验证匹配
 */
-(NSMutableArray*) searchFilesInPath:(NSString *)rootPath MatchContent:(NSString*)matchName;

@end
