//
//  CarServiceDetailViewController.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-3-8.
//
//

#import "ANTableViewController.h"


@protocol TaskStatusDelegate;
@class MWCarOwnerServiceTask;

@interface CarServiceDetailViewController : ANTableViewController<UIActionSheetDelegate,NetReqToViewCtrDelegate,TaskStatusDelegate>
{
    //导航条
    UINavigationBar *_navigationBar;
}

- (id) initWithCarData:(MWCarOwnerServiceTask *) serviceData;

@property (nonatomic, retain) MWCarOwnerServiceTask *serviceData;
@end
