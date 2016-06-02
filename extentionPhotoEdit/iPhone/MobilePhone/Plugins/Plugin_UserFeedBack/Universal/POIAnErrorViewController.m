//
//  POIFeedBackViewController.m
//  AutoNavi
//
//  Created by weisheng on 14-6-9.
//
//

#import "POIAnErrorViewController.h"
#import "FeedBackImageView.h"
#import "POIOtherErrorViewController.h"
#import "POIMesErrorViewController.h"
#import "POICommon.h"
#import "UserFeedBackViewController.h"
@interface POIAnErrorViewController ()
{
    NSArray * _dataArray;
}
@property(retain,nonatomic)FeedBackImageView * trafficDescribeView;
@property(retain,nonatomic)MWPoi * POI;
@end

@implementation POIAnErrorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
-(void)dealloc
{
    CRELEASE(_dataArray);
    CRELEASE(_feedBackPoi);
    CRELEASE(_POI);
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.POI = self.feedBackPoi;
    self.title = STR(@"TS_DataFeedback", Localize_UserFeedback);
    self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    _dataArray = [[NSArray alloc]initWithObjects:STR(@"TS_NoAddress",Localize_UserFeedback),STR(@"TS_LocationError", Localize_UserFeedback),STR(@"TS_MessageError", Localize_UserFeedback),STR(@"TS_OtherError", Localize_UserFeedback), nil];
}

-(void)leftBtnEvent:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count ? _dataArray.count : 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeight2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identy = @"cellidenty";
    GDTableViewCell * cell =[tableView dequeueReusableCellWithIdentifier:identy];
    if (cell == nil) {
            cell = [[[GDTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identy] autorelease];
        }
    cell.backgroundType = BACKGROUND_FOOTER;
    cell.selectionStyle  = UITableViewCellSelectionStyleNone;
    UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png", IMAGEPATH_TYPE_1)];
    cell.accessoryView = tempimg;
    [tempimg release];
    if (_dataArray) {
        cell.textLabel.text = [_dataArray objectAtIndex:indexPath.row];
    }

    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0||indexPath.row==3)
    {
        POIOtherErrorViewController * other = [[POIOtherErrorViewController alloc]init];
        other.poi = self.feedBackPoi;
        if (indexPath.row == 0) {
            other.type = 2002;
        }else
        {
            other.type = 2000;
        }
        [self.navigationController pushViewController:other animated:YES];
        [other release];
    }
    else if (indexPath.row ==2)
    {
        POIMesErrorViewController * mengage= [[POIMesErrorViewController alloc]init];
        mengage.poi = self.POI;
        [self.navigationController pushViewController:mengage animated:YES];
        [mengage release];

    }
    else if(indexPath.row ==1)
    {
        [POICommon intoPOIViewController:self withIndex:0 withViewFlag:INTO_TYPE_ADD_FeedBack_Point withPOIArray:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
