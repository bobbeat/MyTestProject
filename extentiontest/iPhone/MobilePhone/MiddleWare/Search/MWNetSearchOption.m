//
//  MWNetSearchOption.m
//  AutoNavi
//
//  Created by gaozhimin on 14-2-25.
//
//

#import "MWNetSearchOption.h"
#import "NSString+Category.h"
#import "XMLDictionary.h"
#include <objc/runtime.h>
#import "MWAccountOperator.h"

@interface MWNetSearchOption()

@property (nonatomic,copy) NSString *servcode;  //0005 表示 POI 搜索查询、语音搜 索查询、交叉路口搜索查询 0006 表示周边查询
@property (nonatomic,copy) NSString *syscode;  //业务系统账号             非空,参与鉴权计算
@property (nonatomic,copy) NSString *sign;  //签名串                  接口访问鉴权使用,非空
@property (nonatomic,assign) int model;  //搜索模式                 默认为 0,大陆搜索 1,台湾搜索
@property (nonatomic,copy) NSString *imei;  //机器唯一码              非空
@property (nonatomic,assign) int adcodesrc;          //Adcode 来源
@property (nonatomic,copy) NSString * mapv;          //本地数据版本号

@end

@implementation MWNetSearchOption

@synthesize size,adcode,search,adcodesrc,language,mapv,page,servcode,sign,syscode,model,imei;

- (id)init
{
    if (self = [super init])
    {
        
        self.mapv = MapVersionNoV;    //获取地图数据版本号;    //获取地图数据版本号
        NSLog(@"%@",self.mapv);
        self.imei = VendorID;
        self.page = 1;
        self.adcode = @"010";
        self.adcodesrc = 1;
        self.model = 0;
        self.syscode = KNetChannelID;
    }
    return self;
}

- (void)dealloc
{
    self.imei = nil;
    self.servcode = nil;
    self.syscode = nil;
    self.sign = nil;
    self.adcode = nil;
    self.search = nil;
    self.mapv = nil;
    [super dealloc];
}

/*
 获取对象的所有属性和属性内容
 */
- (NSMutableDictionary *)getAllPropertiesAndVaules
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
   
    objc_property_t *properties =class_copyPropertyList([MWNetSearchOption class], &outCount);
    for (i = 0; i<outCount; i++)//创建可变 字典
    {
       // objc_property_t property = properties[i];
        const char * char_f =property_getName(properties[i]);
        
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        
        id propertyValue = [self valueForKey:propertyName];
        
        NSLog(@"%@",propertyValue);//value
        if (propertyValue)
        {
            //[props setValue:propertyValue forKey:propertyName];
            [props setObject:propertyValue forKey:propertyName];
        }
        //NSLog(@"%@",props);
    }
     NSLog(@"%@",props);
    free(properties);
    return props;
}

        

/*
   md5值计算 String sign = MD5(syscode+parameter+"@"+key)
*/
- (NSString *)calculateSignWith:(NSString *)param
{
    NSString *md5 = [NSString stringWithFormat:@"%@%@@%@",self.syscode,param,kNetSignKey];
    md5 = [md5 stringFromMD5];
    return md5;
}

@end

@interface MWNetKeyWordSearchOption()



@end

@implementation MWNetKeyWordSearchOption
@synthesize suggestion;
- (id)init
{
    self = [super init];
    if (self) {
        self.servcode = @"0005";
    }
    return self;
}

@synthesize searchtype;

- (void)dealloc
{
    self.suggestion = nil;
    [super dealloc];
}

/* 
  获取对象的所有属性和属性内容
 */
- (NSDictionary *)getAllPropertiesAndVaules
{
    
    NSMutableDictionary *props = [super getAllPropertiesAndVaules];
    NSLog(@"%@",props);
    unsigned int outCount, i;
    objc_property_t *properties =class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue)
        {
            [props setObject:propertyValue forKey:propertyName];
        }
            
    }
    free(properties);
    NSLog(@"%@",props);
    return props;
}

/*
    搜索条件转换成NSData
 */
- (NSData *)getAllPropertiesAndVaulesData
{
    NSDictionary *props = [self getAllPropertiesAndVaules]; //获取类中所有属性，呈字典显示
    NSLog(@"%@",props);
    NSString * search = [props objectForKey:@"search"];      //将 search 中的 值置为 NSDATA  <search><![CDATA[天安门]]></search>
    if (search)
    {
        NSString *sign_md5 = [super calculateSignWith:search];   //计算MD5值 param = search
        if (sign_md5)
        {
            [props setValue:sign_md5 forKey:@"sign"];
        }
        NSLog(@"%@",search);
        [props setValue:[search dataUsingEncoding:NSUTF8StringEncoding] forKey:@"search"];
    }
    NSLog(@"%@",props);
    NSString *str = [GD_NSObjectToXML xmlHeadString];
    str = [str stringByAppendingString:[GD_NSObjectToXML convertDictionaryToXML:props rootName:@"og"]];
    NSLog(@"%@",str);

    return [str dataUsingEncoding:NSUTF8StringEncoding];
}


@end


@implementation MWNetAroundSearchOption

@synthesize category,center,cx,cy,range;

- (id)init
{
    self = [super init];
    if (self) {
        self.servcode = @"0006";
    }
    return self;
}

- (void)dealloc
{
    self.category = nil;
    self.center = nil;
    self.cx = nil;
    self.cy = nil;
    [super dealloc];
}

/*
 获取对象的所有属性和属性内容
 */
- (NSDictionary *)getAllPropertiesAndVaules
{
    
    NSMutableDictionary *props = [super getAllPropertiesAndVaules];
    unsigned int outCount, i;
    objc_property_t *properties =class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
    free(properties);
    return props;
}

/*
 搜索条件转换成NSData
 */
- (NSData *)getAllPropertiesAndVaulesData
{
    NSDictionary *props = [self getAllPropertiesAndVaules]; //获取类中所有属性，呈字典显示
    
    NSLog(@"%@",props);
    NSString *param = @"";
    if ([props objectForKey:@"cx"])
    {
        param = [param stringByAppendingString:[props objectForKey:@"cx"]];
         NSLog(@"%@",param);
    }
    if ([props objectForKey:@"cy"])
    {
        param = [param stringByAppendingString:[props objectForKey:@"cy"]];
        NSLog(@"%@",param);
    }
    if ([props objectForKey:@"category"])//类别
    {
        param = [param stringByAppendingString:[props objectForKey:@"category"]];
         NSLog(@"%@",param);
    }
    else
    {
        [props setValue:@"" forKey:@"category"];
    }
    if ([props objectForKey:@"search"])
    {
        param = [param stringByAppendingString:[props objectForKey:@"search"]];
         NSLog(@"%@",param);
    }
    else
    {
        [props setValue:@"" forKey:@"search"];
    }
    NSString *sign_md5 = [super calculateSignWith:param];   //计算MD5值 param = cx+cy+category+search
    if (sign_md5)
    {
        [props setValue:sign_md5 forKey:@"sign"];
    }
    
    NSString *data = [props objectForKey:@"search"];      //将 search 中的 值置为 NSDATA  <search><![CDATA[天安门]]</search>
    if (data)
    {
        [props setValue:[data dataUsingEncoding:NSUTF8StringEncoding] forKey:@"search"];
    }
    data = [props objectForKey:@"center"];      //将 center 中的 值置为 NSDATA <center><![CDATA[木香美食]]</center>
    if (data)
    {
        [props setValue:[data dataUsingEncoding:NSUTF8StringEncoding] forKey:@"center"];
    }
   NSLog(@"%@",props);
    NSString *str = [GD_NSObjectToXML xmlHeadString];
    str = [str stringByAppendingString:[GD_NSObjectToXML convertDictionaryToXML:props rootName:@"og"]];
    NSLog(@"%@",str);
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}

@end


#pragma mark --沿途周边

@interface MWNetLineSearchOption ()
@property(assign,nonatomic)int protversion;
@property (nonatomic,copy) NSString *servcode;  //0005 表示 POI 搜索查询、语音搜 索查询、交叉路口搜索查询 0006 表示周边查询
//@property (nonatomic,copy) NSString *sign;  //签名串                  接口访问鉴权使用,非空
@property (nonatomic,assign) int model;  //搜索模式                 默认为 0,大陆搜索 1,台湾搜索
@property (nonatomic,assign) int adcodesrc;          //Adcode 来源
@property (nonatomic,copy) NSString *mapv;          //本地数据版本号
@property(nonatomic,assign)int language;

@end
@implementation MWNetLineSearchOption
@synthesize category,cx,cy,range;
-(id)init
{
    self = [super init];
    if (self) {
        self.servcode = @"0007";
        self.protversion=1;
        self.language=0;
        self.mapv = MapVersionNoV;
        self.adcodesrc=1;
        self.model=0;

    }
    return self;
}
-(void)dealloc
{
    if (self.mapv) {
        self.mapv = nil;
    }
    self.servcode = nil;
    self.cx=nil;
    self.cy=nil;
    self.category=nil;
      [super dealloc];
}
/*
 获取对象的所有属性和属性内容
 */
- (NSMutableDictionary *)getAllPropertiesAndVaules
{
    NSMutableDictionary * props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    
    objc_property_t * properties =class_copyPropertyList([MWNetLineSearchOption class], &outCount);
    for (i = 0; i<outCount; i++)//创建可变 字典
    {
        
        const char * char_f =property_getName(properties[i]);
        
        NSString * propertyName = [NSString stringWithUTF8String:char_f];
        NSLog(@"%@",propertyName);
        id propertyValue = [self valueForKey:propertyName];
        
        NSLog(@"%@",propertyValue);//value
        if (propertyValue)
        {
           
            [props setObject:propertyValue forKey:propertyName];
        }
        //NSLog(@"%@",props);
    }
    NSLog(@"%@",props);
    free(properties);
    return props;
}
- (NSData *)getAllPropertiesAndVaulesData
{
    NSDictionary * props = [self getAllPropertiesAndVaules]; //获取类中所有属性，呈字典显示
    NSString * str = [GD_NSObjectToXML xmlHeadString];
    NSLog(@"%@",str);
    str = [str stringByAppendingString:[GD_NSObjectToXML convertDictionaryToXML:props rootName:@"og"]];
    NSLog(@"%@",str);
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}

/*
 md5值计算 String sign = MD5(syscode+parameter+"@"+key)
 */
- (NSString *)calculateSignWith:(NSString *)param
{
    NSString * md5 = [NSString stringWithFormat:@"%@%@@%@",KNetChannelID,param,kNetSignKey];
    md5 = [md5 stringFromMD5];
    return md5;
}


- (NSDictionary *)getHttpHeader
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:VendorID forKey:@"imei"];
   // [dic setObject:[NSString stringWithFormat:@"%.1f",SOFTVERSIONNUM] forKey:@"apkversion"];
    [dic setObject:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [dic setObject:MapVersionNoV forKey:@"mapversion"];
    [dic setObject:deviceModel forKey:@"model"];
    [dic setObject:DeviceResolutionString forKey:@"resolution"];
    [dic setObject:CurrentSystemVersion forKey:@"os"];
    if (UserID_Account) {
        [dic setObject:UserID_Account forKey:@"userid"];
    }
    [dic setObject:KNetChannelID forKey:@"syscode"];
    [dic setObject:PID forKey:@"pid"];
    
    NSDictionary * props = [self getAllPropertiesAndVaules]; //获取类中所有属性，呈字典显示
    NSString * param = @"";
    
    if ([props objectForKey:@"cx"])
    {
        param = [param stringByAppendingString:[props objectForKey:@"cx"]];
        NSLog(@"%@",param);
    }
    if ([props objectForKey:@"cy"])
    {
        param = [param stringByAppendingString:[props objectForKey:@"cy"]];
        NSLog(@"%@",param);
    }
    if ([props objectForKey:@"category"])//类别
    {
        param = [param stringByAppendingString:[props objectForKey:@"category"]];
        NSLog(@"%@",param);
    }
    else
    {
        [props setValue:@"" forKey:@"category"];
    }
    NSLog(@"%@",param);
    NSString * sign_md5 = [self calculateSignWith:param];//计算MD5值 param = cx+cy+category
    if (sign_md5)
    {
        [dic setObject:sign_md5 forKey:@"sign"];
    }
    // [dic setObject:@"gzip" forKey:@"Accept-Encoding"];
    return dic;
    
}
@end


#pragma mark --目的地停车场
@interface MWNetParkStopSearchOption ()
@property(copy,nonatomic)NSString * servcode;
@property(copy,nonatomic)NSString * mapv;
@property(assign,nonatomic)int model;
@property(assign,nonatomic)int adcodesrc;
@end


@implementation MWNetParkStopSearchOption
-(void)dealloc
{
    self.servcode=nil;
    self.mapv=nil;
    self.search=nil;
    self.cx=nil;
    self.cy=nil;
    [super dealloc];
}
-(id)init
{
    self = [super init];
    if (self) {
        self.servcode = @"0008";
        self.mapv = MapVersionNoV;    //获取地图数据版本号
        self.adcodesrc=1;
        self.model=0;
   
    }
    return self;
}


- (NSMutableDictionary *)getAllPropertiesAndVaules
{
    NSMutableDictionary * props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    
    objc_property_t * properties =class_copyPropertyList([MWNetParkStopSearchOption class], &outCount);
    for (i = 0; i<outCount; i++)//创建可变 字典
    {
        
        const char * char_f =property_getName(properties[i]);
        
        NSString * propertyName = [NSString stringWithUTF8String:char_f];
        NSLog(@"%@",propertyName);
        id propertyValue = [self valueForKey:propertyName];
        
        NSLog(@"%@",propertyValue);//value
        if (propertyValue)
        {
            [props setObject:propertyValue forKey:propertyName];
        }
    }
    NSLog(@"%@",props);
    free(properties);
    return props;
}
- (NSData *)getAllPropertiesAndVaulesData
{
    NSDictionary * props = [self getAllPropertiesAndVaules]; //获取类中所有属性，呈字典显示
    NSString *str = [GD_NSObjectToXML xmlHeadString];
    NSLog(@"%@",str);
    str = [str stringByAppendingString:[GD_NSObjectToXML convertDictionaryToXML:props rootName:@"og"]];
    NSLog(@"%@",str);
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}
- (NSDictionary *)getHttpHeader
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:VendorID forKey:@"imei"];
   // [dic setObject:[NSString stringWithFormat:@"%.1f",SOFTVERSIONNUM] forKey:@"apkversion"];
    [dic setObject:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [dic setObject:MapVersionNoV forKey:@"mapversion"];
    [dic setObject:deviceModel forKey:@"model"];
    [dic setObject:DeviceResolutionString forKey:@"resolution"];
    [dic setObject:CurrentSystemVersion forKey:@"os"];
    if (UserID_Account) {
        [dic setObject:UserID_Account forKey:@"userid"];
    }
    [dic setObject:KNetChannelID forKey:@"syscode"];
    [dic setObject:PID forKey:@"pid"];
    
    NSDictionary * props = [self getAllPropertiesAndVaules]; //获取类中所有属性，呈字典显示
    NSString * param = @"";
    if ([props objectForKey:@"cx"])
    {
        param = [param stringByAppendingString:[props objectForKey:@"cx"]];
        NSLog(@"%@",param);
    }
    if ([props objectForKey:@"cy"])
    {
        param = [param stringByAppendingString:[props objectForKey:@"cy"]];
        NSLog(@"%@",param);
    }
    if ([props objectForKey:@"search"])//类别
    {
        param = [param stringByAppendingString:[props objectForKey:@"search"]];
        NSLog(@"%@",param);
    }
    else
    {
        [props setValue:@"" forKey:@"category"];
    }
    
    NSString  * md5 = [self calculateSignWith:param];          //计算MD5值 param = cx+cy+search
    if (md5)
    {
        [dic setObject:md5 forKey:@"sign"];
    }

    return dic;
    
}

/*
 md5值计算 String sign = MD5(syscode+parameter+"@"+key)
 */
- (NSString *)calculateSignWith:(NSString *)param
{
    NSString * md5 = [NSString stringWithFormat:@"%@%@@%@",KNetChannelID,param,kNetSignKey];
    md5 = [md5 stringFromMD5];
    return md5;
}


@end