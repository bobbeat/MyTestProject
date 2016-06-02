//
//  MWPathPOI.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-4-4.
//
//

#import <Foundation/Foundation.h>

@interface MWPathPOI : NSObject

@property (nonatomic, copy) NSString *name;        //路线名称
@property (nonatomic, copy) NSString *userID;      //用户id
@property (nonatomic, copy) NSString *serviceID;   //服务器下发id，同步下来才会有，删除，修改再同步时需要上传此
@property (nonatomic, copy) NSString *operateTime; //操作时间
@property (nonatomic, assign) int operate;         //操作类型 1：新增 2：修改 3：删除 0: 同步完的状态，终端本地使用 默认值为新增
@property (nonatomic, assign) int rule;            //规划原则
@property (nonatomic, assign) int waypointCount;   //途径点个数
@property (nonatomic, retain) NSMutableArray *poiArray;//行程点数组，已MWPoi结构存储

@end
