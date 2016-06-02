//
//  MWApp.m
//  AutoNavi
//
//  Created by yu.liao on 13-7-29.
//
//

#import "MWApp.h"
#import "MWTTS.h"
#import "MWPreference.h"
#import "plugin-cdm-TaskManager.h"
#import "MWPoiOperator.h"
#import "UIDevice+Category.h"
#import "GDBL_SinaWeibo.h"
#import "GDBL_TCWeibo.h"
#import "POISearchHistory.h"
#import "MWSkinDownloadManager.h"
#import "launchRequest.h"
#import "GDCacheManager.h"
#import "MWDialectDownloadTask.h"
#import "MWDialectDownloadManage.h"
#import "MWAccountOperator.h"
#import "GDBL_Account.h"
#import "MWCarOwnerServiceManage.h"
#import "MWCloudDetourManage.h"
#import "MileRecordDataControl.h"

static MWApp *instance = nil;

@implementation MWApp

+(MWApp*)sharedInstance
{
    @synchronized(self)
    {
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

+(void)releaseInstance
{
    @synchronized(self)
    {
        if (instance != nil)
        {
            [instance release];
            instance = nil;
        }
    }
}

- (id)init
{
    self = [super init];
    if(self)
    {
    }
	
    return self;
}

- (BOOL)loadTTS
{
    int ttsIndex = [[MWPreference sharedInstance] getValue:PREF_IS_LZLDIALECT];
    
    if (ttsIndex > 0) {
        
        MWDialectDownloadTask *task = [[MWDialectDownloadManage sharedInstance] getTaskWithTaskID:ttsIndex];
        
        if (task) {
            
            if (task && task.status == TASK_STATUS_FINISH && [[NSFileManager defaultManager] fileExistsAtPath:[Dialect_path stringByAppendingString:task.folderName]]) {
                
                [[MWTTS SharedInstance] SetTTSSpeed:task.dialectPlaySpeed];
                [[MWTTS SharedInstance] SetTTSUsePrompts:task.dialectHasRecord];
                [[MWTTS SharedInstance] SetTTSFolder:task.folderName];
                [[MWPreference sharedInstance] setValue:PREF_TTSROLEINDEX Value:task.dialectRoleID];
                
            }
            else
            {
                [[MWDialectDownloadManage sharedInstance] removeTaskId:task.taskId];
                [[MWPreference sharedInstance] setValue:PREF_TTSROLEINDEX Value:0];
            }
        }
        else
        {
            [[MWPreference sharedInstance] setValue:PREF_TTSROLEINDEX Value:0];
        }
        
        
    }
    else{
        [[MWPreference sharedInstance] setValue:PREF_TTSROLEINDEX Value:0];
    }
    
    return YES;
}

- (BOOL)loadAccount
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@",account_path]])
    {//主要为了处理老版本包含的内容不一样，升级会造成死机的问题
        NSMutableArray *array=[[NSMutableArray alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@",account_path]];
        if ([array count] < 7)
        {
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@",account_path] error:nil];
        }
        [array release];
    }
    
    NSArray *tmpArray;
    GDBL_GetAccountInfo(&tmpArray);
    int login = [[tmpArray objectAtIndex:0] intValue];
    if (login == 0)
    {
        NSURL *deleteURL = [NSURL URLWithString:kNetDomain];
        NSHTTPCookieStorage *allCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookieArray=[allCookie cookiesForURL:deleteURL];
        //deleteURL即为请求的源地址,删除对应源地址产生的cookie
        for(id obj in cookieArray)
        {
            [allCookie deleteCookie:obj];
        }
    }
    //兼容已登入没有用户ID
    if (tmpArray.count>7) {
        
        NSString *userId =[tmpArray objectAtIndex:7];
        if (userId.length==0) {
            NSString * loginType=nil;
            if (login==1||login==2) {
                //高德登入
                
                loginType = [NSString checkPhoneStandardWith:[tmpArray objectAtIndex:1]]?@"2":@"1";
                [MWAccountOperator accountLoginWith:REQ_LOGIN phone:[tmpArray objectAtIndex:1] password:[tmpArray objectAtIndex:2] type:loginType delegate:self];
            }
            else if (login>2){
                
                if (login==3||login==5) {
                    loginType=@"1";
                }
                else
                {
                    loginType=@"2";
                }
                [MWAccountOperator accountThirdLoginWith:REQ_LOGIN tpuserid:[tmpArray objectAtIndex:5] tpusername:[tmpArray objectAtIndex:6] tptype:loginType delegate:self];
                
            }
        }
    }
    
    
    return YES;
}



/***
 * @name    加载皮肤类型
 * @param
 * @author  by bazinga
 ***/
- (void)loadSkin
{
    //复制皮肤加载plist
//    NSError *error = nil;
//    if(![[NSFileManager defaultManager] fileExistsAtPath:skinConfigDocumentPath])
//    {
//        if([[NSFileManager defaultManager] fileExistsAtPath:skinConfigBundlePath])
//        {
//            [[NSFileManager defaultManager] copyItemAtPath:skinConfigBundlePath toPath:skinConfigDocumentPath error:&error];
//        }
//    }
    //加载皮肤数据
//    NSString *stringFolder = [[GDSkinColor sharedInstance] getFolderByID:[[MWPreference sharedInstance] getValue:PREF_SKINTYPE]];
//    
//    if([[MWPreference sharedInstance] getValue:PREF_SKINTYPE] != 0 && [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",Skin_path,stringFolder]])
//    {
//        NSString *pathstring = [NSString stringWithFormat:@"%@%@",Skin_path,stringFolder];
//        [UIImage setImageSkinType:YES SkinPath:pathstring];
//        [[GDSkinColor sharedInstance] refresh:[NSString stringWithFormat:@"%@%@%@",Skin_path,stringFolder,SKIN_PLIST_NAME]];
//    }
//    else
    {
       // [[MWPreference sharedInstance] setValue:PREF_SKINTYPE Value:[SKIN_DEFAULT_ID intValue]];
        [UIImage setImageSkinType:NO SkinPath:nil];
        [[GDSkinColor sharedInstance] refresh:[[NSBundle mainBundle] pathForResource:@"colorConfig" ofType:@"plist"]];
    }
    
   // [MWSkinDownloadManager sharedInstance];
}


/***
 * @name    开机语音播报
 * @param
 * @author  by bazinga
 ***/
-(void) openSound
{
    NSString *wavPath = nil;
    //是否开启开机语音播报
    if ([[MWPreference sharedInstance] getValue:PREF_SWITCHEDVOICE]) {
        
        
        BOOL hasCache = [[GDCacheManager globalCache] hasCacheForKey:GDCacheType_PowerVoice];
        
        if (hasCache && ![[MWPreference sharedInstance] getValue:PREF_IS_POWERVOICE_PLAY]) {//有下载的开机语音，而且没过期则播报下载的开机语音，否则播报本地语音
            
            
            wavPath = [[GDCacheManager globalCache] pathWithKey:GDCacheType_PowerVoice];
            
            [[MWPreference sharedInstance] setValue:PREF_IS_POWERVOICE_PLAY Value:YES];
        }
        else {
            //判断是否是第一次进入程序
            if([[MWPreference sharedInstance] getValue:PREF_FIRSTSTART])
            {
                //第一次进入，播放的语音
                wavPath = [[NSBundle mainBundle] pathForResource:@"Welcome" ofType:@"mp3"];
            }
            else
            {
                //第二次之后进入，播放的语音
                wavPath = [[NSBundle mainBundle] pathForResource:@"Welcome1" ofType:@"mp3"];
            }
            
        }
        
        [[MWTTS SharedInstance] playSoundWithPath:wavPath priority:TTSPRIORITY_HIGHT];
        
    }
}

- (int)loadEngine
{
    
    
    int res = -1;
    NSString *temp = [NSString stringWithUTF8String:g_data_path];
    Gchar path[260] = {0};
    memcpy(path, NSStringToGchar(temp), 260*sizeof(Gchar));
    GDBL_SetAppPath(path,260);
    
    NSLog(@"%@",GcharToNSString(path));
    res = GDBL_Startup(0);
	if (0 == res)
	{
        if (UIApplicationStateBackground == [[UIApplication sharedApplication] applicationState]) {
            //如果是在后台初始化引擎 需要设置后台模式,防止崩溃
            [[MWPreference sharedInstance] setValue:PREF_BACKGROUND_MODE Value:1];
        }
        
        [MWEngineListener sharedInstance];
        [ANParamValue sharedInstance].isInit = YES;
        
        [self initEngine];
		
        if ([[TaskManager taskManager].taskList count]  == 0)//modify by hlf for 数据下载列表恢复和数据同步
        {
            [[TaskManager taskManager] restore];
        }
		
		NSLog(@"Init Success!");
        
        isEngineInit = 1;
        return res;
	}
	NSLog(@"Init Fail!");
	
    
	return res;
}

- (void)unloadEngine {
    
	GDBL_DestroyView();
	GDBL_Cleanup();
}



- (BOOL)initEngine
{
    CGSize size = {0};
    size.width = SCREENWIDTH;
    size.height = SCREENHEIGHT;
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    NSString *deviceString = [UIDevice getDeviceAndOSInfo];
    if ([deviceString hasPrefix:@"iPhone"])
    {
        if ([deviceString hasPrefix:@"iPhone1"] || [deviceString hasPrefix:@"iPhone2"] || [deviceString hasPrefix:@"iPhone3"]|| [deviceString hasPrefix:@"iPhone4"])//iPhone 4s、iPhone 4及之前的设备
        {
            GDBL_SetScaleRate(GSCALERATE_PPI_SIZE, size.width * scale_screen, size.height * scale_screen, 3.5, 0);
        }
        else if ([deviceString hasPrefix:@"iPhone5"] || [deviceString hasPrefix:@"iPhone6"])//iPhone 5 、iPhone 5s
        {
            GDBL_SetScaleRate(GSCALERATE_PPI_SIZE, size.width * scale_screen, size.height * scale_screen, 4.0, 0);
        }
        else if ([deviceString hasPrefix:@"iPhone7"])//iPhone 6
        {
            if ([deviceString isEqualToString:@"iPhone7,1"])//iPhone 6 Plus
            {
                GDBL_SetScaleRate(GSCALERATE_PPI_SIZE, size.width * scale_screen, size.height * scale_screen, 5.5, 0);
            }
            else
            {
                GDBL_SetScaleRate(GSCALERATE_PPI_SIZE, size.width * scale_screen, size.height * scale_screen, 4.7, 0);
            }
        }
        else
        {
            GDBL_SetScaleRate(GSCALERATE_PPI_SIZE, size.width * scale_screen, size.height * scale_screen, 4.7, 0);
        }
    }
    else if ([deviceString hasPrefix:@"iPad"])
    {
        if ([deviceString isEqualToString:@"iPad2,5"] || [deviceString isEqualToString:@"iPad2,6"] || [deviceString isEqualToString:@"iPad2,7"]||[deviceString isEqualToString:@"iPad4,4"] || [deviceString isEqualToString:@"iPad4,5"]||[deviceString isEqualToString:@"iPad4,6"] )//iPad Mini、iPad Retina Mini
        {
            //ipad mini
            GDBL_SetScaleRate(GSCALERATE_PPI_SIZE, size.width * scale_screen, size.height * scale_screen, 7.9, 0);
        }
        else
        {
            GDBL_SetScaleRate(GSCALERATE_PPI_SIZE, size.width * scale_screen, size.height * scale_screen, 9.7, 0);
        }
    }
    else if ([deviceString hasPrefix:@"iPod"])
    {
        if ([deviceString hasPrefix:@"iPod1"] || [deviceString hasPrefix:@"iPod2"] || [deviceString hasPrefix:@"iPod3"]|| [deviceString hasPrefix:@"iPod4"])
        {
            GDBL_SetScaleRate(GSCALERATE_PPI_SIZE, size.width * scale_screen, size.height * scale_screen, 3.5, 0);
        }
        else
        {
            GDBL_SetScaleRate(GSCALERATE_PPI_SIZE, size.width * scale_screen, size.height * scale_screen, 4.0, 0);
        }
    }
    else
    {
        GDBL_SetScaleRate(GSCALERATE_PPI_SIZE, size.width * scale_screen, size.height * scale_screen, 3.5, 0);
    }
    
    
    GDBL_CreateView();
    
    [[MWPreference sharedInstance] setValue:PREF_TRACK_RECORD Value:0];//每次开机手动关闭自动纪录轨迹开关
    
    GNAVIMODE eWalkFlag = GNAVI_MODE_CAR;
    GDBL_SetParam(G_NAVI_MODE, &eWalkFlag);
    
    
    int  streame = 1;;
    GDBL_SetParam(G_SHOW_TMCSTREAMEVENT,&streame);
    
    [[MWPreference sharedInstance] setValue:PREF_DISABLE_GPS Value:SWITCH_OPEN];
    
    //设置tmc显示为城市tmc
    int isShow = 0;
    GDBL_SetParam(G_MAP_SHOW_TMC, &isShow);
    
    //设置多路线演算后是显示一条路径还是全部显示
    int value = 1;
    GDBL_SetParam(G_MAP_SHOW_ALL_MULTI_ROUTE, &value);
    
    [[MWPreference sharedInstance] setValue:PREF_SHOW_MAP_GRAY_BKGND Value:NO];
    [[MWPreference sharedInstance] setValue:PREF_MAP_TMC_SHOW_OPTION Value:NO];
    
    int i = 1;
	GDBL_SetParam(G_MAP_SHOW_TRACK, &i);
    
    BOOL trafficEvent = 1;
    [[MWPreference sharedInstance] setValue:PREF_SHOW_TMCEVENT Value:trafficEvent];
    
    //同步白天黑夜色盘
    [MWDayNight SyncDayNightTheme];
    
    if (![[MWPreference sharedInstance] getValue:PREF_MUTE]) {
        [[MWPreference sharedInstance] setValue:PREF_SWITCHEDVOICE Value:NO];
    }
    
    [ANParamValue sharedInstance].isStartUpNeedShowView = [[MWPreference sharedInstance] getValue:PREF_STARTUPWARNING];
    
    [[MWCloudDetourManage sharedInstance] updateCloudAvoidPath];//add by hlf for 更新云端避让文件 at 2014.04.02
    
    value = 1;
    GDBL_SetParam(G_MAP_SHOW_ZOOM_VIEW, &value);
    
    GDBL_SetParam(G_SHOW_ZOOM_VIEW, &value);
    
    GDBL_SetParam(G_FAVORITE_SHOW_OPTION, &value);
    
    GDBL_SetParam(G_ROADNAME_LABEL, &value);
    
    GDBL_SetParam(G_POI_HTMUSED, &value);   /**< 港澳台数据使用标志 */
    
    GROUTETMCOPTION tmcOption = GROUTE_TMC_OPTION_NONE;
    GDBL_SetParam(G_ROUTE_TMC_OPTION, &tmcOption); /*所有规划原则，开启TMC参与路径演算*/
    
    GDBL_SetParam(G_MAP_SHOWTMCONROAD, &value); /**< 控制1km-10km 0:tmc 显示在道路两旁 1:tmc流显示在道路上 */
    
    GDBL_SetParam(G_MAP_ASHING_MULTIROUTE, &value); /**< 多路径时是否灰化未选中 */
    
    GDBL_SetParam(G_SHOW_ECOMPASS, &value); /**< 显示车标上的东南西北 */
    
    GDBL_SetParam(G_MAP_IS2MODE, &value); /**< 是否只有两种地图模式 即设置无3D模式*/
    
    [MWEngineInit SetImagePixs];            /**< 设置3dmark，logo大小*/
    
    GDBL_SetParam(G_GUIDE_SHOWLANES, &value); /**< 是否显示车道信息 0-不显示车道 1-显示车道*/
    
    GDBL_SetParam(G_MAP_SHOW_ANIMATED, &value); /**< 动画控制开关 默认开*/
    
    [[ANOperateMethod sharedInstance] GMD_CompatibilityOldEngineFiles]; //兼容引擎旧文件，轨迹，收藏夹，避让
    
    //pcd是否要关闭，根据路况播报开关
    BOOL bTrafficSpeakOn = [[MWPreference sharedInstance] getValue:PREF_SPEAKTRAFFIC];
    if (!bTrafficSpeakOn)
    {
        int value = 0;
        GDBL_SetParam(G_FUNCTION_SUPPORT_PCD, &value);
    }
    
    
    //自动缩放设置
    int autoZoomValue = [[MWPreference sharedInstance] getValue:PREF_AUTOZOOM];
    [[MWPreference sharedInstance] setValue:PREF_AUTOZOOM Value:autoZoomValue];
    
    [MWPoiOperator changeEnginePoiAndSafe];
    
    value = 0;
    GDBL_SetParam(G_SPEAK_DEVIATE, &value); /**< 偏航提示开关,关闭该开关 */
    
#if PROJECTMODE
    GSTATUS res = GDBL_DumpNMEA(YES);
    if (res == GD_ERR_OK)
    {
        NSLog(@"成功开启GPS信息记录");
    }
#endif
    return YES;
}

-(BOOL)saveAppData
{
    [[GDBL_UserBehaviorCountNew shareInstance] saveData];//保存用户行为统计
    
	[[TaskManager taskManager] store];     //保存数据下载列表
    
	[[MWPreference sharedInstance] savePreference];
    
    if ([ANParamValue sharedInstance].isPath == 1)
    {
        [[MWHistoryRoute sharedInstance] SaveHistoryRoute];
    }
    if ([[ANParamValue sharedInstance] isInit]) {
        GDBL_SaveUserConfig();
    }
    
    
    [[MWSkinDownloadManager sharedInstance] store];//皮肤保存
    [[MWSkinDownloadManager sharedInstance] storeSkinUpdateVersion];//皮肤更新的版本号
    
    [[MWDialectDownloadManage sharedInstance] store];  //方言下载列表保存
    [[MWDialectDownloadManage sharedInstance] serviceStore];//后台方言列表保存
    
    [[MWCarOwnerServiceManage sharedInstance] store];//车主服务列表保存
    
    [[MWCloudDetourManage sharedInstance] store];//云端避让下载列表保存
    
    [[MileRecordDataControl sharedInstance] store];//存储里程文件
    
    return YES;
}

- (BOOL)restoreAppData
{
    
    [[MWPreference sharedInstance] loadPreference];
    
    [self loadTTS];            //加载语音库
    
    [self loadAccount];        //加载帐户信息
    
    [[ANOperateMethod sharedInstance] GMD_SetSystemLanguage:NO];//根据系统语言设置本地化语言
    
    [self loadSkin];           //加载皮肤
    
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_6_0) {
        if (Orientation==UIInterfaceOrientationLandscapeLeft||Orientation==UIInterfaceOrientationLandscapeRight) {
            [[MWPreference sharedInstance] setValue:PREF_INTEFACEORIENTATION Value:UIInterfaceOrientationPortrait];
        }
    }
    
    return YES;
}




-(void)ClearAllEngineData
{
    [MWPoiOperator clearFavoriteWith:GFAVORITE_CATEGORY_DEFAULT];
    [MWPoiOperator clearFavoriteWith:GFAVORITE_CATEGORY_HOME];
    [MWPoiOperator clearFavoriteWith:GFAVORITE_CATEGORY_COMPANY];
    [MWPoiOperator clearFavoriteWith:GFAVORITE_CATEGORY_HISTORY];
    [MWPoiOperator clearSmartEyesWith:GSAFE_CATEGORY_ALL ];
    [[GDBL_SinaWeibo shareSinaWeibo] logOut];//新浪微博登出
    [[GDBL_TCWeibo shareTCWeibo] logOut];//腾讯微博登出
    [POISearchHistory removeAllHistory];//历史搜索纪录
    
    [[MWHistoryRoute sharedInstance] MW_RemoveAllGuideRoute];//清空历史路线
}

-(void)executeLogicAfterWarningViewAndNewFunction:(id)viewController
{
    [ANParamValue sharedInstance].isWarningView  = NO;
    
    [[launchRequest shareInstance] softWareVersionUpdateRequest];//软件版本更新检测
    [viewController ContinueNavi]; //续航
    
    if ([[MWPreference sharedInstance] getValue:PREF_STARTUPWARNING]) {
        [self openSound];
    }
    else{
        [self performSelector:@selector(openSound) withObject:nil afterDelay:3.0];
    }
    
    //将第一次进入程序的标志位置为0，
    //---   [self openSound];  这个函数都用到第一次进入程序的判断  ---
    [[MWPreference sharedInstance] setValue:PREF_FIRSTSTART Value:0];
    
}

@end
