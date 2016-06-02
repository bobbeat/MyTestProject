//
//  POIAroundViewController.h
//  AutoNavi
//
//  Created by huang on 13-8-20.
//
//

#import "ANViewController.h"
#import "MWPoiOperator.h"
#import "POIAroundTextField.h"
#import "POIKeyBoardEvent.h"
@interface POIAroundViewController : ANTableViewController<POIAroundTextFieldDelegate,POIKeyBoardEventProtocol>
{
    UIImageView *_imageView;
    int aroundSearchType;                           //设置搜索类型
    int currentCell;                    //当前打开哪个cell
    int openCellCount;                  //打开的cell里有几个子cell
    BOOL _bOpen;
    
}
@property(retain,nonatomic)NSIndexPath * indexPathName;
@property (nonatomic)BOOL isNearBy;     //1表示附近查找，0表示周边
@end
