//
//  CarServiceMoreViewController.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-3-8.
//
//

#import "ANViewController.h"

@interface CarServiceMoreViewController : ANTableViewController<NetReqToViewCtrDelegate>
{
    NSMutableArray *_arrayCellData;
    //导航条
    UINavigationBar *_navigationBar;
}
@end
