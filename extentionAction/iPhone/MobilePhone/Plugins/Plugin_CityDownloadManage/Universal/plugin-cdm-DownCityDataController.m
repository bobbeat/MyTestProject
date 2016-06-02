//
//  DownLoadCityDataController.m
//  SiteVistor
//
//  Created by hlf on 11-11-01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "plugin-cdm-DownCityDataController.h"
#import "plugin-cdm-TableCell.h"
#import "plugin-cdm-TaskManager.h"
#import "plugin-cdm-DownloadTask.h"
#import "SectionInfo.h"
#import "Play.h"
#import "Quotation.h"
#import "SectionHeaderView.h"
#import "QLoadingView.h"
#import "Plugin_Account_Utility.h"
#import "GDBL_Account.h"
#import "GDAlertView.h"
#import "DMDataDownloadManagerViewController.h"
#import "DMDataDownloadPagesContainer.h"
#import "plugin-cdm-Task.h"
#import "plugin-cdm-DownloadTask.h"
#import "plugin-cdm-IntegratedDownLoadTask.h"
#import "plugin-cdm-RoadDownloadTask.h"
#import  "UIDevice+Category.h"
#import "MWCityDownloadMapDataList.h"

#define SectionHeight 50.0
const int mb = 1024*1024;
const int skb = 1024*103;
const int gb = 1024*1024*1024;

@interface DownLoadCityDataController ()
{
	
    POIAroundTextField              *_aroundTextField; //输入框
    POIKeyBoardEvent                *_keyBoardEvent;   //键盘事件
    
	UITableView                     *m_table;
    UIImageView                     *_imageView;       //搜索框背景
	NSMutableArray                  *downLoadArray;    //要下载的城市
    __block NSArray                 *plays;
    __block NSMutableArray          *sectionInfoArray; //城市列表
    
	NSInteger    openSectionIndex;                     //打开的省份索引
	__block int  searchrowcount;                       //搜索计数
	long long    totalsize;                            //总大小
    BOOL         provinceClickFlag;                    //省份按钮点击标志
    id           managerController;
    
}

@property (nonatomic, assign) NSInteger          openSectionIndex;
@property (nonatomic, retain) NSArray            *plays;
@property (nonatomic, retain) NSMutableArray     *sectionInfoArray;
@property (nonatomic,assign) BOOL isCitySelect;

@end

@implementation DownLoadCityDataController

@synthesize  openSectionIndex=openSectionIndex_;
@synthesize plays=plays_,sectionInfoArray;

#pragma mark -
#pragma mark Initialization

- (id)init
{
    self = [super init];
    if (self) {
		self.title = STR(@"CityDownloadManage_cityList", Localize_CityDownloadManage);
        sectionInfoArray = [[NSMutableArray alloc]init];
        
		
    }
    return self;
}

//根据语言选择对应的城市名称 add by xyy
-(NSString*)setTaskTitle:(DownloadTask*) task
{
    if (fontType == 0)
    {
        return task.zhname;
    }
    else if (fontType == 1)
    {
        return task.twname;
    }
    else
    {
        return task.enname;

    }
    
}



- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUIUpdate:) name:NOTIFY_HandleUIUpdate object:nil];
    
    [self initControl];    //控件初始化
    
	
    [ANParamValue sharedInstance].bSupportAutorate = YES;
    
	openSectionIndex_ = NSNotFound;
    
    if (Interface_Flag == 1)
	{
		[self set_HV:1];
	}
	else if(Interface_Flag == 0)
	{
		[self set_HV:0];
	}
    
    [self requestCityList];
}

//数据版本号不匹配警告
- (void)alert_version
{
    if (_cityAdminCodeArray) {
        [_cityAdminCodeArray release];
        _cityAdminCodeArray = nil;
    }
    
    if (downLoadArray && downLoadArray.count > 0) {
        [downLoadArray removeAllObjects];
    }
    
    GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_updateVersion",Localize_CityDownloadManage)] ;
    [alertView addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
        if (self.managerController) {
            [((DMDataDownloadManagerViewController *)self.managerController).pagesContainer setSelectedIndex:GDDownloadViewTypeManager animated:NO];
        }
        
    }];
    [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
        if (self.managerController) {
            [((DMDataDownloadManagerViewController *)self.managerController).pagesContainer setSelectedIndex:GDDownloadViewTypeManager animated:NO];
        }
        [ANOperateMethod rateToAppStore:0];
    }];
    [alertView show];
    [alertView release];
    
}

//选择需要下载的城市
- (void)selectCityWithAdminCode
{
    totalsize = 0;
    if (downLoadArray && downLoadArray.count > 0) {
        [downLoadArray removeAllObjects];
    }
    
    self.isCitySelect = NO;
   
    if (self.cityAdminCodeArray && [self.cityAdminCodeArray isKindOfClass:[NSDictionary class]] && [self.cityAdminCodeArray objectForKey:@"city"]) {//下载缺失的城市
        
        id cityValue = [self.cityAdminCodeArray objectForKey:@"city"];
        
        if (cityValue && [cityValue isKindOfClass:[NSArray class]]) {
            
            for (id adminCode in cityValue) {//遍历传入的城市行政编码列表
                
                DownloadTask *task = [[[DownloadTask alloc] init] autorelease];

                task.taskId = [adminCode intValue];
                
                if ([[TaskManager taskManager]  _taskExisted:task]) {//已在下载列表则继续遍历下一个
                    continue;
                }
                
                
                for(SectionInfo *sectioninfo in self.sectionInfoArray)//遍历城市列表的一级目录列表
                {
                    if(![sectioninfo isKindOfClass:[SectionInfo class] ])
                    {
                        continue;
                    }
                    
                    if (sectioninfo.play.all_suburl && sectioninfo.play.admincode == task.taskId)
                    {//是直辖市且与传入的行政编码相等则勾选上
                        Quotation* quotation = [Quotation quotation];
                        quotation.zhname = sectioninfo.play.zhname;
                        quotation.twname = sectioninfo.play.twname;
                        quotation.enname = sectioninfo.play.enname;
                        quotation.version = sectioninfo.play.version;
                        quotation.updatetype = sectioninfo.play.updatetype;
                        quotation.all_suburl = sectioninfo.play.all_suburl;
                        quotation.all_size = sectioninfo.play.all_size;
                        quotation.all_unzipsize = sectioninfo.play.all_unzipsize;
                        quotation.all_md5 = sectioninfo.play.all_md5;
                        quotation.add_suburl = sectioninfo.play.add_suburl;
                        quotation.add_size = sectioninfo.play.add_size;
                        quotation.add_unzipsize = sectioninfo.play.add_unzipsize;
                        quotation.add_md5 = sectioninfo.play.add_md5;
                        quotation.admincode = sectioninfo.play.admincode;
                        
                        
                        [downLoadArray addObject:quotation];
                        
                        self.isCitySelect = YES;
                        
                        
                        break;
                    }
                    
                    for (Quotation* quotation in sectioninfo.play.quotations)//遍历二级城市列表
                    {
                        
                        if(quotation.admincode == task.taskId)//与传入的行政编码相等则勾选上
                        {
                            [downLoadArray addObject:quotation];
                            
                            self.isCitySelect = YES;
                            
                            break;
                        }
                        
                    }
                    
                }
            }
        }
        else if (cityValue && [cityValue isKindOfClass:[NSString class]])
        {
            DownloadTask *task = [[[DownloadTask alloc] init] autorelease];
            
            task.taskId = [cityValue intValue];
            
            if (![[TaskManager taskManager]  _taskExisted:task]) {//已在下载列表则继续遍历下一个
                for(SectionInfo *sectioninfo in self.sectionInfoArray)//遍历城市列表的一级目录列表
                {
                    if(![sectioninfo isKindOfClass:[SectionInfo class] ])
                    {
                        continue;
                    }
                    
                    if (sectioninfo.play.all_suburl && sectioninfo.play.admincode == task.taskId)
                    {//是直辖市且与传入的行政编码相等则勾选上
                        Quotation* quotation = [Quotation quotation];
                        quotation.zhname = sectioninfo.play.zhname;
                        quotation.twname = sectioninfo.play.twname;
                        quotation.enname = sectioninfo.play.enname;
                        quotation.version = sectioninfo.play.version;
                        quotation.updatetype = sectioninfo.play.updatetype;
                        quotation.all_suburl = sectioninfo.play.all_suburl;
                        quotation.all_size = sectioninfo.play.all_size;
                        quotation.all_unzipsize = sectioninfo.play.all_unzipsize;
                        quotation.all_md5 = sectioninfo.play.all_md5;
                        quotation.add_suburl = sectioninfo.play.add_suburl;
                        quotation.add_size = sectioninfo.play.add_size;
                        quotation.add_unzipsize = sectioninfo.play.add_unzipsize;
                        quotation.add_md5 = sectioninfo.play.add_md5;
                        quotation.admincode = sectioninfo.play.admincode;
                        
                        
                        [downLoadArray addObject:quotation];

                        
                        self.isCitySelect = YES;
                        
                        
                        break;
                    }
                    
                    for (Quotation* quotation in sectioninfo.play.quotations)//遍历二级城市列表
                    {
                        
                        if(quotation.admincode == task.taskId)//与传入的行政编码相等则勾选上
                        {
                            [downLoadArray addObject:quotation];
                            
                            self.isCitySelect = YES;
                            
                            break;
                        }
                        
                    }
                    
                }
            }
        
        }
    
    }
    else if (self.cityAdminCodeArray && [self.cityAdminCodeArray isKindOfClass:[NSDictionary class]] && [self.cityAdminCodeArray objectForKey:@"province"]) {//下载缺失的省份
        
        id province = [self.cityAdminCodeArray objectForKey:@"province"];
        
        if (province && [province isKindOfClass:[NSArray class]]) {
            for (id adminCode in [self.cityAdminCodeArray objectForKey:@"province"]) {//遍历传入的省份行政编码列表
                
                DownloadTask *task = [[[DownloadTask alloc] init] autorelease];
                task.taskId = [adminCode intValue];
                
                if ([[TaskManager taskManager]  _taskExisted:task]) {//已在下载列表则继续遍历下一个
                    continue;
                }
                
                for(SectionInfo *sectioninfo in self.sectionInfoArray)//遍历城市列表的一级目录列表
                {
                    if(![sectioninfo isKindOfClass:[SectionInfo class] ])
                    {
                        continue;
                    }
                    if ( sectioninfo.play.admincode == [adminCode intValue]) {
                        if (sectioninfo.play.all_suburl != nil) {//直辖市
                            
                            Quotation* quotation = [Quotation quotation];
                            quotation.zhname = sectioninfo.play.zhname;
                            quotation.twname = sectioninfo.play.twname;
                            quotation.enname = sectioninfo.play.enname;
                            quotation.version = sectioninfo.play.version;
                            quotation.updatetype = sectioninfo.play.updatetype;
                            quotation.all_suburl = sectioninfo.play.all_suburl;
                            quotation.all_size = sectioninfo.play.all_size;
                            quotation.all_unzipsize = sectioninfo.play.all_unzipsize;
                            quotation.all_md5 = sectioninfo.play.all_md5;
                            quotation.add_suburl = sectioninfo.play.add_suburl;
                            quotation.add_size = sectioninfo.play.add_size;
                            quotation.add_unzipsize = sectioninfo.play.add_unzipsize;
                            quotation.add_md5 = sectioninfo.play.add_md5;
                            quotation.admincode = sectioninfo.play.admincode;
                            
                            [downLoadArray addObject:quotation];
                            
                            self.isCitySelect = YES;
                        }
                        else {//非直辖市，勾选省份下所有城市
                            
                            Quotation* quotation = [Quotation quotation];
                            for (quotation in sectioninfo.play.quotations)
                            {
                                Task *tmp = [[[Task alloc] init] autorelease];
                                tmp.taskId = quotation.admincode;
                                if ([[TaskManager taskManager]  _taskExisted:tmp]) {
                                    continue;
                                }
                                
                                [downLoadArray addObject:quotation];
                                self.isCitySelect = YES;
                            }
                            
                        }
                        
                        
                        break;
                    }
                    
                }
            }
        }
       
    }
    CRELEASE(_cityAdminCodeArray);
    
    if (self.isCitySelect) {
        [self doneButtonItemPressed:nil];
    }
    else{
        if (self.managerController) {
            
            
            __block DownLoadCityDataController *weakSelf = self;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [((DMDataDownloadManagerViewController *)weakSelf.managerController).pagesContainer setSelectedIndex:GDDownloadViewTypeManager animated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:kAddEarthquakesNotif object:[NSNumber numberWithInt:1]];
            });
        }
    }
}

//初始化控件
- (void)initControl
{
    m_table = [[UITableView alloc] initWithFrame:CGRectMake(0, 60.0f, self.view.bounds.size.width, self.view.bounds.size.height-100) style:UITableViewStylePlain];
	m_table.delegate = self;
	m_table.dataSource = self;
	[self.view addSubview:m_table];
	[m_table release];
    m_table.backgroundColor = [UIColor clearColor];
    if ([UITableView instancesRespondToSelector:@selector(backgroundView)])
    {
        m_table.backgroundView = nil;
    }
    m_table.separatorStyle = UITableViewCellSeparatorStyleNone;
    m_table.separatorColor = [UIColor clearColor];
    
    //输入框
    _imageView=[[UIImageView alloc] initWithFrame:CGRectMake(CCOMMON_SPACE, 3.,  APPWIDTH-2*CCOMMON_SPACE, 34)];
    _imageView.backgroundColor=[UIColor clearColor];
    _imageView.userInteractionEnabled=YES;
    [self.view addSubview:_imageView];
    [_imageView release];
    _imageView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    
    _aroundTextField=[[POIAroundTextField alloc] initWithFrame:CGRectMake(0,0, CGRectGetWidth(_imageView.frame), 34)];
    _aroundTextField.textField.placeholder = STR(@"CityDownloadManage_inputCityName", Localize_CityDownloadManage);
    _aroundTextField.delegate=self;
    [_imageView addSubview:_aroundTextField];
    [_aroundTextField release];
    

    //键盘事件
    _keyBoardEvent=[[POIKeyBoardEvent alloc] initWithView:self.view];
    _keyBoardEvent.delegate=self;
    _keyBoardEvent.textFiled=(UITextField*)_aroundTextField.textField;
    _keyBoardEvent.addKeyboardButtonY = -44.0;
    [_keyBoardEvent setHiddenButton:YES];

    downLoadArray =  [[NSMutableArray alloc] init];
}

//请求城市数据列表
- (void)requestCityList
{
    
    //取数据列表
    NSArray *mapdatalist =[[MWCityDownloadMapDataList citydownloadMapDataList] getMapDataList];
    
    //modify by xyy
    //数据列表为空，则重新请求下载地图数据列表
    if (!mapdatalist || mapdatalist.count == 0) {
        
        [QLoadingView showLoadingView:STR(@"Universal_loading", Localize_Universal) view:(UIWindow *)self.view];
        
        MWCityDownloadMapDataList *cdmapdatalist = [MWCityDownloadMapDataList citydownloadMapDataList];
        
        if(cdmapdatalist.isLoading == NO){
            cdmapdatalist.ReqMapDataListDelegate = self;
            [cdmapdatalist getMapDataListWithUrl:kMapdataRequestURL];
        }
        
        return;
    }
    
}

//加载城市数据列表
- (void)loadingDataList
{
    if (self.sectionInfoArray && [self.sectionInfoArray count] > 0 ) {
        [QLoadingView hideWithAnimated:NO];
        [m_table reloadData];
        return;
    }
    
    //取数据列表
    NSArray *mapdatalist =[[MWCityDownloadMapDataList citydownloadMapDataList] getMapDataList];
    
    //modify by xyy
    //数据列表为空，则重新请求下载地图数据列表
    if (!mapdatalist || mapdatalist.count == 0) {
        
        [QLoadingView showLoadingView:STR(@"Universal_loading", Localize_Universal) view:(UIWindow *)self.view];
        
        MWCityDownloadMapDataList *cdmapdatalist = [MWCityDownloadMapDataList citydownloadMapDataList];
        
        if(cdmapdatalist.isLoading == NO){
            cdmapdatalist.ReqMapDataListDelegate = self;
            [cdmapdatalist getMapDataListWithUrl:kMapdataRequestURL];
        }
        
        return;
    }
    
    for (SectionInfo *sectioninfo in mapdatalist)
    {
        [self.sectionInfoArray addObject:sectioninfo];
    }
    searchrowcount = [self.sectionInfoArray count];
    if(searchrowcount>0)
    {
        [QLoadingView hideWithAnimated:NO];
    }
    
    [m_table reloadData];
    
    if (self.cityAdminCodeArray) {//传入城市行政编码，自动勾选指定城市
        [self selectCityWithAdminCode];
    }
}

- (void)setMSectionInfoArray:(NSMutableArray *)mSectionInfoArray
{
    self.sectionInfoArray = mSectionInfoArray;
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
	if (Interface_Flag == 1) 
	{
		[self set_HV:1];
	} 
	else if(Interface_Flag == 0)
	{
		[self set_HV:0];
	}
}
-(void)set_HV:(int)flag
{
	
	if (flag == 0) {
		if ([self.sectionInfoArray count] == searchrowcount ) {
			for (SectionInfo *sectioninfo in self.sectionInfoArray) {
				
				[sectioninfo.headerView.disclosureButton setFrame:CGRectMake(APPWIDTH-38.0, 12.0, 18.0, 18.0)];
				[sectioninfo.headerView.sizeLabel setFrame:CGRectMake(APPWIDTH-120.0, 5.0, 90.0, 30.0)];
			}
		}
        _imageView.frame=CGRectMake(11, 11,  APPWIDTH-2*11, _imageView.frame.size.height);
        
        _aroundTextField.frame= CGRectMake(0,0, CGRectGetWidth(_imageView.frame), 34);
        [_aroundTextField changePortraitControlFrameWithImage];
        
		[m_table setFrame:CGRectMake(0, 57.0, APPWIDTH, CONTENTHEIGHT_V-100.0)];
		

	}
	else if(flag == 1)
	{
		if ([self.sectionInfoArray count] == searchrowcount ) {
		    for (SectionInfo *sectioninfo in self.sectionInfoArray) {
				[sectioninfo.headerView.disclosureButton setFrame:CGRectMake(APPHEIGHT-38.0, 12.0, 18.0, 18.0)];
				[sectioninfo.headerView.sizeLabel setFrame:CGRectMake(APPHEIGHT-100.0, 12.0, 90.0, 30.0)];
			}
		}
        _imageView.frame=CGRectMake(11, 11,  APPHEIGHT-2*11, _imageView.frame.size.height);
        _aroundTextField.frame= CGRectMake(0,0, CGRectGetWidth(_imageView.frame), 34);
        [_aroundTextField changeLandscapeControlFrameWithImage];
        
		[m_table setFrame:CGRectMake(0, 57.0, APPHEIGHT, CONTENTHEIGHT_H-100.0)];
    

	}
	[m_table reloadData];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if (!OrientationSwitch)
    {
        return (Orientation == interfaceOrientation);
    }
	return  YES;
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
		[self set_HV:1];
	}
	else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		[self set_HV:0];
    }
}

- (void)dealloc 
{
    MWCityDownloadMapDataList *cdmapdatalist = [MWCityDownloadMapDataList citydownloadMapDataList];
    cdmapdatalist.ReqMapDataListDelegate = nil;

	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    m_table.delegate = nil;
    m_table.dataSource = nil;
    m_table = nil;
    
    _aroundTextField.delegate = nil;
    _keyBoardEvent.delegate = nil;
    
	[downLoadArray release];
	 downLoadArray = nil;
    
	[plays_ release];
	 plays_ = nil;
    
    [sectionInfoArray release];
	 sectionInfoArray = nil;
    
    if (_keyBoardEvent) {
        [_keyBoardEvent release];
        _keyBoardEvent = nil;
    }
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIAction

//创建按钮
- (UIBarButtonItem*) createButtonItemWithTitle:(NSString*)title action:(SEL)action
{
	UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithTitle:title
																   style:UIBarButtonItemStyleDone
																  target:self
																  action:action];
	return [buttonItem autorelease];
}


//城市选择按钮响应函数
- (void) doneButtonItemPressed:(UIBarButtonItem*)buttonItem
{
    //不交叉数据的处理
//    [[TaskManager taskManager] processNoCrossTask];
    
    NSArray *nocrossTasklist = [[TaskManager taskManager] getNoCrossTask];
    
    if(!nocrossTasklist)
    {
        //数据下载检测
        [self dataDownloadCheck];
        return;
    }
    //有不交叉数据的处理
    NSString *citynames=@"";
    int count = [nocrossTasklist count];
    int i=0;
    for(DownloadTask *task in nocrossTasklist)
    {
        i++;
        citynames = [citynames stringByAppendingString:task.title];
        if(i>2)
        {
            break;
        }
        if(count>= 2 && i!=count)
        {
            citynames = [citynames stringByAppendingString:@","];
        }
    }
    if(fontType ==0 || fontType ==1)
    {
        if(count>2)
        {
            citynames = [citynames stringByAppendingFormat:@"......等%d",count];
        }
        else{
            citynames = [citynames stringByAppendingFormat:@"%d",count];
        }
    }
    
    else
    {
        citynames = @" ";
    }
    
    
    NSString *strTitle = [NSString stringWithFormat:STR(@"CityDownloadManage_noMatchUpdate",Localize_CityDownloadManage),citynames];
    
    GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:strTitle];
    [alertView addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
        [self dataDownloadCheck];
    }];//不操作
    [alertView addButtonWithTitle:STR(@"CityDownloadManage_update", Localize_CityDownloadManage) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
        for(DownloadTask *task in nocrossTasklist)
        {
            [task erase];//先删除数据在更新下载
            [[TaskManager taskManager] updatecity:task.taskId];
        }
        [self dataDownloadCheck];
    }];
    [alertView show];
    [alertView release];
    
    
}

    
-(void)dataDownloadCheck
{
//modify by xyy for 空间大小计算：遍历taskmanager和downarray，需要的大小为所有要下载城市解压后的大小之和加上最大压缩包
    totalsize = 0;
	totalsize = [[TaskManager taskManager] getNeedSize:downLoadArray];
	long long disksize = [UIDevice getCurDiskSpaceInBytes];
	if(disksize < totalsize)
	{
		self.isCitySelect = NO;
		float freesize = (float)(totalsize - disksize)/1024/1024/1024;

        float disksizeUintG = disksize/1024/1024/1024.0;
        float totalUintG = totalsize/1024/1024/1024.0;
        if(disksizeUintG < 0.1)
        {
            disksizeUintG = 0.1;
        }
        if(totalUintG <0.1)
        {
            totalUintG = 0.1;
        }
        
        GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:[NSString stringWithFormat:STR(@"CityDownloadManage_noFreeSize",Localize_CityDownloadManage),disksizeUintG,totalUintG,freesize]] autorelease];
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
            [[TaskManager taskManager]stopAllTask];
            [m_table reloadData];
        }];
        
        [alertView show];
        
	}
	else {
		
		int netType = NetWorkType;
	    
		if (netType == 2) {
			[self downloadAlertWithNoWiFi];
		}
		else if(netType == 1 ){
			[self alert_DownLoad_NOWIFI];
		}
		else {
			GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_withoutNetwork",Localize_Universal)] autorelease];
            
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
            [alertView show];
            
            if (self.isCitySelect) {
                self.isCitySelect = NO;
            }
		}
		
	}
	[m_table reloadData];
	
}


- (void)alert_DownLoad_NOWIFI
{
    
    NSString *Unit;
    float size;
    totalsize =0;
    
    for(DownloadTask *task in [TaskManager taskManager].taskList)
    {
        if(task.status==TASK_STATUS_READY  || task.status == TASK_STATUS_RUNNING)
        {
            totalsize += task.total - task.current;
        }
    }
    for (Quotation *quotation in downLoadArray) {
        if(quotation.updatetype==1)//增量
        {
            totalsize +=  quotation.add_size;
        }
        else
        {
            totalsize +=  quotation.all_size;
        }
    }

    
    if (totalsize >= 1024*1024*1024) {
        Unit = @"GB";
        size = totalsize*1.0/1024/1024/1024;
    }
    else if(1024*103 <= totalsize && totalsize< 1024*1024*1024)
    {
        Unit = @"MB";
        size = totalsize*1.0/1024/1024;
    }
    else {
        Unit = @"MB";
        size = 0.1;
    }
    

    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:[NSString stringWithFormat:STR(@"CityDownloadManage_startDownloadAlert",Localize_CityDownloadManage),size,Unit]] autorelease];
    [alertView addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
            self.isCitySelect = NO;
        
    }];
    [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
        [self downloadAlertWithNoWiFi];
        
    }];
    [alertView show];
}

- (void)downloadAlertWithNoWiFi
{
    [self addBaseDataTask];
    for (Quotation *quotation in downLoadArray) {
            DownloadTask *task = [[DownloadTask alloc] init];
            task.zhname = quotation.zhname;
            task.twname = quotation.twname;
            task.enname = quotation.enname;
            task.version = quotation.version;
            task.updatetype = quotation.updatetype;
            task.all_suburl = quotation.all_suburl;
            task.all_size = quotation.all_size;
            task.all_unzipsize = quotation.all_unzipsize;
            task.all_md5 = quotation.all_md5;
            task.add_suburl = quotation.add_suburl;
            task.add_size = quotation.add_size;
            task.add_unzipsize = quotation.add_unzipsize;
            task.add_md5 = quotation.add_md5;
            task.taskId = quotation.admincode;
            task.title = [self setTaskTitle:task];
            if(task.updatetype==1)//增量
            {
                task.total = quotation.add_size;
                task.url = quotation.add_suburl;
            }
            else
            {
                task.total = quotation.all_size;
                task.url = quotation.all_suburl;
            }
            
        
            [[TaskManager taskManager] addTask:task atFirst:NO];
            [task release];
        
    }
    
    [downLoadArray removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddEarthquakesNotif object:nil];
    
    [m_table reloadData];
    
    if (self.isCitySelect) {
        self.isCitySelect = NO;
        if (self.managerController) {
            
            __block DownLoadCityDataController *weakSelf = self;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [((DMDataDownloadManagerViewController *)weakSelf.managerController).pagesContainer setSelectedIndex:GDDownloadViewTypeManager animated:YES];
            });
            
        }
    }
}

//添加基础资源
- (void)addBaseDataTask
{
    for (Task *task in [TaskManager taskManager].taskList)
    {
        if(task.taskId ==0)//基础资源已经存在，不需要再增加
            return;
    }
    
    NSArray *sectionArray = [[MWCityDownloadMapDataList citydownloadMapDataList] getMapDataList];
    for (SectionInfo *sectioninfo in sectionArray) {
        if (sectioninfo.play.admincode == 0) {//基础资源adcode=0
            plugin_cdm_RoadDownloadTask *task = [[plugin_cdm_RoadDownloadTask alloc] init];
            task.zhname = sectioninfo.play.zhname;
            task.twname = sectioninfo.play.twname;
            task.enname = sectioninfo.play.enname;
            task.version = sectioninfo.play.version;
            task.updatetype = sectioninfo.play.updatetype;
            task.all_suburl = sectioninfo.play.all_suburl;
            task.all_size = sectioninfo.play.all_size;
            task.all_unzipsize = sectioninfo.play.all_unzipsize;
            task.all_md5 = sectioninfo.play.all_md5;
            task.add_suburl = sectioninfo.play.add_suburl;
            task.add_size = sectioninfo.play.add_size;
            task.add_unzipsize = sectioninfo.play.add_unzipsize;
            task.add_md5 = sectioninfo.play.add_md5;
            task.taskId = sectioninfo.play.admincode;
            task.title = [self setTaskTitle:task];
            if (task.updatetype ==1)//增量
            {
                task.url = task.add_suburl;
                task.total = task.add_size;
            }
            else//全量
            {
                task.url = task.all_suburl;
                task.total = task.all_size;
            }
            [[TaskManager taskManager] addTask:task atFirst:YES];
            CRELEASE(task);
            break;

        }
    }
 
}

-(void)GoBack:(id)sender
{
    [QLoadingView hideWithAnimated:NO];
    
	if (self.managerController) {
        [((UIViewController *)self.managerController).navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark -
#pragma mark tableview funtion

//重置tableview
-(void)resetSearch
{
	openSectionIndex_ = NSNotFound;
	
	[self.navigationItem.rightBarButtonItem setEnabled:NO];
	[self.sectionInfoArray removeAllObjects];

    NSArray *mapdatalist =[[MWCityDownloadMapDataList citydownloadMapDataList] getMapDataList];
    for (SectionInfo *sectioninfo in mapdatalist)
    {
        [self.sectionInfoArray addObject:sectioninfo];
    }
    searchrowcount = [self.sectionInfoArray count];
    
    for(SectionInfo *sectionInfo in self.sectionInfoArray)
    {
        NSNumber *defaultRowHeight = [NSNumber numberWithInteger:45];
        NSInteger countOfQuotations = [[sectionInfo.play quotations] count];
        for (NSInteger i = 0; i < countOfQuotations; i++)
        {
            [sectionInfo insertObject:defaultRowHeight inRowHeightsAtIndex:i];
        }
    }

    
}



//搜索输入字符串
- (void)handleSearchForTerm:(NSString *)searchTerm
{
	
	[self allSearch];
	NSMutableArray *toRemove = [[NSMutableArray alloc] init];
	
	for (Quotation *items in self.sectionInfoArray)
	{
		
		if([items.zhname rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound  && [items.twname rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound && [items.enname rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound)
			
			[toRemove addObject:items];
	}		
	
	[self.sectionInfoArray removeObjectsInArray:toRemove];
	[toRemove release];
	
		
	[m_table reloadData];
	
}

//将所有城市加入到数组中
-(void)allSearch
{
    NSArray *mapdatalist = [[MWCityDownloadMapDataList citydownloadMapDataList] getMapDataList];
    [self.sectionInfoArray removeAllObjects];
    
    for(SectionInfo *sectioninfo in mapdatalist)
    {
        if(sectioninfo.play.all_suburl || sectioninfo.play.admincode==86)
        {
            Quotation* cityinfo = [Quotation quotation];
            cityinfo.zhname = sectioninfo.play.zhname;
            cityinfo.twname = sectioninfo.play.twname;
            cityinfo.enname = sectioninfo.play.enname;
            cityinfo.version = sectioninfo.play.version;
            cityinfo.updatetype = sectioninfo.play.updatetype;
            cityinfo.all_suburl = sectioninfo.play.all_suburl;
            cityinfo.all_size = sectioninfo.play.all_size;
            cityinfo.all_unzipsize = sectioninfo.play.all_unzipsize;
            cityinfo.all_md5 = sectioninfo.play.all_md5;
            cityinfo.add_suburl = sectioninfo.play.add_suburl;
            cityinfo.add_size = sectioninfo.play.add_size;
            cityinfo.add_unzipsize = sectioninfo.play.add_unzipsize;
            cityinfo.add_md5 = sectioninfo.play.add_md5;
            cityinfo.admincode = sectioninfo.play.admincode;

            if(sectioninfo.play.admincode==86)
            {
                cityinfo.all_size = sectioninfo.play.size;
                cityinfo.all_unzipsize = sectioninfo.play.unzipsize;
            }
            [self.sectionInfoArray addObject:cityinfo];
            
        }
        else if(sectioninfo.play.quotations && [sectioninfo.play.quotations count]>0)
        {
            for (Quotation *quotation in sectioninfo.play.quotations)
            {
                Quotation* cityinfo = [Quotation quotation];
                cityinfo.zhname = quotation.zhname;
                cityinfo.twname = quotation.twname;
                cityinfo.enname = quotation.enname;
                cityinfo.version = quotation.version;
                cityinfo.updatetype = quotation.updatetype;
                cityinfo.all_suburl = quotation.all_suburl;
                cityinfo.all_size = quotation.all_size;
                cityinfo.all_unzipsize = quotation.all_unzipsize;
                cityinfo.all_md5 = quotation.all_md5;
                cityinfo.add_suburl = quotation.add_suburl;
                cityinfo.add_size = quotation.add_size;
                cityinfo.add_unzipsize = quotation.add_unzipsize;
                cityinfo.add_md5 = quotation.add_md5;
                cityinfo.admincode = quotation.admincode;
                [self.sectionInfoArray addObject:cityinfo];
            }
        }
    }
	
}

- (void) setEditing:(BOOL)editting animated:(BOOL)animated 
{
	
	[super setEditing:editting animated:animated];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
	if (self.sectionInfoArray && [self.sectionInfoArray count] == searchrowcount) {
		return [self.sectionInfoArray count];
	}
    else if(!self.sectionInfoArray)
    {
        return  0;
    }
	else {
		return 1;
	}

   
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if ([self.sectionInfoArray count] == searchrowcount) {
		return SectionHeight;
	}
	else {
		return 0.0;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if ([self.sectionInfoArray count] != searchrowcount) {
		return [self.sectionInfoArray count];
	}
	else {
		SectionInfo *sectionInfo = [self.sectionInfoArray caObjectsAtIndex:section];
		NSInteger numStoriesInSection = [[sectionInfo.play quotations] count];
		
		return sectionInfo.open ? numStoriesInSection : 0;
	}
    
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    FileItemTableCell *cell = (FileItemTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[FileItemTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.font = [cell.textLabel.font fontWithSize:15];
    }
    
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[cell.textLabel setTextColor:GETSKINCOLOR(@"DownloadCellColor")];
	[cell.detailTextLabel setTextColor:GETSKINCOLOR(@"DownloadCellColor")];
    cell.emptyLineLength = 10;
	float size = 0.0;
	if ([self.sectionInfoArray count] == searchrowcount) { //非搜索状态
        
        
		Play *play = (Play *)[[self.sectionInfoArray caObjectsAtIndex:indexPath.section] play];
		Quotation *items = [play.quotations caObjectsAtIndex:indexPath.row];
        size = items.all_size*1.0f;
       
		NSString *dataSize = nil;
        NSString *dataState = nil;
		
		Task *task = [[TaskManager taskManager] getTaskWithTaskID:items.admincode];
        
        if (task) { //如果城市已在下载列表
            if (task.status == TASK_STATUS_FINISH) {//下载完成需要分有更新的状态,大小显示不一样
                if (task.updated == NO)
                {
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    [cell.detailTextLabel setTextColor:DOWNLOADINGCOLOR];
                    dataState = STR(@"CityDownloadManage_beDownload", Localize_CityDownloadManage);
                    task.updated = NO;
                    
                }
                else
                {
                    if(((DownloadTask*)task).updatetype==1)
                    {
                        size = ((DownloadTask*)task).add_size*1.0f;
                    }
                    task.updated = YES;
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    [cell.detailTextLabel setTextColor:STARTDOWNLOADCOLOR];
                    dataState= STR(@"CityDownloadManage_hasupdatedata", Localize_CityDownloadManage);
                     }
            }
            else if (task.status == TASK_STATUS_RUNNING)
            {
                cell.accessoryView = nil;
                cell.accessoryType = UITableViewCellAccessoryNone;
                [cell.detailTextLabel setTextColor:STOPDOWNLOADCOLOR];
                dataState = STR(@"CityDownloadManage_Downloading", Localize_CityDownloadManage);
            }
            else if (task.status == TASK_STATUS_READY)
            {
                cell.accessoryView = nil;
                cell.accessoryType = UITableViewCellAccessoryNone;
                [cell.detailTextLabel setTextColor:STOPDOWNLOADCOLOR];
                dataState = STR(@"CityDownloadManage_readyDownload", Localize_CityDownloadManage);
            }
            else if (task.status == TASK_STATUS_BLOCK)
            {
                cell.accessoryView = nil;
                cell.accessoryType = UITableViewCellAccessoryNone;
                [cell.detailTextLabel setTextColor:STARTDOWNLOADCOLOR];
                dataState = STR(@"CityDownloadManage_pauseDownload", Localize_CityDownloadManage);
            }
            else{
                dataState = @"";
                UIImageView *tempimg = [[UIImageView alloc] initWithImage: IMAGE(@"Download.png", IMAGEPATH_TYPE_1) ];
                [tempimg setFrame:CGRectMake(0.0f, 0.0f, 18.0f, 18.0f)];
                cell.accessoryView = tempimg;
                [tempimg release];
                
            }
            
        }
        else{//不在下载列表中
            if (indexPath.row == 0) { //省份
                
                BOOL allDownload = YES;
                BOOL bRunning = NO;
                BOOL bReady = NO;
                BOOL bPause = NO;
                BOOL bupdate = NO;
                
                //判断省份的下载状态
                Quotation* quotation = [Quotation quotation];
                for (quotation in play.quotations)
                {
                    Task *tmp = [[Task alloc] init];
                    tmp.taskId = quotation.admincode;
                    
                    if (quotation.all_suburl && ![[TaskManager taskManager]  _taskExisted:tmp]) {
                        allDownload = NO;
                    }
                    else if(quotation.all_suburl){
                        
                        Task *_task = [[TaskManager taskManager] getTaskWithTaskID:quotation.admincode];
                        if (_task.status == TASK_STATUS_RUNNING) {
                            bRunning = YES;
                        }
                        else if (_task.status == TASK_STATUS_READY){
                            bReady = YES;
                        }
                        else if (_task.status == TASK_STATUS_BLOCK){
                            bPause = YES;
                        }
                        else if(_task.status == TASK_STATUS_FINISH && _task.updated){
                            bupdate = YES;
                        }
                        
                        
                    }
                    [tmp release];
                    
                }
                
                
                
                if (allDownload == YES) {
                    
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    if(bupdate)
                    {
                        [cell.detailTextLabel setTextColor:STARTDOWNLOADCOLOR];
                        dataState = STR(@"CityDownloadManage_hasupdatedata", Localize_CityDownloadManage);
                    }

                    else if (bRunning) {
                        [cell.detailTextLabel setTextColor:STOPDOWNLOADCOLOR];
                        dataState = STR(@"CityDownloadManage_Downloading", Localize_CityDownloadManage);
                    }
                    else if (bReady)
                    {
                        [cell.detailTextLabel setTextColor:STOPDOWNLOADCOLOR];
                        dataState = STR(@"CityDownloadManage_readyDownload", Localize_CityDownloadManage);
                    }
                    else if (bPause)
                    {
                        [cell.detailTextLabel setTextColor:STARTDOWNLOADCOLOR];
                        dataState = STR(@"CityDownloadManage_pauseDownload", Localize_CityDownloadManage);
                    }
                    else{
                        
                        [cell.detailTextLabel setTextColor:DOWNLOADINGCOLOR];
                        dataState = STR(@"CityDownloadManage_beDownload", Localize_CityDownloadManage);
                    }
                    
                }
                else{
                    dataState = @"";
                    UIImageView *tempimg = [[UIImageView alloc] initWithImage: IMAGE(@"Download.png", IMAGEPATH_TYPE_1) ];
                    [tempimg setFrame:CGRectMake(0.0f, 0.0f, 18.0f, 18.0f)];
                    cell.accessoryView = tempimg;
                    [tempimg release];
                }
            }
            

            else{//其他城市
                dataState = @"";
                UIImageView *tempimg = [[UIImageView alloc] initWithImage: IMAGE(@"Download.png", IMAGEPATH_TYPE_1) ];
                [tempimg setFrame:CGRectMake(0.0f, 0.0f, 18.0f, 18.0f)];
                cell.accessoryView = tempimg;
                [tempimg release];
            }
        
        }
        
		if (size < skb) {
			dataSize = @"0.1MB";
		}
        else if (size > gb)
        {
            size = size/mb;
            size = size/1024.0;
            dataSize = [NSString stringWithFormat:@"%.1fGB",size];
        }
		else {
            size = size/mb;
			dataSize = [NSString stringWithFormat:@"%.1fMB",size];
		}
        
        if (fontType == 0)
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)",items.zhname,dataSize];
        }
        else if (fontType == 1)
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)",items.twname,dataSize];
        }
        else
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)",items.enname,dataSize];
            
        }
        
		cell.detailTextLabel.text = dataState;
		
        
	}
	else { //搜索状态
        
        id tmp =  [self.sectionInfoArray caObjectsAtIndex:indexPath.row];
        
        if (tmp && [tmp isKindOfClass:[SectionInfo class]]) {
            return cell;
        }
        
		Quotation *quotation = (Quotation *)tmp;
        if (!quotation) {
            return cell;
        }
		size = quotation.all_size*1.0f/mb;
        
		NSString *dataSize1 = nil;
		NSString *dataState1 = nil;
		
		Task *task = [[TaskManager taskManager] getTaskWithTaskID:quotation.admincode];
        
        if (task) {
            
            if (task.status == TASK_STATUS_FINISH) {//分是否有更新状态
                if (task.updated == NO)
                {
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    [cell.detailTextLabel setTextColor:DOWNLOADINGCOLOR];
                    dataState1 = STR(@"CityDownloadManage_beDownload", Localize_CityDownloadManage);
                }
                else
                {
                    if(((DownloadTask*)task).updatetype==1)
                    {
                        size = ((DownloadTask*)task).add_size*1.0f;
                    }
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    [cell.detailTextLabel setTextColor:STARTDOWNLOADCOLOR];
                    dataState1 = STR(@"CityDownloadManage_hasupdatedata", Localize_CityDownloadManage);
                }
            }
            else if (task.status == TASK_STATUS_RUNNING)
            {
                cell.accessoryView = nil;
                cell.accessoryType = UITableViewCellAccessoryNone;
                [cell.detailTextLabel setTextColor:STOPDOWNLOADCOLOR];
                dataState1 = STR(@"CityDownloadManage_Downloading", Localize_CityDownloadManage);
                
            }
            else if (task.status == TASK_STATUS_READY)
            {
                cell.accessoryView = nil;
                cell.accessoryType = UITableViewCellAccessoryNone;
                [cell.detailTextLabel setTextColor:STOPDOWNLOADCOLOR];
                dataState1 = STR(@"CityDownloadManage_readyDownload", Localize_CityDownloadManage);
            }
            else if (task.status == TASK_STATUS_BLOCK)
            {
                cell.accessoryView = nil;
                cell.accessoryType = UITableViewCellAccessoryNone;
                [cell.detailTextLabel setTextColor:STARTDOWNLOADCOLOR];
                dataState1 = STR(@"CityDownloadManage_pauseDownload", Localize_CityDownloadManage);
            }
            else{
                dataState1 = @"";
                UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Download.png", IMAGEPATH_TYPE_1) ];
                [tempimg setFrame:CGRectMake(0.0f, 0.0f, 18.0f, 18.0f)];
                cell.accessoryView = tempimg;
                [tempimg release];
            }
            
        }
        else{
            if(quotation.admincode == 86)//全国
            {
                BOOL allDownload = YES;
                BOOL bRunning = NO;
                BOOL bReady = NO;
                BOOL bPause = NO;
                BOOL bupdate = NO;
                NSArray *allArray = [[MWCityDownloadMapDataList citydownloadMapDataList]getMapDataList];
                for (SectionInfo *sectiontmp in allArray) {
                    if(sectiontmp.play.all_suburl)//一级城市
                    {
                        Task *task = [[TaskManager taskManager] getTaskWithTaskID:sectiontmp.play.admincode];
                        if (!task) {
                            allDownload = NO;
                        }
                        else
                        {
                            if (task.status == TASK_STATUS_RUNNING) {
                                bRunning = YES;
                            }
                            else if (task.status == TASK_STATUS_READY){
                                bReady = YES;
                            }
                            else if (task.status == TASK_STATUS_BLOCK){
                                bPause = YES;
                            }
                            else if(task.status == TASK_STATUS_FINISH && task.updated){
                                bupdate = YES;
                            }
                        }
                    }
                    else//省份
                    {
                        for (Quotation* quotation in sectiontmp.play.quotations)
                        {
                            if(!quotation.all_suburl)
                            {
                                continue;
                            }
                            Task *task = [[TaskManager taskManager] getTaskWithTaskID:quotation.admincode];
                            if (!task) {
                                allDownload = NO;
                            }
                            else
                            {
                                if (task.status == TASK_STATUS_RUNNING) {
                                    bRunning = YES;
                                }
                                else if (task.status == TASK_STATUS_READY){
                                    bReady = YES;
                                }
                                else if (task.status == TASK_STATUS_BLOCK){
                                    bPause = YES;
                                }
                                else if(task.status == TASK_STATUS_FINISH && task.updated){
                                    bupdate = YES;
                                }
                            }
                            
                        }
                    }
                }
                if (allDownload == YES) {
                    
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    if(bupdate)
                    {
                        [cell.detailTextLabel setTextColor:STARTDOWNLOADCOLOR];
                        dataState1 = STR(@"CityDownloadManage_hasupdatedata", Localize_CityDownloadManage);
                    }
                    
                    else if (bRunning) {
                        [cell.detailTextLabel setTextColor:STOPDOWNLOADCOLOR];
                        dataState1 = STR(@"CityDownloadManage_Downloading", Localize_CityDownloadManage);
                    }
                    else if (bReady)
                    {
                        [cell.detailTextLabel setTextColor:STOPDOWNLOADCOLOR];
                        dataState1 = STR(@"CityDownloadManage_readyDownload", Localize_CityDownloadManage);
                    }
                    else if (bPause)
                    {
                        [cell.detailTextLabel setTextColor:STARTDOWNLOADCOLOR];
                        dataState1 = STR(@"CityDownloadManage_pauseDownload", Localize_CityDownloadManage);
                    }
                    else{
                        
                        [cell.detailTextLabel setTextColor:DOWNLOADINGCOLOR];
                        dataState1 = STR(@"CityDownloadManage_beDownload", Localize_CityDownloadManage);
                    }
                    
                }
                else{
                    dataState1 = @"";
                    UIImageView *tempimg = [[UIImageView alloc] initWithImage: IMAGE(@"Download.png", IMAGEPATH_TYPE_1) ];
                    [tempimg setFrame:CGRectMake(0.0f, 0.0f, 18.0f, 18.0f)];
                    cell.accessoryView = tempimg;
                    [tempimg release];
                }
                
            }
            else if(!quotation.all_suburl)//全省
            {
                NSArray *allArray = [[MWCityDownloadMapDataList citydownloadMapDataList]getMapDataList];
                for (SectionInfo *sectionInfo in allArray) {
                    if (sectionInfo.play.admincode == quotation.admincode)
                    {
                        BOOL allDownload = YES;
                        BOOL bRunning = NO;
                        BOOL bReady = NO;
                        BOOL bPause = NO;
                        BOOL bupdate = NO;
                        
                        Quotation* quotation = [Quotation quotation];
                        for (quotation in sectionInfo.play.quotations)
                        {
                            Task *tmp = [[Task alloc] init];
                            tmp.taskId = quotation.admincode;
                            if (quotation.all_suburl && ![[TaskManager taskManager]  _taskExisted:tmp]) {
                                allDownload = NO;
                            }
                            else if(quotation.all_suburl){
                                Task *_task = [[TaskManager taskManager] getTaskWithTaskID:quotation.admincode];
                                if (_task.status == TASK_STATUS_RUNNING) {
                                    bRunning = YES;

                                }
                                else if (_task.status == TASK_STATUS_READY){
                                    bReady = YES;
                                }
                                else if (_task.status == TASK_STATUS_BLOCK){
                                    bPause = YES;
                                }
                                else if(_task.updated && _task.status == TASK_STATUS_FINISH)
                                {
                                    bupdate = YES;
                                }
                                
                                
                            }
                            [tmp release];
                            
                        }
                        
                        if (allDownload == YES) {
                            
                            cell.accessoryView = nil;
                            cell.accessoryType = UITableViewCellAccessoryNone;
                            if(bupdate)
                            {
                                [cell.detailTextLabel setTextColor:STARTDOWNLOADCOLOR];
                                dataState1 = STR(@"CityDownloadManage_hasupdatedata", Localize_CityDownloadManage);
                            }
                            
                            else if (bRunning) {
                                [cell.detailTextLabel setTextColor:STOPDOWNLOADCOLOR];
                                dataState1 = STR(@"CityDownloadManage_Downloading", Localize_CityDownloadManage);
                            }
                            else if (bReady)
                            {
                                [cell.detailTextLabel setTextColor:STOPDOWNLOADCOLOR];
                                dataState1 = STR(@"CityDownloadManage_readyDownload", Localize_CityDownloadManage);
                            }
                            else if (bPause)
                            {
                                [cell.detailTextLabel setTextColor:STARTDOWNLOADCOLOR];
                                dataState1 = STR(@"CityDownloadManage_pauseDownload", Localize_CityDownloadManage);
                            }
                            else{
                                
                                [cell.detailTextLabel setTextColor:DOWNLOADINGCOLOR];
                                dataState1 = STR(@"CityDownloadManage_beDownload", Localize_CityDownloadManage);
                            }
                            
                        }
                        else{
                            
                            dataState1 = @"";
                            UIImageView *tempimg = [[UIImageView alloc] initWithImage: IMAGE(@"Download.png", IMAGEPATH_TYPE_1) ];
                            [tempimg setFrame:CGRectMake(0.0f, 0.0f, 18.0f, 18.0f)];
                            cell.accessoryView = tempimg;
                            [tempimg release];
                        }
                        break;
                    }
                }

            }
            else{
                dataState1 = @"";
                UIImageView *tempimg = [[UIImageView alloc] initWithImage: IMAGE(@"Download.png", IMAGEPATH_TYPE_1)  ];
                [tempimg setFrame:CGRectMake(0.0f, 0.0f, 18.0f, 18.0f)];
                cell.accessoryView = tempimg;
                [tempimg release];
            }
            
        }
        
		if (quotation.all_size < skb) {
			dataSize1 = @"0.1MB";
		}
        else if (quotation.all_size > gb)
        {
            size = size/1024.0;
            dataSize1 = [NSString stringWithFormat:@"%.1fGB",size];
        }
		else {
			dataSize1 = [NSString stringWithFormat:@"%.1fMB",size];
		}
        
        if (fontType == 0)
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)",quotation.zhname,dataSize1];
        }
        else if (fontType == 1)
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)",quotation.twname,dataSize1];
        }
        else
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)",quotation.enname,dataSize1];
            
        }


		cell.detailTextLabel.text = dataState1;
    
	}

	return cell;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    
	if ([self.sectionInfoArray count] ==searchrowcount )
    {
		SectionInfo *sectionInfo = [self.sectionInfoArray caObjectsAtIndex:section];
        
        sectionInfo.headerView = [[[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, m_table.bounds.size.width-20., 50) title:@"" size:@"" section:section sectionOpen:sectionInfo.open delegate:self] autorelease];
        
        Task *task = [[TaskManager taskManager] getTaskWithTaskID:sectionInfo.play.admincode];
        
        float size = 0.0;
        NSString *dataSize = nil;
        
        
      
        sectionInfo.headerView.emptyLineLength = 0;
        //一级城市
        if (sectionInfo.play.size == 0) {
            size = sectionInfo.play.all_size*1.0f;
            if (task) {//在下载列表中
                
                if (task.status == TASK_STATUS_FINISH) {//分出有更新的情况，有更新根据updatetype来取size
                    if (task.updated == NO)
                    {
                        sectionInfo.headerView.disclosureButton.hidden = YES;
                        
                        [sectionInfo.headerView.sizeLabel setText:STR(@"CityDownloadManage_beDownload", Localize_CityDownloadManage)];
                        [sectionInfo.headerView.sizeLabel setTextColor:DOWNLOADINGCOLOR];
                        task.updated = NO;
                    }
                    else//有更新
                    {
                        sectionInfo.headerView.disclosureButton.hidden = YES;
                        
                        [sectionInfo.headerView.sizeLabel setText:STR(@"CityDownloadManage_hasupdatedata", Localize_CityDownloadManage)];
                        [sectionInfo.headerView.sizeLabel setTextColor:STARTDOWNLOADCOLOR];
                        if(sectionInfo.play.updatetype==1)
                        {
                            size = sectionInfo.play.add_size;
                        }
                        task.updated = YES;
                    }
                }
                else if (task.status == TASK_STATUS_RUNNING)
                {
                    sectionInfo.headerView.disclosureButton.hidden = YES;
                    [sectionInfo.headerView.sizeLabel setText:STR(@"CityDownloadManage_Downloading", Localize_CityDownloadManage)];
                    [sectionInfo.headerView.sizeLabel setTextColor:STOPDOWNLOADCOLOR];
                }
                else if (task.status == TASK_STATUS_READY)
                {
                    sectionInfo.headerView.disclosureButton.hidden = YES;
                    [sectionInfo.headerView.sizeLabel setText:STR(@"CityDownloadManage_readyDownload", Localize_CityDownloadManage)];
                    [sectionInfo.headerView.sizeLabel setTextColor:STOPDOWNLOADCOLOR];
                }
                else if (task.status == TASK_STATUS_BLOCK)
                {
                    sectionInfo.headerView.disclosureButton.hidden = YES;
                    [sectionInfo.headerView.sizeLabel setText:STR(@"CityDownloadManage_pauseDownload", Localize_CityDownloadManage)];
                    [sectionInfo.headerView.sizeLabel setTextColor:STARTDOWNLOADCOLOR];
                }
                else{
                    sectionInfo.headerView.disclosureButton.hidden = NO;
                    [sectionInfo.headerView.disclosureButton setImage: IMAGE(@"Download.png", IMAGEPATH_TYPE_1)    forState:UIControlStateNormal];
                    [sectionInfo.headerView.sizeLabel setText:@""];
                }
                
            }
            else{

                sectionInfo.headerView.disclosureButton.hidden = NO;
                [sectionInfo.headerView.disclosureButton setImage: IMAGE(@"Download.png", IMAGEPATH_TYPE_1)  forState:UIControlStateNormal];
                [sectionInfo.headerView.sizeLabel setText:@""];
                
            }
            
        }
        //全国
        else if(sectionInfo.play.admincode == 86)
        {
            size = sectionInfo.play.size*1.0f;
            BOOL allDownload = YES;
            BOOL bRunning = NO;
            BOOL bReady = NO;
            BOOL bPause = NO;
            BOOL bupdate = NO;
            
            for(SectionInfo *sectiontmp in self.sectionInfoArray)//判断全国的下载状态
            {
                if(sectiontmp.play.all_suburl)//一级城市
                {
                    Task *task = [[TaskManager taskManager] getTaskWithTaskID:sectiontmp.play.admincode];
                    if (!task) {
                        allDownload = NO;
                    }
                    else
                    {
                        if (task.status == TASK_STATUS_RUNNING) {
                            bRunning = YES;
                        }
                        else if (task.status == TASK_STATUS_READY){
                            bReady = YES;
                        }
                        else if (task.status == TASK_STATUS_BLOCK){
                            bPause = YES;
                        }
                        else if(task.status == TASK_STATUS_FINISH && task.updated){
                            bupdate = YES;
                        }
                    }
                }
                else//省份
                {
                    for (Quotation* quotation in sectiontmp.play.quotations)
                    {
                        if(!quotation.all_suburl)
                        {
                            continue;
                        }
                        Task *task = [[TaskManager taskManager] getTaskWithTaskID:quotation.admincode];
                        if (!task) {
                            allDownload = NO;
                        }
                        else
                        {
                            if (task.status == TASK_STATUS_RUNNING) {
                                bRunning = YES;
                            }
                            else if (task.status == TASK_STATUS_READY){
                                bReady = YES;
                            }
                            else if (task.status == TASK_STATUS_BLOCK){
                                bPause = YES;
                            }
                            else if(task.status == TASK_STATUS_FINISH && task.updated){
                                bupdate = YES;
                            }
                        }

                    }
                }
            }
            if (allDownload) {
                if (bupdate)
                {
                    sectionInfo.headerView.disclosureButton.hidden = YES;
                    
                    [sectionInfo.headerView.sizeLabel setText:STR(@"CityDownloadManage_hasupdatedata", Localize_CityDownloadManage)];
                    [sectionInfo.headerView.sizeLabel setTextColor:STARTDOWNLOADCOLOR];

                }
            
                else if (bRunning)
                {
                    sectionInfo.headerView.disclosureButton.hidden = YES;
                    [sectionInfo.headerView.sizeLabel setText:STR(@"CityDownloadManage_Downloading", Localize_CityDownloadManage)];
                    [sectionInfo.headerView.sizeLabel setTextColor:STOPDOWNLOADCOLOR];
                }
                else if (bReady)
                {
                    sectionInfo.headerView.disclosureButton.hidden = YES;
                    [sectionInfo.headerView.sizeLabel setText:STR(@"CityDownloadManage_readyDownload", Localize_CityDownloadManage)];
                    [sectionInfo.headerView.sizeLabel setTextColor:STOPDOWNLOADCOLOR];
                }
                else if (bPause)
                {
                    sectionInfo.headerView.disclosureButton.hidden = YES;
                    [sectionInfo.headerView.sizeLabel setText:STR(@"CityDownloadManage_pauseDownload", Localize_CityDownloadManage)];
                    [sectionInfo.headerView.sizeLabel setTextColor:STARTDOWNLOADCOLOR];
                }
                else{//已下载
                    sectionInfo.headerView.disclosureButton.hidden = YES;
                    
                    [sectionInfo.headerView.sizeLabel setText:STR(@"CityDownloadManage_beDownload", Localize_CityDownloadManage)];
                    [sectionInfo.headerView.sizeLabel setTextColor:DOWNLOADINGCOLOR];
            }
            
        }
            else{//显示下载按钮
                sectionInfo.headerView.disclosureButton.hidden = NO;
                [sectionInfo.headerView.disclosureButton setImage: IMAGE(@"Download.png", IMAGEPATH_TYPE_1)  forState:UIControlStateNormal];
                [sectionInfo.headerView.sizeLabel setText:@""];
            
            }
        }
        else{//省份
            size = sectionInfo.play.size*1.0f;
            sectionInfo.headerView.disclosureButton.hidden = NO;
            [sectionInfo.headerView.sizeLabel setText:@""];
            
            if (sectionInfo.open) {
                
                [sectionInfo.headerView.disclosureButton setImage: IMAGE(@"AccessoryUp.png", IMAGEPATH_TYPE_1)  forState:UIControlStateNormal];
            }
            else{
                [sectionInfo.headerView.disclosureButton setImage: IMAGE(@"POIAroundBigAccessoryDown.png", IMAGEPATH_TYPE_1)  forState:UIControlStateNormal];
            }
        }
        
        if (size < skb) {
            dataSize = @"0.1MB";
        }
        else if (size > gb)
        {
            size = size/mb;
            size = size/1024.0;
            dataSize = [NSString stringWithFormat:@"%.1fGB",size];
        }
        else {
            size = size/mb;
            dataSize = [NSString stringWithFormat:@"%.1fMB",size];
        }
        NSString *playName;
        
        if (fontType == 0)
        {
            playName = [NSString stringWithFormat:@"%@(%@)",sectionInfo.play.zhname,dataSize];
        }
        else if (fontType == 1)
        {
            playName = [NSString stringWithFormat:@"%@(%@)",sectionInfo.play.twname,dataSize];
        }
        else
        {
            playName = [NSString stringWithFormat:@"%@(%@)",sectionInfo.play.enname,dataSize];
            
        }
        
        
        [sectionInfo.headerView.titleLabel setText:playName];
        
		return sectionInfo.headerView;
	}
	else {
		return nil;
	}

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (downLoadArray && downLoadArray.count > 0) {
        [downLoadArray removeAllObjects];
    }
	totalsize = 0;
    
	if ([self.sectionInfoArray count] == searchrowcount) {
		
		SectionInfo *sectionInfo = [self.sectionInfoArray caObjectsAtIndex:indexPath.section];
		
        if (indexPath.row == 0) {//全省下载
            Quotation* quotation1 = [Quotation quotation];
            for (quotation1 in sectionInfo.play.quotations)
            {
                if ([[TaskManager taskManager] getTaskWithTaskID:quotation1.admincode]) {
                    continue;
                }
                    
                if (quotation1.all_suburl) {
                    [downLoadArray addObject:quotation1];
                        
                }
            }
            
        }
        else
        {
            Quotation* quotation = [sectionInfo.play.quotations caObjectsAtIndex:indexPath.row] ;
            if ([[TaskManager taskManager] getTaskWithTaskID:quotation.admincode]) {
                return;
            }
            [downLoadArray addObject:quotation];
        }
		
		
	}
	else {
        Quotation* quotation = [self.sectionInfoArray caObjectsAtIndex:indexPath.row] ;
        if(!quotation.all_suburl)
        {
            NSArray *allArray = [[MWCityDownloadMapDataList citydownloadMapDataList]getMapDataList];
            if(quotation.admincode == 86)
            {
                for(SectionInfo *sectioninfo in allArray)
                {
                    if(![sectioninfo isKindOfClass:[SectionInfo class] ])
                    {
                        continue;
                    }
                    if(sectioninfo.play.all_suburl)//是直辖市
                    {
                        if([[TaskManager taskManager] getTaskWithTaskID:sectioninfo.play.admincode])
                        {
                            continue;
                        }
                        
                        Quotation* quotation = [Quotation quotation];
                        quotation.zhname = sectioninfo.play.zhname;
                        quotation.twname = sectioninfo.play.twname;
                        quotation.enname = sectioninfo.play.enname;
                        quotation.version = sectioninfo.play.version;
                        quotation.updatetype = sectioninfo.play.updatetype;
                        quotation.all_suburl = sectioninfo.play.all_suburl;
                        quotation.all_size = sectioninfo.play.all_size;
                        quotation.all_unzipsize = sectioninfo.play.all_unzipsize;
                        quotation.all_md5 = sectioninfo.play.all_md5;
                        quotation.add_suburl = sectioninfo.play.add_suburl;
                        quotation.add_size = sectioninfo.play.add_size;
                        quotation.add_unzipsize = sectioninfo.play.add_unzipsize;
                        quotation.add_md5 = sectioninfo.play.add_md5;
                        quotation.admincode = sectioninfo.play.admincode;
                        [downLoadArray addObject:quotation];
                    }
                    else//省份
                    {
                        for (Quotation* quotation in sectioninfo.play.quotations)//遍历二级城市列表
                        {
                            if([[TaskManager taskManager] getTaskWithTaskID:quotation.admincode])
                            {
                                continue;
                            }
                            if (quotation.all_suburl) {
                                [downLoadArray addObject:quotation];
                            }
                        }
                        
                    }
                }

            }
            else
            {
                for (SectionInfo *sectionInfo in allArray) {
                if (sectionInfo.play.admincode == quotation.admincode)
                {
                    for (Quotation* quotation1 in sectionInfo.play.quotations)
                    {
                        if ([[TaskManager taskManager] getTaskWithTaskID:quotation1.admincode]) {
                            continue;
                        }
                        
                        if (quotation1.all_suburl) {
                            [downLoadArray addObject:quotation1];
                        }
                        
                    }
                    break;
                }
            }
            }

        }
        
        else
        {
            if ([[TaskManager taskManager] getTaskWithTaskID:quotation.admincode]) {
                return;
            }
            [downLoadArray addObject:quotation];
        }
        
		
	}

	[m_table deselectRowAtIndexPath:indexPath animated:YES];
    
    if (downLoadArray && downLoadArray.count > 0) {
    
        [self doneButtonItemPressed:nil];
    }
}
#pragma mark Section header delegate

-(void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
	
	SectionInfo *sectionInfo = [self.sectionInfoArray caObjectsAtIndex:sectionOpened];
	sectionInfo.open = YES;
	
    NSInteger countOfRowsToInsert = [sectionInfo.play.quotations count];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
    }
    
    /*
     Create an array containing the index paths of the rows to delete: These correspond to the rows for each quotation in the previously-open section, if there was one.
     */
	
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
	
    NSInteger previousOpenSectionIndex = self.openSectionIndex;
    if (previousOpenSectionIndex != NSNotFound) {
		
		SectionInfo *previousOpenSection = [self.sectionInfoArray caObjectsAtIndex:previousOpenSectionIndex];
		if (previousOpenSection.play.all_suburl == nil) {
			previousOpenSection.open = NO;
			[previousOpenSection.headerView toggleOpenWithUserAction:NO];
		}
        
        
        NSInteger countOfRowsToDelete = [previousOpenSection.play.quotations count];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
        }
    }
    
    // Style the animation so that there's a smooth flow in either direction.
    UITableViewRowAnimation insertAnimation;
    UITableViewRowAnimation deleteAnimation;
    if (previousOpenSectionIndex == NSNotFound || sectionOpened < previousOpenSectionIndex) {
        insertAnimation = UITableViewRowAnimationFade;
        deleteAnimation = UITableViewRowAnimationFade;
    }
    else {
        insertAnimation = UITableViewRowAnimationFade;
        deleteAnimation = UITableViewRowAnimationFade;
    }
    
    // Apply the updates.
    [m_table beginUpdates];
    [m_table insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
    [m_table deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:deleteAnimation];
    [m_table endUpdates];
    self.openSectionIndex = sectionOpened;
    
    [indexPathsToInsert release];
    [indexPathsToDelete release];
   
    
    NSString *sysVersion = CurrentSystemVersion;
    if ([sysVersion floatValue] > 3.2 && sectionInfo.play.all_suburl == nil && countOfRowsToInsert>0) {
        NSIndexPath *indPath = [NSIndexPath indexPathForRow:0 inSection:sectionOpened];
        [m_table scrollToRowAtIndexPath:indPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    double delayInSeconds = 0.15;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [m_table reloadData];
    });
    
}


-(void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
    
    /*
     Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
     */
	SectionInfo *sectionInfo = [self.sectionInfoArray caObjectsAtIndex:sectionClosed];

    sectionInfo.open = NO;
	
	
    NSInteger countOfRowsToDelete = [m_table numberOfRowsInSection:sectionClosed];
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        [m_table deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationFade];
        [indexPathsToDelete release];
    }
    self.openSectionIndex = NSNotFound;
    
   
    double delayInSeconds = 0.15;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [m_table reloadData];
    });
    
}

//省份下载
-(BOOL)provinceClick:(int)section
{
    if (downLoadArray && downLoadArray.count > 0) {
        [downLoadArray removeAllObjects];
    }
    
    totalsize = 0;
    SectionInfo *mySectionInfo = [self.sectionInfoArray caObjectsAtIndex:section];
    
    if (mySectionInfo.play.all_suburl != nil)//直辖市下载
    {
        Quotation* quotation = [Quotation quotation];
        quotation.zhname = mySectionInfo.play.zhname;
        quotation.twname = mySectionInfo.play.twname;
        quotation.enname = mySectionInfo.play.enname;
        quotation.version = mySectionInfo.play.version;
        quotation.updatetype = mySectionInfo.play.updatetype;
        quotation.all_suburl = mySectionInfo.play.all_suburl;
        quotation.all_size = mySectionInfo.play.all_size;
        quotation.all_unzipsize = mySectionInfo.play.all_unzipsize;
        quotation.all_md5 = mySectionInfo.play.all_md5;
        quotation.add_suburl = mySectionInfo.play.add_suburl;
        quotation.add_size = mySectionInfo.play.add_size;
        quotation.add_unzipsize = mySectionInfo.play.add_unzipsize;
        quotation.add_md5 = mySectionInfo.play.add_md5;
        quotation.admincode = mySectionInfo.play.admincode;
        [downLoadArray addObject:quotation];
    }
    else if(mySectionInfo.play.admincode == 86)//全国下载
    {
        for(SectionInfo *sectioninfo in self.sectionInfoArray)
        {
            if(![sectioninfo isKindOfClass:[SectionInfo class] ])
            {
                continue;
            }
            if(sectioninfo.play.all_suburl)//是直辖市
            {
                if([[TaskManager taskManager] getTaskWithTaskID:sectioninfo.play.admincode])
                {
                    continue;
                }
                
                Quotation* quotation = [Quotation quotation];
                quotation.zhname = sectioninfo.play.zhname;
                quotation.twname = sectioninfo.play.twname;
                quotation.enname = sectioninfo.play.enname;
                quotation.version = sectioninfo.play.version;
                quotation.updatetype = sectioninfo.play.updatetype;
                quotation.all_suburl = sectioninfo.play.all_suburl;
                quotation.all_size = sectioninfo.play.all_size;
                quotation.all_unzipsize = sectioninfo.play.all_unzipsize;
                quotation.all_md5 = sectioninfo.play.all_md5;
                quotation.add_suburl = sectioninfo.play.add_suburl;
                quotation.add_size = sectioninfo.play.add_size;
                quotation.add_unzipsize = sectioninfo.play.add_unzipsize;
                quotation.add_md5 = sectioninfo.play.add_md5;
                quotation.admincode = sectioninfo.play.admincode;
                [downLoadArray addObject:quotation];
            }
            else//省份
            {
                for (Quotation* quotation in sectioninfo.play.quotations)//遍历二级城市列表
                {
                    if([[TaskManager taskManager] getTaskWithTaskID:quotation.admincode])
                    {
                        continue;
                    }
                    if (quotation.all_suburl) {
                        [downLoadArray addObject:quotation];
                    }
                }

            }
        }
        
        
    }
    else
    {
        return NO;
    }
    if (downLoadArray && downLoadArray.count > 0) {
        [self doneButtonItemPressed:nil];
    }
    return YES;
}


#pragma mark -
#pragma mark - delegate
//城市数据解析完成后委托调用
- (void)dataparseDone
{
    [ANParamValue sharedInstance].isParseFinish = YES;
	
    [QLoadingView hideWithAnimated:YES];
	
}
//解析失败委托回调函数
-(void)dataparseFail:(NSError *)error
{
    [ANParamValue sharedInstance].isParseFinish = NO;

    [QLoadingView hideWithAnimated:NO];
    
    if ([error code] == NSURLErrorTimedOut)
    {
        [[Plugin_Account_Utility shareInstance] UIAlertFormWithErrorType:NET_CON_TIMEOUT Delegate:self Tag:8];
    }
    else
    {
        [[Plugin_Account_Utility shareInstance] UIAlertFormWithErrorType:NET_CON_FAILE Delegate:self Tag:8];
    }
}

#pragma mark -
#pragma mark POIAroundTextFieldDelegate
-(void)buttonTouchEvent:(NSString*)string withButton:(UIButton*)button
{
    [self handleSearchForTerm:string];
    
}
-(void)textFieldReturn:(NSString *)string
{
    [self handleSearchForTerm:string];
    
}

- (void)textFieldClear:(UITextField *)textField
{
    [self resetSearch];
    [m_table reloadData];
}
-(void)textFieldBackSpace:(NSString *)string
{
    if ([string length] == 0) {
		[self resetSearch];
		[m_table reloadData];
	}
}

-(BOOL)textFieldChanage:(UITextField*)textField withRange:(NSRange)range withString:(NSString *)string
{
    if (range.location>=30) {
        
        return NO;
    }
    
    return YES;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (_aroundTextField && [_aroundTextField.textField isFirstResponder])
    {

        [_aroundTextField.textField resignFirstResponder];
    }
	
}

#pragma mark POIKeyBoardEventProtocol
-(void)keyBoardEvent:(BOOL)isShow//0表示隐藏，1表示显示
{
    if (!isShow) {
       
        [self resetSearch];
        [m_table reloadData];
        
    }
}

- (void)handleUIUpdate:(NSNotification *)result
{
    switch ([[result object] intValue]) {
        case UIUpdate_MapDataDownloadFinish:
        {
            if (m_table) {
                [m_table reloadData];
            }
            
        }
            break;
        case UIUpdate_MapDataDownloadresignKeyboard:
        {
            
            if (_aroundTextField && [_aroundTextField.textField isFirstResponder])
            {
                
                [_aroundTextField.textField resignFirstResponder];
            }
        }
            break;
        case UIUpdate_MapDataDownloadUpdate:
        {
            
            if(self.sectionInfoArray &&[self.sectionInfoArray count]==0)
            {
                [QLoadingView hideWithAnimated:NO];
                NSArray *mapdatalist =[[MWCityDownloadMapDataList citydownloadMapDataList] getMapDataList];
                for (SectionInfo *sectioninfo in mapdatalist)
                {
                    [self.sectionInfoArray addObject:sectioninfo];
                }
                searchrowcount = [self.sectionInfoArray count];
                [m_table reloadData];
                
                if (self.cityAdminCodeArray) {//传入城市行政编码，自动勾选指定城市
                    [self selectCityWithAdminCode];
                }
            
            }
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - ReqMapDataListDelegate

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    if (requestType == REQ_GET_MapDataList)
    {
        [QLoadingView hideWithAnimated:YES];
        
        if(self.sectionInfoArray && [self.sectionInfoArray count]>0)
        {
            [self.sectionInfoArray removeAllObjects];
        }
//        self.sectionInfoArray = [[[MWCityDownloadMapDataList citydownloadMapDataList] getMapDataList]mutableCopy];
        NSArray *mapdatalist =[[MWCityDownloadMapDataList citydownloadMapDataList] getMapDataList];
        for (SectionInfo *sectioninfo in mapdatalist)
        {
            [self.sectionInfoArray addObject:sectioninfo];
        }
        searchrowcount = [self.sectionInfoArray count];
        [m_table reloadData];
        
        if (self.cityAdminCodeArray) {//传入城市行政编码，自动勾选指定城市
            [self selectCityWithAdminCode];
        }
    }
}

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error
{
    if (requestType == REQ_GET_MapDataList)
    {
        
        [QLoadingView hideWithAnimated:NO];
        
        
        if (self.managerController) {
            
            int index = [((DMDataDownloadManagerViewController *)self.managerController).pagesContainer getCurIndex];
            if(index == 1)
            {
                if ([error code] == NSURLErrorTimedOut)
                {
                    [[Plugin_Account_Utility shareInstance] UIAlertFormWithErrorType:NET_CON_TIMEOUT Delegate:self Tag:8];
                }
                else
                {
                    [[Plugin_Account_Utility shareInstance] UIAlertFormWithErrorType:NET_CON_FAILE Delegate:self Tag:8];
                }
            }
           
        }

    }
   
}


@end

