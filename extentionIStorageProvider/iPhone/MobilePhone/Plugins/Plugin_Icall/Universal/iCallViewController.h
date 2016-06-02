//
//  iCallViewController.h
//  AutoNavi
//
//  Created by gaozhimin on 13-9-18.
//
//

#import "ANViewController.h"

@interface iCallViewController : ANTableViewController
{

    UIImageView * imageViewBG;
}
@property (nonatomic,copy) NSString *icallInfoPhone;    //用户手机号码
@property (nonatomic,copy) NSString *phoneNum; //用户手机号码
@property (nonatomic,assign) UIViewController *viewController;

@end
