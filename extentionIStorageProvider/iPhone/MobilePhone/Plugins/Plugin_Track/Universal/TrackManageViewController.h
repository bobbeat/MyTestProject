//
//  TrackManageViewController.h
//  AutoNavi
//
//  Created by jiangshu.fu on 13-8-13.
//
//

#import "ANViewController.h"

@interface TrackManageViewController : ANTableViewController
{
	UIBarButtonItem *_buttonRight;
}

@property (nonatomic,copy) NSString *naviBackTitle;

- (id) initWithbackNaviTitle:(NSString *)backNaviTitle;

@end
