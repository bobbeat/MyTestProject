//
//  POISearchDesViewController.h
//  AutoNavi
//
//  Created by weisheng on 14-7-11.
//
//

#import "ANTableViewController.h"
#import "GDSearchListCell.h"
#import "POIDataCache.h"
@interface POISearchDesViewController : ANTableViewController
{
    int        openCellCount;//收藏加有多少个
    UIButton * _buttonNaviGation,* _buttonMap;
    UIView   * _headView;
}
@property(retain,nonatomic)NSMutableArray * arrayFavorites;
@property(retain,nonatomic)NSMutableArray * arrayDestinations;
@property(retain,nonatomic)NSIndexPath    * indexPathName;
@end
