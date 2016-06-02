//
//  POISearchInputViewController.h
//  AutoNavi
//
//  Created by huang on 13-8-16.
//
//

#import "ANViewController.h"
#import "POIKeyBoardEvent.h"
//输入
@class POISearchHistory;
@class POITextField;
@class POIAroundTextField;
@interface POISearchInputViewController : ANTableViewController<POIKeyBoardEventProtocol>
{
}
@property(nonatomic,copy)NSString * searchText;
@end
