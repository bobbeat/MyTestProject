//
//  Setting_VersionViewController.h
//  AutoNavi
//
//  Created by huang on 13-8-12.
//
//

#import "ANViewController.h"
#import "GDBL_LaunchRequest.h"
#import<MessageUI/MFMailComposeViewController.h>
//版本介绍
@interface SettingVersionViewController : ANTableViewController<NetReqToViewCtrDelegate,MFMailComposeViewControllerDelegate>
{
    UILabel *_labelVersion,*_labelCompany;
    UIImageView *_imagViewAutonavi;
    BOOL isCheck;
   
}
@property(nonatomic,copy) NSString *updateCommand;
@end
