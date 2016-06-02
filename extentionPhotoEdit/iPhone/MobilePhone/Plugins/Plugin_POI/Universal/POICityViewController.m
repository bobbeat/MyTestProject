//
//  POICityViewController.m
//  AutoNavi
//
//  Created by huang on 13-8-16.
//
//

#import "POICityViewController.h"
#import "POIDefine.h"
@interface POICityViewController ()
{
    MWAreaList *_areaList;
}
@end

@implementation POICityViewController


#pragma mark -
#pragma mark viewcontroller ,
- (id)init
{
	self = [super init];
	if (self)
	{
        GSTATUS ret = [MWPoiOperator AbortSearchPOI];
        if (ret==GD_ERR_OK) {
            NSLog(@"取消成功");
        }
	}
	return self;
}


- (void)dealloc
{
    [_areaList release];
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    [self initControl];
}

#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl{
       
    _areaList = [[MWAdminCode GetAdareaListFlag:ADAREA_DATA_WHOLE admincode:0] retain];
    _arrayCityData = _areaList.pAdareaArray;
    NSLog(@"%@",_arrayCityData);
}
//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 0.0f, APPWIDTH-2*CCOMMON_TABLE_X, CONTENTHEIGHT_V)];
    [_tableView reloadData];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 0.0f, APPHEIGHT-2*CCOMMON_TABLE_X, CONTENTHEIGHT_H)];
    [_tableView reloadData];
}
//改变控件文本
-(void)changeControlText
{
    self.title=STR(@"POI_ProvinceSettings",Localize_POI);
    self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
}
-(void)leftBtnEvent:(id)object
{
    MWArea *area = [_arrayCityData firstObject];
    if (area)
    {
        _arrayCityData = area.superArray;
        if (_arrayCityData)
        {
            MWArea * temp = [_arrayCityData firstObject];
            if (temp.superArray)
            {
                self.title=STR(@"POI_CitySettings",Localize_POI);
            }
            else
            {
                self.title=STR(@"POI_ProvinceSettings",Localize_POI);
            }
            [_tableView reloadData];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)rightBtnEvent:(id)object
{
    
}



#pragma mark -
#pragma mark xxx delegate
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return  _arrayCityData.count?_arrayCityData.count:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kHeight2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section==0?CCTABLE_VIEW_HEAD_HEIGHT:CCTABLE_VIEW_SPACE_HEIGHT;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [view setBackgroundColor:[UIColor clearColor]];
    return view;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	GDTableViewCell *cell = (GDTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if( cell == nil)
	{
        cell = [[[GDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
    MWArea * area = [_arrayCityData caObjectsAtIndex:indexPath.row];
    cell.textLabel.text = area.szAdminName;

    cell.textLabel.backgroundColor=[UIColor clearColor];
    cell.backgroundType = BACKGROUND_FOOTER;
    cell.accessoryView=[[[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)] autorelease];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MWArea * temp = [_arrayCityData caObjectsAtIndex:indexPath.row];
    if ([temp.pSubAdareaArray count] <= 1)
    {
        [MWAdminCode SetCurAdarea:temp.lAdminCode];
        [ANParamValue sharedInstance].isSelectCity = 1;
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    _arrayCityData = temp.pSubAdareaArray;
    self.title=STR(@"POI_CitySettings",Localize_POI);
	[_tableView reloadData];
	[_tableView setContentOffset:CGPointMake(0, 0) animated:NO];
	
}

@end
