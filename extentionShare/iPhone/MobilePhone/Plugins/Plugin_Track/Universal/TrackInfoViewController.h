//
//  TrackInfoViewController.h
//  AutoNavi
//
//  Created by jiangshu.fu on 13-8-13.
//
//

#import "ANViewController.h"

@interface TrackInfoViewController : ANViewController
{
	NSArray			*_dataSourceArray;
	UITextField		*_textFieldTrack_name;
	NSString		*track_name;
	UIButton		*_buttonTrack_replay;
    UIButton        *_buttonTrack_show;
	UIBarButtonItem *_buttonright;
    BOOL            _isLoaded;
    
    UITableView *_tableView;
}

@property (nonatomic, copy) NSString* track_name;
@property (nonatomic,assign) int trackIndex;
@property (nonatomic, retain, readonly) UITextField	*textFieldTrack_name;

@property (nonatomic,copy) NSString *naviBackTitle;

- (id) initWithbackNaviTitle:(NSString *)backNaviTitle;
@end
