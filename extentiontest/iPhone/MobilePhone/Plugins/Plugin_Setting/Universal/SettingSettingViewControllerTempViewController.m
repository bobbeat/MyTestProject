//
//  SettingSettingViewControllerTempViewController.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-5-21.
//
//

#import "SettingSettingViewControllerTempViewController.h"
#import "GDTableCellArray.h"
#import "GDTableCellData.h"
#import "POITableHeadView.h"
#import "GDSkinColor.h"
#import "MWPreference.h"
#import "UMengEventDefine.h"
#import "PluginStrategy.h"
#import "BottomMenuBar.h"
#import "MWDialectDownloadTask.h"
#import "MWDialectDownloadManage.h"
#import "GDBL_LaunchRequest.h"
#import "VCCustomNavigationBar.h"
#import "XMLDictionary.h"
#import "KLSwitch.h"
#import "Plugin_UserFeedBack.h"
#import "GDActionSheet.h"
#import "MWApp.h"
#import "SettingSinaWeiboViewController.h"
#import "GDSettingTabelCell.h"
#import "MWTTS.h"


@implementation SwitchInfoData

- (id) initInfoData:(NSString*)title
          withPress:(BottomButoonPress) buttonPress
{
    self = [super  init];
    if(self)
    {
        self.stringTitle = title;
        self.buttonPress = buttonPress;
        self.isSelected = NO;
        self.fontSize = -1;
    }
    return self;
}

- (id) initInfoData:(NSString*)title
          withPress:(BottomButoonPress) buttonPress
       withSelected:(BOOL) select
{
    self = [self initInfoData:title withPress:buttonPress];
    if(self)
    {
        self.isSelected = select;
    }
    return self;
}

- (id) initInfoData:(NSString*)title
          withPress:(BottomButoonPress) buttonPress
       withSelected:(BOOL) select
       withFontSize:(CGFloat) fontSize
{
    self = [self initInfoData:title withPress:buttonPress withSelected:select];
    if(self)
    {
        self.fontSize = fontSize;
    }
    return self;
}

- (void) dealloc
{
    CRELEASE(_stringTitle);
    CRELEASE(_buttonPress);

    [super dealloc];
}

@end

#pragma mark - ---  设置界面  ---


@interface SettingSettingViewControllerTempViewController ()
{
    NSMutableArray *_arrayData;
    BOOL isCheck;
}

@end

@implementation SettingSettingViewControllerTempViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initControl];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
    //換背景色
    [self reloadBackgroundImage];;
    //換導航條背景
    [(VCCustomNavigationBar*)self.navigationController.navigationBar refeshBackground];
    //換導航條的標題顏色
    self.title=STR(@"Setting_Setting",Localize_Setting);
    self.navigationItem.leftBarButtonItem = LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    CRELEASE(_arrayData);
    [super dealloc];
}

#pragma mark - ---  初始化界面的控件  ---
//初始化控件
-(void) initControl
{
    self.title=STR(@"Setting_Setting",Localize_Setting);
    self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    //初始化数据
    [self initCellData];
    [_tableView reloadData];
}

- (void) initCellData
{
    
    __block UINavigationController *navigationController=self.navigationController;
    __block SettingSettingViewControllerTempViewController *weakSelf=self;
    __block PluginStrategy *strategy=[PluginStrategy sharedInstance];

    GDTableCellData * tempData;
    GDTableCellArray *cellArray;
    _arrayData = [[NSMutableArray alloc]initWithCapacity:0];
   // 地图下载
   cellArray = [[GDTableCellArray alloc]initWithHeader:nil];
   tempData = [GDTableCellData getTableCellDataByIconString:nil
                                        withTitle:@"Setting_MapDownload"
                                          withAccessoryView:^UIView *(){
                                              return [weakSelf accessoryViewDefault];
                                          }
                                   withHeightCell:-1
                                   withTouchEvent:^(id object) {
                                       [MobClick event:UM_EVENTID_SETTING_COUNT label:UM_LABEL_SETTING_DownData];
                                       [weakSelf intoModule:@"CityDownLoadModule" withObject:@{@"controller":navigationController,@"parma":@"HasData"}];
                                   }
                                  withDetailTitle:^NSString *{
                                      return  @"";
                                  }
               
                                ];
    [cellArray.arrayCellData addObject:tempData];
    
    [_arrayData addObject:cellArray];
    [cellArray release];
    //*显示设置
    cellArray = [[GDTableCellArray alloc]initWithHeader:nil];
    //显示设置 -- 昼夜模式
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_Day/NightModesTitle"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf accessoryViewWithSelectArray:[weakSelf getArrayDayAndNightSwitch]];
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  @"";
                                             }
                                                  withSelect:NO];
    [cellArray.arrayCellData addObject:tempData];
    
    //显示设置 -- 地图配色
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_MapScheme"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf accessoryViewDefault];
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  [strategy allocViewControllerWithName:@"SettingMapSchemeTableViewController" withType:0 withViewController:weakSelf];
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  [self getMapSchemeText];
                                             }
                                                  withSelect:NO];
    [cellArray.arrayCellData addObject:tempData];
    
    //显示设置 -- 字体
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_FontSizeTitle"
                                           withAccessoryView:^UIView *(){
                                               return  [weakSelf fontSizeWithBottomMenuBar:[weakSelf getFontSizeSwitch] ];
                                              
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  @"";
                                             }
                                                  withSelect:NO];
    [cellArray.arrayCellData addObject:tempData];
    
    //显示设置 -- 街区详图
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_BuildingFootprint"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf getArrayNeighborhoodsSwitch];
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  @"";
                                             }
                                                  withSelect:NO];
    [cellArray.arrayCellData addObject:tempData];

    
    //显示设置 -- 地点优先显示
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_DisplayPriority"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf accessoryViewDefault];
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  [MobClick event:UM_EVENTID_SETTING_COUNT label:UM_LABEL_SETTING_Prioritize];
                                                  [weakSelf pushViewController:@"SettingPOIPriorityViewController"];
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  @"";
                                             } ];
    [cellArray.arrayCellData addObject:tempData];
    
     [_arrayData addObject:cellArray];
    [cellArray release];
    
    //后台导航设置
    cellArray = [[GDTableCellArray alloc]initWithHeader:nil];
    //后台导航设置 -- 后台导航开关
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_NaviInBackground"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf getArrayNaviInBackgroundSwitch];
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  @"";
                                             }
                                                  withSelect:NO];
    [cellArray.arrayCellData addObject:tempData];
    [_arrayData addObject:cellArray];
    [cellArray release];
    
    //*声音设置
    cellArray = [[GDTableCellArray alloc]initWithHeader:nil];
    //声音设置 -- 语音
    int soundSection = _arrayData.count;
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_VoiceSetting"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf getArrayBroadcastSwitch:soundSection];
//                                               return  nil;
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  @"";
                                             }
                                                  withSelect:NO];
    [cellArray.arrayCellData addObject:tempData];
    
    //声音设置 -- 语音类别
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_SettingVoiceChoice"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf accessoryViewDefault];
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  [strategy allocViewControllerWithName:@"SettingDialectViewController" withType:0 withViewController:weakSelf];
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  [weakSelf voiceType];
                                             } ];
    [cellArray.arrayCellData addObject:tempData];
    
    //声音设置 -- 路况播报
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_SettingTrafficReplay"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf getArrayRoadSpeakSwitch];
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  @"";
                                             }
                                                  withSelect:NO];
    [cellArray.arrayCellData addObject:tempData];
    
    //声音设置 -- 语音提示频率
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_SettingFrequency"
                                           withAccessoryView:^UIView *(){
                                               return  [weakSelf accessoryViewWithSelectArray:[weakSelf getArraySoundFrequency]];
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  
                                              }
                                             withDetailTitle:^NSString *{
                                                 return @"";
                                             }
                                                  withSelect:NO];
    [cellArray.arrayCellData addObject:tempData];
    
    //声音设置 -- 电子眼播报
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_SettingCamera"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf getArrayEyeSpeakSwitch] ;
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  @"";
                                             }
                                                  withSelect:NO];
    [cellArray.arrayCellData addObject:tempData];
    
    //声音设置 -- 欢迎语  &  结束语
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_Welcome"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf getArrayWelcomeSwitch] ;
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  @"";
                                             }
                                                  withSelect:NO];
    [cellArray.arrayCellData addObject:tempData];
    
    [_arrayData addObject:cellArray];
    [cellArray release];
    //*控制
     cellArray = [[GDTableCellArray alloc]initWithHeader:nil];
    
    //控制 -- 语言选择
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_SettingLanguage"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf accessoryViewWithSelectArray:[weakSelf getArrayLanguageType]];
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  
                                              }
                                             withDetailTitle:^NSString *{
                                                 return @"";
                                             }
                                                  withSelect:NO];
    [cellArray.arrayCellData addObject:tempData];
    
    //控制 -- 优先联网搜索
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_OnlineSearch"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf getArraySearchSwitch] ;
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  @"";
                                             }
                                                  withSelect:NO];
    [cellArray.arrayCellData addObject:tempData];
    
    //控制 -- 地点信息即时显示
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_SettingPopUp"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf getArrayPoiPopSwitch];
                                               
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  @"";
                                             }
                                                  withSelect:NO];
    [cellArray.arrayCellData addObject:tempData];
    
    //控制 -- 电子罗盘
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_SettingElectronicCompass"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf getArrayEcompassSwitch] ;
                                             
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  @"";
                                             }
                                                  withSelect:NO];
    [cellArray.arrayCellData addObject:tempData];
    //控制 --  自动打分开关
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_AutoScore"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf getArrayAutoScore] ;
                                               
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
 
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  @"";
                                             }
                                                  withSelect:NO];
    [cellArray.arrayCellData addObject:tempData];
    //控制 --  自动缩放
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_AutoZoom"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf getArrayAutoZoom] ;
                                               
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  @"";
                                             }
                                                  withSelect:NO];
    [cellArray.arrayCellData addObject:tempData];
    //控制 --  轨迹文件
    tempData = [GDTableCellData getTableCellDataByIconString:nil
                                                   withTitle:@"Setting_TrackManagements"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf accessoryViewDefault] ;
                                               
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  [MobClick event:UM_EVENTID_SETTING_COUNT label:UM_LABEL_SETTING_TrackRecording];
                                                  [weakSelf intoModule:@"Plugin_Track" withObject:@{@"controller":navigationController,@"backNaviTitle":STR(@"Setting_Setting", Localize_Setting)}];
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  @"";
                                             }
                                                  withSelect: YES];
    [cellArray.arrayCellData addObject:tempData];
    
    [_arrayData addObject:cellArray];
    [cellArray release];
    //检查更新
    cellArray = [[GDTableCellArray alloc]initWithHeader:nil];
    tempData = [GDTableCellData getTableCellDataByIconString: nil
                                                   withTitle:@"Setting_SettingCheckingUpdate"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf accessoryViewDefault];
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  [weakSelf checkUpdate];
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  @"";
                                             } ];
    [cellArray.arrayCellData addObject:tempData];
    
    
    //问题反馈
    tempData = [GDTableCellData getTableCellDataByIconString: nil
                                                   withTitle:@"Setting_SettingFeedBack"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf accessoryViewDefault];
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  [MobClick event:UM_EVENTID_SETTING_COUNT label:UM_LABEL_SETTING_Feedback];
                                                  Plugin_UserFeedBack * user  = [[Plugin_UserFeedBack alloc]init];
                                                  NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                                                  [dic setObject:@"1" forKey:@"controllertype"];
                                                  [dic setObject:weakSelf forKey:@"controller"];
                                                  [user enter:dic];
                                                  [user release];
                                                  //[weakSelf intoModule:@"Plugin_TrafficStatus" withObject:@{@"controller":navigationController,@"param":@"TS_Second"}];

                                              }
                                             withDetailTitle:^NSString *{
                                                 return  @"";
                                             } ];
    [cellArray.arrayCellData addObject:tempData];
    
    //给个好评
    tempData = [GDTableCellData getTableCellDataByIconString: nil
                                                   withTitle:@"Setting_SettingRate"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf accessoryViewDefault];
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  [MobClick event:UM_EVENTID_SETTING_COUNT label:UM_LABEL_SETTING_Rate];
                                                  [ANOperateMethod rateToAppStore:1];
                                              }
                                             withDetailTitle:^NSString *{
                                                 return  @"";
                                             } ];
    [cellArray.arrayCellData addObject:tempData];
    
    //关于
    tempData = [GDTableCellData getTableCellDataByIconString: nil
                                                   withTitle:@"Setting_SettingAbout"
                                           withAccessoryView:^UIView *(){
                                               return [weakSelf accessoryViewDefault];
                                           }
                                              withHeightCell:-1
                                              withTouchEvent:^(id object) {
                                                  //关于高德
                                                  [MobClick event:UM_EVENTID_SETTING_COUNT label:UM_LABEL_SETTING_About];
                                                  [weakSelf pushViewController:@"SettingVersionViewController"];
                                              }
                                             withDetailTitle:^NSString *{
                                                 return SOFTVERSION;
                                             } ];
    [cellArray.arrayCellData addObject:tempData];
    [_arrayData addObject:cellArray];
    [cellArray release];
    cellArray = [[GDTableCellArray alloc]initWithHeader:@"Setting_SettingReset" withFoot:nil];

    [_arrayData addObject:cellArray];
    [cellArray release];
    
}

- (UIImageView *) accessoryViewDefault
{
    return [[[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)] autorelease];
}

//cell 的 title header  视图
- (UIView *) headerViewWithTitle:(NSString *)title
{
    POITableHeadView *headView=[[[POITableHeadView alloc] initWithTitle:STR(title,Localize_Setting)] autorelease];
    [headView downMove];
    return headView;
}
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


- (UIView *) fontSizeWithBottomMenuBar:(NSArray *) array
{
    id  tempView = [self accessoryViewWithSelectArray:array];
    if([tempView isKindOfClass:[BottomMenuBar class]])
    {
        for (int i = 0; i < array.count; i++)
        {
            id temp = [array objectAtIndex:i];
            if([temp isKindOfClass:[SwitchInfoData class]] && ((SwitchInfoData *)temp).fontSize != -1)
            {
                [((BottomMenuBar *)tempView) setTitleFont:[UIFont
                                                           systemFontOfSize:((SwitchInfoData *)temp).fontSize]
                                                  withTag:i];
            }
        }
    }
    return tempView;
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

-(void)leftBtnEvent:(id)object
{
    if (isCheck) {
       
        [[GDBL_LaunchRequest sharedInstance] Net_CancelRequestWithType:RT_LaunchRequest_SoftWareUpdate];
        
    }
    [self.navigationController popViewControllerAnimated:YES];
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
    [super changePortraitControlFrameWithImage];
    [_tableView reloadData];
    
}

-(void)pushViewController:(NSString*)viewControllerName
{
    [[PluginStrategy sharedInstance] allocViewControllerWithName:viewControllerName withType:0 withViewController:self];
}

#pragma mark -  ---  推出新的界面  ---
-(void)intoModule:(NSString *)moduleName withObject:(NSObject*)object
{
    [[PluginStrategy sharedInstance] allocModuleWithName:moduleName withObject:object];
}

#pragma mark -
#pragma mark tableView datasource
#pragma mark ---  tableView的栏目数   ----
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _arrayData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int total = 0;
    id  tempObject = [_arrayData objectAtIndex:section];
    if([tempObject isKindOfClass:[GDTableCellArray class]])
    {
        total += ((GDTableCellArray *)tempObject).arrayCellData.count;
    }
    return total;
}

/***
 * @name    tableView的标题
 * @param
 * @author  by bazinga
 ***/
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view;
    if( ((GDTableCellArray *)[_arrayData objectAtIndex:section]).stringHeader == nil)
    {
        view=[[[UIView alloc] init] autorelease];
        [view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
        [view setBackgroundColor:[UIColor clearColor]];
        view.userInteractionEnabled = NO;
    }
    else
    {
        NSString *string = ((GDTableCellArray *)[_arrayData objectAtIndex:section]).stringHeader;
        POITableHeadView *headView=[[[POITableHeadView alloc] initWithTitle:STR(string,Localize_Setting)] autorelease];
        [headView downMove];
        view = headView;
        
        if(_arrayData.count - 1 == section)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button setBackgroundImage:IMAGE(@"SettingResetBackGround.png", IMAGEPATH_TYPE_1)
                              forState:UIControlStateNormal];
            [button setBackgroundImage:IMAGE(@"SettingResetBackGroundPress.png", IMAGEPATH_TYPE_1)
                              forState:UIControlStateHighlighted];
            [button setTitleColor:GETSKINCOLOR(SETTING_RESET_BUTTON_COLOR) forState:UIControlStateNormal];
            [button setTitle:STR(string,Localize_Setting) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(resetSettingAlert) forControlEvents:UIControlEventTouchUpInside];
            view = button;
        }
    }
    
    return view;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = nil;
    if(((GDTableCellArray *)[_arrayData objectAtIndex:section]).stringFoot == nil)
    {
        view=[[[UIView alloc] init] autorelease];
        [view setBackgroundColor:[UIColor clearColor]];
    }
    else
    {
        NSString *stringFoot = ((GDTableCellArray *)[_arrayData objectAtIndex:section]).stringFoot;
        UILabel *label = [[[UILabel alloc]init] autorelease];
        label.text = STR(stringFoot,Localize_Setting);
        view = label;
    }
    return view;
}


#pragma mark ---  cell的高度，标题 title 的高度  ---
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kHeight2 + 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 20.0f;
    if( ((GDTableCellArray *)[_arrayData objectAtIndex:section]).stringHeader != nil)
    {
        height=52;
    }
    return  height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 0;
    if( ((GDTableCellArray *)[_arrayData objectAtIndex:section]).stringFoot != nil)
    {
        height=10;
    }
    return  height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier_Lable = @"Cell_Lable";
    
    GDSettingTabelCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_Lable];
    if (cell == nil)
    {
        cell = [[[GDSettingTabelCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier:CellIdentifier_Lable] autorelease];
    }
    GDTableCellArray *cellArray = ((GDTableCellArray *)[_arrayData
                                                        objectAtIndex:indexPath.section]);
    GDTableCellData *cellData = [cellArray.arrayCellData
                                 objectAtIndex:indexPath.row];
    
    cell.textLabel.text = STR(cellData.stringTitle, Localize_Setting);
    cell.imageView.image = (cellData.stringIcon == nil) ? nil : IMAGE(cellData.stringIcon, IMAGEPATH_TYPE_1);
    [cell.detailTextLabel setText:cellData.blockDetail()];
    cell.accessoryView = cellData.viewAccessory();
    if(cellData.blockShowNewIcon)
    {
        if(cellData.blockShowNewIcon() == YES)
        {
            [self addNewIcon:cell.accessoryView];
        }
    }
    cell.detailTextLabel.textColor= GETSKINCOLOR(SETTING_CELL_DETAIL_TEXT_COLOR);
    if(cellData.isCanSelect)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //设置 cell 的类型
    
    if(indexPath.row == 0)
    {
        if (indexPath.row != cellArray.arrayCellData.count - 1)
        {
            cell.backgroundType = BACKGROUND_HEAD;
        }
        else
        {
            cell.backgroundType = BACKGROUND_FOOTER;
        }
    }
    else if (indexPath.row != cellArray.arrayCellData.count - 1)
    {
        cell.backgroundType = BACKGROUND_MIDDLE;
    }
    else
    {
        if(_arrayData.count - 2 == indexPath.section)
        {
            cell.backgroundType = BACKGROUND_MIDDLE;
        }
        else
        {
            cell.backgroundType = BACKGROUND_FOOTER;
        }
    }

    return cell;
}

-(void)addNewIcon:(UIView *)view
{
    UIImageView *imageView=[[UIImageView alloc] initWithImage:IMAGE(@"shareNewImage.png",IMAGEPATH_TYPE_1) ];
    imageView.center=CGPointMake(view.center.x-25, view.center.y);
    [view addSubview:imageView];
    [imageView release];
}

#pragma mark - ---  tableview delegate  ---
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    GDTableCellArray *cellArray = ((GDTableCellArray *)[_arrayData
                                                        objectAtIndex:indexPath.section]);
    GDTableCellData *cellData = [cellArray.arrayCellData
                                 objectAtIndex:indexPath.row];
    CellTouchEventBlock _block=cellData.blockTouchEvent;
    _block(nil);
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - ---  语音类别  ---
- (NSString *)voiceType
{
    int language=[[MWPreference sharedInstance] getValue:PREF_UILANGUAGE];
    NSString *dialectKey=nil;
    Role_Player role = [[MWPreference sharedInstance] getValue:PREF_TTSROLEINDEX];
    int type = 0;
    if(language==2)//英语
    {
        type=role==Role_Catherine?0:1;
        dialectKey= [NSString stringWithFormat:@"Setting_DialectType%i",type];
    }
    else
    {
        if([[MWPreference sharedInstance] getValue:PREF_IS_LZLDIALECT] == 0)
        {
            dialectKey= [NSString stringWithFormat:@"Setting_DialectType%i",type];
        }
        else
        {
            MWDialectDownloadTask *task = [[MWDialectDownloadManage sharedInstance] getTaskWithTaskID:[[MWPreference sharedInstance] getValue:PREF_IS_LZLDIALECT]];
            dialectKey = [[MWDialectDownloadManage sharedInstance] getDialectTitle:task.title];
        }
    }
    return STR(dialectKey, Localize_Setting);
}

- (NSString *)getMapSchemeText
{
    NSString *schemeString = @"";
    int schemeIndex = [MWDayNight getDayNightSchemeIndex];
    NSArray *array = [MWDayNight getDayNightArray];
    
    if (array) {
        schemeString = [array caObjectsAtIndex:schemeIndex];
    }

    return schemeString;
}
#pragma mark -  ---  开关按钮切换  ---

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
                                             [MobClick event:UM_EVENTID_Preferences_COUNT label:UM_LABEL_Preferences_LightMode];
                                             [[MWPreference sharedInstance] setValue:PREF_MAPDAYNIGHTMODE Value:0];
                                             [blockView reloadData];
                                         }
                                      withSelected:(mode == 0? YES : NO)];
    [array addObject:infoData];
    [infoData release];
    infoData = [[SwitchInfoData alloc]initInfoData:STR(@"Setting_Day/NightModes1", Localize_Setting)
                                         withPress:^(id sender) {
                                             [MobClick event:UM_EVENTID_Preferences_COUNT label:UM_LABEL_Preferences_NightMode];
                                             [[MWPreference sharedInstance] setValue:PREF_MAPDAYNIGHTMODE Value:1];
                                             [blockView reloadData];
                                         }
                                      withSelected:(mode == 1? YES : NO)];
    [array addObject:infoData];
    [infoData release];
    infoData = [[SwitchInfoData alloc]initInfoData:STR(@"Setting_Day/NightModes2", Localize_Setting)
                                         withPress:^(id sender) {
                                              [MobClick event:UM_EVENTID_Preferences_COUNT label:UM_LABEL_Preferences_AutoMode];
                                             [[MWPreference sharedInstance] setValue:PREF_MAPDAYNIGHTMODE Value:2];
                                             [blockView reloadData];
                                         }
                                      withSelected:(mode == 2? YES : NO)];
    [array addObject:infoData];
    [infoData release];
    return array;
}

/***
 * @name    字体大小开关按钮选择
 * @param
 * @author  by bazinga
 ***/
- (NSArray *) getFontSizeSwitch
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    __block UITableView *blockView = _tableView;
    SwitchInfoData *infoData;
    int mode= [[MWPreference sharedInstance] getValue:PREF_FONTSIZE];
    
    infoData = [[SwitchInfoData alloc]initInfoData:STR(@"Setting_FontSize0", Localize_Setting)
                                         withPress:^(id sender) {
                                             [MobClick event:UM_EVENTID_Preferences_COUNT
                                                       label:UM_LABEL_Preferences_LargeFont];
                                             [[MWPreference sharedInstance] setValue:PREF_FONTSIZE Value:2];
                                             [blockView reloadData];
                                         }
                                      withSelected:(mode == 0? YES : NO)
                                      withFontSize:14.0f];
    [array addObject:infoData];
    [infoData release];
    
    infoData = [[SwitchInfoData alloc]initInfoData:STR(@"Setting_FontSize1", Localize_Setting)
                                         withPress:^(id sender) {
                                              [MobClick event:UM_EVENTID_Preferences_COUNT
                                                        label:UM_LABEL_Preferences_MidFont];
                                             [[MWPreference sharedInstance] setValue:PREF_FONTSIZE Value:1];
                                             [blockView reloadData];
                                         }
                                      withSelected:(mode == 1? YES : NO)
                                      withFontSize:12.0f];
    [array addObject:infoData];
    [infoData release];
    
    infoData = [[SwitchInfoData alloc]initInfoData:STR(@"Setting_FontSize2", Localize_Setting)
                                         withPress:^(id sender) {
                                             [MobClick event:UM_EVENTID_Preferences_COUNT
                                                       label:UM_LABEL_Preferences_SmallFont];
                                             [[MWPreference sharedInstance] setValue:PREF_FONTSIZE Value:0];
                                             [blockView reloadData];
                                         }
                                      withSelected:(mode == 2? YES : NO)
                                      withFontSize:10.0f];
    [array addObject:infoData];
    [infoData release];
    
    
    return array;
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
 * @name    语言选择
 * @param
 * @author  by bazinga
 ***/
- (NSArray *) getArrayLanguageType
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    SwitchInfoData *infoData;
    __block SettingSettingViewControllerTempViewController *blockSelf = self;
    int mode=[[MWPreference sharedInstance] getValue:PREF_UILANGUAGE];
    infoData = [[SwitchInfoData alloc]initInfoData:@"简体中文"
                                         withPress:^(id sender) {
                                             [blockSelf setLanguageWithType:0];
                                         }
                                      withSelected:(mode == 0? YES : NO)];
    [array addObject:infoData];
    [infoData release];
    infoData = [[SwitchInfoData alloc]initInfoData:@"繁體中文"
                                         withPress:^(id sender) {
                                             [blockSelf setLanguageWithType:1];
                                         }
                                      withSelected:(mode == 1? YES : NO)];
    [array addObject:infoData];
    [infoData release];
    infoData = [[SwitchInfoData alloc]initInfoData:@"English"
                                         withPress:^(id sender) {
                                             [blockSelf setLanguageWithType:2];
                                         }
                                      withSelected:(mode == 2? YES : NO)];
    [array addObject:infoData];
    [infoData release];
    return array;
}

- (void) setLanguageWithType:(int) type
{
    
    int currentLanguage =[[MWPreference sharedInstance] getValue:PREF_UILANGUAGE];
    if (currentLanguage != type) {//切换字体后，数据下载列表重新下载
        [ANParamValue sharedInstance].isParseFinish = NO;
        if(currentLanguage == 1 || currentLanguage == 0)
        {
            if(type == 2)
            {
                [[MWDialectDownloadManage sharedInstance] switchTTSPathWithTaskID:0];
            }
        }
        else
        {
            if(type == 1 || type == 0)
            {
                [[MWDialectDownloadManage sharedInstance] switchTTSPathWithTaskID:0];
            }
        }
    }
    
    [[MWPreference sharedInstance] setValue:PREF_SETLANGUAGEMANUALLY Value:YES];
	if (type == 0) {
        //        中文简体--语言设置
        [MobClick event:UM_EVENTID_Preferences_COUNT label:UM_LABEL_Preferences_Hans];
		[[MWPreference sharedInstance] setValue:PREF_UILANGUAGE Value:PREF_LANGUAGE_SIMPLE_CHINESE];
        //換導航條的標題顏色
        self.title=STR(@"Setting_Setting",Localize_Setting);
	}
	else if(type == 1){
        //        中文繁体--语言设置
        [MobClick event:UM_EVENTID_Preferences_COUNT label:UM_LABEL_Preferences_Hant];
		[[MWPreference sharedInstance] setValue:PREF_UILANGUAGE Value:PREF_LANGUAGE_TRADITIONAL_CHINESE];
        //換導航條的標題顏色
        self.title=STR(@"Setting_Setting",Localize_Setting);
	}
    else{
        //        英文--语言设置
        [MobClick event:UM_EVENTID_Preferences_COUNT label:UM_LABEL_Preferences_English];
        [[MWPreference sharedInstance] setValue:PREF_UILANGUAGE Value:PREF_LANGUAGE_ENGLISH];
        //換導航條的標題顏色
        self.title=STR(@"Setting_Setting",Localize_Setting);
    }
    [_tableView reloadData];
}

/***
 * @name    街区详图
 * @param
 * @author  by bazinga
 ***/
- (UIView *) getArrayNeighborhoodsSwitch
{
    CGRect frame = CGRectMake(0, 0, 51, 31);
     KLSwitch *klswitch = [[KLSwitch alloc] initWithFrame:frame didChangeHandler:^(BOOL isOn)
                                  {
                                      if(isOn)
                                      {
                                          [MobClick event:UM_EVENTID_Preferences_COUNT label:UM_LABEL_Preferences_OpenBlock];
                                          [[MWPreference sharedInstance] setValue:PREF_MAP_CONTENT Value:GMAP_CONTENT_GL_MIX];
                                      }
                                      else
                                      {
                                          [MobClick event:UM_EVENTID_Preferences_COUNT label:UM_LABEL_Preferences_CloseBlock];
                                          
                                          [[MWPreference sharedInstance] setValue:PREF_MAP_CONTENT Value:GMAP_CONTENT_NOBLOCK];
                                      }
                                    }];
    int mode=[[MWPreference sharedInstance] getValue:PREF_MAP_CONTENT];
    klswitch.on = (mode == GMAP_CONTENT_GL_MIX ? YES:NO);
    [klswitch setOnTintColor:SWITCHCOLOR];
    return [klswitch autorelease];
}

/***
 * @name    摇晃地图切换配色
 * @param
 * @author  by bazinga
 ***/
- (UIView *) getArrayMapColorSwitch
{
    CGRect frame = CGRectMake(0, 0, 51, 31);
    KLSwitch *klswitch = [[KLSwitch alloc] initWithFrame:frame didChangeHandler:^(BOOL isOn)
                          {
                              if(isOn)
                              {
                                  [[MWPreference sharedInstance] setValue:PREF_SHAKETOCHANGETHEME Value:1];
                              }
                              else
                              {
                                  
                                  [[MWPreference sharedInstance] setValue:PREF_SHAKETOCHANGETHEME Value:0];
                              }
                          }];
    int mode=[[MWPreference sharedInstance] getValue:PREF_SHAKETOCHANGETHEME];
    klswitch.on = (mode == 1 ? YES:NO);
    [klswitch setOnTintColor:SWITCHCOLOR];
    return [klswitch autorelease];
}

/***
 * @name    自动打分
 * @param
 * @author  by bazinga
 ***/
- (UIView *) getArrayAutoScore
{
    CGRect frame = CGRectMake(0, 0, 51, 31);
    KLSwitch *klswitch = [[KLSwitch alloc] initWithFrame:frame didChangeHandler:^(BOOL isOn)
                          {
                              if(isOn)
                              {
                                  [[MWPreference sharedInstance] setValue:PREF_AUTODRIVINGTRACK Value:0];
                              }
                              else
                              {
                                  
                                  [[MWPreference sharedInstance] setValue:PREF_AUTODRIVINGTRACK Value:1];
                              }
                          }];
    int mode=[[MWPreference sharedInstance] getValue:PREF_AUTODRIVINGTRACK];
    klswitch.on = (mode == 0 ? YES:NO);
    [klswitch setOnTintColor:SWITCHCOLOR];
    return [klswitch autorelease];
}

/***
 * @name    自动缩放
 * @param
 * @author  by hlf
 ***/
- (UIView *) getArrayAutoZoom
{
    CGRect frame = CGRectMake(0, 0, 51, 31);
    KLSwitch *klswitch = [[KLSwitch alloc] initWithFrame:frame didChangeHandler:^(BOOL isOn)
                          {
                              if(isOn)
                              {
                                  [[MWPreference sharedInstance] setValue:PREF_AUTOZOOM Value:1];
                              }
                              else
                              {
                                  
                                  [[MWPreference sharedInstance] setValue:PREF_AUTOZOOM Value:0];
                              }
                          }];
    int mode=[[MWPreference sharedInstance] getValue:PREF_AUTOZOOM];
    klswitch.on = (mode == 1 ? YES:NO);
    [klswitch setOnTintColor:SWITCHCOLOR];
    return [klswitch autorelease];
}

- (void) setValueBroadcast:(BOOL)isOn withSection:(int)section
{
    if(isOn)
    {
        [[MWPreference sharedInstance] setValue:PREF_MUTE Value:1];
        [[MWPreference sharedInstance] setValue:PREF_SPEAKTRAFFIC Value:1];
        [[MWPreference sharedInstance] setValue:PREF_SPEAK_SAFETY Value:1];
        [[MWPreference sharedInstance] setValue:PREF_SWITCHEDVOICE Value:1];
        
    }
    else
    {
        [[MWPreference sharedInstance] setValue:PREF_MUTE Value:0];
        [[MWPreference sharedInstance] setValue:PREF_SPEAKTRAFFIC Value:0];
        [[MWPreference sharedInstance] setValue:PREF_SPEAK_SAFETY Value:0];
        [[MWPreference sharedInstance] setValue:PREF_SWITCHEDVOICE Value:0];
    }
    
    //语音播报 ---  路况播报，电子眼播报，欢迎语&结束语  -- 获取的 cell 的
    GDTableViewCell * cell1 =(GDTableViewCell* )  [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:section]];
    GDTableViewCell * cell2 =(GDTableViewCell* )  [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:section]];
    GDTableViewCell * cell3 =(GDTableViewCell* )  [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:section]];
    
    [((KLSwitch *)cell1.accessoryView) setOn:isOn animated:YES];
    [((KLSwitch *)cell2.accessoryView) setOn:isOn animated:YES];
    [((KLSwitch *)cell3.accessoryView) setOn:isOn animated:YES];
    [((KLSwitch *)cell1.accessoryView) setEnabled:isOn];
    [((KLSwitch *)cell2.accessoryView) setEnabled:isOn];
    [((KLSwitch *)cell3.accessoryView) setEnabled:isOn];
}

/***
 * @name    语音
 * @param
 * @author  by bazinga
 ***/
- (UIView *) getArrayBroadcastSwitch:(int) section
{
    
    CGRect frame = CGRectMake(0, 0, 51, 31);
    __block SettingSettingViewControllerTempViewController *blockSelf = self;
    KLSwitch *klswitch = [[KLSwitch alloc] initWithFrame:frame];
    
    int mode=[[MWPreference sharedInstance] getValue:PREF_MUTE];
    klswitch.didChangeHandler = nil;
    klswitch.on = (mode == 1 ? YES:NO);
    klswitch.didChangeHandler = ^(BOOL isOn){
        [blockSelf setValueBroadcast:isOn withSection:section];
        
    };
    
    [klswitch setOnTintColor:SWITCHCOLOR];
    return [klswitch autorelease];
}

/***
 * @name    欢迎语&结束语
 * @param
 * @author  by bazinga
 ***/
- (UIView *) getArrayWelcomeSwitch
{
    CGRect frame = CGRectMake(0, 0, 51, 31);
    KLSwitch *klswitch = [[KLSwitch alloc] initWithFrame:frame didChangeHandler:^(BOOL isOn)
                          {
                              if(isOn)
                              {
                                  [[MWPreference sharedInstance] setValue:PREF_SWITCHEDVOICE Value:1];
                              }
                              else
                              {
                                  [[MWPreference sharedInstance] setValue:PREF_SWITCHEDVOICE Value:0];
                              }
                          }];
    int isOpen = [[MWPreference sharedInstance] getValue:PREF_MUTE ];
    if(isOpen == 0)
    {
        [[MWPreference sharedInstance] setValue:PREF_SWITCHEDVOICE Value:0];
        klswitch.enabled = NO;
    }
    int mode=[[MWPreference sharedInstance] getValue:PREF_SWITCHEDVOICE];
    klswitch.on = (mode == 1 ? YES:NO);
    [klswitch setOnTintColor:SWITCHCOLOR];
    return [klswitch autorelease];
}

/***
 * @name    路况播报
 * @param
 * @author  by bazinga
 ***/
- (UIView *) getArrayRoadSpeakSwitch
{
    CGRect frame = CGRectMake(0, 0, 51, 31);
    int isOpen = [[MWPreference sharedInstance] getValue:PREF_MUTE ];
    KLSwitch *klswitch = [[KLSwitch alloc] initWithFrame:frame didChangeHandler:^(BOOL isOn)
                          {
                              if(isOn)
                              {
                                  [[MWPreference sharedInstance] setValue:PREF_SPEAKTRAFFIC Value:1];
                              }
                              else
                              {
                                  [[MWPreference sharedInstance] setValue:PREF_SPEAKTRAFFIC Value:0];
                              }
                          }];
    if(isOpen == 0)
    {
        [[MWPreference sharedInstance] setValue:PREF_SPEAKTRAFFIC Value:0];
        klswitch.enabled = NO;
    }
    int mode=[[MWPreference sharedInstance] getValue:PREF_SPEAKTRAFFIC];
    klswitch.on = (mode == 1 ? YES:NO);
    [klswitch setOnTintColor:SWITCHCOLOR];
    return [klswitch autorelease];
}

/***
 * @name    电子眼播报
 * @param
 * @author  by bazinga
 ***/
- (UIView *) getArrayEyeSpeakSwitch
{
    
    CGRect frame = CGRectMake(0, 0, 51, 31);
    KLSwitch *klswitch = [[KLSwitch alloc] initWithFrame:frame didChangeHandler:^(BOOL isOn)
                          {
                              if(isOn)
                              {
                                  [[MWPreference sharedInstance] setValue:PREF_SPEAK_SAFETY Value:1];
                              }
                              else
                              {
                                  [[MWPreference sharedInstance] setValue:PREF_SPEAK_SAFETY Value:0];
                              }
                          }];
    int isOpen = [[MWPreference sharedInstance] getValue:PREF_MUTE ];
    if(isOpen == 0)
    {
        [[MWPreference sharedInstance] setValue:PREF_SPEAK_SAFETY Value:0];
        klswitch.enabled = NO;
    }
    int mode=[[MWPreference sharedInstance] getValue:PREF_SPEAK_SAFETY];
    klswitch.on = (mode == 1 ? YES:NO);
    [klswitch setOnTintColor:SWITCHCOLOR];
    return [klswitch autorelease];
}

/***
 * @name    优先网络搜索
 * @param
 * @author  by bazinga
 ***/
- (UIView *) getArraySearchSwitch
{
    
    CGRect frame = CGRectMake(0, 0, 51, 31);
    KLSwitch *klswitch = [[KLSwitch alloc] initWithFrame:frame didChangeHandler:^(BOOL isOn)
                          {
                              if(isOn)
                              {
                                  [[MWPreference sharedInstance] setValue:PREF_SEARCHTYPE Value:0];
                              }
                              else
                              {
                                  [[MWPreference sharedInstance] setValue:PREF_SEARCHTYPE Value:1];
                              }
                          }];
    int mode=[[MWPreference sharedInstance] getValue:PREF_SEARCHTYPE];
    klswitch.on = (mode == 0 ? YES:NO);
    [klswitch setOnTintColor:SWITCHCOLOR];
    return [klswitch autorelease];
}
/***
 * @name    地点信息即可显示
 * @param
 * @author  by bazinga
 ***/
- (UIView *) getArrayPoiPopSwitch
{
    
    CGRect frame = CGRectMake(0, 0, 51, 31);
    __block SettingSettingViewControllerTempViewController *blockSelf = self;
    KLSwitch *klswitch = [[KLSwitch alloc] initWithFrame:frame didChangeHandler:^(BOOL isOn)
                          {
                              if(isOn)
                              {
                                  [MobClick event:UM_EVENTID_Preferences_COUNT label:UM_LABEL_Preferences_OpenAutoObtain];
                                  [[MWPreference sharedInstance] setValue:PREF_AUTO_GETPOIINFO Value:1];
                              }
                              else
                              {
                                  [MobClick event:UM_EVENTID_Preferences_COUNT label:UM_LABEL_Preferences_CloseAutoObtain];
                                  [blockSelf warningMessageBox];
                              }
                          }];
    int mode=[[MWPreference sharedInstance] getValue:PREF_AUTO_GETPOIINFO];
    klswitch.on = (mode == 1 ? YES:NO);
    [klswitch setOnTintColor:SWITCHCOLOR];
    return [klswitch autorelease];
}

- (void) warningMessageBox
{
    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Setting_ClosePOITitle",Localize_Setting)] autorelease];
    __block SettingSettingViewControllerTempViewController *blockSelf = self;

    [alertView addButtonWithTitle:STR(@"Setting_NO",Localize_Setting)
                             type:GDAlertViewButtonTypeCancel
                          handler:^(GDAlertView *alertView)
    {
        [blockSelf reloadBoxTableView];
    }];
    [alertView addButtonWithTitle:STR(@"Setting_YES", Localize_Setting)
                             type:GDAlertViewButtonTypeDefault
                          handler:^(GDAlertView *alertView)
    {
        [blockSelf reloadBoxTableView];
        [[MWPreference sharedInstance] setValue:PREF_AUTO_GETPOIINFO Value:0];
    }];
    [alertView show];
}


- (void) reloadBoxTableView
{
    [_tableView reloadData];
}

/***
 * @name    电子罗盘车标
 * @param
 * @author  by bazinga
 ***/
- (UIView *) getArrayEcompassSwitch
{
    CGRect frame = CGRectMake(0, 0, 51, 31);
    KLSwitch *klswitch = [[KLSwitch alloc] initWithFrame:frame didChangeHandler:^(BOOL isOn)
                          {
                              if(isOn)
                              {
                                  [MobClick event:UM_EVENTID_Preferences_COUNT label:UM_LABEL_Preferences_OpenCompass];
                                  [[MWPreference sharedInstance] setValue:PREF_DISABLE_ECOMPASS Value:1];
                              }
                              else
                              {
                                  [MobClick event:UM_EVENTID_Preferences_COUNT label:UM_LABEL_Preferences_CloseCompass];
                                  [[MWPreference sharedInstance] setValue:PREF_DISABLE_ECOMPASS Value:0];
                              }
                          }];
    int mode=[[MWPreference sharedInstance] getValue:PREF_DISABLE_ECOMPASS];
    klswitch.on = (mode == 1 ? YES:NO);
    [klswitch setOnTintColor:SWITCHCOLOR];
    return [klswitch autorelease];
}

- (void) checkUpdate
{
    //版本更新
    isCheck=YES;
    [self showLoadingViewInView:STR(@"Setting_CheckingUpdate", Localize_Setting) view:self.view];
    
    [[GDBL_LaunchRequest sharedInstance] Net_SoftWareVersionUpdateRequest:self withRequestType:RT_LaunchRequest_HandSoftWareUpdate];
}

- (UIView *) getArrayNaviInBackgroundSwitch
{
    CGRect frame = CGRectMake(0, 0, 51, 31);
    KLSwitch *klswitch = [[KLSwitch alloc] initWithFrame:frame didChangeHandler:^(BOOL isOn)
                          {
                              if(isOn)
                              {
                                  [MobClick event:UM_EVENTID_Preferences_COUNT label:UM_LABEL_Preferences_OpenBlock];
                                 // [[MWPreference sharedInstance] setValue:PREF_MAP_CONTENT Value:GMAP_CONTENT_GL_MIX];
                                  [[MWPreference sharedInstance] setValue:PREF_BACKGROUND_NAVI Value:YES];
                                  NSLog(@"NaviInBackground On");
                              }
                              else
                              {
                                  [MobClick event:UM_EVENTID_Preferences_COUNT label:UM_LABEL_Preferences_CloseBlock];
                                  
                                  //[[MWPreference sharedInstance] setValue:PREF_MAP_CONTENT Value:GMAP_CONTENT_NOBLOCK];
                                  [[MWPreference sharedInstance] setValue:PREF_BACKGROUND_NAVI Value:NO];
                                  NSLog(@"NaviInBackground Off");
                              }
                          }];
    int mode=[[MWPreference sharedInstance] getValue:PREF_BACKGROUND_NAVI];
    klswitch.on = (BOOL)mode;
    [klswitch setOnTintColor:SWITCHCOLOR];
    return [klswitch autorelease];
}



#pragma mark -
#pragma mark NetReqToViewCtrDelegate

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:
(id)result//id类型可以是NSDictionary NSArray
{
    isCheck=NO;
    [self hideLoadingViewWithAnimated:YES];
    if (result==nil) {
        return;
    }
    
    
    if (requestType==RT_LaunchRequest_HandSoftWareUpdate) {
        
        NSString *tmp = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"软件升级：%@",tmp);
        [tmp release];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            NSDictionary *softWareDic = [NSJSONSerialization
                                         
                                         JSONObjectWithData:result
                                         
                                         options:NSJSONReadingMutableLeaves
                                         
                                         error:nil];
            
            if (softWareDic) {
                
                
                NSString *string = [softWareDic objectForKey:@"respcode"];
                
                if (string && [string isEqualToString:@"0000"]) {
                    
                    
                    NSString *update = [softWareDic objectForKey:@"update"];
                    
                    if (update && ([update intValue] == 1) ) { //有新版本
                        
                        NSString *status = [softWareDic objectForKey:@"status"];
                        NSString *updateDesc = [softWareDic objectForKey:@"updatedesc"];
                        NSArray *mapNotMatch = [NSArray arrayWithArray:[softWareDic objectForKey:@"mapnotmatch"]];
                        NSString *mapMatchDesc = [softWareDic objectForKey:@"mapmatchdesc"];
                        NSString *resNotMatch = [softWareDic objectForKey:@"resnotmatch"];
                        NSString *resmatchdesc = [softWareDic objectForKey:@"resmatchdesc"];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            
                            if (status && [status intValue] == 1) {//强制升级
                                
                                GDAlertView *alertView1 = [[GDAlertView alloc] initWithTitle:STR(@"Setting_NewVersion",Localize_Setting) andMessage:updateDesc];
                                [alertView1 addButtonWithTitle:STR(@"Setting_UpdateCancel",Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                                    
                                    [[UIApplication sharedApplication] exitApplication];//退出导航
                                    
                                }];
                                [alertView1 addButtonWithTitle:STR(@"Setting_UpdateSure",Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                                    
                                    
                                    [ANOperateMethod rateToAppStore:0];
                                    [[UIApplication sharedApplication] exitApplication];//退出导航
                                    
                                }];
                                [alertView1 show];
                                [alertView1 release];
                            }
                            else{
                                GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:STR(@"Setting_NewVersion",Localize_Setting) andMessage:updateDesc];
                                
                                [alertView addButtonWithTitle:STR(@"Setting_UpdateCancel",Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                                }];
                                
                                [alertView addButtonWithTitle:STR(@"Setting_UpdateSure",Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                                    
                                    if (resNotMatch && [resNotMatch intValue] == 1) {//基础资源不匹配
                                        
                                        GDAlertView *alertView1 = [[GDAlertView alloc] initWithTitle:STR(@"Setting_NewVersion",Localize_Setting) andMessage:resmatchdesc];
                                        [alertView1 addButtonWithTitle:STR(@"Setting_UpdateCancel",Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                                        }];
                                        [alertView1 addButtonWithTitle:STR(@"Setting_UpdateSure",Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                                            
                                            //add by hlf for 先删除其他城市数据，再删除基础资源，否则，基础资源删除后，调用引擎的接口获取不出数据目录
                                            if (mapNotMatch && mapNotMatch.count > 0) {//删除不兼容城市数据
                                                [[TaskManager taskManager] removeNotMatchTaskWithArray:mapNotMatch];
                                            }
                                            
                                            [[TaskManager taskManager] removeTaskId:0];//删除基础资源
                                            
                                            [[TaskManager taskManager] updatecity:0];//添加基础资源
                                            
                                            [ANOperateMethod rateToAppStore:0];
                                            
                                            [[UIApplication sharedApplication] exitApplication];//退出导航
                                            
                                        }];
                                        [alertView1 show];
                                        [alertView1 release];
                                    }
                                    else if (mapNotMatch && mapNotMatch.count > 0)//城市数据不匹配
                                    {
                                        GDAlertView *alertView2 = [[GDAlertView alloc] initWithTitle:STR(@"Setting_NewVersion",Localize_Setting) andMessage:mapMatchDesc];
                                        [alertView2 addButtonWithTitle:STR(@"Setting_UpdateCancel",Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                                        }];
                                        [alertView2 addButtonWithTitle:STR(@"Setting_UpdateSure",Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                                            
                                            [[TaskManager taskManager] removeNotMatchTaskWithArray:mapNotMatch];
                                            [ANOperateMethod rateToAppStore:0];
                                            
                                        }];
                                        [alertView2 show];
                                        [alertView2 release];
                                        
                                    }
                                    else
                                    {
                                        [ANOperateMethod rateToAppStore:0];
                                    }
                                    
                                    
                                }];
                                
                                [alertView show];
                                [alertView release];
                            }
                            
                        });
                        
                    }
                    else if (update && ([update intValue] == 0)){
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Setting_NewestVersion",Localize_Setting)];
                            [alertView show];
                            [alertView release];
                        });
                    }
                }
            }
            
            
        });
        
        
    }
    
}
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error//上层需根据error的值来判断网络连接超时还是网络连接错误
{
    isCheck=NO;
    [self hideLoadingViewWithAnimated:YES];
    NSString *string=@"";
    if ([error.domain isEqualToString:KNetResponseErrorDomain])
    {
        //        服务器返回内容异常，HTTP error" 其中HTTP error后面要跟error的成员变量code
        
        string=[NSString stringWithFormat:STR(@"Universal_httpError",Localize_Universal),error.code];
        
    }
    else
    {
        if (error.code==NSURLErrorTimedOut) {
            
            string=STR(@"Universal_networkTimeout",Localize_Universal);
        }
        else
        {
            string=STR(@"Universal_networkError",Localize_Universal);
        }
        
    }
    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:string] autorelease];
    [alertView show];
}

#pragma mark -  ---  恢复默认  ---
- (void)GDActionSheet:(GDActionSheet *)actionSheet clickedButtonAtIndex:(int)index
{
    __block SettingSettingViewControllerTempViewController *blockSelf = self;
    if(index == 0)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Setting_ResetAllAlertMessage", Localize_Setting)] autorelease];
            
            [alertView addButtonWithTitle:STR(@"Setting_ResetAlertBack",Localize_Setting)
                                     type:GDAlertViewButtonTypeCancel handler:nil];
            
            [alertView addButtonWithTitle:STR(@"Setting_ResetAllAlertSure", Localize_Setting)
                                     type:GDAlertViewButtonTypeDefault
                                  handler:^(GDAlertView *alertView){
                                      [blockSelf resetSetting];
                                  }];
            [alertView show];
        });
    }
    else if(index == 1)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Setting_EraseAllAlertMessage", Localize_Setting)] autorelease];
            
            [alertView addButtonWithTitle:STR(@"Setting_ResetAlertBack",Localize_Setting)
                                     type:GDAlertViewButtonTypeCancel handler:nil];
            
            [alertView addButtonWithTitle:STR(@"Setting_ResetAllAlertSure", Localize_Setting)
                                     type:GDAlertViewButtonTypeDefault
                                  handler:^(GDAlertView *alertView){
                                         [blockSelf eraseSetting];
                                     }];
            [alertView show];
        });
    }
                       
}
- (void) resetSettingAlert
{
    [self createGDActionSheetWithTitle:STR(@"Setting_SettingReset",Localize_Setting)
                              delegate:self
                     cancelButtonTitle:STR(@"Setting_ResetAlertBack",Localize_Setting)
                destructiveButtonTitle:nil
                                   tag:-1
                     otherButtonTitles:STR(@"Setting_ResetAllSettings", Localize_Setting),STR(@"Setting_EraseAll", Localize_Setting),nil];
}

#pragma mark -  ---  恢复默认  ---
- (void) resetSetting
{
    [[MWPreference sharedInstance] reset];
    [self handleUIUpdate:YES];
}

-(void)eraseSetting
{
    [[MWPreference sharedInstance] reset];
	[[MWApp sharedInstance] ClearAllEngineData];
    [self handleUIUpdate:YES];
}

- (void) handleUIUpdate : (BOOL) isReset
{
//        [UIImage setImageSkinType:!isReset SkinPath:nil];
//        [[GDSkinColor sharedInstance] refresh:[[NSBundle mainBundle] pathForResource:@"colorConfig" ofType:@"plist"]];
//    
//        //換背景色
//        [self reloadBackgroundImage];;
//        //換導航條背景
//        [(VCCustomNavigationBar*)self.navigationController.navigationBar refeshBackground];
        //換導航條的標題顏色
        self.title=STR(@"Setting_Setting",Localize_Setting);
//        if(isReset)
//        {
//            [MWEngineSwitch setTheme:0];
//        }
//        self.navigationItem.leftBarButtonItem = LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
        [_tableView reloadData];
}

@end
