//
//  SettingMapSchemeTableViewController.m
//  AutoNavi
//
//  Created by longfeng.huang on 10/21/14.
//
//

#import "SettingMapSchemeTableViewController.h"
#import "plugin-cdm-TaskManager.h"
#import "plugin-cdm-Task.h"

@interface SettingMapSchemeTableViewController ()
{
    NSArray *dayNightArray;
}
@end

@implementation SettingMapSchemeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = STR(@"Setting_MapScheme", @"Setting");
    self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    
    dayNightArray = [[NSArray alloc] initWithArray:[MWDayNight getDayNightArray]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    CRELEASE(dayNightArray);
    
    [super dealloc];
}

-(void)leftBtnEvent:(id)object
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [dayNightArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeight2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    GDTableViewCell *cell = (GDTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if( cell == nil)
    {
        cell = [[[GDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSString *schemeString = [dayNightArray caObjectsAtIndex:indexPath.row];
    cell.textLabel.text = schemeString ? schemeString : @"";
    
    
    if([MWDayNight getDayNightSchemeIndex] == indexPath.row)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Checkmark.png",IMAGEPATH_TYPE_1)];
        cell.accessoryView = tempimg;
        [tempimg release];
        
    }
    else
    {
        cell.accessoryType =  UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        
    }
    
    if (indexPath.row==0) {
        cell.backgroundType=BACKGROUND_HEAD;
    }
    else if(indexPath.row==dayNightArray.count-1)
    {
        cell.backgroundType=BACKGROUND_FOOTER;
    }
    else
    {
        cell.backgroundType=BACKGROUND_MIDDLE;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GSTATUS res = [MWDayNight setDayNightSchemeWithIndex:indexPath.row];
    if (res != GD_ERR_OK)
    {
        Task *task = [[TaskManager taskManager] getTaskWithTaskID:0];
        
        if (task.updated) {
            GDAlertView *alertView=[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Setting_NotSupportScheme",Localize_Setting)];
            
            [alertView addButtonWithTitle:STR(@"Universal_cancel",Localize_Universal)
                                     type:GDAlertViewButtonTypeCancel
                                  handler:^(GDAlertView *alertView)
             {
             }];
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal)
                                     type:GDAlertViewButtonTypeDefault
                                  handler:^(GDAlertView *alertView)
             {
                 [[NSNotificationCenter defaultCenter] postNotificationName:kDataDownload object:[NSNumber numberWithInt:2]];//到下载页面
             }];
            [alertView show];
            [alertView release];
        }
        else if (task.status == TASK_STATUS_FINISH){
            
            GDAlertView *alertView=[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_basicresouce_restart",Localize_CityDownloadManage)];
            
            [alertView addButtonWithTitle:STR(@"Universal_cancel",Localize_Universal)
                                     type:GDAlertViewButtonTypeCancel
                                  handler:^(GDAlertView *alertView)
             {
             }];
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal)
                                     type:GDAlertViewButtonTypeDefault
                                  handler:^(GDAlertView *alertView)
             {
                 [[UIApplication sharedApplication] exitApplication];//退出导航
             }];
            [alertView show];
            [alertView release];
        }
        
    }
    
    [_tableView reloadData];
    
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
