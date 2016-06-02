//
//  POIDetailViewController.h
//  AutoNavi
//
//  Created by huang longfeng on 13-9-9.
//
//

#import "ANViewController.h"
typedef enum POIButtonType{
    
    POIButtonType_SetStart = 0,
    POIButtonType_SetDes,
    POIButtonType_Collect,
    POIButtonType_Call,
    POIButtonType_Home,
    POIButtonType_Company,
    POIButtonType_Share,
    POIButtonType_Error,
    
}POIButtonType;

@interface POIDetailViewController : ANTableViewController
{
    
}
- (id)initWithPOI:(MWPoi *)detailInfo;
@end
