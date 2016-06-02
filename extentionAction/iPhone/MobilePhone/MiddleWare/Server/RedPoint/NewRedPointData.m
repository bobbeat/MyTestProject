//
//  NewRedPointData.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-5-29.
//
//

#import "NewRedPointData.h"

@interface NewRedPointData ()
{
    NSMutableDictionary *_dictionary;
}

@end

@implementation NewRedPointData

#pragma mark - ---  公有函数调用  ---
+ (NewRedPointData *)sharedInstance
{
    static NewRedPointData *gdRedPoint = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gdRedPoint = [[NewRedPointData alloc] init];
    });
	return gdRedPoint;
}


- (id) init
{
    self = [super init];
    if(self)
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:RED_POINT_PATH])
        {
            _dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:RED_POINT_PATH];
        }
        else
        {
            _dictionary = [[NSMutableDictionary alloc] init];
        }
        _redRequestSuccess = nil;
        _redRequestFail = nil;
    }
    return  self;
}


/*!
  @brief    设置某一项被点击过
  @param    点击过的设置为 NO
  @author   by bazinga
  */
- (void) setItemPress:(NSString *) type withID:(NSString *)stringID
{
    NSMutableDictionary *dict = [[_dictionary objectForKey:type] objectForKey:stringID];
    //下载完成，推荐会被置为非推荐，所以，还要尝试搜索推荐的，并且设置推荐被点击过
    //bug ： 12617   by bazinga  @ 2014.8.18
    if(dict == nil)
    {
        dict = [[_dictionary objectForKey:RED_TYPE_RECOMMEND] objectForKey:stringID];
    }
    [dict setValue:[NSNumber numberWithBool:NO] forKey:RED_POINT_ISPRESS];
    [self save];
}

/*!
  @brief    根据类型来获取是否需要显示红点信息
  @param    type —— 类型，0-服务推荐插件 1-服务非推荐插件 2-图层
  @author   by bazinga
  */
- (BOOL) getValueByType:(NSString *)type
{
    BOOL returnBool = NO;
    NSArray *array = [[_dictionary objectForKey:type] allObjects];
    for (int i = 0; i < array .count; i++)
    {
        if([[[array objectAtIndex:i] objectForKey:RED_POINT_ISPRESS] boolValue] == YES)
        {
            returnBool = YES;
            break;
        }
    }
    return returnBool;
}

/*!
  @brief    根据类型来获取某一个类型的数组
  @param    type —— 类型，0-服务推荐插件 1-服务非推荐插件 2-图层
  @author   by bazinga
  */
- (NSDictionary *) getArrayByType:(NSString *)type
{
    return   [_dictionary objectForKey:type];
}


/*!
  @brief    根据类型 和 id 信息 来获取是否需要显示红点信息
  @param    type —— 类型，0-服务推荐插件 1-服务非推荐插件 2-图层
  @param    stringID —— 类型下的服务 id
  @author   by bazinga
  */
- (BOOL) getValueByType:(NSString *)type withID:(NSString *) stringID
{
    BOOL returnBool = NO;
    NSDictionary *dictionary = [[_dictionary objectForKey:type] objectForKey:stringID];
    if([[dictionary objectForKey:RED_POINT_ISPRESS] boolValue] == YES)
    {
        returnBool = YES;
    }
    return returnBool;
}

#pragma  mark -  ---  网络请求部分  ---

/*!
  @brief     请求红点的信息列表
  @param
  @author    by bazinga
  */
- (void)RequestRedPointURL
{
    NSString *jsonBody = nil;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddhhmmss"];
    NSString *dateString = [formatter stringFromDate: [NSDate date]];
    [formatter release];
    
    
    
    NSMutableDictionary *messageBody = [[NSMutableDictionary alloc]init];
    [messageBody setValue:@"0001" forKey:@"activitycode"];
    [messageBody setValue:dateString forKey:@"processtime"];
    [messageBody setValue:@"2" forKey:@"protversion"];
    int language = 0;     //程序语言
    if (fontType == 0) {
        language = 0;
    }
    else if (fontType == 1)
    {
        language = 2;
    }
    else if (fontType == 2)
    {
        language = 1;
    }
    [messageBody setValue:[NSString stringWithFormat:@"%d",language] forKey:@"language"];
    
    int adminCode = [MWAdminCode GetCurAdminCode];//行政编码
    
    
    NSMutableDictionary *messageSvccont = [[NSMutableDictionary alloc]init];
    [messageSvccont setValue:[NSString stringWithFormat:@"%f",IOS_VERSION] forKey:@"osversion"];
    [messageSvccont setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"hostversion"];
    [messageSvccont setValue:@"1" forKey:@"pluginxmlv"];
    [messageSvccont setValue:[NSString stringWithFormat:@"%d",adminCode] forKey:@"adcode"];
    [messageSvccont setValue:@"0" forKey:@"type"];
    
    [messageBody setValue:messageSvccont forKey:@"svccont"];
    
    
    if ([NSJSONSerialization isValidJSONObject:messageBody])
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:messageBody options:NSJSONWritingPrettyPrinted error:&error];
        jsonBody =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"json data:%@",jsonBody);
    }
    
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    
    condition.requestType = RT_RedPointURLRequest;
    condition.httpMethod = @"POST";
    condition.urlParams = nil;
    condition.baceURL = kRedPointTipsURL;
    condition.bodyData = [jsonBody dataUsingEncoding:NSUTF8StringEncoding];
    condition.httpHeaderFieldParams = [self getHttpHeaderDictionary];
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    
    [messageSvccont release];
    [messageBody release];
    if(jsonBody)
    {
        [jsonBody release];
        jsonBody = nil;
    }
}


/*!
  @brief     网络请求的头
  @param
  @author    by bazinga
  */
- (NSMutableDictionary *) getHttpHeaderDictionary
{
    NSString *signString = [[NSString stringWithFormat:@"%@%f%d@%@",KNetChannelID,IOS_VERSION,SOFTVERSIONCODE,kNetSignKey] stringFromMD5];
    NSMutableDictionary *urlParams = [[NSMutableDictionary alloc] init];
    [urlParams setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kNetRequestStringBoundary] forKey:@"Content-Type"];
    [urlParams setValue:VendorID forKey:@"imei"];
    [urlParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [urlParams setValue:MapVersionNoV forKey:@"mapversion"];
    [urlParams setValue:deviceModel forKey:@"model"];
    [urlParams setValue:DeviceResolutionString forKey:@"resolution"];
    [urlParams setValue:[NSString stringWithFormat:@"%f",IOS_VERSION] forKey:@"os"];
    [urlParams setValue:UserID_Account forKey:@"userid"];
    [urlParams setValue:KNetChannelID forKey:@"syscode"];
    [urlParams setValue:PID forKey:@"pid"];
    [urlParams setValue:signString forKey:@"sign"];
    return [urlParams autorelease];
}



/**
 *  @brief	异步请求成功回调委托
 *
 *	@param	request	自定义NetRequestExt对象，其中有包含请求条件，delegate对象 @see NetRequestExt
 *
 *	@param	data	服务器下发的数据
 *
 */
- (void)request:(NetRequestExt *)request didFinishLoadingWithData:(NSData *)data
{
    if(RT_RedPointURLRequest == request.requestCondition.requestType)
    {
        NSLog(@"RT_RedPointURLRequest");
        NSError *error = nil;
        NSLog(@"%@",[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
        id jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                      options:NSJSONReadingAllowFragments
                                                        error:&error];
        //判断 json 数据的格式正确
        if(jsonData && !error && [jsonData isKindOfClass:[NSDictionary class]])
        {
            [self addDataByService:[jsonData objectForKey:RED_POINT_SVCCONT]];
        }
        if(self.redRequestSuccess)
        {
            self.redRequestSuccess();
        }
    }
}
/*!
  @brief    请求失败回调
  @param
  @author    by bazinga
  */
- (void)request:(NetRequestExt *)request didFailWithError:(NSError *)error
{
    if(RT_RedPointURLRequest == request.requestCondition.requestType)
    {
        NSLog(@"RT_RedPointURLRequest didFailWithError =  %d",error.code);
        if(self.redRequestFail)
        {
            self.redRequestFail();
        }
    }
}




#pragma mark - ---  plist 文件读取相关  ---
/*!
  @brief     保存红点信息至文件夹
  @param
  @author    by bazinga
  */
- (void) save
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:RedPointService_path]) //要是文件目录不存在，创建目录
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:RedPointService_path withIntermediateDirectories:NO attributes:nil error:nil];
	}
    if([_dictionary writeToFile:RED_POINT_PATH atomically:YES])
    {
        NSLog(@"保存红点信息");
    }
    else
    {
        NSLog(@"保存红点信息失败~");
    }
}

/*!
  @brief    服务器下发数据添加
  @param    服务器下发的字典数据添加 ——
  @param    array 里，每一项都是一个字典，key 为 servicesid，sign，tag，type ,在这里进行数据转换成本地数据
  @author   by bazinga
  */
- (void) addDataByService:(NSArray *) array
{

    for (int i = 0 ; i < array.count; i++)
    {
        id tempData = [array objectAtIndex:i];
        if([tempData isKindOfClass: [NSDictionary class]])
        {
            [self analysisDictionary:[self stringFromId:[tempData objectForKey:RED_POINT_ID]]
                            withSign:[self stringFromId:[tempData objectForKey:RED_POINT_SIGN]]
                             withTag:[self stringFromId:[tempData objectForKey:RED_POINT_TAG]]
                            withType:[self stringFromId:[tempData objectForKey:RED_POINT_TYPE]]];
        }
    }
    
    //把 Key —— RED_POINT_ISDOWN  = NO 的删除，把RED_POINT_ISDOWN = YES 的值置为 NO
    //为什么呢 ？ 就是位了覆盖数据，删除没用的旧数据，否则会出现一点问题
    //for example —— like .etc
    NSArray *typeKeys = [_dictionary allKeys];
    for ( int i = 0 ; i < typeKeys.count; i++)
    {
        NSString *typeKey = [typeKeys objectAtIndex:i];
        NSArray *serviceIDs = [[_dictionary objectForKey:typeKey] allKeys];
        for (int j = 0; j < serviceIDs.count; j++)
        {
            NSString *serviceID = [serviceIDs  objectAtIndex:j];
            NSMutableDictionary *mutableDictionary = [[_dictionary objectForKey:typeKey] objectForKey:serviceID] ;
            if([[mutableDictionary objectForKey:RED_POINT_ISDOWN] boolValue] == NO) //删除这一项
            {
                [[_dictionary objectForKey:typeKey] removeObjectForKey:serviceID];
            }
            else
            {
                [mutableDictionary setValue:[NSNumber numberWithBool:NO] forKey:RED_POINT_ISDOWN];
                [[_dictionary objectForKey:typeKey] setValue:mutableDictionary forKey:serviceID];
            }
        }
    }
    
    
    
    [self save];
}

/*!
  @brief    根据解析的单个结果，设置本地字典的数据
  @brief-------------------------------------------------------
  @dataStruct    ▼  (Dictionary)
  @dataStruct        ▼  type
  @dataStruct           ▼	servicesid
  @dataStruct               ▶	sign
  @dataStruct               ▶	tag
  @dataStruct               ▶	isPress ： 有红点为 YES 否则为 NO
  @brief-------------------------------------------------------
  @author    by bazinga
  */

- (void) analysisDictionary:(NSString *) servicesId
                   withSign:(NSString *) sign
                    withTag:(NSString *) tag
                   withType:(NSString *) type
{
    NSMutableDictionary *localDictionary = [_dictionary objectForKey:type];
    if(localDictionary != nil)
    {
        NSMutableDictionary *idDictionary = [localDictionary objectForKey:servicesId];
       
        if(idDictionary != nil)
        {
            //如果签名不相等，则认为需要显示红点，将isPress变量设置为 YES  ,并且要讲签名设置为新的值
            if(![[idDictionary objectForKey:RED_POINT_SIGN] isEqualToString:sign])
            {
                [idDictionary setValue:[NSNumber numberWithBool:YES] forKey:RED_POINT_ISPRESS];
                [idDictionary setValue:sign forKey:RED_POINT_SIGN];
            }
            [idDictionary setValue:[NSNumber numberWithBool:YES] forKey:RED_POINT_ISDOWN];
        }
        else //说明没有数据 if(idDictionary != nil)
        {
            idDictionary = [self dictionaryBySign:sign withTag:tag];
            [localDictionary setValue:idDictionary forKey:servicesId];
        }
    }
    else
    {
        localDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
        NSMutableDictionary *dict = [self dictionaryBySign:sign withTag:tag];
        [localDictionary setValue:dict forKey:servicesId];
    }
    
    [_dictionary setValue:localDictionary forKey:type];
}

/*!
  @brief    新增加的字典数据才使用这个函数
  @param
  @author    by bazinga
  */
- (NSMutableDictionary *)dictionaryBySign:(NSString *) sign withTag:(NSString *) tag
{
    //serviceId 下的字典序列
    NSMutableDictionary *dataDictonary = [NSMutableDictionary dictionaryWithCapacity:0];
    [dataDictonary setValue:sign forKey:RED_POINT_SIGN];
    [dataDictonary setValue:tag forKey:RED_POINT_TAG];
    NSNumber *isPressNumber = [NSNumber numberWithBool:[tag isEqualToString:@"1"]];
    [dataDictonary setValue:isPressNumber forKey:RED_POINT_ISPRESS];
    [dataDictonary setValue:[NSNumber numberWithBool:YES] forKey:RED_POINT_ISDOWN];

    return dataDictonary;
}


#pragma  mark - ---  辅助函数  ---
/*!
  @brief    将 id 类型的变量转换成 NSString
  @param
  @author    by bazinga
  */
- (NSString *) stringFromId:(id) tempId
{
    NSString *returnString = nil;
    if([tempId isKindOfClass:[NSString class]])
    {
        returnString = tempId;
    }
    else
    {
        returnString = [NSString stringWithFormat:@"%d",[tempId intValue]];
    }
    return  returnString;
}

@end
