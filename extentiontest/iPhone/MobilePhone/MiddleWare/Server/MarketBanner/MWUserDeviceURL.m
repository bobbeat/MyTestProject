//
//  MWUserDeviceProtocol.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-5-8.
//
//

#import "MWUserDeviceURL.h"
#import <AdSupport/AdSupport.h>
#import "MWMapOperator.h"
#import "OpenUDID.h"

@implementation MWUserDeviceURL

/***
 * @name    计算签名的值
 * @param   nil
 * @author  by bazinga
 * @algorithm   
 * 1、使用channel + diu + @ + key（签名的key值）组合成的字符串，进行MD5加密
 * 2、并将加密后的结果，全部转化为大写字母
 ***/
+ (NSString *)encryptChannel
{
    NSMutableString *encryptChannel = [[NSMutableString alloc]initWithFormat:@"%@%@@%@",USER_DEVICE_INFO_CHANNEL,USER_DEVICE_INFO_MAC,USER_DEVICE_INFO_KEY] ;
    
    NSString *returnString = [[encryptChannel stringFromMD5] uppercaseString];
    [encryptChannel release];
    return returnString;
}

/***
 * @name    2011-01-01 00:00:00以来，距离fromdate的时间秒数
 * @param   fromDate —— 要计算的日期
 * @author  by bazinga
 ***/
+ (NSString *) timeFrom:(NSDate *)fromDate
{
    //创建2011-01-01的日期
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:1];
    [comps setDay:1];
    [comps setYear:2011];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [calendar dateFromComponents:comps];
    //计算间隔的秒数
    NSTimeInterval secondsInterval = [fromDate timeIntervalSinceDate:date];
    NSLog(@"%lf",secondsInterval);
    [comps release];
    [calendar release];
    return [NSString stringWithFormat:@"%.0lf",secondsInterval];
}

/***
 * @name    安全水印的获取方法
 * @param   sessionString —— 距离2011-01-01 00:00:00以来的秒数
 * @param   div ——  设备版本
 * @param   diu ——  设备的uuid~唯一识别码
 * @return  水印字符串
 * @author  by bazinga
 * @algorithm
 * 1、sessionString + div + diu 进行MD5加密，将结果转换为小写——记为 MD5String
 * 2、将 MD5String 中的数字进行删除，取出前5个字母（不足5个字母，则有几个字母就取几个字母）
 * 3、将获取的字母字符串，进行BASE62 转码 —— 返回对象
 ***/
+ (NSString *) SecurityWaterMark:(NSString *)sessionString withDiv:(NSString *)div withDiu:(NSString *)diu
{
    //将组合成的字符串，进行MD5加密，并转换为小写字母
    NSMutableString *encryptChannel = [[NSMutableString alloc]initWithFormat:@"%@%@%@",sessionString,div,diu];
    NSString *lowString = [[encryptChannel stringFromMD5] lowercaseString];
    NSString *replaceString = nil;
    //将字符串中的数字删除
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    replaceString =  [[lowString componentsSeparatedByCharactersInSet:doNotWant] componentsJoinedByString:@""];
    NSLog(@"replaceString：%@",replaceString);
    //取出字符串的前五个字母（不足5个，就有几个，取几个）
    NSString *replaceString5 = ([replaceString length] > 5) ? [replaceString substringWithRange:NSMakeRange(0, 5)] : replaceString;
    NSLog(@"replaceString5：%@",replaceString5);
    [encryptChannel release];
    return [self toBase62:replaceString5];
}


/***
 * @name    将字符串转为 base62 的数字
 * @param   letterString —— 待转换字符串
 * @return  算法加密后的base62编码的数字
 * @author  by bazinga
 * @algorithm
 * 1、看代码……就是计算的数学题
 ***/
+ (NSString *)toBase62:(NSString *)letterString
{
    const char *replaceChar5 = [letterString UTF8String];
    
    //转位base62编码
    NSString *returnFinalString = @"";
    if([letterString length] < 1 || [letterString length] > 5)
    {
        returnFinalString = @"123456789";
    }
    
    long long y  = 0;
    for ( int i = 0;  i < [letterString length]; i++)
    {
        y += (10 + replaceChar5[i] - 'a')
        * pow(62.0f, [letterString length] - (i + 1));
    }
    
    NSLog(@"y  ===   %lld",y);
    
    return [NSString stringWithFormat:@"%lld",y];
}

/***
 * @name    获取上传设备信息的url
 * @param   基础URL
 * @author  by bazinga
 ***/
+ (NSURL *) userDeviceInfoURL:(NSString *)baseUrl
{
    GCARINFO carInfo = {0};
    [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carInfo];
    NSString *divText = SOFT_AOS_VERSION;
    NSMutableString *uploadUrl = [[[NSMutableString alloc]initWithString:baseUrl] autorelease];
    NSString *channelString = [NSString stringWithFormat:@"channel=%@",USER_DEVICE_INFO_CHANNEL];
    NSString *dipString = [NSString stringWithFormat:@"&dip=%@",USER_DEVICE_INFO_APPID];
    NSString *dicString = [NSString stringWithFormat:@"&dic=%@",USER_DEVICE_INFO_DIC];
    NSString *divString = [NSString stringWithFormat:@"&div=%@",divText];
    NSString *diuString = [NSString stringWithFormat:@"&diu=%@",USER_DEVICE_INFO_MAC];
    NSString *diu2String = [NSString stringWithFormat:@"&diu2=%@",IDFA];
    NSString *diu3String = [NSString stringWithFormat:@"&diu3=%@",OpenUDIDValue];
    NSString *signString = [NSString stringWithFormat:@"&sign=%@",[self encryptChannel]];
    NSString *deviceString = [NSString stringWithFormat:@"&device=%@",deviceModel];
    NSString *modelString = [NSString stringWithFormat:@"&model=%@",CurrentSystemVersion];
    NSString *lonString = [NSString stringWithFormat:@"&lon=%lf",carInfo.Coord.x/1000000.0f];
    NSString *latString = [NSString stringWithFormat:@"&lat=%lf",carInfo.Coord.y/1000000.0f];
    NSString *tokenString = [NSString stringWithFormat:@"&token=%@",deviceTokenEx];
    
    
    NSString *timerSession = [self timeFrom:[NSDate date]];
    NSString *session = [NSString stringWithFormat:@"&session=%@",timerSession];
    NSString *codexString =[self SecurityWaterMark:timerSession withDiv:divText withDiu:USER_DEVICE_INFO_MAC];
    
    NSString *codex = [NSString stringWithFormat:@"&codex=%@",codexString];
    
    
    [uploadUrl appendFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",channelString,dipString,dicString,divString,diuString,diu2String,diu3String,signString,session,codex,deviceString,modelString,lonString,latString,tokenString];
    NSLog(@" uploadUrl  =   %@",uploadUrl);
    return [NSURL URLWithString:uploadUrl];
}

@end




















