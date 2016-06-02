//
//  POICellButtonEvent.h
//  AutoNavi
//
//  Created by huang on 13-10-28.
//
//

#import <Foundation/Foundation.h>
#import "POIRouteCalculation.h"
@interface POICellButtonEvent : NSObject
@property(nonatomic,assign)UIViewController *viewController;
@property (nonatomic,readonly)POIRouteCalculation *route;
-(id)initWithViewController:(UIViewController*)viewController;
-(NSIndexPath*)buttonInTableCell:(id)object withTableView:(UITableView*)tableView;
-(void)buttonTouchEvent:(MWPoi*)poi;
-(void)naviButtonEvent:(MWPoi*)poi;
-(void)naviButtonEvent:(MWPoi *)poi withAnimate:(BOOL)animate;
-(void)addButtonEvent:(MWPoi*)poi;
@end
