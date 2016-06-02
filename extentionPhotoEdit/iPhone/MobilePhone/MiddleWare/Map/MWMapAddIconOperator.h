//
//  MWMapAddIcon.h
//  AutoNavi
//
//  Created by gaozhimin on 13-9-4.
//
//

#import <Foundation/Foundation.h>
#import "MWPoiOperator.h"

#define Fresh_Poi @"Fresh_Poi"

typedef enum IconPosition
{
    Position_Center = 0,    //将图标的中心设置在指定点
    Position_Bottom = 1,    //将图标的底部设置在指定点
}IconPosition;

@interface MWMapPoi : MWPoi

/**
 *	经纬度转换后的屏幕坐标 内部使用
 */
@property (nonatomic,assign) CGPoint scPoint;

@end

@protocol MWMapPoiAddIconDelegate <NSObject>

@optional

/**
 *	点击地图ICON响应函数
 *
 *	@param	mapPoi	点击Icon的信息
 */
- (void)tapMapPoiIconnWith:(MWMapPoi *)mapPoi;

@end

/*!
 @brief 地图添加标签图标类
 */
@interface MWMapAddIconOperator : NSObject


/**
 *	判断是否在图面上有绘制图标
 *  @parm sender 当前的MWMapAddIconOperator对象
 *	@return	有图标为yes 无图标为no
 */
+ (BOOL)ExistIconInMap:(MWMapAddIconOperator *)sender;

/**
 *	清除地图图标
 */
+(void)ClearMapIcon;


/**
 *	初始化方法
 *
 *	@param	dic	绘制信息，key为图片名称，如***.png。value为数组，存储对象为MWMapPoi
 *	@param	view	添加地图的父视图    目前此参数废弃，内部赋值
 *
 */
- (id)initWith:(NSDictionary *)dic inView:(UIView *)view  delegate:(id<MWMapPoiAddIconDelegate>)delegate;

/**
 *	重新刷新poi数组
 *
 *	@param	dic	新的poi数据
 */
- (void)freshPoiDic:(NSDictionary *)dic;

/**
 *	设置图标相对于点的位置
 *
 *	@param	position	设置的位置类型
 */
- (void)SetIconPosition:(IconPosition)position;

@end
