//
//  POIDataCache.h
//  AutoNavi
//
//  Created by huang on 13-8-19.
//
//

#import <Foundation/Foundation.h>
#import "Plugin_POI.h"

typedef enum
{
    EXAMINE_POI_NO=0,                      //直接查看
    EXAMINE_POI_ADD_ADDRESS=1,             //添加地址（途径点）
    EXAMINE_POI_ADD_FAV,                   //添加兴趣点(去哪里 中的家或公司)
    EXAMINE_POI_ADD_COMMON,                //添加常用
    EXAMINE_POI_ADD_START,                 //设为起点
    EXAMINE_POI_ADD_END,                   //设为终点
    
}EXAMINE_POI_TYPE;                         //查看POI 类型

@interface POIDataCache : NSObject
@property (nonatomic,assign) EXAMINE_POI_TYPE flag;//1表示要返回当前进入界面(暂时用于添加途径点)，0表示不用返回，2表示设置家或公司地址，3表示添加常用
@property (nonatomic,assign) id<POISelectPOIDelegate> selectPOIDelegate;
@property (nonatomic,assign) UIViewController* layerController;
@property (nonatomic)int viewControllerLocation;
@property (nonatomic)int isSetHomeAddress;                                          //判断是否设置家0表示设置家，1表示公司

+(POIDataCache*)sharedInstance;
-(void)clearData;
@end
