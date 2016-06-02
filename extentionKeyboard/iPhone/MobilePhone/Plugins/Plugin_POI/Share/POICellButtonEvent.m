//
//  POICellButtonEvent.m
//  AutoNavi
//
//  Created by huang on 13-10-28.
//
//

#import "POICellButtonEvent.h"
#import "POIRouteCalculation.h"
#import "POIDataCache.h"
#import "GDSearchListCell.h"
@implementation POICellButtonEvent
-(id)init
{
    self=[super init];
    if (self) {
        _route=[[POIRouteCalculation alloc] initWithViewController:nil];
    }
    return self;
}
-(id)initWithViewController:(UIViewController*)viewController
{
    self=[self init];
    if (self) {
        self.viewController=viewController;
    }
    return self;
}
-(void)setViewController:(UIViewController *)viewController
{
    _viewController=viewController;
    _route.viewController=viewController;
}
-(NSIndexPath*)buttonInTableCell:(id)object withTableView:(UITableView*)tableView
{
    if ([object isKindOfClass:[GDsearchButton class]])
    {
        GDsearchButton  * button = (GDsearchButton *)object;
        NSIndexPath * indexPath =  [tableView indexPathForCell:button.buttonCell];
        return indexPath;
    }
    return nil;
}

-(void)buttonTouchEvent:(MWPoi*)poi
{
//    EXAMINE_POI_NO=0,                      //直接查看
//    EXAMINE_POI_ADD_ADDRESS,               //添加地址（途径点）
//    EXAMINE_POI_ADD_FAV,                   //添加兴趣点(去哪里 中的家或公司)
//    EXAMINE_POI_ADD_COMMON                 //添加常用
    if (poi==nil) {
        return;
    }
    EXAMINE_POI_TYPE flag=[POIDataCache sharedInstance].flag;
    if (flag==EXAMINE_POI_NO)
    {
        [self naviButtonEvent:poi];
    }
    else
    {
        [self addButtonEvent:poi];
    }
    
 
}
-(void)naviButtonEvent:(MWPoi*)poi
{
    [self naviButtonEvent:poi withAnimate:YES];
//    if (_route) {
//        [_route setBourn:poi];
//    }
}
-(void)naviButtonEvent:(MWPoi *)poi withAnimate:(BOOL)animate
{
    if (_route) {
        [_route setBourn:poi withAnimate:animate];
    }
}
-(void)addButtonEvent:(MWPoi*)poi
{
    if (poi==nil) {
        return;
    }
     EXAMINE_POI_TYPE flag=[POIDataCache sharedInstance].flag;
    //设置起点 终点 途经点
    if (flag==EXAMINE_POI_ADD_ADDRESS||flag ==EXAMINE_POI_ADD_END||flag == EXAMINE_POI_ADD_START)
    {
        MWPoi *newPoi =[[MWPoi alloc] init];
        [POICommon copyWMPoiValutToSubclass:poi withPoiSubclass:newPoi];
        
        if ([[POIDataCache sharedInstance].selectPOIDelegate respondsToSelector:@selector(selectPoi:withOperation:)]) {
             [[POIDataCache sharedInstance].selectPOIDelegate selectPoi:newPoi withOperation:2];
        }
        [self.viewController.navigationController popToViewController:[POIDataCache sharedInstance].layerController animated:NO ];
        [[POIDataCache sharedInstance] clearData];
        [newPoi release];

        
    }
    else if(flag==EXAMINE_POI_ADD_COMMON)
    {
        NSLog(@"添加常用");
    }
    else if(flag==EXAMINE_POI_ADD_FAV)
    {
        MWPoi *newPoi =[[MWPoi alloc] init];
        [POICommon copyWMPoiValutToSubclass:poi withPoiSubclass:newPoi];
        if ([[POIDataCache sharedInstance].selectPOIDelegate respondsToSelector:@selector(selectPoi:withOperation:)]) {
            [[POIDataCache sharedInstance].selectPOIDelegate selectPoi:newPoi withOperation:2];
        }
        [self.viewController.navigationController popToViewController:[POIDataCache sharedInstance].layerController animated:NO ];
        [[POIDataCache sharedInstance] clearData];
        [newPoi release];

    }
}
-(void)dealloc
{
    CRELEASE(_route);
    CLOG_DEALLOC(self);
    [super dealloc];
}
@end
