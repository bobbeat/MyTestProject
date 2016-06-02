//
//  Setting_DialectViewController.m
//  AutoNavi
//
//  Created by huang on 13-8-12.
//
//

#import "SettingDialectViewController.h"
#import "POIDefine.h"
#import "GDVoiceDownloadButton.h"
#import "GDTableVoiceCell.h"
#import "MWDialectDownloadManage.h"
#import "QLoadingView.h"
#import "GDTableVoiceData.h"

typedef enum EnglishEnum
{
    FEMALE_ID = 0,
}EnglishEnum;

#define SELECT_VOICE_ID ([[MWPreference sharedInstance] getValue:PREF_IS_LZLDIALECT])


@interface SettingDialectViewController ()
{
    NSMutableArray *_arrayCellData;
}

@end

@implementation SettingDialectViewController
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [MWDialectDownloadManage sharedInstance].delegate = nil;
    CRELEASE(_arrayCellData);
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
    [self.navigationController setNavigationBarHidden:NO animated:NO];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUIUpdate:) name:NOTIFY_HandleUIUpdate object:nil];
    _arrayCellData = [[NSMutableArray alloc]initWithCapacity:0];
    //下载回调和网络请求接口回调
    [MWDialectDownloadManage sharedInstance].delegate = self;
    [MWDialectDownloadManage sharedInstance].reqDelegate = self;
   
    if([[ANDataSource sharedInstance] isNetConnecting] == NO)
    {
        [QLoadingView showAlertWithoutClick:STR(@"Account_NetError",Localize_Account) ShowTime:2.0f];
    }
    else
    {
//        [QLoadingView showLoadingView:STR(@"Universal_loading", Localize_Universal) view:(UIWindow *)self.view];
        [[MWDialectDownloadManage sharedInstance] RequestDialect];
    }
     [self addDataByNetWork];
}

//初始化数据
- (void) addDataByNetWork
{
    if(_arrayCellData.count != 0)
    {
        [_arrayCellData removeAllObjects];
    }
    GDTableVoiceData *data = nil;
    data = [[[GDTableVoiceData alloc] init] autorelease];
    data.voiceID = FEMALE_ID;
    data.voiceSelect = ^BOOL{
        return (SELECT_VOICE_ID == FEMALE_ID);
    };
    data.voiceName = STR(@"Setting_DialectType0", Localize_Setting);
    data.voiceDefault = YES;
    [_arrayCellData addObject:data];
    
    
    NSArray *array = [[MWDialectDownloadManage sharedInstance] getDialectTaskIDList];
    GDTableVoiceData *data1 = nil;
    for ( int i = 0; i < array.count; i++)
    {
        if([[array objectAtIndex:i] isKindOfClass:[MWDialectDownloadTask class]])
        {
            MWDialectDownloadTask *tempTask = [array objectAtIndex:i];
            
            __block int tempID = tempTask.taskId;
            
            MWDialectDownloadTask *task = [[MWDialectDownloadManage sharedInstance] getTaskWithTaskID:tempTask.taskId];
            if(task && task.status == TASK_STATUS_RUNNING)
            {
                [[MWDialectDownloadManage sharedInstance] stopWithTaskID:tempTask.taskId];
                [[MWDialectDownloadManage sharedInstance] startWithTaskID:tempTask.taskId];
            }
            
            NSString *voiceTitle = [[MWDialectDownloadManage sharedInstance] getDialectTitle:tempTask.title];
            data1 = [[[GDTableVoiceData alloc] init] autorelease];
            data1.voiceID = tempTask.taskId;
            data1.voiceSelect = ^BOOL{
                return (SELECT_VOICE_ID == tempID);
            };
            data1.voiceName = voiceTitle;
            data1.voiceDefault = NO;
            
            [_arrayCellData addObject:data1];
        }
    }
    
    
    [_tableView reloadData];
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
    self.title=STR(@"Setting_SettingVoiceChoice",Localize_Setting);
    self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
 
    [_tableView reloadData];

}
-(void)leftBtnEvent:(id)object
{
    [MWDialectDownloadManage sharedInstance].delegate = nil;
    [MWDialectDownloadManage sharedInstance].reqDelegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark xxx delegate

- (NSInteger)numberOfSectionInTableView:(UITableView *)tableView
{
	return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kHeight2+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 中英文lyh11-1
	return _arrayCellData.count;
}

#pragma comment -TableView DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

	static NSString *CellIdentifier = @"Cell";
	GDTableVoiceCell *cell = (GDTableVoiceCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if( cell == nil)
	{
        cell = [[[GDTableVoiceCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:CellIdentifier
                                         withIsDownload:NO] autorelease];
        __block SettingDialectViewController *blockSelf = self;
        cell.downloadButtonTap = ^(GDVoiceDownloadButton *button){
            [blockSelf downloadButtonPress:button];
        };
	}
    GDTableVoiceData *cellData = [_arrayCellData objectAtIndex:indexPath.row];
    
    NSString *dialectKey = @"";

    
    cell.hasDownloadButton = !cellData.voiceDefault;
    cell.tag = cellData.voiceID ;
    if(!cellData.voiceDefault)
    {
        MWDialectDownloadTask *task = [[MWDialectDownloadManage sharedInstance] getLocalDialectTaskWithTaskID:cellData.voiceID];
        cell.voiceDownloadButton.total = task.total;
        dialectKey = [[MWDialectDownloadManage sharedInstance] getDialectTitle:task.title];
        MWDialectDownloadTask *downLoadtask = [[MWDialectDownloadManage sharedInstance] getTaskWithTaskID:cellData.voiceID];
        if(downLoadtask == nil)
        {
            cell.hasDownloadButton = YES;
            [cell.voiceDownloadButton setDownloadType:DOWNLOAD_NO];
        }
        else
        {
             cell.hasDownloadButton = YES;
            if(task.beNeedUpdate)
            {
                [cell.voiceDownloadButton setDownloadType:DOWNLOAD_UPDATE];
            }
            else
            {
                if(TASK_STATUS_READY == downLoadtask.status)
                {
                    [cell.voiceDownloadButton setDownloadType:DOWNLOAD_WAITING];
                }
                else if(TASK_STATUS_BLOCK == downLoadtask.status)
                {
                    [cell.voiceDownloadButton setDownloadType:DOWNLOAD_STOP];
                }
                else if(TASK_STATUS_RUNNING == downLoadtask.status)
                {
                    [cell.voiceDownloadButton setDownloadType:DOWNLOAD_ING];
                    cell.voiceDownloadButton.downloadPercent = downLoadtask.percent;
                }
                else
                {
                    cell.hasDownloadButton = NO;
                }
            }
        }
        cell.voiceDownloadButton.tag = cellData.voiceID;
    }
    else
    {
        dialectKey = cellData.voiceName;
    }
    
    cell.textLabel.text = dialectKey;

    //选择按钮的显示逻辑
    {
        BOOL *hasSelect = NO;
    
        if(cellData.voiceSelect != nil)
        {
            hasSelect = cellData.voiceSelect();
        }
        
        if(hasSelect)
        {
            BOOL displayDown = NO;
            if (cellData.voiceDefault)
            {
                displayDown = YES;
            }
            else
            {
                MWDialectDownloadTask *task = [[MWDialectDownloadManage sharedInstance] getLocalDialectTaskWithTaskID:cellData.voiceID];
                if(task.beNeedUpdate)
                {
                    displayDown = NO;
                }
                else
                {
                    displayDown = YES;
                }
            }
        
            if(displayDown)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Checkmark.png",IMAGEPATH_TYPE_1)];
                cell.accessoryView = tempimg;
                [tempimg release];
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.accessoryView = nil;
            }
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = nil;
        }
    }
    
    if (indexPath.row==0) {
        cell.backgroundType=BACKGROUND_HEAD;
    }
    else if(indexPath.row+1== _arrayCellData.count)
    {
        cell.backgroundType=BACKGROUND_FOOTER;
    }
    else
    {
        cell.backgroundType=BACKGROUND_MIDDLE;
    }
    _isDelete = NO;
	return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GDTableVoiceData *cellData = [_arrayCellData objectAtIndex:indexPath.row];
    
    if(!cellData.voiceDefault)
    {
        MWDialectDownloadTask *downLoadtask = [[MWDialectDownloadManage sharedInstance] getTaskWithTaskID:cellData.voiceID];
        if(downLoadtask != nil )
        {
            if(!downLoadtask.beNeedUpdate && downLoadtask.status == TASK_STATUS_FINISH)
            {
                [[MWDialectDownloadManage sharedInstance] switchTTSPathWithTaskID:cellData.voiceID];
            }
        }
        else
        {
//           [[MWDialectDownloadManage sharedInstance] switchTTSPath:indexPath.row];
        }
    }
    else
    {
        [[MWDialectDownloadManage sharedInstance] switchTTSPathWithTaskID:cellData.voiceID];
    }
    [_tableView reloadData];
}

#pragma mark - 删除实现
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL returnBool = NO;
    GDTableVoiceData *cellData = [_arrayCellData objectAtIndex:indexPath.row];
    if(cellData.voiceDefault == NO)
    {
        MWDialectDownloadTask *downLoadtask = [[MWDialectDownloadManage sharedInstance] getTaskWithTaskID:cellData.voiceID];
        if(downLoadtask != nil && !downLoadtask.beNeedUpdate)
        {
            returnBool = YES;
        }
    }
    return returnBool;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle style = UITableViewCellAccessoryNone;
    GDTableVoiceData *cellData = [_arrayCellData objectAtIndex:indexPath.row];
    if(!cellData.voiceDefault)
    {
        MWDialectDownloadTask *downLoadtask = [[MWDialectDownloadManage sharedInstance] getTaskWithTaskID:cellData.voiceID];
        if(downLoadtask != nil)
        {
            if(downLoadtask.status == TASK_STATUS_RUNNING)
            {
                [[MWDialectDownloadManage sharedInstance] stopWithTaskID:downLoadtask.taskId];
                GDTableVoiceCell *tempCell = (GDTableVoiceCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
                [tempCell.voiceDownloadButton setDownloadType:DOWNLOAD_STOP];
            }
            style = UITableViewCellEditingStyleDelete;
            _isDelete = YES;
        }
    }
    return style;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        GDTableVoiceData *cellData = [_arrayCellData objectAtIndex:indexPath.row];
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            if(!cellData.voiceDefault)
            {
                MWDialectDownloadTask *downLoadtask = [[MWDialectDownloadManage sharedInstance] getTaskWithTaskID:cellData.voiceID];
                if(downLoadtask != nil && !downLoadtask.beNeedUpdate)
                {
                    [[MWDialectDownloadManage sharedInstance] removeTaskId:downLoadtask.taskId];
                    
                        [self addDataByNetWork];
                   
                }
            }
       }
        [tableView setEditing:NO animated:NO];
        [_tableView reloadData];
    });
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return  STR(@"Universal_delete", Localize_Universal);
    
}
-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    _isDelete = NO;
}

#pragma mark - 下载按钮点击实现
- (void)downloadButtonPress:(GDVoiceDownloadButton *)button
{
    if(_isDelete)
    {
    }
    else
    {
        GDVoiceDownloadButton *temp = button;
    
        MWDialectDownloadTask *downLoadtask = [[MWDialectDownloadManage sharedInstance] getTaskWithTaskID:temp.tag];
        
        int status = downLoadtask.status;
        
        [[MWDialectDownloadManage sharedInstance] switchTTSPathWithTaskID:temp.tag];
        if (downLoadtask)
        {
            switch (status) {
                case TASK_STATUS_READY:
                {
                    [temp setDownloadType:DOWNLOAD_WAITING];
                    [[MWDialectDownloadManage sharedInstance] stopWithTaskID:temp.tag];
                }
                    break;
                case TASK_STATUS_RUNNING:
                {
                    [temp setDownloadType:DOWNLOAD_ING];
                    [[MWDialectDownloadManage sharedInstance] stopWithTaskID:temp.tag];
                }
                    break;
                case TASK_STATUS_BLOCK:
                {
                    [temp setDownloadType:DOWNLOAD_STOP];
                    [[MWDialectDownloadManage sharedInstance] downloadTTSWithTaskID:temp.tag];
                }
                break;
                case TASK_STATUS_FINISH:
                {
                }
                    break;
                default:
                break;
            }
        }
        else
        {
            temp.downloadPercent = 0;
            [[MWDialectDownloadManage sharedInstance] downloadTTSWithTaskID:temp.tag];
        }
        
    }
    [_tableView reloadData];
}

- (void)handleUIUpdate:(NSNotification *)result
{
    switch ([[result object] intValue]) {
        case UIUpdate_DialectDownloadUpdate:
        {
            if (_tableView) {
                [_tableView reloadData];
            }
            
        }
            break;
            
        default:
            break;
    }
    
}

#pragma  mark - 网络请求回调
/**
 *  @brief	请求成功回调委托
 *
 *	@param	RequestType	请求类型
 *
 *	@param	result	对下发数据进行处理过后的结果，id类型可以是NSDictionary NSArray
 *
 */
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    if(requestType == RT_DialectRequest)
    {
//        [QLoadingView hideWithAnimated:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addDataByNetWork];
        });
    }
}

/**
 *  @brief	请求失败回调委托
 *
 *	@param	RequestType	请求类型
 *
 *	@param	error	错误信息，上层需根据error的值来判断网络连接超时还是网络连接错误
 *
 */
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error
{
    if(requestType == RT_DialectRequest)
    {
        [QLoadingView showAlertWithoutClick:STR(@"Account_NetError",Localize_Account) ShowTime:2.0f];
//        [QLoadingView hideWithAnimated:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addDataByNetWork];
        });
    }
}


#pragma mark - 下载的委托
/*
 进度通知
 sender：通知发送者
 current：当前已完成的工作量
 total：总的工作量
 */
static int DialectCount = 20;
-(void)progress:(Task*)sender current:(long long)current total:(long long)total
{
   
    if(DialectCount == 20)
    {
        DialectCount = 0;
        NSLog(@"-(void)progress:(Task*)sender current:(long long)current total:(long long)total");
        dispatch_async(dispatch_get_main_queue(), ^{
            for (int i = 0; i < _arrayCellData.count; i++)
            {
                GDTableVoiceCell *tempCell = (GDTableVoiceCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                if(tempCell && tempCell.tag == sender.taskId)
                {
                    tempCell.voiceDownloadButton.downloadPercent = ((current * 1.0f) / (total * 1.0f)) * 100;
                }
            }
        });
    }
    DialectCount++;
}

/*
 任务完成通知
 sender：通知发送者
 */
-(void)finished:(Task*)sender
{
    NSLog(@"-(void)finished:(Task*)sender");
    [self reloadTabelData];
}

/*
 出现异常通知
 sender：通知发送者
 exception：异常内容
 */
-(void)exception:(Task*)sender exception:(id)exception
{
//    if (exceptionCode == DOWNLOADHANDLETYPE_UPZIPFAIL) {//解压失败，删除数据，重新下载
//        
//        [self removeTaskId:sender.taskId];
//        
//    }
//    else if( exceptionCode == DOWNLOADHANDLETYPE_CURRENTLAGERTOTAL || exceptionCode == DOWNLOADHANDLETYPE_UPZIPFAIL || exceptionCode == DOWNLOADHANDLETYPE_CURRENTSMALLTOTAL || exceptionCode == DOWNLOADHANDLETYPE_MD5NOMATCH )
    if([exception intValue] == DOWNLOADHANDLETYPE_UPZIPFAIL || [exception intValue] == DOWNLOADHANDLETYPE_CURRENTLAGERTOTAL ||
       [exception intValue] == DOWNLOADHANDLETYPE_CURRENTSMALLTOTAL ||[exception intValue] == DOWNLOADHANDLETYPE_MD5NOMATCH)
    {
        [[MWDialectDownloadManage sharedInstance]start];
    }
    NSLog(@"-(void)exception:(Task*)sender exception:(id)exception");
    if([exception isKindOfClass:[NSNumber class]])
    {
        if ([exception intValue] == DOWNLOADHANDLETYPE_URLREQUESTFAIL ||
            [exception intValue] == DOWNLOADHANDLETYPE_NONETWORK)
        {
            //网络连接出错，请检查网络连接后重试
            GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_networkError",Localize_Universal)] autorelease];
            
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
            [alertView show];
            if(sender)
            {
//                [self setStopByID:sender.taskId];
            }
            
            if ([exception intValue] == DOWNLOADHANDLETYPE_NONETWORK)
            {
                if(sender)
                {
//                    [self setButtonStatus:sender.taskId withType:DOWNLOAD_STOP];
//                    [self setRightItemEnable];
                    [self reloadTabelData];
                    return;
                }
            }
        }
        else if ([exception intValue] == DOWNLOADHANDLETYPE_NOSKINID )
        {
            //当前版本无兼容的皮肤，请升级至最新版本
            GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"SkinDownload_NoSkinID",Localize_Setting)] autorelease];
            
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
            [alertView show];
        }
        else if ([exception intValue] == DOWNLOADHANDLETYPE_CURRENTLAGERTOTAL )
        {
//            [_skinDownloadData requestPlistData];
            //下载的大小大于服务器返回大小
            GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"SkinDownload_CurrentLarge",Localize_Setting)] autorelease];
            
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
            [alertView show];
        }
        else if ([exception intValue] == DOWNLOADHANDLETYPE_CURRENTSMALLTOTAL )
        {
            //下载的大小小于服务器返回大小
            GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_actualSmallServer",Localize_CityDownloadManage)] autorelease];
            
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
            [alertView show];
        }
        else if ([exception intValue] == DOWNLOADHANDLETYPE_NOSPACE )
        {
            //磁盘空间不足
            GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"SkinDownload_NoSpace",Localize_Setting)] autorelease];
            
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
            [alertView show];
        }
        else if ([exception intValue] == DOWNLOADHANDLETYPE_UPZIPFAIL )
        {
            //文件解压失败
            GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"SkinDownload_UnzipFail",Localize_Setting)] autorelease];
            
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
            [alertView show];
        }
        else if ([exception intValue] == DOWNLOADHANDLETYPE_3GDOWNLOAD )
        {
            [self reloadTabelData];
            return;
        }
        if(sender)
        {
//            [[MWSkinDownloadManager sharedInstance] removeTaskId:sender.taskId];
//            [self setRightItemEnable];
//            [self setButtonStatus:sender.taskId withType:DOWNLOAD_NO];
        }
        else
        {
//            [self setRightItemEnable];
//            [self setButtonStatus:[MWSkinDownloadManager sharedInstance].skinID withType:DOWNLOAD_NO];
        }
        
    }
    else
    {
        GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_networkError",Localize_Universal)] autorelease];
        
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
        [alertView show];
        
        if(sender)
        {
            [self reloadTabelData];
            return;
        }
        
    }
    [self reloadTabelData];
}

/*
 数据解压完成通知
 sender: 通知发送者
 */
- (void)unZipFinish:(Task*)sender
{
    NSLog(@"- (void)unZipFinish:(Task*)sender");
     [self reloadTabelData];
}

 - (void) reloadTabelData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

@end
