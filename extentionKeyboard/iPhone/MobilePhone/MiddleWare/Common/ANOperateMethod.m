//
//  ANOperateMethod.m
//  AutoNavi
//
//  Created by GHY on 12-3-1.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//


#import "ANOperateMethod.h"
#import "ANParamValue.h"
#import "DefineNotificationParam.h"
#include <sys/xattr.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import"sys/utsname.h"
#import "GDBL_Account.h"
#import "MWMapOperator.h"
#import	<CoreMotion/CoreMotion.h>
#import "MWSearchResult.h"
#import "POICommon.h"
#import "QLoadingView.h"
#import "MWTTS.h"
#import "CustomRealTimeTraffic.h"
#import "CustomTrafficPlaySound.h"
#import "MileRecordDataControl.h"
#import "UMengEventDefine.h"

#import <AudioToolbox/AudioToolbox.h>

@interface ANOperateMethod()

@property (nonatomic,copy) NSString *startTime;
@property (nonatomic,assign) GCOORD startCoord;


@end

static ANOperateMethod *sharedANOperateMethod = nil;

static BOOL fun(void)
{
    return YES;
}

@implementation ANOperateMethod

@synthesize localizeType,startTime,startCoord;

#pragma mark 单例
+ (ANOperateMethod *)sharedInstance {
	
	if (nil==sharedANOperateMethod)
	{
		sharedANOperateMethod = [[ANOperateMethod alloc] init];
	}
	return sharedANOperateMethod;
}

- (id)init {
	
	self = [super init];
	if (self)
	{
       localizeType = [[MWPreference sharedInstance] getValue:PREF_UILANGUAGE];
       
	}
	return self;
}


#pragma mark 其他操作==========================================================================



#pragma mark 设置相应的目录不备份
-(void)GMD_BackUp
{
	NSURL *url;
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",document_path]];
    
    //    if(&NSURLIsExcludedFromBackupKey == nil)// iOS <= 5.0.1
    {
        const char* filePath = [[url path] fileSystemRepresentation];
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    }
    //   else// iOS >= 5.1
    //    {
    //        NSError *error = nil;
    //       [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    //    }
}






#pragma mark 拨打95190
- (void)getListenMessage:(NSNotification *)notify
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_ACCOUNT object:nil];
    NSArray* result = (NSArray*)[notify object];
    int requestType=[[result objectAtIndex:1] intValue];
	if (result==nil||[result count]<3)
    {
        if(requestType == REQ_PRE_CALL_95190)
        {
            NSLog(@"pre_call fail");
        }
		return;
	}
    
    NSString *notifyName =[notify name];
	if ([notifyName isEqual:NOTIFY_ACCOUNT])
    {
		if ([[result objectAtIndex:0] isEqual:PARSE_OK])
        {
            if(requestType == REQ_PRE_CALL_95190)
            {
                
                int nResult = [[result objectAtIndex:2] intValue];
                if (nResult == GD_ERR_OK)
                {
                    NSLog(@"pre_call success");
                }
                else
                {
                    NSLog(@"pre_call fail");
                }
            }
        }
        
    }
}

-(void)GMD_Call_95190:(NSString *)phone
{
    
    [ANParamValue sharedInstance].isReq95190Des = 1;
    NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",phone]];
    [[UIApplication sharedApplication] openURL:telURL];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getListenMessage:) name:NOTIFY_ACCOUNT object:nil];
}

#pragma mark 将view转化成镜子中的view显示
- (void)GMD_ChangeTomirrorViewInView:(UIView *)view isSwitch:(BOOL)isSwitch
{
    static UIImageView *mirror_view = nil;
    if (view == nil)
    {
        if (mirror_view != nil)
        {
            [mirror_view removeFromSuperview];
            [mirror_view release];
            mirror_view = nil;
        }
        return;
    }

    if (mirror_view == nil)
    {
        mirror_view = [[UIImageView alloc] initWithFrame:view.bounds];
    }
    else
    {
        [mirror_view removeFromSuperview];
    }
    
    if(!isSwitch)
    {
        [mirror_view removeFromSuperview];
        [mirror_view release];
        mirror_view = nil;
        return;
    }
    
    mirror_view.frame = view.bounds;
    if(IOS_7)
    {
        mirror_view.center = CGPointMake(view.bounds.size.width/2,
                                         view.bounds.size.height/2 + DIFFENT_STATUS_HEIGHT);
    }
    else
    {
        mirror_view.center = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
    }
//    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI);
//    [mirror_view setTransform:trans];
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0); //高清下scale为2，否则为1
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextTranslateCTM(context, 0,view.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
        
    [view.layer renderInContext:context];
    mirror_view.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [view addSubview:mirror_view];
    [view bringSubviewToFront:mirror_view];
}

#pragma mark 设置系统语言
-(BOOL)GMD_SetSystemLanguage:(BOOL)isEngineInit
{
    if (isEngineInit) {//引擎已初始化
        if (![[MWPreference sharedInstance] getValue:PREF_SETLANGUAGEMANUALLY])
        {
            // UI保存当前的语言选项0简体1繁体2英文
            // en:英文  zh-Hans:简体中文   zh-Hant:繁体中文    ja:日本  ......
            NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
            NSArray* languages = [defs objectForKey:@"AppleLanguages"];
            NSString* preferredLang = [languages objectAtIndex:0];
            if ([preferredLang isEqualToString:@"zh-Hans"]) {
                [[MWPreference sharedInstance] setValue:PREF_UILANGUAGE Value:0];
            }
            else if([preferredLang isEqualToString:@"zh-Hant"]){
                [[MWPreference sharedInstance] setValue:PREF_UILANGUAGE Value:1];
                
            }else{
                [[MWPreference sharedInstance] setValue:PREF_UILANGUAGE Value:2];
            }
        }
        else{
            localizeType = [[MWPreference sharedInstance] getValue:PREF_UILANGUAGE];
            [[MWPreference sharedInstance] setValue:PREF_UILANGUAGE Value:localizeType];
        }
    }
    else{
        if (![[MWPreference sharedInstance] getValue:PREF_SETLANGUAGEMANUALLY])
        {
            // UI保存当前的语言选项0简体1繁体2英文
            // en:英文  zh-Hans:简体中文   zh-Hant:繁体中文    ja:日本  ......
            NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
            NSArray* languages = [defs objectForKey:@"AppleLanguages"];
            NSString* preferredLang = [languages objectAtIndex:0];
            if ([preferredLang isEqualToString:@"zh-Hans"]) {
                localizeType = 0;
            }
            else if([preferredLang isEqualToString:@"zh-Hant"]){
                localizeType = 1;
                
            }else{
                localizeType = 2;
            }
            
        }
    }
    
    return YES;
}

#pragma mark 设置本地化路径
- (NSString *)GMD_SetLocalizeKey:(NSString *)key table:(NSString *)tableName
{
    NSString *path = nil;
    if (0 == localizeType) {
        path=[[NSBundle mainBundle] pathForResource:@"zh-Hans" ofType:@"lproj"];
    }
    else if (1 == localizeType){
        path=[[NSBundle mainBundle] pathForResource:@"zh-Hant" ofType:@"lproj"];
    }
    else if (2 == localizeType){
        path=[[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
    }
    
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    NSString *string = [bundle localizedStringForKey:key value:@"" table:tableName];
    return string;
}

#pragma mark 阿拉伯数字转汉字
- (NSString *)ArabToChinese:(int)num
{
    NSArray *array = [NSArray arrayWithObjects:@"零",@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",nil];
    
    NSString *temp = [NSString string];
    temp = @"方案";
    int ten = num/10;
    if (ten)
    {
        if (ten != 1)
        {
            temp = [temp stringByAppendingString:[array objectAtIndex:ten]];
        }
        temp = [temp stringByAppendingString:@"十"];
    }
    
    int bits = num%10;
    if (bits)
    {
        temp = [temp stringByAppendingString:[array objectAtIndex:bits]];
    }
    temp = [temp stringByAppendingString:@":"];
    
    return temp;
}


-(void)GMD_PassInfoToHud
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_PASSINFOTOHUD object:nil userInfo:nil
     ];
}



#pragma mark- GPS信号情况播报
- (void)GMD_PlayGPS
{
    
    
        if (![[MWPreference sharedInstance] getValue:PREF_DISABLE_GPS] || ![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
            [[MWTTS SharedInstance] playSoundWithString:STR(@"Main_OpenGPSSound", Localize_Main) priority:TTSPRIORITY_HIGHT];
        }
        else{
            GGPSINFO pGpsInfo = {0};
            GDBL_GetGPSInfo(&pGpsInfo);
            
            if (pGpsInfo.nValid) {
                
                [[MWTTS SharedInstance] playSoundWithString:STR(@"Main_GPSLocationedSound", Localize_Main) priority:TTSPRIORITY_HIGHT];
            }
            else{
                
                [[MWTTS SharedInstance] playSoundWithString:STR(@"Main_GPSLocatingSound", Localize_Main) priority:TTSPRIORITY_HIGHT];
            }
        }
}
#pragma mark- 实时交通语音播报
- (void)GMD_TrafficPlaySound
{
    if (!isEngineInit)
    {
        return;
    }
    BOOL bTMCStartup = [MWEngineSwitch isTMCOn];
    BOOL bTrafficSpeakOn = [[MWPreference sharedInstance] getValue:PREF_SPEAKTRAFFIC];
    BOOL bPath = [[ANParamValue sharedInstance] isPath];
    BOOL bSimulate = [[ANParamValue sharedInstance] isNavi];
    Gint32 mapType;
    GMAPVIEW pMapview = {0};
    GDBL_GetMapView(&pMapview);
    mapType = pMapview.eViewType;
    if (bTMCStartup && bTrafficSpeakOn && bPath &&!bSimulate && mapType == GMAP_VIEW_TYPE_MAIN)
    {
        [[CustomTrafficPlaySound SharedInstance] StartPlaySound];
    }
    else
    {
        [[CustomTrafficPlaySound SharedInstance] StopPlaySound];
    }
}

#pragma mark- 兼容引擎旧文件
-(void)GMD_CompatibilityOldEngineFiles
{
    //兼容引擎轨迹文件
    NSString *document_trc = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/trc/"];
    NSString *trc_path = [NSString stringWithFormat:@"%@/trc/", GNaviData_Directory];
	if ([[NSFileManager defaultManager] fileExistsAtPath:trc_path] && [[NSFileManager defaultManager] fileExistsAtPath:document_trc])
    {
        NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:document_trc error:nil];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like %@",@"*.dat"];
        NSArray *results = [fileArray filteredArrayUsingPredicate:predicate];
        for (int i = 0; i < [results count]; i++)
        {
            NSString *tempFilePath = [results objectAtIndex:i];
            NSString *filePath1 = [document_trc stringByAppendingFormat:@"/%@",tempFilePath];
            NSString *filePath2 = [trc_path stringByAppendingFormat:@"/%@",tempFilePath];
            NSError *error = nil;
            [[NSFileManager defaultManager] moveItemAtPath:filePath1 toPath:filePath2 error:&error];
            GSTATUS res = [MWTrack UpgradeTrackFile:NSStringToGchar(tempFilePath)];
            NSLog(@"UpgradeTrackFile %d",res);
        }
        [[NSFileManager defaultManager]removeItemAtPath:document_trc error:nil];
	}
    
    //兼容引擎的收藏夹 历史目的地 家 公司
    NSString *document_addr = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/address/"];
    NSString *addr_path = [NSString stringWithFormat:@"%@/address/", GNaviData_Directory];
    if ([[NSFileManager defaultManager] fileExistsAtPath:addr_path] && [[NSFileManager defaultManager] fileExistsAtPath:document_addr])
    {
        [[NSFileManager defaultManager]removeItemAtPath:addr_path error:nil];
        [[NSFileManager defaultManager] moveItemAtPath:document_addr toPath:addr_path error:nil];
        GSTATUS res = [MWPoiOperator UpgradeFavoriteFiles];
        NSLog(@"UpgradeFavoriteFiles %d",res);
        NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:addr_path error:nil];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like %@",@"*.addr"];
        NSArray *results = [fileArray filteredArrayUsingPredicate:predicate];
        for (int i = 0; i < [results count]; i++)
        {
            NSString *tempFilePath = [results objectAtIndex:i];
            NSString *filePath = [addr_path stringByAppendingFormat:@"/%@",tempFilePath];
            [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
        }
	}
    
    NSDictionary *DirectoryAttrib = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLong:0777UL] forKey:NSFilePosixPermissions];
    if (![[NSFileManager defaultManager] fileExistsAtPath:addr_path]) //如果不存在address，则创建
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:addr_path withIntermediateDirectories:YES attributes:DirectoryAttrib error:nil];
	}
}

#pragma mark- 开机创建相应的文件夹
-(void)GMD_CreatRelatedFolder
{
    NSError *myError;
	NSDictionary *DirectoryAttrib = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLong:0777UL] forKey:NSFilePosixPermissions];
    
    //判断是否在document下存在帐号plist文件，存在就删除
    NSString *oldAccountPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/accountInfo.plist"] ;
    if ([[NSFileManager defaultManager] fileExistsAtPath:oldAccountPath])
    {
        [[NSFileManager defaultManager]removeItemAtPath:oldAccountPath error:nil];
    }
    NSString *newAccountPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/Account"] ;
    if (![[NSFileManager defaultManager] fileExistsAtPath:newAccountPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:newAccountPath withIntermediateDirectories:YES attributes:DirectoryAttrib error:&myError];

    }
    
    //判断是否存在usafe文件夹，不存在则创建
     NSString *usafe_path = [NSString stringWithFormat:@"%@/usafe", GNaviData_Directory];
    if (![[NSFileManager defaultManager] fileExistsAtPath:usafe_path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:usafe_path withIntermediateDirectories:YES attributes:DirectoryAttrib error:&myError];
	}
    
    //移动引擎电子眼文件 dspoi.pat
    NSString *document_dspoi = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/dspoi.pat"];
    NSString *dspoi_path = [NSString stringWithFormat:@"%@/usafe/dspoi.pat", GNaviData_Directory];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:document_dspoi])
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:dspoi_path])
        {
            [[NSFileManager defaultManager]removeItemAtPath:dspoi_path error:nil];
        }
        [[NSFileManager defaultManager] moveItemAtPath:document_dspoi toPath:dspoi_path error:nil];
	}
    
    //覆盖NetConfig.txt
    NSString *netConfigBundlePath = [[NSBundle mainBundle] pathForResource:@"NetConfig" ofType:@"txt"];
    NSString *netConfigDocumentPath = [Map_Data_Path stringByAppendingString:@"download/NetConfig.txt"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:netConfigBundlePath] && [[NSFileManager defaultManager] fileExistsAtPath:netConfigDocumentPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:netConfigDocumentPath error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:netConfigBundlePath toPath:netConfigDocumentPath error:nil];
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath:netConfigBundlePath] && ![[NSFileManager defaultManager] fileExistsAtPath:netConfigDocumentPath])
    {
        NSString *downLoadPath = [Map_Data_Path stringByAppendingString:@"download"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:downLoadPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:downLoadPath withIntermediateDirectories:YES attributes:DirectoryAttrib error:&myError];
        }
        [[NSFileManager defaultManager] copyItemAtPath:netConfigBundlePath toPath:netConfigDocumentPath error:nil];
    }
    
    //皮肤
    if (![[NSFileManager defaultManager] fileExistsAtPath:Skin_path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:Skin_path withIntermediateDirectories:YES attributes:DirectoryAttrib error:&myError];
	}
    //车主服务
    if (![[NSFileManager defaultManager] fileExistsAtPath:CarOwnerService_path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:CarOwnerService_path withIntermediateDirectories:YES attributes:DirectoryAttrib error:&myError];
	}
    //方言
    if (![[NSFileManager defaultManager] fileExistsAtPath:Dialect_path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:Dialect_path withIntermediateDirectories:YES attributes:DirectoryAttrib error:&myError];
	}
    if (![[NSFileManager defaultManager] fileExistsAtPath:RedPointService_path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:RedPointService_path withIntermediateDirectories:YES attributes:DirectoryAttrib error:&myError];
	}
    //驾驶记录
    if (![[NSFileManager defaultManager] fileExistsAtPath:DrivingTrack_PATH]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:DrivingTrack_PATH withIntermediateDirectories:YES attributes:DirectoryAttrib error:&myError];
	}
    //地图数据下载
    if (![[NSFileManager defaultManager] fileExistsAtPath:DataDownload_PATH]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:DataDownload_PATH withIntermediateDirectories:YES attributes:DirectoryAttrib error:&myError];
	}
    
    
    /*60引擎换70时需要检测删除的文件*/
    NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/TTS/"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] )
    {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    
    file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/iPad/"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] )
    {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    
    file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/iPhone3/"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] )
    {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    
    file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/iPhone4/"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] )
    {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    
    file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/iPhone5/"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] )
    {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    
    file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/NewiPad/"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] )
    {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    
    file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/GPS/"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] )
    {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    
    file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/AutoNavi_Mapdata.dat"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] )
    {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    
    file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/GconfigUser.dat"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] )
    {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    
    file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/value.dat"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] )
    {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    
    file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/UUID.txt"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] )
    {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    
    file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userpoi"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] )
    {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    
    file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/NetCount.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] )
    {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    
    file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/DataDownloadList.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] )
    {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Skin"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] )
    {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    //系统升级时删除旧的路径文件，解决路径文件不兼容问题
    NSString *oldPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/path.dat"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:oldPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:oldPath error:nil];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:GresourceFile_PATH])
    {
        [[NSFileManager defaultManager] removeItemAtPath:GresourceFile_PATH error:nil];
    }
    /*60引擎换70时需要检测删除的文件*/

}


#pragma mark - 里程计算接口

/*!
  @brief 里程计算接口
 *-------------------------------------
 *0           不记录gps信息点
 *15以下       4秒
 *16-30        3秒
 *31-60        2秒
 *61-90及以上   1秒
 *-------------------------------------
 *距离计算:每收到一个GPS点,就判断该点不上一个“记录点”的时间差是否满足时间间隔,若是就记录,若丌是就直接丢弃
  @param newLocation 新定位点
  @param oldLocation 旧定位点
  @return 成功返回 YES 失败返回 NO
  */
- (int)GMD_MileageCalculateWithNewLocation:(CLLocation *)newLocation oldLocation:(CLLocation *)oldLocation
{
    if ([ANParamValue sharedInstance].isNavi) {//模拟导航不计算里程
        return 0;
    }
    
    GGPSINFO pGpsInfo1 = {0};
    GDBL_GetGPSInfo(&pGpsInfo1);
    
    if (pGpsInfo1.nSpeed > 0) {//有效定位，且有速度值，则保存下当前的行政编码
        NSString *tmpString = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_MileCalAdminCode];
        if (!tmpString) {
            NSString *adcodeString = [NSString stringWithFormat:@"%d",[MWAdminCode GetCurAdminCode]];
            [[NSUserDefaults standardUserDefaults] setValue:adcodeString forKey:USERDEFAULT_MileCalAdminCode];
        }
    }
    
    int mileageCount = 0;
    
    if (!self.startTime || startCoord.x == 0 || startCoord.y == 0) //保存第一个记录点的时间和经纬度
    {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.startTime = [formatter stringFromDate:[NSDate date]];
        [formatter release];
        
        startCoord.x = newLocation.coordinate.longitude * 1000000;
        startCoord.y = newLocation.coordinate.latitude * 1000000;
        return mileageCount;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date1 = nil;
    
    @synchronized(self.startTime)
    {
        date1 = [formatter dateFromString:self.startTime];
        
    }
    
    NSDate *date2 = [NSDate date];
    NSTimeInterval aTimer = [date2 timeIntervalSinceDate:date1];
    
    GCOORD newCoord = {0};
    
    newCoord.x = newLocation.coordinate.longitude * 1000000;
    newCoord.y = newLocation.coordinate.latitude * 1000000;
    
    
    if (pGpsInfo1.nSpeed == 0)
    {
        //不记录
    }
    else if (pGpsInfo1.nSpeed < 15 && pGpsInfo1.nSpeed > 0 && (fabs(aTimer - 4.0) > 0.01f))
    {
         mileageCount= [MWEngineTools CalcDistanceFrom:startCoord To:newCoord];
        self.startTime = [formatter stringFromDate:[NSDate date]];
        startCoord.x = newLocation.coordinate.longitude * 1000000;
        startCoord.y = newLocation.coordinate.latitude * 1000000;
    }
    else if (pGpsInfo1.nSpeed < 31 &&  pGpsInfo1.nSpeed > 14 && (fabs(aTimer - 3.0) > 0.01f))
    {
        mileageCount= [MWEngineTools CalcDistanceFrom:startCoord To:newCoord];
        self.startTime = [formatter stringFromDate:[NSDate date]];
        startCoord.x = newLocation.coordinate.longitude * 1000000;
        startCoord.y = newLocation.coordinate.latitude * 1000000;
    }
    else if (pGpsInfo1.nSpeed < 61 &&  pGpsInfo1.nSpeed > 30 && (fabs(aTimer - 2.0) > 0.01f))
    {
        mileageCount= [MWEngineTools CalcDistanceFrom:startCoord To:newCoord];
        self.startTime = [formatter stringFromDate:[NSDate date]];
        startCoord.x = newLocation.coordinate.longitude * 1000000;
        startCoord.y = newLocation.coordinate.latitude * 1000000;
    }
    else if (pGpsInfo1.nSpeed > 60 && (fabs(aTimer - 1.0) > 0.01f))
    {
       mileageCount= [MWEngineTools CalcDistanceFrom:startCoord To:newCoord];
        self.startTime = [formatter stringFromDate:[NSDate date]];
        startCoord.x = newLocation.coordinate.longitude * 1000000;
        startCoord.y = newLocation.coordinate.latitude * 1000000;
    }
    
    
    [formatter release];
    
    [[MileRecordDataControl sharedInstance] isSameUserDate:mileageCount];
    
    return mileageCount;
}

#pragma mark - 跳转到appstore
/*param:0 更新软件 1：评价软件*/
+(void)rateToAppStore:(int)param;
{
    if (param == 0)
    {
        
        NSString *str = [NSString stringWithFormat:@"http://itunes.apple.com/cn/app/gao-dao-hanghd-autonavi-navigation/id324101974?mt=8"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
    else
    {
        //给个好评        
        
        NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d",324101974];
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d", 324101974];
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}

#pragma mark -获取屏幕宽度，高度

- (CGFloat)getScreenWidth
{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 && Interface_Flag == 1)
    {
        return [[UIScreen mainScreen] bounds].size.height;
    }
    else
    {
        return [[UIScreen mainScreen] bounds].size.width;
    }
}

- (CGFloat)getScreenHeight
{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 && Interface_Flag == 1)
    {
        return [[UIScreen mainScreen] bounds].size.width;
    }
    else
    {
        return [[UIScreen mainScreen] bounds].size.height;
    }
}

- (CGFloat)getApplicationFrameWidth
{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 && Interface_Flag == 1)
    {
        return [[UIScreen mainScreen] applicationFrame].size.height;
    }
    else
    {
        return [[UIScreen mainScreen] applicationFrame].size.width;
    }
}

- (CGFloat)getApplicationFrameHeight
{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 && Interface_Flag == 1)
    {
        return [[UIScreen mainScreen] applicationFrame].size.width;
    }
    else
    {
        return [[UIScreen mainScreen] applicationFrame].size.height;
    }
}

- (CGFloat)getApplicationFrameContentHeight_V
{
    return [[UIScreen mainScreen] applicationFrame].size.height - 44.0;
}

- (CGFloat)getApplicationFrameContentHeight_H
{
    
    float offset = 44.0;
    if ((UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) && ([UIDevice currentResolution] != UIDevice_iPhone6PlusHiRes))
    {
        offset = 32.0;
    }
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 &&  Interface_Flag == 1)
    {
        return [[UIScreen mainScreen] applicationFrame].size.height - offset;
    }
    else
    {
        return [[UIScreen mainScreen] applicationFrame].size.width - offset;
    }
    
}



@end
