//
//  DrivingTrackListViewController.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-15.
//
//

#import "DrivingTrackListViewController.h"
#import "DringTracksManage.h"
#import "AccountPersonalCell.h"
#import "DrivingTrackDetailViewController.h"
#import "UMengEventDefine.h"

#define kTrackLineHeight  70.

@interface DrivingTrackListViewController ()
{
    UITableView *_mTableView;
}

@property (nonatomic, retain) NSMutableArray *drivingTrackArray;
@property (nonatomic, assign) int cellCount;

@end

@implementation DrivingTrackListViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [MobClick event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_TrackListCount];
    
    self.title = STR(@"DrivingTrack_drivingRecord", Localize_DrivingTrack);
    self.navigationItem.leftBarButtonItem = LEFTBARBUTTONITEM(@"", @selector(goBack));
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    self.drivingTrackArray = [[DringTracksManage sharedInstance] getDrivingInfoList];
    self.cellCount = self.drivingTrackArray ? self.drivingTrackArray.count : 0;
    
    [_tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    CRELEASE(_drivingTrackArray);
    [super dealloc];
}
- (void)initControl
{
    
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    [super changePortraitControlFrameWithImage];
    _tableView.frame = CGRectMake(0., 0., APPWIDTH, CONTENTHEIGHT_V);
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    [super changeLandscapeControlFrameWithImage];
    _tableView.frame = CGRectMake(0., 0., APPHEIGHT, CONTENTHEIGHT_H);
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row != (self.cellCount))
    {
        return kTrackLineHeight;
    }
    
    return kHeight2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.cellCount == 0) {
        return 1;
    }
    return (self.cellCount + 1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier_1 = @"Personal_CellIdentifier_1";
    static NSString *CellIdentifier_2 = @"Personal_CellIdentifier_2";
    
    AccountTrackRecordCell *cell = nil;
    AccountPersonalCell *clearAllCell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_1];
    
    if (!cell)
    {
        cell = [[[AccountTrackRecordCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_1] autorelease];
    }
    
    
    
    if (indexPath.row == self.cellCount ) {
        
        clearAllCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_2];
        if (!clearAllCell)
        {
            clearAllCell = [[[AccountPersonalCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier_2] autorelease];
        }
        
        if (self.cellCount == 0) {
            clearAllCell.seeMoreLable.hidden = YES;
            clearAllCell.textLabel.text = STR(@"DrivingTrack_noDrivingRecord", Localize_DrivingTrack);
            clearAllCell.textLabel.textColor = [UIColor blackColor];
        }
        else{
            
            clearAllCell.emptyLineLength = -1;
            clearAllCell.seeMoreLable.hidden = NO;
            clearAllCell.seeMoreLable.font = [UIFont systemFontOfSize:kSize2];
            clearAllCell.seeMoreLable.textColor = [UIColor blackColor];
            clearAllCell.seeMoreLable.text = STR(@"DrivingTrack_clearDrivingRecord", Localize_DrivingTrack);
        }
        
        return clearAllCell;
    }
    else{
        
        cell.backgroundType = BACKGROUND_FOOTER;
        
        [cell SetTrackInfo:[self.drivingTrackArray caObjectsAtIndex:indexPath.row]];
        
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.textColor = TEXTDETAILCOLOR;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (indexPath.row == self.cellCount && self.cellCount != 0) {
        
        
        __block DrivingTrackListViewController *weakSelf = self;
        
        GDAlertView *alertView=[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"DrivingTrack_clearAllDrivingRecord",Localize_DrivingTrack)];
        [alertView addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView)
         {
             [[DringTracksManage sharedInstance] removeAllDrivingTrackInfo];
             
             weakSelf.drivingTrackArray = [[DringTracksManage sharedInstance] getDrivingInfoList];
             weakSelf.cellCount = self.drivingTrackArray ? self.drivingTrackArray.count : 0;
             
             [_tableView reloadData];
         }];
        [alertView show];
        [alertView release];
        
        
        
    }
    else{
        
        DrivingInfo *trackInfo = [self.drivingTrackArray caObjectsAtIndex:indexPath.row];
        
        if (trackInfo) {
            DrivingTrackDetailViewController *viewController = [[DrivingTrackDetailViewController alloc] init];
            [viewController setValueWithDrivingTrack:trackInfo];
            [self.navigationController pushViewController:viewController animated:YES];
            [viewController release];
        }
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//滑动删除响应函数
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	DrivingInfo *info = [self.drivingTrackArray caObjectsAtIndex:indexPath.row];
    
	[[DringTracksManage sharedInstance] deleteDrivingTrackInfoWithID:info.drivingID];
    
    self.drivingTrackArray = [[DringTracksManage sharedInstance] getDrivingInfoList];
    self.cellCount = self.drivingTrackArray ? self.drivingTrackArray.count : 0;
    
    [_tableView reloadData];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return  STR(@"Universal_delete", Localize_Universal);
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
