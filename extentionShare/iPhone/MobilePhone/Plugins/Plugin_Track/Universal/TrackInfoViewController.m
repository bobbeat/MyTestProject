//
//  TrackInfoViewController.m
//  AutoNavi
//
//  Created by jiangshu.fu on 13-8-13.
//
//  self.title =  "轨迹详情"

#import "TrackInfoViewController.h"
#import "ANOperateMethod.h"
#import "ANParamValue.h"
#import "stdio.h"
#import "MWMapOperator.h"

#define kLeftMargin				20.0

@interface TrackInfoViewController ()

@end

@implementation TrackInfoViewController

#define kTextFieldWidth	260.0
@synthesize  textFieldTrack_name = _textFieldTrack_name,track_name;
@synthesize trackIndex;
@synthesize naviBackTitle = _naviBackTitle;

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
- (id) initWithbackNaviTitle:(NSString *)backNaviTitle
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
    [_textFieldTrack_name release];
	_textFieldTrack_name = NULL;
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
    self.title = STR(@"TrackInfo", Localize_Track);
    [self _textFieldTrack_name];
    _dataSourceArray = [NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             STR(@"TrackName", Localize_Track), @"sectionTitleKey",
                             @"", @"sourceKey",
//                             self._textFieldTrack_name, @"viewKey",
                             nil],
                            nil];
    
    self.navigationItem.leftBarButtonItem = LEFTBARBUTTONITEM(self.naviBackTitle, @selector(GoBack:));
    _buttonright = RIGHTBARBUTTONITEM(STR(@"TracKDele", Localize_Track), @selector(delete_alert));
    self.navigationItem.rightBarButtonItem = _buttonright;
    
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
    _tableView = [self createTableViewWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.backgroundColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
    _tableView.backgroundView = nil;
    
    [self.view addSubview:_tableView];
    
     _buttonTrack_replay = [UIButton buttonWithType:UIButtonTypeCustom];
     _buttonTrack_replay.titleLabel.font = [UIFont boldSystemFontOfSize:kSize2];
     [_buttonTrack_replay setTitle:STR(@"TrackReplay", Localize_Track) forState:UIControlStateNormal];
     [_buttonTrack_replay addTarget:self action:@selector(Replay:)
            forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:_buttonTrack_replay];
     [_buttonTrack_replay setTitleColor:GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR) forState:(UIControlState)UIControlStateNormal];
     UIImage *buttonImageNormal1 = IMAGE(@"button_back2_1.png", IMAGEPATH_TYPE_1);
     UIImage *stretchableButtonImageNormal = [buttonImageNormal1 stretchableImageWithLeftCapWidth:8 topCapHeight:0];
     [_buttonTrack_replay setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
     UIImage *buttonImagePressed = IMAGE(@"button_back2_2.png",IMAGEPATH_TYPE_1);
     UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:8 topCapHeight:0];
     [_buttonTrack_replay setBackgroundImage:stretchableButtonImagePressed forState:(UIControlState)UIControlStateHighlighted];
     
     _buttonTrack_show = [UIButton buttonWithType:UIButtonTypeCustom];
     _buttonTrack_show.titleLabel.font = [UIFont boldSystemFontOfSize:kSize2];
     _isLoaded = [[MWTrack TrackOperationWithID:10 Index:self.trackIndex] boolValue];
     
     if(_isLoaded)
     {
         [_buttonTrack_show setTitle:STR(@"TrackClose", Localize_Track) forState:(UIControlState)UIControlStateNormal];
     }
     else
     {
         [_buttonTrack_show setTitle:STR(@"TrackOpen", Localize_Track) forState:(UIControlState)UIControlStateNormal];
     }
     [_buttonTrack_show addTarget:self action:@selector(ShowTrack:)
          forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:_buttonTrack_show];
     [_buttonTrack_show setTitleColor:GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR) forState:(UIControlState)UIControlStateNormal];
     
     [_buttonTrack_show setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
     
     [_buttonTrack_show setBackgroundImage:stretchableButtonImagePressed forState:(UIControlState)UIControlStateHighlighted];
    
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    if(isiPhone)
    {
        [_buttonTrack_replay setFrame:CGRectMake(0.0f, 0.0f, APPWIDTH-20.0, 50.0f)];
        [_buttonTrack_replay setCenter:CGPointMake(APPWIDTH/2.0, 100.0f)];
        [_buttonTrack_show setFrame:CGRectMake(0.0f, 0.0f, APPWIDTH-20.0, 50.0f)];
        [_buttonTrack_show setCenter:CGPointMake(APPWIDTH/2.0, 170.0f)];
        [_textFieldTrack_name setFrame:CGRectMake(kLeftMargin, 14.0, APPWIDTH-60.0 , kHeight2 - 15)];
    }
    else
    {
        [_buttonTrack_replay setFrame:CGRectMake(0.0f, 0.0f, APPWIDTH-83.0, 50.0f)];
        [_buttonTrack_replay setCenter:CGPointMake(APPWIDTH/2.0+3.0, 115.0f)];
        [_buttonTrack_show setFrame:CGRectMake(0.0f, 0.0f, APPWIDTH-83.0, 50.0f)];
        [_buttonTrack_show setCenter:CGPointMake(APPWIDTH/2.0+3.0, 185.0f)];
        [_textFieldTrack_name setFrame:CGRectMake(kLeftMargin, 14.0, APPWIDTH-128.0, kHeight2 - 15)];
    }
    _tableView.frame = self.view.bounds;
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    if(isiPhone)
    {
        [_buttonTrack_replay setFrame:CGRectMake(0.0f, 0.0f, APPHEIGHT-20.0, 50.0f)];
        [_buttonTrack_replay setCenter:CGPointMake(APPHEIGHT/2.0, 100.0f)];
        [_buttonTrack_show setFrame:CGRectMake(0.0f, 0.0f, APPHEIGHT-20.0, 50.0f)];
        [_buttonTrack_show setCenter:CGPointMake(APPHEIGHT/2.0, 170.0f)];
        [_textFieldTrack_name setFrame:CGRectMake(kLeftMargin , 14.0, APPHEIGHT-60.0, kHeight2 - 15)];
    }
    else
    {
        [_buttonTrack_replay setFrame:CGRectMake(0.0f, 0.0f, APPHEIGHT-89.0, 50.0f)];
        [_buttonTrack_replay setCenter:CGPointMake(APPHEIGHT/2.0+1.0, 115.0f)];
        [_buttonTrack_show setFrame:CGRectMake(0.0f, 0.0f, APPHEIGHT-89.0, 50.0f)];
        [_buttonTrack_show setCenter:CGPointMake(APPHEIGHT/2.0+1.0, 185.0f)];
        [_textFieldTrack_name setFrame:CGRectMake(kLeftMargin , 14.0, APPHEIGHT-130.0, kHeight2 - 15)];
    }
    _tableView.frame = self.view.bounds;
}

//改变控件文本
-(void)changeControlText
{
    
}

#pragma mark -
#pragma mark control action
- (void)delete_alert
{
    NSArray *array = [[NSArray alloc] initWithObjects:STR(@"TrackCancel", Localize_Track),STR(@"TrackOK", Localize_Track), nil];
	[self createAlertViewWithTitle:nil
                           message:STR(@"TrackIsDel",Localize_Track)
                 cancelButtonTitle:nil
                 otherButtonTitles:array
                               tag:2];
    [array release];
}

- (void)delete_track
{
    _isLoaded = [[MWTrack TrackOperationWithID:10 Index:self.trackIndex] boolValue];
    if (_isLoaded)
    {
        [MWTrack TrackOperationWithID:9 Index:self.trackIndex];
    }
	[MWTrack TrackOperationWithID:1 Index:0];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)GoBack:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)Nav:(id)sender
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark logic relate
-	(void)landscapeLogic
{
    
    
}
-	(void)portraitLogic
{
    
    
}

-(void)Replay:(id)sender
{
	[[MWMapOperator sharedInstance] MW_SetMapOperateType:4];
	[self.navigationController popToRootViewControllerAnimated:YES];
}


-(void)ShowTrack:(id)sender
{

    _isLoaded = [[MWTrack TrackOperationWithID:10 Index:self.trackIndex] boolValue];
    BOOL tmp;
    if(_isLoaded)//关闭轨迹
    {
        tmp = [[MWTrack TrackOperationWithID:9 Index:self.trackIndex] boolValue];
        if (tmp == YES)
        {
            [_buttonTrack_show setTitle:STR(@"TrackOpen", Localize_Track) forState:(UIControlState)UIControlStateNormal];
        }
    }
    else//加载轨迹
    {
        tmp = [[MWTrack TrackOperationWithID:4 Index:self.trackIndex] boolValue];
        if (tmp == YES)
        {
            [_buttonTrack_show setTitle:STR(@"TrackClose", Localize_Track) forState:(UIControlState)UIControlStateNormal];
        }
    }
    _isLoaded = [[MWTrack TrackOperationWithID:10 Index:self.trackIndex] boolValue];
}



#pragma mark -
#pragma mark notification
-(void)notificationReceived:(NSNotification*) notification
{
    
}

#pragma mark -
#pragma mark ---  get TextField  ---
- (UITextField *)_textFieldTrack_name
{
	if(nil == _textFieldTrack_name)
	{
		NSString *name = [NSString stringWithString:track_name];
        
		_textFieldTrack_name = [[UITextField alloc] init];
		_textFieldTrack_name.borderStyle = UITextBorderStyleNone;
		_textFieldTrack_name.textColor = GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR);
		_textFieldTrack_name.font = [UIFont systemFontOfSize:kSize1];
		_textFieldTrack_name.text =name;
		_textFieldTrack_name.backgroundColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
		_textFieldTrack_name.autocorrectionType = UITextAutocorrectionTypeNo;
		_textFieldTrack_name.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
		_textFieldTrack_name.keyboardType = UIKeyboardTypeDefault;
		_textFieldTrack_name.returnKeyType = UIReturnKeyDone;
		_textFieldTrack_name.clearButtonMode = UITextFieldViewModeWhileEditing;
		_textFieldTrack_name.tag = 1;
		_textFieldTrack_name.delegate = self;
	}
	return _textFieldTrack_name;
}


#pragma mark -
#pragma mark ---  uitableview datasource  ---
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kHeight2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"any_cell"];
	if( cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any_cell"] autorelease];
	}
	cell.textLabel.font = [UIFont systemFontOfSize:22];
	cell.textLabel.textColor = GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR);
    cell.backgroundColor = GETSKINCOLOR(TRACK_INFOCELL_BACK_COLOR);
    
	if(indexPath.row == 0)
	{
		UITextField *textField = self._textFieldTrack_name;
		textField.font = [UIFont systemFontOfSize:16];
		[cell.contentView addSubview:textField];
	}
	[cell.textLabel setBackgroundColor:GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR)];
	return cell;
}

- (NSInteger)numberOfSectionInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

#pragma mark -
#pragma mark ---  uitableview delegate  ---
#pragma mark -
#pragma mark ---  UIAlert delegate  ---
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 2)
	{
		switch(buttonIndex)
		{
			case 1:
				[self delete_track];
				break;
			default:
				break;
				
		}
		
	}
}

#pragma mark -
#pragma mark ---  UITextField delegate  ---
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	if(strlen(NSSTRING_TO_CSTRING(_textFieldTrack_name.text)) == 0)
	{
        [self createAlertViewWithTitle:STR(@"TrackNameNull", Localize_Track)
                               message:nil
                     cancelButtonTitle:STR(@"TrackBack", Localize_Track)
                     otherButtonTitles:nil
                                   tag:17];

        _textFieldTrack_name.text = [NSString stringWithString:track_name];
		return NO;
		
	}
	if ([_textFieldTrack_name.text length] > 0)
	{
		if(strlen(NSSTRING_TO_CSTRING(_textFieldTrack_name.text))>30)
		{
			[self createAlertViewWithTitle:STR(@"TrackLimitLength", Localize_Track)
                                   message:nil
                         cancelButtonTitle:STR(@"TrackBack", Localize_Track)
                         otherButtonTitles:nil
                                       tag:18];
            _textFieldTrack_name.text = [NSString stringWithString:track_name];
			return NO;
		}
		
	}
    
	BOOL isEqual = NO;
	NSArray *myArray = [NSArray arrayWithArray:[MWTrack GetTrackList]];
	for (NSString* obj in myArray)
	{
		if ([_textFieldTrack_name.text isEqualToString:obj]&&![_textFieldTrack_name.text isEqualToString:track_name])
		{
			isEqual = YES;
			break;
		}
	}
	
	if (NO==isEqual)
	{
		track_name = [NSString stringWithString:_textFieldTrack_name.text];
//		[[MWGuideOperator sharedInstance] MW_EditTrackName:track_name];
		return YES;
	}
	else
	{
        [self createAlertViewWithTitle:STR(@"TrackHasExist", Localize_Track)
                               message:nil
                     cancelButtonTitle:STR(@"TrackBack", Localize_Track)
                     otherButtonTitles:nil
                                   tag:18];
		return NO;
	}
}

@end
