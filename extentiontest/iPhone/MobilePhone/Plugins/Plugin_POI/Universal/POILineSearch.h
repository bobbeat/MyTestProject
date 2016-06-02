//
//  POILineSearch.h
//  AutoNavi
//
//  Created by weisheng on 14-4-4.
//
//

#import <Foundation/Foundation.h>
#import "MWPoiOperator.h"
@interface POILineSearch : NSObject<NetReqToViewCtrDelegate,MWPoiOperatorDelegate>
{
    BOOL           _bNetWorking;//当前是不是正在进行网络检索
    int            _firstTime;
    MWPoiOperator *poiOperator;
}
@property(assign,nonatomic)int  CategoryID;
@property(assign,nonatomic)GHGUIDEROUTE guideRouteHandle;
@property(retain,nonatomic)NSMutableArray * poiLineArray;

+(POILineSearch*)sharedInstance;
/*
 *沿途周边检索
 *@param 周边类别ID
 */
-(void)PLS_LineSearchKeyWorld:(int)CategoryID;


@end
