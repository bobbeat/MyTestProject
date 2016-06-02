//
//  AccountXmlParser.m
//  Plugin_Account
//
//  Created by y y on 11-12-12.
//  Copyright 2011年 autonavi.com. All rights reserved.
//

#import "AccountXmlParser.h"


@implementation AccountXmlParser


static NSString *kName_BookMark=@"auth";//first element
static NSString *kName_Result =@"Result";
static NSString *kName_Message =@"Message";
static NSString *kName_Authenticate =@"Authenticate";
static NSString *kName_TimeStamp =@"TimeStamp";
static NSString *kName_Error =@"Error";

static NSString *kName_Profile =@"profile";

/**************** 用户帐号包含的信息 *****************/
static NSString *kName_UserId =@"id";
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
static NSString *kName_Gd_User_Name =@"Gd_User_Name";
static NSString *kName_tptype =@"tptype";
//服务器下发95190的POI信息点
static NSString *kName_Dest =@"Dest";
static NSString *kName_poi_name  =@"poi_name";
static NSString *kName_poi_lon  =@"poi_lon";
static NSString *kName_poi_lat   =@"poi_lat";
static NSString *kName_poi_phone  =@"poi_phone";
static NSString *kName_poi_addr  =@"poi_addr";

//任务栏文字
static NSString *kName_txt1  =@"txt1";
static NSString *kName_txt2  =@"txt2";

/**************** 用户帐号包含的信息 *****************/


#pragma mark NSXMLParser delegate
/**
 <?xml version="1.0" encoding="utf-8" ?>
 <auth>
 <Result><!-- OK or PARAMS_ERROR | UNKNOWN_ERROR --></Result>
 <Message><!-- 错误描述 --></Message>
 <Authenticate><!-- 是否认证通过 --></Authenticate>
 <TimeStamp><!-- 服务器时间戳 --></TimeStamp>
 <profile>
 <id><!-- 用户ID --></id>
 <username><!-- 用户名 --></username>
 <nickname><!-- 呢称 --></nickname>
 <firstname><!-- 姓氏 --></firstname>
 <lastname><!-- 名字 --></lastname>
 <telnumber><!-- 手机号 --></telnumber>
 <email><!-- 邮箱 --></email>
 <deciveid><!-- 硬件ID(uuid) --></deciveid>
 <phonedevice><!-- 导航设备使用电话号码  --></phonedevice>
 <sex><!-- 性别 --></sex>
 <age><!-- 年龄 --></age>
 <country><!-- 国家 --></country>
 <province><!-- 省份 --></province>
 <city><!-- 城市名称或城市代码 --></city>
 </profile>
 </auth>
 
 */

/**
 <?xml version="1.0" encoding="utf-8" ?>
 <auth>
 <Result><!-- OK or PARAMS_ERROR | UNKNOWN_ERROR --></Result>
 <Message><!-- 错误描述 --></Message>
 <Authenticate><!-- 是否认证通过 --></Authenticate>
 <TimeStamp><!-- 服务器时间戳 --></TimeStamp>
 </auth>
 
 */
static AccountXmlParser* singleXmlParse = nil;	//singleton
static BOOL parseAccountInfo = NO;  	//当前是否解析帐户信息

@synthesize kMessage,kAuthenticate,kResult,isAuth,kTimeStamp,contentOfCurrentProperty,myAccountInfo,kError,m_POI,kText1,kText2;
- (id)init
{
	self = [super init];
	if (self)
    {
        self.myAccountInfo =[[[AccountInfo alloc] init] autorelease];
        self.m_POI = [[[NSMutableDictionary  alloc] init] autorelease];
    }
	return self;
}

+(AccountXmlParser*)instance
{
    if(singleXmlParse ==nil)
    {
        singleXmlParse=[[AccountXmlParser alloc]init];
    }
    return singleXmlParse;
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

//解析XML结点头标志,存储变量值,供解析结点尾使用
- (void)parserDidStartDocument:(NSXMLParser *)parser
{

}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (qName) {
        elementName = qName;
    }

    if([elementName isEqualToString:kName_BookMark])
    {
//        NSLog(@"start parse XML");
        return;
    }

    if([elementName isEqualToString:kName_Result]||
       [elementName isEqualToString:kName_Message]||
       [elementName isEqualToString:kName_Authenticate]||
       [elementName isEqualToString:kName_Error]||
       [elementName isEqualToString:kName_TimeStamp])
    {
        self.contentOfCurrentProperty = [NSMutableString string];
        return;
    }
    
    if ([elementName isEqualToString:kName_Profile])
    {
		return;
    }

   else if([elementName isEqualToString:kName_UserId ]||
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
           [elementName isEqualToString:kName_Order ]||
           [elementName isEqualToString:kName_End_Time ]||
           [elementName isEqualToString:kName_days ]||
           [elementName isEqualToString:kName_Phone]||
           [elementName isEqualToString:kName_poi_addr]||
           [elementName isEqualToString:kName_poi_lat]||
           [elementName isEqualToString:kName_poi_lon]||
           [elementName isEqualToString:kName_poi_name]||
           [elementName isEqualToString:kName_poi_phone]||
           [elementName isEqualToString:kName_Dest]||
           [elementName isEqualToString:kName_txt1]||
           [elementName isEqualToString:kName_txt2]||
           [elementName isEqualToString:kName_Birthday]||
           [elementName isEqualToString:kName_Login_Type]||
           [elementName isEqualToString:kName_gdusername]||
           [elementName isEqualToString:kName_headimage]||
           [elementName isEqualToString:kName_Image_dir]||
           [elementName isEqualToString:kName_signature]||
           [elementName isEqualToString:kName_Gd_User_Name]||
           [elementName isEqualToString:kName_tptype]||
           [elementName isEqualToString:kName_tpusername]||
           [elementName isEqualToString:kName_Remain_Days ] )
    {
			//Account info
        self.contentOfCurrentProperty = [NSMutableString string];
    }
    else
    {
			// The element isn't one that we care about, so set the property that holds the 
			// character content of the current element to nil. That way, in the parser:foundCharacters:
			// callback, the string that the parser reports will be ignored.
        self.contentOfCurrentProperty = nil;        
    }
}
	///接收数据
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
    if (qName) {
        elementName = qName;
        if (XML_DEBUG) {
            NSLog(@"elementName is:%@",elementName);
        }
		
    }
	else if([elementName isEqualToString:kName_BookMark])
    {

    }   

    else if([elementName isEqualToString:kName_Result ])
    {
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);            
        }
        self.kResult =self.contentOfCurrentProperty;
    }

    else if([elementName isEqualToString:kName_Message ])
    {
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);            
        }
        self.kMessage =self.contentOfCurrentProperty;//messageStr        
    }
    else if([elementName isEqualToString:kName_Authenticate ])
    {
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);            
        }
		self.kAuthenticate =self.contentOfCurrentProperty;//isAuth        
    }
    else if([elementName isEqualToString:kName_Error ])
    {
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);
        }
		self.kError =self.contentOfCurrentProperty;//isAuth
    }
    else if([elementName isEqualToString:kName_TimeStamp ])
    {
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);            
        }
        self.kTimeStamp =self.contentOfCurrentProperty;//timeStampStr        
    }
    
    /*********************** 任务栏文字 start ***********************/
    if ([elementName isEqualToString:kName_txt1])
    {
        self.kText1 = self.contentOfCurrentProperty;
    }
    else if ([elementName isEqualToString:kName_txt2])
    {
        self.kText2 = self.contentOfCurrentProperty;
    }
    /*********************** 任务栏文字 end ***********************/
    
    /*********************** POI start ***********************/
    if ([elementName isEqualToString:kName_poi_addr])
    {
        [self.m_POI setObject:self.contentOfCurrentProperty forKey:@"szAddr"];
    }
    else if ([elementName isEqualToString:kName_poi_lat])
    {
        [self.m_POI setObject:self.contentOfCurrentProperty forKey:@"lLat"];
    }
    else if ([elementName isEqualToString:kName_poi_lon])
    {
        [self.m_POI setObject:self.contentOfCurrentProperty forKey:@"lLon"];
    }
    else if ([elementName isEqualToString:kName_poi_name])
    {
        [self.m_POI setObject:self.contentOfCurrentProperty forKey:@"szName"];
    }
    else if ([elementName isEqualToString:kName_poi_phone])
    {
        [self.m_POI setObject:self.contentOfCurrentProperty forKey:@"szTel"];
    }
    /*********************** POI end ***********************/
     
	
    /*********************** AccountInfo start ***********************/
	
    if ([elementName isEqualToString:kName_UserId ]){
        self.myAccountInfo.userId = [ self.contentOfCurrentProperty longLongValue];
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);            
        }        
    } else if ([elementName isEqualToString:kName_UserName ]){
        self.myAccountInfo.userName = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);            
        }        
    } else if ([elementName isEqualToString:kName_NickName ]){
        self.myAccountInfo.nickName = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);            
        }        
    } else if ([elementName isEqualToString:kName_FirstName ]){
        self.myAccountInfo.firstName = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);            
        }        
    } else if ([elementName isEqualToString:kName_LastName ]){
        self.myAccountInfo.lastName = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);            
        }        
    } else if ([elementName isEqualToString:kName_TelNumber ]){
        self.myAccountInfo.telNumber = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);
        }
    }else if ([elementName isEqualToString:kName_gdusername]){
        self.myAccountInfo.gdusername = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);
        }
    }else if ([elementName isEqualToString:kName_headimage]){
        self.myAccountInfo.headimage = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);
        }
    }else if ([elementName isEqualToString:kName_Image_dir]){
        self.myAccountInfo.headimage = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);
        }
    }else if ([elementName isEqualToString:kName_signature]){
        self.myAccountInfo.signature = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);
        }
    }else if ([elementName isEqualToString:kName_Gd_User_Name]){
        self.myAccountInfo.Gd_User_Name = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);
        }
    }else if ([elementName isEqualToString:kName_tptype]){
        self.myAccountInfo.tptype = [self.contentOfCurrentProperty intValue];
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);
        }
    }else if ([elementName isEqualToString:kName_tpusername]){
        self.myAccountInfo.tpusername = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);
        }
    }else if ([elementName isEqualToString:kName_Phone]){
        if (m_requestType == REQ_GET_PROFILE)
        {
            self.myAccountInfo.telNumber = self.contentOfCurrentProperty;
        }
        else if (m_requestType == REQ_GET_95190_STATUS || m_requestType == REQ_BUY_95190_SERVICE || m_requestType == REQ_FREE_95190)
        {
            self.myAccountInfo.m_tel_95190 = self.contentOfCurrentProperty;
        }
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);
        }
    } else if ([elementName isEqualToString:kName_Email ]){
        self.myAccountInfo.email = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);            
        }        
    } else if ([elementName isEqualToString:kName_DeviceId ]){
        self.myAccountInfo.deviceId = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);            
        }        
    } else if ([elementName isEqualToString:kName_PhoneDevice ]){
        self.myAccountInfo.phoneDevice = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);            
        }        
    } else if ([elementName isEqualToString:kName_Sex ]){
        self.myAccountInfo.sex = [self.contentOfCurrentProperty intValue];
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);            
        }        
    } else if ([elementName isEqualToString:kName_Age ]){
        self.myAccountInfo.age = [self.contentOfCurrentProperty intValue];
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);            
        }        
    }else if ([elementName isEqualToString:kName_Birthday ]){
        self.myAccountInfo.birthday = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);
        }
    }
    else if ([elementName isEqualToString:kName_Country ]){
       self.myAccountInfo.country = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);            
        }        
    } else if ([elementName isEqualToString:kName_Provice ]){
        self.myAccountInfo.province = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);            
        }        
    } else if ([elementName isEqualToString:kName_City ]){
        self.myAccountInfo.city = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);            
        }        
    }
    else if ([elementName isEqualToString:kName_Order ]){
        self.myAccountInfo.m_order = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);
        }
    }
    else if ([elementName isEqualToString:kName_End_Time ]){
        self.myAccountInfo.m_end_timer = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);
        }
    }
    else if ([elementName isEqualToString:kName_Dest ]){
        self.myAccountInfo.m_Destination = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);
        }
    }
    else if ([elementName isEqualToString:kName_Remain_Days ]){
        self.myAccountInfo.m_retaiDay = [self.contentOfCurrentProperty intValue];
        if (m_requestType == REQ_FREE_95190)
        {
            self.myAccountInfo.m_order = FREE_USER;
        }
        else if (m_requestType == REQ_BUY_95190_SERVICE)
        {
            self.myAccountInfo.m_order = BUY_USER;
        }
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);
        }
    }
    else if ([elementName isEqualToString:kName_days ]){
        self.myAccountInfo.m_retaiDay = [self.contentOfCurrentProperty intValue];
        self.myAccountInfo.m_order = FREE_USER;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);
        }
    }
    else if ([elementName isEqualToString:kName_Login_Type ]){
        self.myAccountInfo.loginType = self.contentOfCurrentProperty;
        if (XML_DEBUG) {
            NSLog(@"%@ is:%@",elementName,self.contentOfCurrentProperty);
        }
    }
    
    /*********************** AccountInfo end ***********************/
}

#pragma mark AccountInfo Thread

-(void)ClearAccountInfo
{
    myAccountInfo.userName = @"";
    myAccountInfo.firstName = @"";
    myAccountInfo.lastName = @"";
    myAccountInfo.nickName = @"";
    myAccountInfo.telNumber = @"";
    myAccountInfo.email = @"";
    myAccountInfo.province = @"";
    myAccountInfo.country = @"";
    myAccountInfo.city = @"";
    myAccountInfo.deviceId = @"";
    myAccountInfo.phoneDevice = @"";
    myAccountInfo.userId = 0;
    myAccountInfo.sex = 0;
    myAccountInfo.age = 0;
    myAccountInfo.headimage = @"";
    myAccountInfo.gdusername = @"";
    myAccountInfo.loginType = @"";
    myAccountInfo.birthday = @"";
    myAccountInfo.signature = @"";
    myAccountInfo.tpusername = @"";
}

-(void)Clear95190Info
{
    //95190信息
    myAccountInfo.m_order = @"";
    myAccountInfo.m_end_timer = @"";
    myAccountInfo.m_Destination = @"";
    myAccountInfo.m_tel_95190 = @"";
    myAccountInfo.m_retaiDay = 0;
}

//解析数据
-(NSDictionary *)GetOperationResultByData:(NSData *)data WithOperation:(id)op
{
	m_requestType = [op intValue];
    if (m_requestType == REQ_GET_95190_STATUS)
    {
        [self Clear95190Info];
    }
	if (data==nil)
	{
		return [[[NSDictionary alloc] initWithObjectsAndKeys:PARSE_DATA_NIL,KEY_FOR_RESULT,nil] autorelease];
	}
	NSError *parseError = nil;
    NSLog(@"%@",[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
	[self parseXMLFileWithData:data ParseError:&parseError];
	
	if (parseError!=nil||kResult == nil)
	{
        self.kResult =PARSE_ERROR;
    }
    //init value for NSDictionary values,abort NSDictionary attempt to insert nil value
	if (kMessage==nil) {
		self.kMessage=@"";
	}
	if (kTimeStamp==nil) {
		self.kTimeStamp = @"";
	}
	if (kAuthenticate==nil) {
		self.kAuthenticate =@"";
	}
    if (kError==nil) {
		self.kError =@"";
	}
    if (kText1 == nil)
    {
        kText1 = @"";
    }
    if (kText2 == nil)
    {
        kText2 = @"";
    }
    NSDictionary *result;
   
    NSLog(@"id:%ld,name:%@,Pb:%@,sex:%i,tel_95190:%@",myAccountInfo.userId,myAccountInfo.userName,myAccountInfo.telNumber,myAccountInfo.sex,myAccountInfo.m_tel_95190);
    result=[[NSDictionary alloc] initWithObjectsAndKeys:
            kResult,KEY_FOR_RESULT,kMessage,KEY_FOR_MESSAGE,kAuthenticate,KEY_FOR_AUTH,kTimeStamp,KEY_FOR_TIMESTAMP,myAccountInfo,KEY_FOR_PROFILE,kError,KEY_FOR_Error,self.m_POI,KEY_FOR_95190_POI,self.kText1,KEY_FOR_Text1,self.kText2,KEY_FOR_Text2,nil];

	return [result autorelease];
}




-(void)dealloc
{
	free(kAuthenticate);
	[myAccountInfo release];
	[contentOfCurrentProperty release];
    [kResult release];
    [kAuthenticate release];
    [kMessage release];
    [kTimeStamp release];
    [kError release];
	[super dealloc];
}

@end
