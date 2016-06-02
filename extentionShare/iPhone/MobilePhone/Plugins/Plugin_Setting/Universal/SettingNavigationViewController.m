//
//  SettingNavigationViewController.m
//  AutoNavi
//
//  Created by huang on 13-9-2.
//
//

#import "SettingNavigationViewController.h"
#import "PluginStrategy.h"
#import "POIDefine.h"
#import "GDSwitchCell.h"
#import "GDTableViewCell.h"
#import "SettingTableCellData.h"
#import "BottomMenuBar.h"
#import "SettingSettingViewControllerTempViewController.h"

@interface SettingNavigationViewController ()<GDSwitchCellDelegate>

@end

@implementation SettingNavigationViewController

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
    CLOG_DEALLOC(self);
    [_array release];
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
    self.navigationController.navigationBarHidden=NO;
    _array=[[NSMutableArray alloc] init];
    [self initTableData];
}
-(void)initTableData
{
    __block UITableView *tableView=_tableView;
    __block MWPreference *preference=[MWPreference sharedInstance];
    __block SettingNavigationViewController *weakSelf=self;
    __block PluginStrategy *strategy=[PluginStrategy sharedInstance];

    [self allocCellData:STR(@"Setting_VoiceSetting",Localize_Setting) withType:PREF_MUTE withIsSwitch:YES withArray:_array withTouchBlock:^(id object){
       //语音播报
        GDSwitchCell * cell1 =(GDSwitchCell*)  [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        GDSwitchCell * cell2 =(GDSwitchCell*)  [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        int isOn=[object isOn];
        cell1.textLabel.textColor=  isOn?TEXTCOLOR:GETSKINCOLOR(@"TextDisableColor");
        cell2.textLabel.textColor=  isOn?TEXTCOLOR:GETSKINCOLOR(@"TextDisableColor");
        [preference setValue:PREF_MUTE Value:isOn];
        [preference setValue:PREF_SPEAKTRAFFIC Value:isOn];//语音提示跟路况播报同步
        [preference setValue:PREF_SPEAK_SAFETY Value:isOn];
        [preference setValue:PREF_SWITCHEDVOICE Value:isOn];
        [cell1.onswitch setOn:isOn animated:YES];
        [cell2.onswitch setOn:isOn animated:YES];
        [cell1.onswitch setEnabled:isOn];
        [cell2.onswitch setEnabled:isOn];
    }withDetailTitleBlock:nil];
    [self allocCellData:STR(@"Setting_SettingTrafficReplay",Localize_Setting) withType:PREF_SPEAKTRAFFIC withIsSwitch:YES withArray:_array withTouchBlock:^(id object){
        //路况播报
         [preference setValue:PREF_SPEAKTRAFFIC Value:[object isOn]];
    }withDetailTitleBlock:nil];
    [self allocCellData:STR(@"Setting_SettingCamera",Localize_Setting)withType:PREF_SPEAK_SAFETY withIsSwitch:YES withArray:_array withTouchBlock:^(id object){
        //电子眼播报
        [preference setValue:PREF_SPEAK_SAFETY Value:[object isOn]];
    }withDetailTitleBlock:nil];
    [self allocCellData:STR(@"Setting_SettingFrequency",Localize_Setting) withType:PREF_PROMPTOPTION withIsSwitch:NO withArray:_array withTouchBlock:^(id object){
        //语音频率
        [strategy allocViewControllerWithName:@"SettingFrequencyViewController" withType:0 withViewController:weakSelf];
    }withDetailTitleBlock:^(int type){
        type=type>=1?1:0;
        return [NSString stringWithFormat:@"Setting_FrequencyType%i",type];
    }];
    
    [self allocCellData:STR(@"Setting_Day/NightModesTitle",Localize_Setting) withType:PREF_MAPDAYNIGHTMODE withIsSwitch:NO withArray:_array withTouchBlock:^(id object){
        //昼夜模式
        [strategy allocViewControllerWithName:@"SettingDayAndNightViewController" withType:0 withViewController:weakSelf];
        
    }withDetailTitleBlock:^(int type){
    type = type>2?2:type;
    return [NSString stringWithFormat:@"Setting_Day/NightModes%i",type];
    }];
}
-(void)allocCellData:(NSString*)title withType:(int)type  withIsSwitch:(BOOL)isSwitch withArray:(NSMutableArray*)arr withTouchBlock:(TableCellTouchBlock)_block withDetailTitleBlock:(GetTableDetailTilteBlock) detailBlock
{
    
    [SettingTableCellData allocCellData:title withImageString:@"" withType:type withIsSwitch:isSwitch withArray:arr withTouchBlock:_block withDetailTitleBlock:detailBlock];
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 0.0f, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT)];
    [_tableView reloadData];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 0.0f, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT)];
    [_tableView reloadData];
}

//改变控件文本
-(void)changeControlText
{
    self.title=STR(@"Setting_NavigationSetting", Localize_Setting);
    self.navigationItem.leftBarButtonItem= LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    [_tableView reloadData];
}
-(void)leftBtnEvent:(id)object
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)switchAction:(id)object cell:(GDSwitchCell *)cell
{
    NSIndexPath *indexPath =  [_tableView indexPathForCell:cell];
    if(indexPath==nil)
        return;
    SettingTableCellData *dic=[_array objectAtIndex:indexPath.row];
    if (dic.isSwitch) {
        TableCellTouchBlock _block=dic.touchEventBlock;
        _block(object);
    }
}


#pragma mark -
#pragma mark UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_array count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeight2;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier_Lable = @"Cell_Lable";
    static NSString *CellIdentifier_Table = @"Cell_Table";
  
    SettingTableCellData *dic=[_array objectAtIndex:indexPath.row];
    GDTableViewCell *cell;
    GDSwitchCell *table_cell;
   if(dic.isSwitch)
   {
       
       table_cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_Table];
       if (table_cell == nil)
       {
           table_cell = [[[GDSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_Table] autorelease];
       }
       
       cell = table_cell;
       BOOL  isSwitch=[[MWPreference sharedInstance] getValue:dic.detailTitleType];
       BOOL  isprefMute=[[MWPreference sharedInstance] getValue:[(SettingTableCellData*)[_array objectAtIndex:0] detailTitleType]];
       table_cell.textLabel.textColor=TEXTCOLOR;
       if (indexPath.row!=0) {
           
           if(isprefMute == NO && indexPath.row<3)
           {
               [table_cell.onswitch setEnabled:NO ];
               [table_cell.onswitch setOn:isSwitch animated:NO];
               
               table_cell.textLabel.textColor = GETSKINCOLOR(@"TextDisableColor");
           }
           else if(isSwitch == YES && indexPath.row<3)
           {
               [table_cell.onswitch setEnabled:YES ];
               [table_cell.onswitch setOn:isSwitch animated:NO];
           }
           else
           {
               [table_cell.onswitch setOn:isSwitch animated:NO];
           }
          

       }
       else
       {
           [table_cell.onswitch setEnabled:YES ];
           [table_cell.onswitch setOn:isprefMute animated:NO];
       }
       table_cell.delegate=self;
       cell.selectionStyle = UITableViewCellSelectionStyleNone;
       cell.accessoryType = UITableViewCellAccessoryNone;

   }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_Lable];
        if (cell == nil)
        {
            cell = [[[GDTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier_Lable] autorelease];
        }
       if(indexPath.row == 3)
       {
           cell.accessoryView = [self accessoryViewWithSelectArray:[self getArraySoundFrequency]];
           cell.selectionStyle = UITableViewCellSelectionStyleNone;
       }
       else if(indexPath.row == 4)
       {
           cell.accessoryView = [self accessoryViewWithSelectArray:[self getArrayDayAndNightSwitch]];
           cell.selectionStyle = UITableViewCellSelectionStyleNone;
       }
       else
       {
           cell.selectionStyle = UITableViewCellSelectionStyleGray;
           cell.accessoryView = [[UIView alloc]init];
       }
//        int type=[[MWPreference sharedInstance] getValue:dic.detailTitleType];
//        GetTableDetailTilteBlock detailBlock = dic.getDetailBlock;
//
//        NSString* labeltext = STR(detailBlock(type), Localize_Setting);
//        [cell.detailTextLabel setText: labeltext];
//        cell.detailTextLabel.textColor=TITLECOLOR;
//        
//        UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
//		cell.accessoryView = tempimg;
//		[tempimg release];

    }
    cell.textLabel.text =dic.title;
   	cell.textLabel.textColor = TEXTCOLOR;
    if (indexPath.row==0) {
        cell.backgroundType=BACKGROUND_HEAD;
    }
    else if(indexPath.row+1==_array.count)
    {
        cell.backgroundType=BACKGROUND_FOOTER;
    }
    else
    {
        cell.backgroundType=BACKGROUND_MIDDLE;
    }
    return cell;
}


#pragma mark - ---  语音提示频率和昼夜模式  ---

//
- (UIView *) accessoryViewWithSelectArray:(NSArray *) array
{
    CGRect rect = CGRectMake(0, 0, 60 * array.count, 30);
    BottomMenuBar *tempMenuBar = [[[BottomMenuBar alloc]initWithFrame:rect] autorelease];
    [tempMenuBar SetButtonsByInfoes:[self getMenuInfoByArray:array]];
    //设置按钮的字体颜色
    [tempMenuBar setTitleColor:GETSKINCOLOR(SETTING_NORMAL_BUTTON_TITLE_COLOR) forState:UIControlStateNormal];
    [tempMenuBar setTitleColor:GETSKINCOLOR(SETTING_HIGHLIGHTED_BUTTON_TITLE_COLOR) forState:UIControlStateSelected];
    [tempMenuBar setTitleColor:GETSKINCOLOR(SETTING_HIGHLIGHTED_BUTTON_TITLE_COLOR) forState:UIControlStateHighlighted];
    //标记选中的按钮
    for (int i = 0; i < array.count; i++)
    {
        id temp = [array objectAtIndex:i];
        if([temp isKindOfClass:[SwitchInfoData class]] && ((SwitchInfoData *)temp).isSelected)
        {
            [tempMenuBar selectTag:i];
            break;
        }
    }
    return tempMenuBar;
}

- (NSArray *) getMenuInfoByArray:(NSArray *) array
{
    NSMutableArray *infoArray = [NSMutableArray arrayWithCapacity:0];
    for(int i = 0; i < array.count; i++)
    {
        id temp = [array objectAtIndex:i];
        if([temp isKindOfClass:[SwitchInfoData class]])
        {
            BottomMenuInfo *menuInfo = [[[BottomMenuInfo alloc] init] autorelease];
            menuInfo.title = ((SwitchInfoData *)temp).stringTitle ;
            if( i == 0)
            {
                menuInfo.image = IMAGE(@"CellSelectButtonFirst.png", IMAGEPATH_TYPE_1);
                menuInfo.highlightedImage = IMAGE(@"CellSelectButtonFirstPress.png", IMAGEPATH_TYPE_1);
            }
            else if(i == array.count - 1)
            {
                menuInfo.image = IMAGE(@"CellSelectButtonLast.png", IMAGEPATH_TYPE_1);
                menuInfo.highlightedImage = IMAGE(@"CellSelectButtonLastPress.png", IMAGEPATH_TYPE_1);
            }
            else
            {
                menuInfo.image = IMAGE(@"CellSelectButtonMiddle.png", IMAGEPATH_TYPE_1);
                menuInfo.highlightedImage = IMAGE(@"CellSelectButtonMiddlePress.png", IMAGEPATH_TYPE_1);
            }
            menuInfo.tag = i;
            menuInfo.buttonPress = ((SwitchInfoData *)temp).buttonPress;
            [infoArray addObject:menuInfo];
        }
    }
    return  infoArray;
}

/***
 * @name    语音提示频率
 * @param
 * @author  by bazinga
 ***/
- (NSArray *) getArraySoundFrequency
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    SwitchInfoData *infoData;
    __block UITableView *blockView = _tableView;
    int mode=[[MWPreference sharedInstance] getValue:PREF_PROMPTOPTION];
    infoData = [[SwitchInfoData alloc]initInfoData:STR(@"Setting_FrequencyType1", Localize_Setting)
                                         withPress:^(id sender) {
                                             [[MWPreference sharedInstance] setValue:PREF_PROMPTOPTION Value:1];
                                             [blockView reloadData];
                                         }
                                      withSelected:(mode == 1? YES : NO)];
    [array addObject:infoData];
    [infoData release];
    infoData = [[SwitchInfoData alloc]initInfoData:STR(@"Setting_FrequencyType0", Localize_Setting)
                                         withPress:^(id sender) {
                                             [[MWPreference sharedInstance] setValue:PREF_PROMPTOPTION Value:0];
                                             [blockView reloadData];
                                         }
                                      withSelected:(mode == 0? YES : NO)];
    [array addObject:infoData];
    [infoData release];
    return array;
}

/***
 * @name    白天黑夜自动模式开关按钮选择
 * @param
 * @author  by bazinga
 ***/
- (NSArray *) getArrayDayAndNightSwitch
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    __block UITableView *blockView = _tableView;
    SwitchInfoData *infoData;
    int mode=[[MWPreference sharedInstance] getValue:PREF_MAPDAYNIGHTMODE];
    infoData = [[SwitchInfoData alloc]initInfoData:STR(@"Setting_Day/NightModes0", Localize_Setting)
                                         withPress:^(id sender) {
                                             [[MWPreference sharedInstance] setValue:PREF_MAPDAYNIGHTMODE Value:0];
                                             [blockView reloadData];
                                         }
                                      withSelected:(mode == 0? YES : NO)];
    [array addObject:infoData];
    [infoData release];
    infoData = [[SwitchInfoData alloc]initInfoData:STR(@"Setting_Day/NightModes1", Localize_Setting)
                                         withPress:^(id sender) {
                                             [[MWPreference sharedInstance] setValue:PREF_MAPDAYNIGHTMODE Value:1];
                                             [blockView reloadData];
                                         }
                                      withSelected:(mode == 1? YES : NO)];
    [array addObject:infoData];
    [infoData release];
    infoData = [[SwitchInfoData alloc]initInfoData:STR(@"Setting_Day/NightModes2", Localize_Setting)
                                         withPress:^(id sender) {
                                             [[MWPreference sharedInstance] setValue:PREF_MAPDAYNIGHTMODE Value:2];
                                             [blockView reloadData];
                                         }
                                      withSelected:(mode == 2? YES : NO)];
    [array addObject:infoData];
    [infoData release];
    return array;
}


@end
