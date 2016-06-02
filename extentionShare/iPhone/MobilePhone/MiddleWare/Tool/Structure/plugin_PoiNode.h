//
//  plugin_PoiNode.h
//  AutoNavi
//
//  Created by huang longfeng on 12-4-19.
//  Copyright 2012 autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubCityItem : NSObject

@property(nonatomic,assign) int lAdminCode;
@property(nonatomic,copy) NSString *szAdminName;
@property(nonatomic,copy) NSString *szAdminSpell;
@property(nonatomic,assign) int lNumberOfSubAdarea;
@property(nonatomic,retain) SubCityItem *subcityItem;

@end

@interface Plugin_CityItem : NSObject

@property(nonatomic,assign) int lNumberOfAdarea;

@property(nonatomic,retain) SubCityItem *cityItem;

@end

@interface plugin_PoiNode : NSObject {

}
@property (nonatomic, assign) long lLon;
@property (nonatomic, assign) long lLat;//经纬度坐标
@property (nonatomic, assign) int lCategoryID;//类别编码，参见POI类别编码表
@property (nonatomic, assign) int lDistance;//距参考点的距离
@property (nonatomic, assign) int lMatchCode;//匹配度，表示关键字匹配程度
@property (nonatomic, assign) int lHilightFlag;//匹配高亮显示，从低位到高位匹配名称字段，最多32位
@property (nonatomic, assign) long lAdminCode;//行政编码，参见行政区域编码表
@property (nonatomic, assign) GOBJECTID stPoiId;//POI唯一ID
@property (nonatomic, assign) short lNaviLon;//导航经度坐标, 与Coord差值
@property (nonatomic, assign) short lNaviLat;//导航纬度坐标, 与Coord差值
@property (nonatomic, copy) NSString* szName;//名称
@property (nonatomic, copy) NSString* szAddr;//地址
@property (nonatomic, copy) NSString* szTel;//电话
@property (nonatomic, copy) NSString* szTown;//区域
@property (nonatomic, assign) int lPoiIndex;//POI索引，内部使用
@property (nonatomic, assign) char ucFlag;
@property (nonatomic, assign) unsigned char ucNodeType;//保留
@property (nonatomic, assign) unsigned short usNodeId;//交叉节点ID

@end
