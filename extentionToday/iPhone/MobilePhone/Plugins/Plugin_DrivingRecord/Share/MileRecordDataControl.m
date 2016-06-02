//
//  MileRecordDataControl.m
//  objectToplist
//
//  Created by weihong.wang on 14-4-9.
//  Copyright (c) 2014年 wangweihong. All rights reserved.
//

#import "MileRecordDataControl.h"
#import "ThreeDes.h"
#import "XMLDictionary.h"
#import "MWMileageList.h"
#import "DDXML.h"
#import "MileageData.h"
#import "DringTracksManage.h"
#import "JSON.h"

#define kMileageActivityCode  @"0001"
#define kMileageActivityCode1 @"0002"
#define kMileageActionCode    @"0"      //0:请求 1:应答
#define kMileageProtversion   @"2"

@implementation MileRecordDataControl
@synthesize reqDelegare,mileageServiceList=_mileageServiceList,shortURL=_shortURL;


- (id)init
{
    if (self = [super init]) {
        if (_mileRecordDataList == nil) {
            _mileRecordDataList = [[NSMutableArray alloc]init];
            
            _recordMileTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                                target:self
                                                              selector:@selector(store)
                                                              userInfo:nil
                                                               repeats:YES];
        }
    }
    return self;
}

#pragma mark 单例
+ (MileRecordDataControl *)sharedInstance {
	
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[self alloc] init];
        
        [sharedInstance restore];
    });
    
    return sharedInstance;
}
#pragma mark - ThreeDes
//加密用户名和今日未上传里程
-(void)encryptionList:(NSMutableArray*)sarray{
    for (MileageData* enData in sarray){
        NSString *tempMil= [NSString stringWithFormat:@"%@",enData.noUpTodayMileage];
        NSString *tempuserId= [NSString stringWithFormat:@"%@",enData.userID];
        
        enData.noUpTodayMileage = [ThreeDes encrypt:tempMil];
        enData.userID =  [ThreeDes encrypt:tempuserId];
    }
}

//解密用户名和今日未上传里程
-(void)decryptList:(NSArray*)readRecordList{
    for (MileageData* enData in readRecordList){
        NSString *tempMil= [NSString stringWithFormat:@"%@",enData.noUpTodayMileage];
        NSString *tempuserId= [NSString stringWithFormat:@"%@",enData.userID];
        
        enData.noUpTodayMileage = [ThreeDes decrypt:tempMil];
        enData.userID =  [ThreeDes decrypt:tempuserId];
    }
}

#pragma mark - 存储Plist
/*!
  @brief 把mileRecordDataList 中的所有的里程信息保存到文件系统，一般是在退出程序时调用
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)store
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:Mileage_path]) //要是文件目录不存在，创建目录
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:Mileage_path withIntermediateDirectories:NO attributes:nil error:nil];
	}
    
    NSMutableArray *saveEncryptArray = [[NSMutableArray alloc] init];
    
    for (MileageData *saveData in _mileRecordDataList) {
        MileageData *tempSdata = [[MileageData alloc]init];
        tempSdata.userID = saveData.userID;
        tempSdata.recordDate =saveData.recordDate;
        tempSdata.totalMileage = saveData.totalMileage;
        tempSdata.upTodayMileage = saveData.upTodayMileage;
        tempSdata.weekMileage = saveData.weekMileage;
        tempSdata.noUpTodayMileage = saveData.noUpTodayMileage;
        [saveEncryptArray addObject:tempSdata];
        [tempSdata release];
    }
    
    [self encryptionList:saveEncryptArray];//加密
	
	if (![NSKeyedArchiver archiveRootObject:saveEncryptArray toFile:MileageRecordFile_PATH]){
        [saveEncryptArray release];
        
		return NO;
	}
	else {
        [saveEncryptArray release];
        
		return YES;
	}
}

/*!
  @brief 从文件系统还原通过save保存的所有任务信息，一般是在进入程序时调用，该方法调用将把carOwnerTaskList中的所有任务更新为最后一次调用save保存的任务
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)restore
{
    /*
     1、反序列化各个Task对象，构建处carOwnerTaskList
     2、遍历carOwnerTaskList，把task.delegate = self;
     */
    
	
	NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:MileageRecordFile_PATH];
    [self decryptList:array];//解密
    [_mileRecordDataList removeAllObjects];
    [_mileRecordDataList addObjectsFromArray:array];
    
    
    //测试打出数据
    /*
     int ii =0;
     for (MileageData* milData in _mileRecordDataList){
     NSLog(@"index = %d _mileRecordDataList noupdata = %d ID=%@ recordDate=%@",ii,[milData.noUpTodayMileage intValue],milData.userID,milData.recordDate);
     ii++;
     }
     */
	return YES;
}

/*!
  @brief 传入记录的里程
 不是同一用户，那就创建一条，加入数组。
 是同一个用户 同一天  累加今日未上传里程
 没有找到数组里今天的数据，就创建一条今天的。
 
  @return 成功返回 YES 失败返回 NO
  */

- (BOOL)isSameUserDate:(int)mile{
    //加入当天此用户未上传里程，如果是加入成功则跳出函数
    @synchronized(_mileRecordDataList)
    {
        for (MileageData* milData in _mileRecordDataList)
        {
            NSString *tuserId = UserID_Account;
            BOOL isSameday =[milData.recordDate isEqualToString:[self returnCurrentDate]];
            BOOL isSameUser = [milData.userID isEqualToString:tuserId];
            
            if (isSameday&&isSameUser) {
                int rdata =[milData.noUpTodayMileage intValue];
                rdata += mile;
                milData.noUpTodayMileage = [NSString stringWithFormat:@"%d",rdata];
                return YES;
            }
        }
        //创建新的单条记录加入_mileRecordDataList数组 （不是此用户 没有当天数据 || 此用户但不是当天的数据）
        [self makeMiledata:mile];
        return YES;
    }
}

//构造Miledata
-(void)makeMiledata:(int)tmile{
    MileageData *milData = [[MileageData alloc]init];
    milData.userID = UserID_Account;
    milData.recordDate = [self returnCurrentDate];
    milData.totalMileage = [self readServerReCordAllData];
    milData.weekMileage = [self readServerReCordWeekData];
    milData.upTodayMileage = [self readServerReCordTodayData];
    milData.noUpTodayMileage = [NSString stringWithFormat:@"%d",
                                [[self readNoUpdata]intValue] + tmile];
    [_mileRecordDataList addObject:milData];
    [milData release];
}

//判断当前用户是否有需要上传的里程
- (BOOL)isNeedPost
{
    
    for (MileageData *list in _mileRecordDataList) {
        if (list.userID && [list.userID isEqualToString:UserID_Account] && [list.noUpTodayMileage intValue] > 0) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - 读取服务器最后一次保存在plist里面的值
//读文件里面该用户保存的服务端同步过来的总里程
-(NSString *)readServerReCordAllData{
    for (MileageData* tmilData in _mileRecordDataList){
        NSLog(@"userID = %@, UserID_Account = %@",tmilData.userID,UserID_Account);
        if ([tmilData.userID isEqualToString:UserID_Account]) {
            //如果读取到有此用户的信息，就把改用户的随便一条记录的总里程返回
            NSLog(@"tmilData = %@",tmilData.totalMileage);
            return  [NSString stringWithFormat: @"%@",tmilData.totalMileage];
        }
    }
    return [NSString stringWithFormat:@"0"];
}
//读取 与服务器最后一次同步保存的本周里程 如果不是本周的数据 则返回0;
-(NSString*)readServerReCordWeekData{
    for (MileageData* tmilData in _mileRecordDataList){
        if ([tmilData.userID isEqualToString:UserID_Account]) {
            long int cweek = [self returnCompsWeek:[self returnCurrentDate]];//当前周
            long int rweek = [self returnCompsWeek:tmilData.recordDate];//记录周
            if (cweek == rweek) {
                return [NSString stringWithFormat: @"%@",tmilData.weekMileage];
            }
        }
    }
    return [NSString stringWithFormat:@"0"];
}
//读取 与服务器最后一次同步保存的今日里程 如果不是今日的数据 则返回0;

-(NSString*)readServerReCordTodayData{
    for (MileageData* tmilData in _mileRecordDataList){
        if ([tmilData.userID isEqualToString:UserID_Account]) {
            if ([tmilData.recordDate isEqualToString:[self returnCurrentDate]]) {
                return [NSString stringWithFormat: @"%@",tmilData.upTodayMileage];
            }
        }
    }
    
    return [NSString stringWithFormat:@"0"];
}
//读取 最后一次保存的未上传的今日里程  否 则返回0;
-(NSString*)readNoUpdata{
    for (MileageData* tmilData in _mileRecordDataList){
        if ([tmilData.userID isEqualToString:UserID_Account]) {
            
            if ([tmilData.recordDate isEqualToString:[self returnCurrentDate]])
            {
                return [NSString stringWithFormat: @"%@",tmilData.noUpTodayMileage];
            }
        }
    }
    return [NSString stringWithFormat:@"0"];
}

//获取今年的第几周
-(long int)returnCompsWeek:(NSString *)dateStr{
    NSString *dateString =dateStr;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    NSDate *future = [dateFormatter dateFromString:dateString];
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setFirstWeekday:2];
    //    calendar.firstWeekday =2;每周的第一天从星期几开始算 1 星期日 2星期一
    
    NSDateComponents *comps = [calendar components:NSWeekCalendarUnit fromDate:future];
    
    long int whichWeek = comps.week;
    [dateFormatter release];
    [calendar release];
    NSLog(@"第%ld周,", whichWeek);
    return whichWeek;
}

//获取系统当前日期
-(NSString*)returnCurrentDate{
    // 获取系统当前时间
    NSDate * date = [NSDate date];
    NSTimeInterval sec = [date timeIntervalSinceNow];
    NSDate * currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
    
    //设置时间输出格式：
    NSDateFormatter * dfa = [[NSDateFormatter alloc]init];
    [dfa setDateFormat:@"yyyyMMdd"];
    NSString * na =[NSString stringWithFormat:@"%@",[dfa stringFromDate:currentDate]];
    [dfa release];
    [currentDate release];
    return na;
}

#pragma mark - 没有网络情况下 计算——实际返回给界面的值
//计算出界面显示的总里程 = （总里程）最后一次服务保存的里程 + 所有未上传的里程
-(NSString*)readAllUpData{
    int allmileCount =0;
    for (MileageData* tmilData in _mileRecordDataList){
        if ([tmilData.userID isEqualToString:UserID_Account]) {
            allmileCount += [tmilData.noUpTodayMileage intValue];
        }
    }
    allmileCount += [[self readServerReCordAllData]intValue];
    return [NSString stringWithFormat:@"%d",allmileCount];
}


//计算出界面要显示的本周里程 =（周里程）服务端最后一次保存的当周里程+当周未上传的里程
-(NSString*)readAllWeekMile{
    int allwmileCount =0;
    
    for (MileageData* tmilData in _mileRecordDataList){
        if ([tmilData.userID isEqualToString:UserID_Account]){
            long int rweek = [self returnCompsWeek:tmilData.recordDate];
            long int cweek = [self returnCompsWeek:[self returnCurrentDate]];
            if (rweek == cweek) {
                allwmileCount += [tmilData.noUpTodayMileage intValue];
            }
        }
    }
    allwmileCount += [[self readServerReCordWeekData] intValue];
    return [NSString stringWithFormat:@"%d",allwmileCount];
}

//计算出界面要显示的今日里程 = （今日里程）服务端最后一次保存的今日里程+今日未上传的里程
-(NSString*)readAlltodayMile{
    int allmileCount=0;
    for (MileageData* tmilData in _mileRecordDataList){
        if ([tmilData.userID isEqualToString:UserID_Account]){
            if ([tmilData.recordDate isEqualToString:[self returnCurrentDate]]){
                allmileCount += [tmilData.noUpTodayMileage intValue];
            }
        }
    }
    allmileCount += [[self readServerReCordTodayData]intValue];
    return [NSString stringWithFormat:@"%d",allmileCount];
}



#pragma mark - 登陆账号后，把未登陆的账号的数据付给第一次登陆的
-(void)modifyAccount{
    for (MileageData* tmilData in _mileRecordDataList){
        if ([tmilData.userID isEqualToString:@""]) {
            tmilData.userID = UserID_Account;
        }
    }
    
    NSMutableArray *driveArray = [[DringTracksManage sharedInstance] getAllDrivingInfoList];
    
    for (DrivingInfo *mInfo in driveArray) {
        if ([mInfo.userID isEqualToString:@""]) {
            mInfo.userID = UserID_Account;
        }
    }
    
}

- (void)dealloc
{
    if (_xmlString) {
        [_xmlString release];
        _xmlString = nil;
    }
    if (_shortURL) {
        [_shortURL release];
        _shortURL =nil;
    }
    if (_mileageServiceList) {
        [_mileageServiceList release];
        _mileageServiceList =nil;
    }
    if (_recordMileTimer)
    {
        [_recordMileTimer invalidate];
        _recordMileTimer = nil;
    }
    [_mData release];
    [_mileRecordDataList release];
    
    [super dealloc];
}

#pragma mark - 里程上传，短地址获取

- (void)mileageRequestWithType:(RequestType)type
{
    if (type == RT_MileageStartUpRequest)
    {
        if ([LoginStatus_Account intValue] == 0) {
            return;
        }
        //当前用户没有里程需要上传则不请求
//        if (![self isNeedPost])
//        {
//            return;
//        }
        
    }
    if (RT_MileageRequest == type || RT_MileageStartUpRequest == type)
    {
        [self modifyAccount];
    }
    
    NSString *postSting = [self getXMLString:type];
    
    NSString *signString = [[NSString stringWithFormat:@"%@%@%@@%@",KNetChannelID, PID,UserID_Account,kNetSignKey] stringFromMD5];
    NSMutableDictionary *urlParams = [[NSMutableDictionary alloc] init];
    [urlParams setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kNetRequestStringBoundary] forKey:@"Content-Type"];
    [urlParams setValue:VendorID forKey:@"imei"];
    [urlParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [urlParams setValue:MapVersionNoV forKey:@"mapversion"];
    [urlParams setValue:deviceModel forKey:@"model"];
    [urlParams setValue:DeviceResolutionString forKey:@"resolution"];
    [urlParams setValue:CurrentSystemVersion forKey:@"os"];
    [urlParams setValue:UserID_Account forKey:@"userid"];
    [urlParams setValue:KNetChannelID forKey:@"syscode"];
    [urlParams setValue:PID forKey:@"pid"];
    [urlParams setValue:signString forKey:@"sign"];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    
    condition.requestType = type;
    condition.httpMethod = @"POST";
    condition.urlParams = nil;
    
    condition.bodyData = [postSting dataUsingEncoding:NSUTF8StringEncoding];
    condition.httpHeaderFieldParams = urlParams;
    
    if (RT_MileageRequest == type || RT_MileageStartUpRequest == type)
    {
        condition.baceURL = kMileageURL;
    }
    
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [urlParams release];
}

- (NSString *)getXMLString:(RequestType)type
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddhhmmss"];
    NSString *dateString = [formatter stringFromDate: [NSDate date]];
    [formatter release];
    
    if (RT_MileageRequest == type || RT_MileageStartUpRequest == type)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        NSString *adcodeString = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_MileCalAdminCode] ? [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_MileCalAdminCode] : @"";
        
        DDXMLElement*  opg = [DDXMLElement elementWithName: @"opg"];
        DDXMLElement*  activitycode = [DDXMLElement elementWithName: @"activitycode"];
        [activitycode setStringValue:kMileageActivityCode];
        [opg addChild:activitycode];
        
        DDXMLElement*  processtime =[DDXMLElement elementWithName: @"processtime"];
        [processtime setStringValue:dateString];
        [opg addChild:processtime];
        
        DDXMLElement*  protversion =[DDXMLElement elementWithName: @"protversion"];
        [protversion setStringValue:kMileageProtversion];
        [opg addChild:protversion];
        
        DDXMLElement*  svccont = [DDXMLElement elementWithName: @"svccont"];
        
        
        NSString* string2 = [UserName_Account stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//add by hlf for 中文加密后台乱码
        
        DDXMLElement*  username = [DDXMLElement elementWithName: @"username"];
        [username setStringValue:[ThreeDes encrypt:string2]];
        [svccont addChild:username];
        
        DDXMLElement*  adcode = [DDXMLElement elementWithName: @"adcode"];
        [adcode setStringValue:adcodeString];
        [svccont addChild:adcode];
        
        DDXMLElement*  mileagelist = [DDXMLElement elementWithName: @"mileagelist"];
        
        
        for (MileageData *mData in self.mileRecordDataList) {
            if([mData.userID isEqual:UserID_Account])
            {
                DDXMLElement*  mileage = [DDXMLElement elementWithName: @"mileage"];
                
                DDXMLElement*  dateElement = [DDXMLElement elementWithName: @"date"];
                [dateElement setStringValue:mData.recordDate];
                [mileage addChild:dateElement];
                
                DDXMLElement*  valueElement = [DDXMLElement elementWithName: @"value"];
                [valueElement setStringValue:[ThreeDes encrypt:mData.noUpTodayMileage]];
                [mileage addChild:valueElement];
                [mileagelist addChild:mileage];
            }
        }
        
        [svccont addChild:mileagelist];
        
        DDXMLElement*  drivelist = [DDXMLElement elementWithName: @"drivelist"];
        
        NSMutableArray *driveArray = [[DringTracksManage sharedInstance] getAllDrivingInfoList];
        
        for (DrivingInfo *mInfo in driveArray) {
            if([mInfo.userID isEqual:UserID_Account] && (mInfo.postType == 0))
            {
                NSString *string = [NSString stringWithFormat:@"%@%@",mInfo.userID,mInfo.drivingID];
                
                DDXMLElement*  drive = [DDXMLElement elementWithName: @"drive"];
                
                DDXMLElement*  idElement = [DDXMLElement elementWithName: @"id"];
                [idElement setStringValue:string];
                [drive addChild:idElement];
                
                DDXMLElement*  scoreElement = [DDXMLElement elementWithName: @"score"];
                [scoreElement setStringValue:[NSString stringWithFormat:@"%f",mInfo.trackScore]];
                [drive addChild:scoreElement];
                
                DDXMLElement*  startElement = [DDXMLElement elementWithName: @"start"];
                [startElement setStringValue:mInfo.startPOI.szName];
                [drive addChild:startElement];
                
                DDXMLElement*  sxElement = [DDXMLElement elementWithName: @"sx"];
                [sxElement setStringValue:[NSString stringWithFormat:@"%ld",mInfo.startPOI.longitude]];
                [drive addChild:sxElement];
                
                DDXMLElement*  syElement = [DDXMLElement elementWithName: @"sy"];
                [syElement setStringValue:[NSString stringWithFormat:@"%ld",mInfo.startPOI.latitude]];
                [drive addChild:syElement];
                
                DDXMLElement*  endElement = [DDXMLElement elementWithName: @"end"];
                [endElement setStringValue:mInfo.desPOI.szName];
                [drive addChild:endElement];
                
                DDXMLElement*  exElement = [DDXMLElement elementWithName: @"ex"];
                [exElement setStringValue:[NSString stringWithFormat:@"%ld",mInfo.desPOI.longitude]];
                [drive addChild:exElement];
                
                DDXMLElement*  eyElement = [DDXMLElement elementWithName: @"ey"];
                [eyElement setStringValue:[NSString stringWithFormat:@"%ld",mInfo.desPOI.latitude]];
                [drive addChild:eyElement];
                
                NSMutableDictionary *detailDic = [[NSMutableDictionary alloc] init];
                [detailDic setValue:[NSNumber numberWithInt:mInfo.trackLength] forKey:@"length"];
                [detailDic setValue:[NSNumber numberWithInt:mInfo.trackTimeConsuming] forKey:@"time"];
                [detailDic setValue:[NSNumber numberWithInt:mInfo.haccelerationCount] forKey:@"accelerator"];
                [detailDic setValue:[NSNumber numberWithInt:mInfo.brakesCount] forKey:@"brake"];
                [detailDic setValue:[NSNumber numberWithInt:mInfo.uturnCount] forKey:@"turning"];
                [detailDic setValue:[NSNumber numberWithInt:mInfo.hypervelocityCount] forKey:@"speedlimit"];
                [detailDic setValue:[NSNumber numberWithInt:mInfo.yawCount] forKey:@"yaw"];
                
                NSString *jsonString = [detailDic JSONRepresentation];
                [detailDic release];
                
                DDXMLElement*  detailElement = [DDXMLElement elementWithName: @"detail"];
                [detailElement setStringValue:jsonString];
                [drive addChild:detailElement];
                
                DDXMLElement*  createTimeElement = [DDXMLElement elementWithName: @"createtime"];
                [createTimeElement setStringValue:mInfo.creatTime];
                [drive addChild:createTimeElement];
                
                [drivelist addChild:drive];
            }
        }
        
        [svccont addChild:drivelist];
        
        [opg addChild:svccont];
        
        if (_xmlString !=nil) {
            [_xmlString release];
            _xmlString = nil;
        }
        _xmlString = [[NSString alloc]initWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\" ?>%@",[opg XMLString]];
        [pool drain];
        
        
    }
    else if (RT_MileageURLRequest == type)
    {
        MWMileageList *mileList = self.mileageServiceList;
        
        NSString *areaString = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_MileCalArea];
        if (!areaString) {
            areaString = @"0";
        }
        NSString* string2 = [UserName_Account stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//add by hlf for 中文加密后台乱码
        
        if (_xmlString !=nil) {
            [_xmlString release];
            _xmlString = nil;
        }
        _xmlString = [[NSString alloc]initWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\" ?><opg><activitycode>%@</activitycode><processtime>%@</processtime><actioncode>%@</actioncode><protversion>%@</protversion><svccont><username>%@</username><area>%@</area><weekmileage>%d</weekmileage><totalmileage>%d</totalmileage><weekranking>%d</weekranking><totalranking>%d</totalranking></svccont></opg>",kMileageActivityCode1,dateString,kMileageActionCode,kMileageProtversion,[ThreeDes encrypt:string2],areaString,mileList.week,mileList.total,mileList.week_ranking,mileList.total_ranking];
    }
    NSLog(@"里程xml:%@",_xmlString);
    
    return _xmlString;
}

- (void)parseMileageData:(NSData *)data withRequestType:(RequestType)type
{
    NSDictionary *dialectDic = [NSDictionary dictionaryWithXMLData:data];
    NSDictionary *svccont = [dialectDic objectForKey:@"svccont"];
    
    if (svccont)
    {
        if (RT_MileageURLRequest == type)
        {
            self.shortURL = [svccont objectForKey:@"shareurl"] ? [svccont objectForKey:@"shareurl"] : @"";
        }
        else
        {
            //驾驶记录平均分
            [DringTracksManage sharedInstance].averageScore = [[svccont objectForKey:@"avgscore"] floatValue];
            
            //击败人数列表
            NSString *jsonString = [svccont objectForKey:@"scoredetail"];
            if (jsonString) {
                NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                
                NSDictionary *requestDic = [NSJSONSerialization
                                            
                                            JSONObjectWithData:data
                                            
                                            options:NSJSONReadingMutableLeaves
                                            
                                            error:nil];
                if (requestDic) {
                    
                    [[NSUserDefaults standardUserDefaults] setValue:requestDic forKey:USERDEFAULT_ScoreDetail];
                }
            }
            
            [[DringTracksManage sharedInstance] setPostType];
            
            MWMileageList *mileageList = [[MWMileageList alloc] init];
            mileageList.total = [[svccont objectForKey:@"total"] intValue];
            mileageList.week = [[svccont objectForKey:@"week"] intValue];
            mileageList.today = [[svccont objectForKey:@"today"] intValue];
            mileageList.total_ranking = [[svccont objectForKey:@"total_ranking"] intValue];
            mileageList.week_ranking = [[svccont objectForKey:@"week_ranking"] intValue];
            mileageList.area = [[svccont objectForKey:@"area"] intValue];
            
            [[NSUserDefaults standardUserDefaults] setValue:[svccont objectForKey:@"area"] forKey:USERDEFAULT_MileCalArea];
            
            NSMutableArray *userArray = [[NSMutableArray alloc] init];
            
            id total_rankings = [svccont objectForKey:@"total_rankings"];
            
            if (total_rankings && [total_rankings isKindOfClass:[NSDictionary class]])
            {
                id mileDic = [total_rankings objectForKey:@"user"];
                
                
                if (mileDic && [mileDic isKindOfClass:[NSDictionary class]])
                {
                    
                    MWMileageUserDetail *detail = [[MWMileageUserDetail alloc] init];
                    
                    detail.userName = [mileDic objectForKey:@"name"];
                    detail.total = [[mileDic objectForKey:@"value"] intValue];
                    
                    [userArray addObject:detail];
                    
                    [detail release];
                }
                else if (mileDic && [mileDic isKindOfClass:[NSArray class]])
                {
                    
                    for (NSDictionary *dic in mileDic)
                    {
                        MWMileageUserDetail *detail = [[MWMileageUserDetail alloc] init];
                        
                        detail.userName = [dic objectForKey:@"name"];
                        detail.total = [[dic objectForKey:@"value"] intValue];
                        
                        [userArray addObject:detail];
                        
                        [detail release];
                    }
                }
            }
            
            mileageList.totalUserRanking = userArray;
            [userArray release];
            
            NSMutableArray *areaUserArray = [[NSMutableArray alloc] init];
            
            id week_rankings = [svccont objectForKey:@"week_rankings"];
            
            if (week_rankings && [week_rankings isKindOfClass:[NSDictionary class]])
            {
                id areaMileDic = [week_rankings objectForKey:@"user"];
                
                if (areaMileDic && [areaMileDic isKindOfClass:[NSDictionary class]])
                {
                    
                    MWMileageUserDetail *detail = [[MWMileageUserDetail alloc] init];
                    
                    detail.userName = [areaMileDic objectForKey:@"name"];
                    detail.total = [[areaMileDic objectForKey:@"value"] intValue];
                    
                    [areaUserArray addObject:detail];
                    
                    [detail release];
                }
                else if (areaMileDic && [areaMileDic isKindOfClass:[NSArray class]])
                {
                    
                    for (NSDictionary *dic in areaMileDic)
                    {
                        MWMileageUserDetail *detail = [[MWMileageUserDetail alloc] init];
                        
                        detail.userName = [dic objectForKey:@"name"];
                        detail.total = [[dic objectForKey:@"value"] intValue];
                        
                        [areaUserArray addObject:detail];
                        
                        [detail release];
                    }
                }
            }
            
            
            mileageList.areaUserRanking = areaUserArray;
            [areaUserArray release];
            
            self.mileageServiceList = mileageList;
            [mileageList release];
            [self cleanMileRecordDataList];//清空本地的存储的数组 并且存入最新的服务器下来的一条
        }
    }
}
//清空之前本地保存的数据
-(void)cleanMileRecordDataList{
    
    @synchronized(_mileRecordDataList)
    {
        [_mileRecordDataList removeAllObjects];
        
        MileageData *milData = [[MileageData alloc]init];
        milData.userID = UserID_Account;
        milData.recordDate = [self returnCurrentDate];
        milData.totalMileage = [NSString stringWithFormat:@"%d",_mileageServiceList.total] ;
        milData.weekMileage =[NSString stringWithFormat:@"%d",_mileageServiceList.week] ;
        milData.upTodayMileage = [NSString stringWithFormat:@"%d",_mileageServiceList.today];
        milData.noUpTodayMileage = [NSString stringWithFormat:@"0"];
        [_mileRecordDataList addObject:milData];
        
        [milData release];
    }
}


#pragma mark - url请求回调
/*!
  @brief 请求应答成功回调
  */
- (void)request:(NetRequestExt *)request didFinishLoadingWithData:(NSData *)data
{
    
    if (data && [data length])
    {
        NSString *tmp = [[[NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        
        NSLog(@"里程请求结果：%@",tmp);
        
        NSDictionary *dialectDic = [NSDictionary dictionaryWithXMLData:data];
        if ([[[dialectDic objectForKey:@"response"] objectForKey:@"rspcode"] isEqualToString:@"0000"])
        {
            __block id weakself = self;
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                
                [weakself parseMileageData:data withRequestType:request.requestCondition.requestType];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if ([reqDelegare respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)])
                    {
                        [reqDelegare requestToViewCtrWithRequestType:request.requestCondition.requestType didFinishLoadingWithResult:data];
                    }
                    
                });
            });
            
            
        }
        else
        {
            
            if ([reqDelegare respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
            {
                [reqDelegare requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
            }
        }
    }
    else
    {
        
        if ([reqDelegare respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
        {
            [reqDelegare requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
        }
    }
}

/*!
  @brief 请求失败回调
  */
- (void)request:(NetRequestExt *)request didFailWithError:(NSError *)error
{
    NSLog(@"mileageFail");
    if ([reqDelegare respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
    {
        [reqDelegare requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:error];
    }
}
@end
