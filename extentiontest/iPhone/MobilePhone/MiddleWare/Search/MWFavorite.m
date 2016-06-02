//
//  MWFavorite.m
//  AutoNavi
//
//  Created by gaozhimin on 13-7-30.
//
//

#import "MWFavorite.h"

@implementation MWFavoritePoi

@synthesize eCategory,eIconID,Date,Time,nIndex;

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
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.eIconID] forKey:@"eIconID"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.nIndex] forKey:@"nIndex"];
    
    [encoder encodeObject:self.szName forKey:@"szName"];
    [encoder encodeObject:self.szAddr forKey:@"szAddr"];
    [encoder encodeObject:self.szTel forKey:@"szTel"];
    
    [encoder encodeObject:self.szTown forKey:@"szTown"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.lNaviLon] forKey:@"lNaviLon"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.lNaviLat] forKey:@"lNaviLat"];
    
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.lAdminCode] forKey:@"lAdminCode"];
    [encoder encodeObject:[NSString stringWithFormat:@"%ld",self.longitude] forKey:@"longitude"];
    [encoder encodeObject:[NSString stringWithFormat:@"%ld",self.latitude] forKey:@"latitude"];
    
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.lCategoryID] forKey:@"lCategoryID"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.lHilightFlag] forKey:@"lHilightFlag"];
    
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.lMatchCode] forKey:@"lMatchCode"];
//    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.stPoiId.unMeshID] forKey:@"lPoiId"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.lPoiIndex] forKey:@"lPoiIndex"];
    
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.Reserved] forKey:@"Reserved"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.ucFlag] forKey:@"ucFlag"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.usNodeId] forKey:@"usNodeId"];
    
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
        self.eCategory = [[decoder decodeObjectForKey:@"eCategory"] intValue];
        self.eIconID = [[decoder decodeObjectForKey:@"eIconID"] intValue];
        
        self.lCategoryID = [[decoder decodeObjectForKey:@"lCategoryID"] intValue];
        self.latitude = [[decoder decodeObjectForKey:@"latitude"] intValue];
        self.longitude = [[decoder decodeObjectForKey:@"longitude"] intValue];
        
        self.lAdminCode = [[decoder decodeObjectForKey:@"lAdminCode"] intValue];
        self.lHilightFlag = [[decoder decodeObjectForKey:@"lHilightFlag"] intValue];
        
        self.lMatchCode = [[decoder decodeObjectForKey:@"lMatchCode"] intValue];
//        self.stPoiId.unMeshID = [[decoder decodeObjectForKey:@"lPoiId"] intValue];
        self.lPoiIndex = [[decoder decodeObjectForKey:@"lPoiIndex"] intValue];
        
        self.Reserved = [[decoder decodeObjectForKey:@"Reserved"] intValue];
        self.lNaviLat = [[decoder decodeObjectForKey:@"lNaviLat"] intValue];
        self.lNaviLon = [[decoder decodeObjectForKey:@"lNaviLon"] intValue];
        
        self.ucFlag = [[decoder decodeObjectForKey:@"ucFlag"] intValue];
        self.usNodeId = [[decoder decodeObjectForKey:@"usNodeId"] intValue];
        self.szAddr = [decoder decodeObjectForKey:@"szAddr"];
        
        self.szName = [decoder decodeObjectForKey:@"szName"];
        self.szTel = [decoder decodeObjectForKey:@"szTel"];
        self.szTown = [decoder decodeObjectForKey:@"szTown"];
        
        self.netPoiId = [decoder decodeObjectForKey:@"netPoiId"];
        self.accountId = [decoder decodeObjectForKey:@"accountId"];
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
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end

@implementation MWFavorite

@synthesize nNumberOfItem,pFavoritePOIArray,Date,Time,allIdentify,userId;

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
    [encoder encodeObject:pFavoritePOIArray forKey:@"pFavoritePOIArray"];
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
        self.pFavoritePOIArray = [decoder decodeObjectForKey:@"pFavoritePOIArray"];
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
        self.pFavoritePOIArray = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.userId = nil;
    self.allIdentify = nil;
    self.pFavoritePOIArray = nil;
    [super dealloc];
}

@end

@implementation MWFavoriteOption

@synthesize eCategory;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end

@implementation MWFavXMLParser

@synthesize favorite;
/**
 *	解析收藏夹，历史目的地
 *	@return	解析对象
 */
- (id)init
{
	if (self = [super init])
	{

        favorite = [[MWFavorite alloc] init];

	}
	return self;
}

- (void)dealloc
{
    [favorite release];
    favorite = nil;
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
        itemNode = [[MWFavoritePoi alloc] init];// Create the element
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
        if (name)
        {
            itemNode.szName = name;
        }
        else
        {
            itemNode.szName = STR(@"Main_unNameRoad", Localize_Main);
        }
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
    else if ([elementName isEqualToString:@"longitude_off"])
    {
        itemNode.lNaviLon = [currentProperty intValue];
    }
    else if ([elementName isEqualToString:@"latitude_off"])
    {
        itemNode.lNaviLat = [currentProperty intValue];
    }
    else if ([elementName isEqualToString:@"item_id"])
    {
//        itemNode.lPoiId = [currentProperty intValue];
    }
    else if ([elementName isEqualToString:@"from_type"])
    {
        itemNode.lCategoryID = [currentProperty intValue];
    }
    else if ([elementName isEqualToString:@"address"])
    {
        itemNode.szAddr = currentProperty;
    }
    else if ([elementName isEqualToString:@"flag"])
    {
        itemNode.eCategory = [currentProperty intValue];
    }
    else if ([elementName isEqualToString:@"alldata"])
    {
        favorite.allIdentify = currentProperty;
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
                favorite.Date = date;
            }
            if ([timeArray count] >= 3)
            {
                GTIME time;
                time.hour = [[timeArray objectAtIndex:0] intValue];
                time.minute = [[timeArray objectAtIndex:1] intValue];
                time.second = [[timeArray objectAtIndex:2] intValue];
                favorite.Time = time;
            }
        }
        
        
    }
    if ([elementName isEqualToString:@"item"])
    {
        [favorite.pFavoritePOIArray addObject:itemNode];
        [itemNode release];
        itemNode = nil;
    }
	currentProperty = nil;
}

@end
