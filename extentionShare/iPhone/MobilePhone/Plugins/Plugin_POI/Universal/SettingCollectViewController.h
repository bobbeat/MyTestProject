//
//  SettingCollectViewController.h
//  AutoNavi
//
//  Created by huang on 13-9-2.
//
//

#import "ANViewController.h"
#import "POIDefine.h"
#import "GDSetFavTableCell.h"
//数据管理




@interface SettingCollectViewController : ANTableViewController
{
    int             _isNull;
    NSMutableArray *_arrayData;
}
@property(nonatomic)SEARCH_POI_TYPE   type;
@property(nonatomic)COLLECT_INTO_TYPE intoType;
@end
