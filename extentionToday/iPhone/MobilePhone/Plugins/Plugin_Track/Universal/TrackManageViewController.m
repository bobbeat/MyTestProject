//
//  TrackManageViewController.m
//  AutoNavi
//
//  Created by jiangshu.fu on 13-8-13.
//
//  self.title =  "轨迹管理"

#import "TrackManageViewController.h"
#import "TrackInfoViewController.h"
#import "ANOperateMethod.h"
#import	"ANParamValue.h"
#import "GDTableViewCell.h"
#import "KLSwitch.h"
#import "MWMapOperator.h"
#import "TrackMapViewController.h"
#import "ControlCreat.h"

#define Date_Key @"Date_Key"

@interface TrackManageViewController ()
{
    KLSwitch *_switchOnOff;
}

@property (nonatomic,retain) NSArray *setContentArray;

@end

@implementation TrackManageViewController
@synthesize naviBackTitle = _naviBackTitle;
@synthesize setContentArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark -
#pragma mark viewcontroller ,
- (id)initWithbackNaviTitle:(NSString *)backNaviTitle
{
	self = [super init];
	if (self)
	{
		self.naviBackTitle = backNaviTitle;
	}
	return self;
}


- (void)dealloc
{
    self.setContentArray = nil;
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
- (void)viewDidUnLoad
{
	[super viewDidLoad];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    [self initControl];
    
    self.title = STR(@"TrackManage", Localize_Track);
//    _buttonRight = RIGHTBARBUTTONITEM(STR(@"Universal_edit", Localize_Universal), @selector(editButtonPressed:));
//    self.navigationItem.rightBarButtonItem = _buttonRight;
    self.navigationItem.leftBarButtonItem = LEFTBARBUTTONITEM(self.naviBackTitle, @selector(GoBack:));
    
}
// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    [self parseFileNameWith:[MWTrack GetTrackList]];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
	
	if([self.setContentArray count] != 0)
	{
		[_buttonRight setEnabled:YES];
	}
	else
	{
		[_buttonRight setEnabled:NO];
	}
    
	[_tableView reloadData];
}
// Called when the view has been fully transitioned onto the screen. Default does nothing

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
// Called when the view is dismissed, covered or otherwise hidden. Default does nothing

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

// Called after the view was dismissed, covered or otherwise hidden. Default does nothing
-(void)viewDidDisappear:(BOOL)animated;
{
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl
{
    
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    [super changePortraitControlFrameWithImage];
    
    [_tableView reloadData];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    [super changeLandscapeControlFrameWithImage];
    [_tableView reloadData];
}

//改变控件文本
-(void)changeControlText
{
    
}

#pragma mark -
#pragma mark control action

- (void)clear_alert
{
	
    
    
}

- (void)clear_track
{
	[MWTrack TrackOperationWithID:2 Index:0];
    [_buttonRight setEnabled:NO];
    
	[self viewWillAppear:YES];
}

- (void)GoBack:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)editButtonPressed:(id)sender
{
    return;
    if([self.setContentArray count] == 0)
	{
		return;
	}
	
    if ([sender isKindOfClass:[NSNumber class]])
    {
        BOOL editing = [(NSNumber *)sender boolValue];
        if (editing)
        {
            self.navigationItem.rightBarButtonItem = RIGHTBARBUTTONITEM(STR(@"Universal_save", Localize_Universal), @selector(editButtonPressed:));
        }
        else
        {
            self.navigationItem.rightBarButtonItem = RIGHTBARBUTTONITEM(STR(@"Universal_edit", Localize_Universal), @selector(editButtonPressed:));
        }
        return;
    }
    
    
    BOOL editing;
	if ([self.navigationItem.rightBarButtonItem.title isEqualToString:STR(@"Universal_edit", Localize_Universal)])
    {
        self.navigationItem.rightBarButtonItem = RIGHTBARBUTTONITEM(STR(@"Universal_save", Localize_Universal), @selector(editButtonPressed:));
        editing = YES;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = RIGHTBARBUTTONITEM(STR(@"Universal_edit", Localize_Universal), @selector(editButtonPressed:));
        editing = NO;
    }
    
    [_tableView beginUpdates];
    [_tableView setEditing:editing animated:YES];
    [_tableView endUpdates];
}

- (void)klswithAction:(KLSwitch *)klswitch
{
        [[MWPreference sharedInstance] setValue:PREF_TRACK_RECORD Value:klswitch.isOn];//自动记录轨迹开关
    }
#pragma mark -
#pragma mark logic relate
-	(void)landscapeLogic
{
    
    
}
-	(void)portraitLogic
{
    
    
}

- (void)parseFileNameWith:(NSArray *)fileArray
{
    NSMutableArray *dateArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *timeDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *timeArray = nil;
    for (int i = [fileArray count] - 1; i >= 0; i--)
    {
        NSString *fileName = [fileArray objectAtIndex:i];
        NSString *date = nil;
        NSString *time = nil;
        if ([fileName length] >= 12)
        {
            date = [fileName substringWithRange:NSMakeRange(0, 6)];
            time = [fileName substringWithRange:NSMakeRange(6, 6)];
        }
        else
        {
            continue;
        }
        
        NSString *last_date = [dateArray lastObject];
        if ([last_date isEqualToString:date])
        {
            timeArray = [timeDictionary objectForKey:last_date];
            if (timeArray)
            {
                [timeArray addObject:[NSDictionary dictionaryWithObject:time forKey:[NSString stringWithFormat:@"%d",i]]];
            }
            else
            {
                timeArray = [NSMutableArray array];
                [timeArray addObject:[NSDictionary dictionaryWithObject:time forKey:[NSString stringWithFormat:@"%d",i]]];
                [timeDictionary setObject:timeArray forKey:date];
            }
        }
        else
        {
            [dateArray addObject:date];
            timeArray = [NSMutableArray array];
            [timeArray addObject:[NSDictionary dictionaryWithObject:time forKey:[NSString stringWithFormat:@"%d",i]]];
            [timeDictionary setObject:timeArray forKey:date];
        }
    }
    
    NSLog(@"%d",[timeDictionary count]);
    NSLog(@"%d",[dateArray count]);
    
    NSMutableArray *showArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [dateArray count]; i++)
    {
        NSString *date = [dateArray objectAtIndex:i];
        [showArray addObject:[NSDictionary dictionaryWithObject:[self getDateWith:date] forKey:Date_Key]];
        timeArray = [timeDictionary objectForKey:date];
        for (int j = 0; j < [timeArray count]; j++)
        {
            NSMutableDictionary *dic = [timeArray objectAtIndex:j];
            NSString *time = [[dic allValues] lastObject];
            time = [NSString stringWithFormat:@"%02d:%02d",[[time substringWithRange:NSMakeRange(0, 2)] intValue],[[time substringWithRange:NSMakeRange(2, 2)] intValue]];
            [showArray addObject:[NSDictionary dictionaryWithObject:time forKey:[[dic allKeys] lastObject]]];
        }
        
    }
    self.setContentArray = [NSArray arrayWithArray:showArray];
    
    [dateArray release];
    [timeDictionary release];
    [showArray release];
}

/**
 *	根据日期返回日期
 *
 *	@param	date	如，120916
 *
 *	@return	返回月日，如09.16，或今天，昨天，前天
 */
- (NSString *)getDateWith:(NSString *)date
{
    if ([date length] < 6)
    {
        return date;
    }
    
    int thisyear = 0;
    NSInteger date_month = [[date substringWithRange:NSMakeRange(2, 2)] integerValue];
    NSInteger date_day = [[date substringWithRange:NSMakeRange(4, 2)] integerValue];
    NSInteger date_year = 2000 + [[date substringWithRange:NSMakeRange(0, 2)] integerValue];
    
    NSDate *today = [NSDate date];
    NSCalendar  * cal = [NSCalendar  currentCalendar];
    NSUInteger  unitFlags = NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:today];
    NSInteger year = [conponent year];
    NSInteger month = [conponent month];
    NSInteger day = [conponent day];
    thisyear = year;
    if (year == date_year && month == date_month && day == date_day)
    {
        return STR(@"TrackToday", Localize_Track);
    }
    
    
    NSDate * yesterday = [NSDate dateWithTimeIntervalSinceNow:-86400];
    cal=[NSCalendar  currentCalendar];
    unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    conponent= [cal components:unitFlags fromDate:yesterday];
    year = [conponent year];
    month = [conponent month];
    day = [conponent day];
    if (year == date_year && month == date_month && day == date_day)
    {
        return STR(@"TrackYesterday", Localize_Track);
    }
    
    
    NSDate * beforeYesterday = [NSDate dateWithTimeIntervalSinceNow:-86400 * 2];
    cal=[NSCalendar  currentCalendar];
    unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    conponent= [cal components:unitFlags fromDate:beforeYesterday];
    year = [conponent year];
    month = [conponent month];
    day = [conponent day];
    if (year == date_year && month == date_month && day == date_day)
    {
        return STR(@"TrackBeforYesterday", Localize_Track);
    }
    
    if (abs(thisyear - date_year) > 0)
    {
        return [NSString stringWithFormat:@"%02d.%02d.%02d",date_year,date_month,date_day];
    }
    return [NSString stringWithFormat:@"%02d.%02d",date_month,date_day];
}

#pragma mark -
#pragma mark notification
-(void)notificationReceived:(NSNotification*) notification
{
    
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 55;
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    float height = [self tableView:tableView heightForHeaderInSection:section];
    CGRect lastRect = CGRectMake(0, 0, 0, height);
    return [[[UIView alloc] initWithFrame:lastRect] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kHeight2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.setContentArray count] == 0)
    {
        return 1;
    }
    return [self.setContentArray count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSLog(@"canEditRowAtIndexPath %d",indexPath.row);
    if (indexPath.row >= [self.setContentArray count])
    {
        return NO;
    }
    NSDictionary *dic = [self.setContentArray objectAtIndex:indexPath.row];
    if (![[[dic allKeys] lastObject] isEqual:Date_Key])
    {
        return YES;
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	GDTableViewCell *cell = (GDTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if( cell == nil)
	{
        cell = [[[GDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.backgroundColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
	cell.textLabel.font = [UIFont systemFontOfSize:kSize2];
    cell.accessoryView = nil;
    cell.imageView.image = nil;
    cell.textLabel.text = nil;
    cell.editing = NO;
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:112];
    if (imageView)
    {
        [imageView removeFromSuperview];
    }
    UILabel *lable = (UILabel *)[cell viewWithTag:113];
    if (lable)
    {
        [lable removeFromSuperview];
    }

        if ([self.setContentArray count] == 0)
        {
            cell.backgroundType = BACKGROUND_FOOTER;
            cell.textLabel.text = STR(@"TrackNoData",Localize_Track);
        }
        else
        {
            if([tableView numberOfRowsInSection:1]- 1 == indexPath.row)
            {
                cell.backgroundType = BACKGROUND_FOOTER;
            }
            else
            {
                cell.backgroundType = BACKGROUND_TRACK;
            }
            NSDictionary *dic = [self.setContentArray objectAtIndex:indexPath.row];
            UILabel *lable = [self createLabelWithText:[[dic allValues] lastObject] fontSize:kSize2 textAlignment:UITextAlignmentLeft];
            lable.textColor = TEXTCOLOR;
            lable.frame = CGRectMake(65, 0, cell.frame.size.width - 100, kHeight2);
            lable.tag = 113;
            [cell.contentView addSubview:lable];
            
            NSString *imageName = nil;
            if ([[[dic allKeys] lastObject] isEqual:Date_Key])
            {
                if (indexPath.row == 0)
                {
                    imageName = @"Track1.png";
                }
                else
                {
                    imageName = @"Track3.png";
                }
            }
            else
            {
                if(indexPath.row == [self.setContentArray count] - 1)
                {
                    imageName = @"TrackEnd.png";
                }
                else
                {
                    imageName = @"Track2.png";
                }
                UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
                cell.accessoryView = tempimg;
                [tempimg release];
                cell.editing = YES;
            }
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:IMAGE(imageName,IMAGEPATH_TYPE_1)];
            if(indexPath.row == [self.setContentArray count] - 1)
            {
                imageView.center = CGPointMake(30, kHeight2/2);
                UIImage *imageViewImage = IMAGE(imageName,IMAGEPATH_TYPE_1);
                imageView.frame = CGRectMake(30 - imageViewImage.size.width / 2, 0, imageViewImage.size.width, imageViewImage.size.height);
            }
            else
            {
                 imageView.center = CGPointMake(30, kHeight2/2);
            }
            imageView.tag = 112;
            [cell.contentView addSubview:imageView];
            [imageView release];
        }
	return cell;
}


- (BOOL) isNetMap:(long)lon Lat:(long)lat
{
    GCOORD pcoord ={0};
    pcoord.x = lon;
    pcoord.y = lat;
    int sign = [MWAdminCode checkIsExistDataWithCoord:pcoord];
    if (sign == 0)
    {
        //当前区域无数据
        return NO;
    }
    else if (sign == 2)
    {
        //当前区域处于海
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if ([self.setContentArray count] == 0)
        {
            return;
        }
        NSDictionary *dic = [self.setContentArray objectAtIndex:indexPath.row];
        NSString *track_name = [[dic allKeys] lastObject];
        if ([track_name isEqualToString:Date_Key])
        {
            return;
        }
        int nameIndex = [[[dic allKeys] lastObject] intValue];
        [MWTrack TrackOperationWithID:0 Index:nameIndex];
        
        GMAPCENTERINFO centerInfo = {0};
        [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:GMAP_VIEW_TYPE_MAIN mapCenterInfo:&centerInfo];
        
        if (![self isNetMap:centerInfo.CenterCoord.x Lat:centerInfo.CenterCoord.y])
        {
            [self createAlertViewWithTitle:nil
                                   message:STR(@"TrackNetWork",Localize_Track)
                         cancelButtonTitle:STR(@"TrackOK", Localize_Track)
                         otherButtonTitles:nil
                                       tag:-1];
            return;
        }
        
        [MWTrack TrackOperationWithID:4 Index:nameIndex];
        
        TrackMapViewController *ctl = [[TrackMapViewController alloc] init];
        [self.navigationController  pushViewController:ctl animated:YES];
        [ctl release];
        
    
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
        [MWTrack TrackOperationWithID:0 Index:indexPath.row];
        
        TrackInfoViewController * track_info = [[TrackInfoViewController alloc] initWithbackNaviTitle:self.title];
        track_info.trackIndex = indexPath.row;
        track_info.track_name = [self.setContentArray objectAtIndex:indexPath.row];
        [[self navigationController] pushViewController:track_info animated:YES];
        [track_info release];
}


- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self editButtonPressed:[NSNumber numberWithBool:YES]];
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self editButtonPressed:[NSNumber numberWithBool:NO]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:
(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSDictionary *dic = [self.setContentArray objectAtIndex:indexPath.row ];
        NSString *track_name = [[dic allKeys] lastObject];
        if ([track_name isEqualToString:Date_Key])
        {
            return;
        }
        int nameIndex = [[[dic allKeys] lastObject] intValue];
        
        [MWTrack TrackOperationWithID:0 Index:nameIndex];
        BOOL isLoaded = [[MWTrack TrackOperationWithID:10 Index:nameIndex] boolValue];
        if (isLoaded)
        {
            [MWTrack TrackOperationWithID:9 Index:nameIndex];
        }
        BOOL sign = [[MWTrack TrackOperationWithID:1 Index:nameIndex] boolValue];
        if (sign)
        {
            [self parseFileNameWith:[MWTrack GetTrackList]];
            
            [_tableView reloadData];
        }
        
    }
}



@end
