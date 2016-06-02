//
//  MWSmartEyes.m
//  AutoNavi
//
//  Created by gaozhimin on 13-7-30.
//
//

#import "MWSmartEyes.h"

@implementation MWSmartEyesItem

@synthesize Date,nIndex,eCategory,Time,nAngle,nSpeed,nId;

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.actionType] forKey:@"actionType"];
    
	[encoder encodeObject:[NSString stringWithFormat:@"%d",self.Date.year] forKey:@"year"];
	[encoder encodeObject:[NSString stringWithFormat:@"%d",self.Date.month] forKey:@"month"];
	[encoder encodeObject:[NSString stringWithFormat:@"%d",self.Date.day] forKey:@"day"];
    
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.Time.hour] forKey:@"hour"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.Time.minute] forKey:@"minute"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.Time.second] forKey:@"second"];
    
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.eCategory] forKey:@"eCategory"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.nIndex] forKey:@"nIndex"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.nId] forKey:@"nId"];
    [encoder encodeObject:self.szName forKey:@"szName"];
    
    
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.lAdminCode] forKey:@"lAdminCode"];
    [encoder encodeObject:[NSString stringWithFormat:@"%ld",self.longitude] forKey:@"longitude"];
    [encoder encodeObject:[NSString stringWithFormat:@"%ld",self.latitude] forKey:@"latitude"];
    
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.nAngle] forKey:@"nAngle"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.nSpeed] forKey:@"nSpeed"];
    
    [encoder encodeObject:self.netPoiId forKey:@"netPoiId"];
    [encoder encodeObject:self.accountId forKey:@"accountId"];

}


- (id)initWithCoder:(NSCoder *) decoder
{
	if (self = [super init])
	{
        GDATE				Date_tmp;
		Date_tmp.year = [[decoder decodeObjectForKey:@"year"] intValue];
        Date_tmp.month = [[decoder decodeObjectForKey:@"month"] intValue];
        Date_tmp.day = [[decoder decodeObjectForKey:@"day"] intValue];
		self.Date = Date_tmp;
        
        GTIME				Time_tmp;
		Time_tmp.hour = [[decoder decodeObjectForKey:@"hour"] intValue];
        Time_tmp.minute = [[decoder decodeObjectForKey:@"minute"] intValue];
        Time_tmp.second = [[decoder decodeObjectForKey:@"second"] intValue];
		self.Time = Time_tmp;
        
        self.actionType = [[decoder decodeObjectForKey:@"actionType"] intValue];
        
        self.nIndex = [[decoder decodeObjectForKey:@"nIndex"] intValue];
        self.nId = [[decoder decodeObjectForKey:@"nId"] intValue];
        self.eCategory = [[decoder decodeObjectForKey:@"eCategory"] intValue];
        
        self.latitude = [[decoder decodeObjectForKey:@"latitude"] intValue];
        self.longitude = [[decoder decodeObjectForKey:@"longitude"] intValue];
        
        self.lAdminCode = [[decoder decodeObjectForKey:@"lAdminCode"] intValue];
        self.nAngle = [[decoder decodeObjectForKey:@"nAngle"] intValue];
        self.nSpeed = [[decoder decodeObjectForKey:@"nSpeed"] intValue];
        
        self.szName = [decoder decodeObjectForKey:@"szName"];
        
        self.netPoiId = [decoder decodeObjectForKey:@"netPoiId"];
        self.accountId = [decoder decodeObjectForKey:@"accountId"];
        
	}
	
	return self;
}

//需要对角度赋值nAngle =360，360指360个方向监控
- (int)nAngle
{
    return 360;
}


- (id)init
{
    self = [super init];
    if (self)
    {
        GDATE	Date_tmp = {1975,1,1};
        self.Date	= Date_tmp;
        GTIME	Time_tmp = {1,1,1};
        self.Time	= Time_tmp;
    }
    return self;
}

- (void)dealloc
{
    self.szName = nil;
    [super dealloc];
}

@end

@implementation MWSmartEyes

@synthesize nNumberOfItem,smartEyesArray,Date,Time,allIdentify,userId;

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:[NSString stringWithFormat:@"%d",self.Date.year] forKey:@"year"];
	[encoder encodeObject:[NSString stringWithFormat:@"%d",self.Date.month] forKey:@"month"];
	[encoder encodeObject:[NSString stringWithFormat:@"%d",self.Date.day] forKey:@"day"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.Time.hour] forKey:@"hour"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.Time.minute] forKey:@"minute"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.Time.second] forKey:@"second"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.nNumberOfItem] forKey:@"nNumberOfItem"];
    [encoder encodeObject:userId forKey:@"userId"];
    [encoder encodeObject:smartEyesArray forKey:@"pFavoritePOIArray"];
}


- (id)initWithCoder:(NSCoder *) decoder
{
	if (self = [super init])
	{
        GDATE				Date_tmp;
		Date_tmp.year = [[decoder decodeObjectForKey:@"year"] intValue];
        Date_tmp.month = [[decoder decodeObjectForKey:@"month"] intValue];
        Date_tmp.day = [[decoder decodeObjectForKey:@"day"] intValue];
		self.Date = Date_tmp;
        
        GTIME				Time_tmp;
		Time_tmp.hour = [[decoder decodeObjectForKey:@"hour"] intValue];
        Time_tmp.minute = [[decoder decodeObjectForKey:@"minute"] intValue];
        Time_tmp.second = [[decoder decodeObjectForKey:@"second"] intValue];
		self.Time = Time_tmp;
        
        self.userId = [decoder decodeObjectForKey:@"userId"];
        self.nNumberOfItem = [[decoder decodeObjectForKey:@"nNumberOfItem"] intValue];
        self.smartEyesArray = [decoder decodeObjectForKey:@"pFavoritePOIArray"];
	}
	
	return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        GDATE	Date_tmp = {1975,1,1};
        self.Date	= Date_tmp;
        GTIME	Time_tmp = {1,1,1};
        self.Time	= Time_tmp;
        self.smartEyesArray = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.userId = nil;
    self.allIdentify = nil;
    self.smartEyesArray = nil;
    [super dealloc];
}

@end

@implementation MWSmartEyesOption

@synthesize eCategory;

- (id)init
{
    self = [super init];
    if (self)
    {
        eCategory = GSAFE_CATEGORY_ALL;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end

@implementation MWSmartEyesXMLParser

@synthesize smartEyes;
/**
 *	解析收藏夹，历史目的地
 *	@return	解析对象
 */
- (id)init
{
	if (self = [super init])
	{
        
        smartEyes = [[MWSmartEyes alloc] init];
        
	}
	return self;
}

- (void)dealloc
{
    [smartEyes release];
    smartEyes = nil;
    [super dealloc];
}

- (BOOL)parser:(NSData *)data
{
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
	if ([parser parserError])
	{
		return NO;
	}
	
    [parser release];
	return YES;
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (qName)
	{
        elementName = qName;
	}
    if ([elementName isEqualToString:@"town"] || [elementName isEqualToString:@"name"] || [elementName isEqualToString:@"latitude_off"] ||
        [elementName isEqualToString:@"telephone"] || [elementName isEqualToString:@"longitude"] || [elementName isEqualToString:@"detail"] ||
        [elementName isEqualToString:@"latitude"] || [elementName isEqualToString:@"longitude_off"] || [elementName isEqualToString:@"from_type"] ||
        [elementName isEqualToString:@"address"] || [elementName isEqualToString:@"item_id"] || [elementName isEqualToString:@"type"] ||
        [elementName isEqualToString:@"origen_type"] || [elementName isEqualToString:@"admin_code"] || [elementName isEqualToString:@"angle"] ||
        [elementName isEqualToString:@"speed"] || [elementName isEqualToString:@"flag"] || [elementName isEqualToString:@"lastuploadtime"] || [elementName isEqualToString:@"alldata"])
    {
        currentProperty = [NSMutableString string];
    }
    
    else if ([elementName isEqualToString:@"item"])
    {
        itemNode = [[MWSmartEyesItem alloc] init];// Create the element
    }
    
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (currentProperty)
	{
        [currentProperty appendString:string];
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (qName)
	{
        elementName = qName;
    }
    if ([elementName isEqualToString:@"town"])
    {
        itemNode.szTown = currentProperty;
    }
    else if ([elementName isEqualToString:@"name"])
    {
        NSString *name =(NSString *)CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault,
                                                                               (CFStringRef)currentProperty,
                                                                               CFSTR("")
                                                                               );
        
        itemNode.szName = name;
        [name release];
    }
    else if ([elementName isEqualToString:@"telephone"])
    {
        itemNode.szTel = currentProperty;
    }
    else if ([elementName isEqualToString:@"longitude"])
    {
        itemNode.longitude = [currentProperty intValue];
    }
    else if ([elementName isEqualToString:@"latitude"])
    {
        itemNode.latitude = [currentProperty intValue];
    }
    else if ([elementName isEqualToString:@"item_id"])
    {
        itemNode.nId = [currentProperty intValue];
    }
    else if ([elementName isEqualToString:@"from_type"])
    {
        itemNode.lCategoryID = [currentProperty intValue];
    }
    else if ([elementName isEqualToString:@"address"])
    {
        itemNode.szAddr = currentProperty;
    }
    else if ([elementName isEqualToString:@"speed"])
    {
        itemNode.nSpeed = [currentProperty intValue];
    }
    else if ([elementName isEqualToString:@"angle"])
    {
        itemNode.nAngle = [currentProperty intValue];
    }
    else if ([elementName isEqualToString:@"flag"])
    {
        itemNode.eCategory = [currentProperty intValue];
    }
    else if ([elementName isEqualToString:@"alldata"])
    {
        smartEyes.allIdentify = currentProperty;
    }
    else if ([elementName isEqualToString:@"lastuploadtime"])
    {
        NSArray *temp = [currentProperty componentsSeparatedByString:@" "];
        if ([temp count] >= 2)
        {
            NSArray *dataArray = [[temp objectAtIndex:0] componentsSeparatedByString:@"-"];
            NSArray *timeArray = [[temp objectAtIndex:1] componentsSeparatedByString:@":"];
            if ([dataArray count] >= 3)
            {
                GDATE date;
                date.year = [[dataArray objectAtIndex:0] intValue];
                date.month = [[dataArray objectAtIndex:1] intValue];
                date.day = [[dataArray objectAtIndex:2] intValue];
                smartEyes.Date = date;
            }
            if ([timeArray count] >= 3)
            {
                GTIME time;
                time.hour = [[timeArray objectAtIndex:0] intValue];
                time.minute = [[timeArray objectAtIndex:1] intValue];
                time.second = [[timeArray objectAtIndex:2] intValue];
                smartEyes.Time = time;
            }
        }
        
        
    }
    if ([elementName isEqualToString:@"item"])
    {
        [smartEyes.smartEyesArray addObject:itemNode];
        [itemNode release];
        itemNode = nil;
    }
	currentProperty = nil;
}

@end