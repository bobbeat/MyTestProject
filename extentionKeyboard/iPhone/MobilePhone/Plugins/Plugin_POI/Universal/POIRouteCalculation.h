//
//  POIGoHomeAndCompany.h
//  AutoNavi
//
//  Created by huang on 13-8-27.
//
//

#import <Foundation/Foundation.h>
//路线演算
#pragma 代理主要用于 删除添加途经点进入死循环的现象
@protocol POIDeleteNationControlDelegate <NSObject>
-(void)poiDeleteControlViewController;
@end
@interface POIRouteCalculation : NSObject
@property(nonatomic,assign)UIViewController *viewController;
@property(nonatomic,assign)UIViewController *modalViewController;
@property(nonatomic)int viewControllerCount;                            //用于判断是否在最上层
@property(assign,nonatomic)id<POIDeleteNationControlDelegate>delegate;
-(id)initWithViewController:(UIViewController*)viewController;
//多点导航 把所有的POI点放到数组
-(void)gotoNavigationWithArray:(NSMutableArray *)array;
-(void)goHome;
-(void)goCompany;
//设置目的地
-(void)setBourn:(MWPoi*)poi;
-(void)setBourn:(MWPoi *)poi withAnimate:(BOOL)_animate;

@end
