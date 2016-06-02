//
//  RouteSearchTpyeView.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-4-2.
//
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSInteger, SearchSelectType){
    SearchSelectType_Stations = 0,  //加油站
    SearchSelectType_Parking,   //停车场
    SearchSelectType_Toilets,   //公共厕所
    SearchSelectType_Dinning,   //餐饮
    SearchSelectType_Store,     //便利店
};


typedef void (^SelectTypeHandle)(int);

@interface RouteSearchTypeView : NSObject

/***
 * @name    显示弹出选择框的界面
 * @param   handle  --  选择的函数句柄
 * @author  by bazinga
 ***/
+ (void) showRouteSearchTypWithHandle:(SelectTypeHandle)handle;

+ (void) hiddenRouteSearchType;

@end
