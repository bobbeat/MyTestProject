//
//  MWCityDownloadMapDataList.h
//  AutoNavi
//
//  Created by yaying.xiao on 14-7-15.
//
//

#import <Foundation/Foundation.h>
#import "SectionInfo.h"

enum {
    FORCE_UPDATE_ALL            = 0,    // 强制更新基础资源和不匹配
    FORCE_UPDATE_FOUNDATION     = 1,    // 强制更新基础资源
//    FORCE_UPDATE_NOMATCH        = 2,    // 强制更新不匹配数据
    ONLY_UPDATE_FOUNDATION      = 3,    // 只有基础资源有更新
   UPDATE_MAPADATA,
    
    //以上是旧分支
    MAPDATA_UPDATE             ,    // 除了基础资源以外有更新
    NO_UPDATE                   ,     // 无更新
    FOUNDATION_FORCE_UPDATE_ALL,
    FOUNDATION_FORCE_UPDATE_PART,
    FOUNDATION_UPDATE_PART,
    FOUNDATION_UPDATE_ALL,
    
};

@interface MWCityDownloadMapDataList : NSObject<NetRequestExtDelegate>
{
    NSMutableArray *mapdatalist;
    NSMutableArray *tempdatalist;
    NSMutableArray *nocrosslist;
    id<NetReqToViewCtrDelegate> ReqMapDataListDelegate;
    BOOL isLoading;
    BOOL isModifying;//下载列表正在解析中,tempdatalist正在修改中
}

//@property (nonatomic ,assign) id<MapDataListDelegate> delegate;
@property (nonatomic, assign) id<NetReqToViewCtrDelegate> ReqMapDataListDelegate;
@property (atomic, assign) BOOL isLoading;//是否在请求下载列表中


-(NSArray*)getMapDataList;
- (void)getMapDataListWithUrl:(NSString *)dataUrl;
-(BOOL) comperMapVersion:(int)adcode version:(NSString*)version;
-(NSArray*)getNoCrossVersions;


//数据列表请求完毕，检查数据更新，根据结果进行强制更新或者一般更新
//返回值：强制更新全部数据;强制更新基础资源;只更新基础资源;基础资源和城市有更新;无更新
-(int)checkMapadataUpdate;

//获取已下载的各个城市的版本信息
//返回排重后的版本列表
-(NSArray *) getLocalMapVersions;
-(SectionInfo *) GetBasicResourceSectionInfo;

- (BOOL) GetBasicResourceStatus;

+(id) citydownloadMapDataList;//单例模式
//+(void)releaseInstance;
- (UIViewController *)getCurrentRootViewController;
@end
