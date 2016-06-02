//
//  POIAroundListViewController.h
//  AutoNavi
//
//  Created by huang on 13-8-20.
//
//

#import "ANViewController.h"
#import "MWPoiOperator.h"
#import "MWSearchResult.h"
#import "POIAroundTextField.h"
#import "POIKeyBoardEvent.h"
@class GraphicMixedView;
@interface POIAroundListViewController : ANTableViewController<MWPoiOperatorDelegate,POIAroundTextFieldDelegate>
{
    BOOL netSearchBefore;//判断当前是先进行网络还是本地
    BOOL _bNetSearch;//当前是否是网络检索
    BOOL _bNetWorking;//当前是不是正在进行网络检索
    int _firstTime;
}
@property (nonatomic,assign) int searchType;            //0表示一级进入，如停车场，1表示二级子菜单进入，2表示关键字搜索
@property(copy,nonatomic)NSString * keyWorld;//关键字检索
-(id)initWithTitle:(NSString*)title keyName:(NSString *)titleName withPoiCategroy:(MWPoiCategory*)poicategory;
@end
