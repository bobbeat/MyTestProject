//
//  Setting_POIPriorityViewController.m
//  AutoNavi
//
//  Created by huang on 13-8-12.
//
//

#import "SettingPOIPriorityViewController.h"
#import "POIDefine.h"
@interface SettingPOIPriorityViewController ()

@end

@implementation SettingPOIPriorityViewController

#pragma mark -
#pragma mark viewcontroller ,
- (id)init
{
	self = [super init];
	if (self)
	{
		
	}
	return self;
}


- (void)dealloc
{
    [_poiConent release];
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
}
// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
  
    
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
-(void) initControl{

    _poiConent = [[NSArray alloc] initWithObjects:@"Auto",@"Fuel",@"AUTO_4S",@"Catering",@"Market",@"SuperMarket",@"Hall",@"Golf",@"KTV",@"Cinema",@"Hospital",@"Hotel",@"ScenicSpots",@"School",@"Parking",@"Bank",@"Toilet",nil];
    
    _viewFoot=[[[UIView alloc] init] autorelease];

    UILabel *headerLabel = [[[UILabel alloc] init] autorelease];
    headerLabel.frame=CGRectMake(30, -5,CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X-60 ,45);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont systemFontOfSize:kSize3];
    headerLabel.text=[NSString stringWithFormat:@"%@",STR(@"Setting_POIExplanations",Localize_Setting)];
    headerLabel.lineBreakMode=NSLineBreakByWordWrapping;
    headerLabel.numberOfLines=0;
    headerLabel.textAlignment=UITextAlignmentCenter;
    headerLabel.textColor=FOOTERCOLOR;
    headerLabel.tag=10010;
    [_viewFoot addSubview:headerLabel];
    _viewFoot.frame=CGRectMake(0, 0, APPWIDTH, 40);
    _tableView.tableFooterView=_viewFoot;


}

- (void)leftBtnEvent:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 0.0f, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT)];
    
    _viewFoot.frame=CGRectMake(0, 0, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, 50);
    [[_viewFoot viewWithTag:10010] setFrame:CGRectMake(0, -5,_viewFoot.frame.size.width ,45)];
    [_tableView reloadData];

}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 0.0f, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT)];
   
     _viewFoot.frame=CGRectMake(0, 0, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, 50);
    [[_viewFoot viewWithTag:10010] setFrame:CGRectMake(0, -5,_viewFoot.frame.size.width ,45)];
    [_tableView reloadData];


}


//改变控件文本
-(void)changeControlText
{
    self.title=STR(@"Setting_POIDisplayPriority",Localize_Setting);
      self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));

    [_tableView reloadData];
}


#pragma mark -
#pragma mark xxx delegate
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return  [_poiConent count];
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

	
    NSString *key = [NSString stringWithFormat:@"Setting_POIType%@",[_poiConent objectAtIndex:indexPath.row]];
    cell.textLabel.text =STR(key,Localize_Setting);
  
	if([[MWPreference sharedInstance] getValue:PREF_MAPPOIPRIORITY] == 0)
	{
		if(indexPath.row == 0)
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
		
		
	}
	else
	{
		int a ;
		
		
		if(indexPath.row == 0)
		{
			cell.accessoryType =  UITableViewCellAccessoryNone;
	
			cell.accessoryView = nil;
		
		}
		else if(indexPath.row == 1)
		{
			a = 1;
		}
		else
		{
			a = 0x1 << (indexPath.row - 1);
		}
		
		if(((a & [[MWPreference sharedInstance] getValue:PREF_MAPPOIPRIORITY]) == a)&&(indexPath.row != 0))
		{
			cell.accessoryType =  UITableViewCellAccessoryCheckmark;
	
			UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Checkmark.png",IMAGEPATH_TYPE_1)];
			cell.accessoryView = tempimg;
			[tempimg release];
		
		}
		else
		{
			cell.accessoryType =  UITableViewCellAccessoryNone;
		
			cell.accessoryView = nil;
		
		}
	}
    if (indexPath.row==0) {
        cell.backgroundType=BACKGROUND_HEAD;
    }
    else if(indexPath.row==_poiConent.count-1)
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
    if( indexPath.row == 0)
	{
		[[MWPreference sharedInstance] setValue:PREF_MAPPOIPRIORITY Value:0];
	}
	else
	{
        int tmp = [[MWPreference sharedInstance] getValue:PREF_MAPPOIPRIORITY];
		int a = 0x1 << (indexPath.row - 1);
		if((tmp & a)==a)
		{
			
			tmp &= ~a;
			
		}
		else
		{
			tmp |= a;
			
		}
		[[MWPreference sharedInstance] setValue:PREF_MAPPOIPRIORITY Value:tmp];
	}
	
    
	[_tableView reloadData];
	
	
}




@end
