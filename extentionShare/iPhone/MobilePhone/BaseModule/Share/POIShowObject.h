//
//  POIShowObject.h
//  AutoNavi
//
//  Created by jiangshu.fu on 13-10-29.
//
//

#import <Foundation/Foundation.h>
#import "MWPoiOperator.h"
#import "GDPopPOI.h"

@protocol POIShowObjectDelegate <NSObject>

@optional
//搜索结束，成功和失败
- (void) afterSuccessSearch;
- (void) afterFailSearch;

@end

@interface POIShowObject : NSObject <MWPoiOperatorDelegate>

@property (nonatomic, assign) GCOORD coord;             //弹出点的中心点
@property (nonatomic, retain) GDPopPOI *popPoi;         //需要弹出框的poi框
@property (nonatomic, assign) id<POIShowObjectDelegate> delegate;   //搜索结束后委托
@property (nonatomic, assign) GMAPVIEWTYPE mapType;     //地图类型

@property (nonatomic, assign) ViewPOIType poiType;      //弹出POI的类型

- (id) initwithPopPoi:(GDPopPOI *)popPoi withCenter:(GCOORD)coord;  //初始化
- (void) show;      //调用这个函数才会显示poi弹出框
- (void) showPOI:(MWPoi*) poi;
-(void)cancel;

@end
