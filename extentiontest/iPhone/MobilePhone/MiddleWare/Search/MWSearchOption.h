//
//  MWSearchOption.h
//  AutoNavi
//
//  Created by gaozhimin on 13-7-29.
//
//

#import <Foundation/Foundation.h>

@interface MWSearchOption : NSObject
{
    
}
/*!
  @brief 检索类型
  @see GSEARCHTYPE
  */
@property (nonatomic,assign) GSEARCHTYPE operatorType;

/*!
  @brief 类别编码组合
  */
@property (nonatomic,assign) GPOICATCODE  stCatCode;

/*!
  @brief 周边检索半径，单位：米
  */
@property (nonatomic,assign) int aroundRange;

/*!
  @brief 经度坐标
  */
@property (nonatomic,assign) int longitude;

/*!
  @brief 纬度坐标
  */
@property (nonatomic,assign) int latitude;

/*!
  @brief 返回结果的排序方式 0：按匹配度(默认)，从高到低  1：按距离，从近到院
  */
@property (nonatomic,assign) int sortType;

/*!
  @brief 关键字
  */
@property (nonatomic,copy) NSString *keyWord;

/*!
  @brief 指定沿路径POI搜索类型
  @see GROUTEPOITYPE
  */
@property (nonatomic,assign) GROUTEPOITYPE routePoiTpe;

@end
