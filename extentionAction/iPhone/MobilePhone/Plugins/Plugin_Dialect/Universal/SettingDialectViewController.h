//
//  Setting_DialectViewController.h
//  AutoNavi
//
//  Created by huang on 13-8-12.
//
//

#import "ANTableViewController.h"
@protocol TaskStatusDelegate;
@protocol  NetReqToViewCtrDelegate;
//方言选择
@interface SettingDialectViewController : ANTableViewController<TaskStatusDelegate,NetReqToViewCtrDelegate>
{
    BOOL _isDelete;
}
@end
