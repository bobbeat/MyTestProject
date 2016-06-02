//
//  MWAccountParseData.m
//  AutoNavi
//
//  Created by gaozhimin on 13-9-8.
//
//

#import "MWAccountParseData.h"

static NSString *kName_Result =@"Result";
static NSString *kName_Message =@"Message";
static NSString *kName_Authenticate =@"Authenticate";
static NSString *kName_TimeStamp =@"TimeStamp";
static NSString *kName_Error =@"Error";

/**************** 用户帐号包含的信息 *****************/
static NSString *kName_UserId =@"userid";
static NSString *kName_Id =@"id";
static NSString *kName_UserName =@"username";
static NSString *kName_NickName =@"nickname";
static NSString *kName_FirstName =@"firstname";
static NSString *kName_LastName =@"lastname";
static NSString *kName_TelNumber =@"telnumber";
static NSString *kName_Email =@"email";
static NSString *kName_DeviceId =@"deciveid";
static NSString *kName_PhoneDevice =@"phonedevice";
static NSString *kName_Sex =@"sex";
static NSString *kName_Age =@"age";
static NSString *kName_Birthday =@"birthday";
static NSString *kName_Country =@"country";
static NSString *kName_Provice =@"province";
static NSString *kName_City =@"city";
static NSString *kName_Phone =@"phone";
static NSString *kName_Order =@"order";
static NSString *kName_End_Time =@"end_time";
static NSString *kName_Remain_Days =@"remain_days";
static NSString *kName_days =@"days";
static NSString *kName_Login_Type =@"Login_Type";
static NSString *kName_gdusername =@"gdusername";
static NSString *kName_headimage =@"headimage";
static NSString *kName_Image_dir =@"Image_dir";
static NSString *kName_signature =@"signature";
static NSString *kName_tpusername =@"tpusername";
static NSString *kName_tpuserid =@"tpuserid";
static NSString *kName_Gd_User_Name =@"Gd_User_Name";
static NSString *kName_tptype =@"tptype";

//任务栏文字
static NSString *kName_txt1  =@"txt1";
static NSString *kName_txt2  =@"txt2";

//服务器下发95190的POI信息点
static NSString *kName_poi_name  =@"poi_name";
static NSString *kName_poi_lon  =@"poi_lon";
static NSString *kName_poi_lat   =@"poi_lat";
static NSString *kName_poi_phone  =@"poi_phone";
static NSString *kName_poi_addr  =@"poi_addr";

@interface MWAccountParseData ()
{
    
}
@property(nonatomic,copy)NSString *kResult;
@property(nonatomic,copy)NSString *kMessage;
@property(nonatomic,copy)NSString *kAuthenticate;
@property(nonatomic,copy)NSString *kTimeStamp;
@property(nonatomic,copy)NSString *kError;
@property(nonatomic,retain)NSMutableString *contentOfCurrentProperty;
@property(nonatomic,retain)NSMutableDictionary *infoDictonary;  //存储解析数据

@end

@implementation MWAccountParseData

@synthesize contentOfCurrentProperty;
@synthesize kMessage,kAuthenticate,kResult,kTimeStamp,kError;

- (id)init
{
	self = [super init];
	if (self)
    {
        self.infoDictonary = [NSMutableDictionary dictionary];
    }
	return self;
}

- (void)dealloc
{
    self.infoDictonary = nil;
    self.contentOfCurrentProperty = nil;
    [super dealloc];
}

//解析URL请求的XML
-(void)parseXMLFileWithData:(NSData *)data ParseError:(NSError **)error
{
	NSXMLParser *parser =[[NSXMLParser alloc]initWithData:data];
	
	[parser setDelegate:self];
	// Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
	
	[parser parse];//start
	
	NSError *parseError = [parser parserError];
    if (parseError && error) {
        *error = parseError;
    }
    
    [parser release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"txt_en"]
        ||[elementName isEqualToString:@"txt_china"]
        ||[elementName isEqualToString:@"txt_tw"]
        ||[elementName isEqualToString:@"phone"])
    {
        self.contentOfCurrentProperty = [NSMutableString string];
    }
    else if([elementName isEqualToString:kName_Result]||
            [elementName isEqualToString:kName_Message]||
            [elementName isEqualToString:kName_Authenticate]||
            [elementName isEqualToString:kName_Error]||
            [elementName isEqualToString:kName_TimeStamp]
            )
    {
        self.contentOfCurrentProperty = [NSMutableString string];
    }
    else if([elementName isEqualToString:kName_Order ]||    //智驾相关字段
            [elementName isEqualToString:kName_End_Time ]||
            [elementName isEqualToString:kName_days ]||
            [elementName isEqualToString:kName_Remain_Days ]||
            [elementName isEqualToString:kName_Phone] ||
            [elementName isEqualToString:kName_txt1]||
            [elementName isEqualToString:kName_txt2]
            )
    {
        self.contentOfCurrentProperty = [NSMutableString string];
    }
    else if([elementName isEqualToString:kName_poi_name ]||    //服务器下发95190的POI信息点
            [elementName isEqualToString:kName_poi_lon ]||
            [elementName isEqualToString:kName_poi_lat ]||
            [elementName isEqualToString:kName_poi_phone ]||
            [elementName isEqualToString:kName_poi_addr]
            )
    {
        self.contentOfCurrentProperty = [NSMutableString string];
    }
    else if([elementName isEqualToString:kName_Id ]||       //账户信息解析字段
            [elementName isEqualToString:kName_UserId ]||
            [elementName isEqualToString:kName_UserName  ]||
            [elementName isEqualToString:kName_NickName ]||
            [elementName isEqualToString:kName_FirstName ]||
            [elementName isEqualToString:kName_LastName ]||
            [elementName isEqualToString:kName_TelNumber ]||
            [elementName isEqualToString:kName_Email ]||
            [elementName isEqualToString:kName_DeviceId ]||
            [elementName isEqualToString:kName_PhoneDevice ]||
            [elementName isEqualToString:kName_Sex ]||
            [elementName isEqualToString:kName_Age ]||
            [elementName isEqualToString:kName_Country ]||
            [elementName isEqualToString:kName_Provice ]||
            [elementName isEqualToString:kName_City ]||
            [elementName isEqualToString:kName_Birthday]||
            [elementName isEqualToString:kName_Login_Type]||
            [elementName isEqualToString:kName_gdusername]||
            [elementName isEqualToString:kName_headimage]||
            [elementName isEqualToString:kName_Image_dir]||
            [elementName isEqualToString:kName_signature]||
            [elementName isEqualToString:kName_Gd_User_Name]||
            [elementName isEqualToString:kName_tptype]||
            [elementName isEqualToString:kName_tpusername]||
            [elementName isEqualToString:kName_tpuserid]||
            [elementName isEqualToString:kName_Remain_Days ] )
    {
        //Account info
        self.contentOfCurrentProperty = [NSMutableString string];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.contentOfCurrentProperty) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        [self.contentOfCurrentProperty appendString:string];
    }
}

//解析XML结点尾标志,存储数据
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (self.contentOfCurrentProperty == nil)
    {
        self.contentOfCurrentProperty = [NSMutableString string];
    }
    if ([elementName isEqualToString:@"txt_en"]
        ||[elementName isEqualToString:@"txt_china"]
        ||[elementName isEqualToString:@"txt_tw"]
        ||[elementName isEqualToString:@"phone"])
    {
        [self.infoDictonary setObject:self.contentOfCurrentProperty forKey:elementName];
    }
    else if([elementName isEqualToString:kName_Result]||
            [elementName isEqualToString:kName_Message]||
            [elementName isEqualToString:kName_Authenticate]||
            [elementName isEqualToString:kName_Error]||
            [elementName isEqualToString:kName_TimeStamp]
            )
    {
        [self.infoDictonary setObject:self.contentOfCurrentProperty forKey:elementName];
    }
    /*智驾相关字段*/
    else if([elementName isEqualToString:kName_Order ]||    //智驾相关字段
            [elementName isEqualToString:kName_End_Time ]||
            [elementName isEqualToString:kName_days ]||
            [elementName isEqualToString:kName_Remain_Days ]||
            [elementName isEqualToString:kName_Phone] ||
            [elementName isEqualToString:kName_txt1]||
            [elementName isEqualToString:kName_txt2]
            )
    {
        [self.infoDictonary setObject:self.contentOfCurrentProperty forKey:elementName];
    }
    else if([elementName isEqualToString:kName_poi_name ]||    //服务器下发95190的POI信息点
            [elementName isEqualToString:kName_poi_lon ]||
            [elementName isEqualToString:kName_poi_lat ]||
            [elementName isEqualToString:kName_poi_phone ]||
            [elementName isEqualToString:kName_poi_addr]
            )
    {
        [self.infoDictonary setObject:self.contentOfCurrentProperty forKey:elementName];
    }
    /*智驾相关字段*/
    else if([elementName isEqualToString:kName_Id ]||       //账户信息解析字段
            [elementName isEqualToString:kName_UserId ]||
            [elementName isEqualToString:kName_UserName  ]||
            [elementName isEqualToString:kName_NickName ]||
            [elementName isEqualToString:kName_FirstName ]||
            [elementName isEqualToString:kName_LastName ]||
            [elementName isEqualToString:kName_TelNumber ]||
            [elementName isEqualToString:kName_Email ]||
            [elementName isEqualToString:kName_DeviceId ]||
            [elementName isEqualToString:kName_PhoneDevice ]||
            [elementName isEqualToString:kName_Sex ]||
            [elementName isEqualToString:kName_Age ]||
            [elementName isEqualToString:kName_Country ]||
            [elementName isEqualToString:kName_Provice ]||
            [elementName isEqualToString:kName_City ]||
            [elementName isEqualToString:kName_Birthday]||
            [elementName isEqualToString:kName_Login_Type]||
            [elementName isEqualToString:kName_gdusername]||
            [elementName isEqualToString:kName_headimage]||
            [elementName isEqualToString:kName_Image_dir]||
            [elementName isEqualToString:kName_signature]||
            [elementName isEqualToString:kName_Gd_User_Name]||
            [elementName isEqualToString:kName_tptype]||
            [elementName isEqualToString:kName_tpusername]||
            [elementName isEqualToString:kName_tpuserid]||
            [elementName isEqualToString:kName_Remain_Days ] )
    {
        [self.infoDictonary setObject:self.contentOfCurrentProperty forKey:elementName];
    }
    self.contentOfCurrentProperty = nil;
}

+ (NSDictionary *)GetOperationResultByData:(NSData *)data
{
    NSError *parseError = nil;
    NSLog(@"%@",[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
    
    MWAccountParseData *parse = [[[MWAccountParseData alloc] init] autorelease];
	[parse parseXMLFileWithData:data ParseError:&parseError];
    if (!parseError)
    {
        NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:parse.infoDictonary];
        return [dic autorelease];
    }
    return nil;
}

@end
