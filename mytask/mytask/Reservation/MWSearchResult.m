//
//  MWSearchResult.m
//  AutoNavi
//
//  Created by gaozhimin on 13-7-29.
//
//

#import "MWSearchResult.h"

@implementation MWPoi

@synthesize lCategoryID,latitude,longitude,lAdminCode,lDistance,lHilightFlag,lMatchCode,lPoiIndex,Reserved,lNaviLon,lNaviLat,szAddr,szName,szTel,ucFlag,usNodeId,szTown,netPoiId,accountId,actionType;

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.lCategoryID] forKey:@"lCategoryID"];
    
	[encoder encodeObject:[NSString stringWithFormat:@"%d",self.lHilightFlag] forKey:@"lHilightFlag"];
	[encoder encodeObject:[NSString stringWithFormat:@"%d",self.lMatchCode] forKey:@"lMatchCode"];
    
    //    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.stPoiId] forKey:@"stPoiId"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.lPoiIndex] forKey:@"lPoiIndex"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.Reserved] forKey:@"Reserved"];
    
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.lNaviLon] forKey:@"lNaviLon"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.lNaviLat] forKey:@"lNaviLat"];
    [encoder encodeObject:self.szName forKey:@"szName"];
    
    [encoder encodeObject:self.szAddr forKey:@"szAddr"];
    [encoder encodeObject:self.szTel forKey:@"szTel"];
    [encoder encodeObject:self.szTown forKey:@"szTown"];
    
    
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.lAdminCode] forKey:@"lAdminCode"];
    [encoder encodeObject:[NSString stringWithFormat:@"%ld",self.longitude] forKey:@"longitude"];
    [encoder encodeObject:[NSString stringWithFormat:@"%ld",self.latitude] forKey:@"latitude"];
    
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.ucFlag] forKey:@"ucFlag"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.usNodeId] forKey:@"usNodeId"];
    
    [encoder encodeObject:self.netPoiId forKey:@"netPoiId"];
    [encoder encodeObject:self.accountId forKey:@"accountId"];
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.actionType] forKey:@"actionType"];
}


- (id)initWithCoder:(NSCoder *) decoder
{
	if (self = [super init])
	{
        
        self.usNodeId = [[decoder decodeObjectForKey:@"usNodeId"] intValue];
        //        self.stPoiId = [[decoder decodeObjectForKey:@"stPoiId"] intValue];
        self.lCategoryID = [[decoder decodeObjectForKey:@"lCategoryID"] intValue];
        
        self.ucFlag = [[decoder decodeObjectForKey:@"ucFlag"] intValue];
        self.lNaviLat = [[decoder decodeObjectForKey:@"lNaviLat"] intValue];
        self.lNaviLon = [[decoder decodeObjectForKey:@"lNaviLon"] intValue];
        
        self.latitude = [[decoder decodeObjectForKey:@"latitude"] intValue];
        self.longitude = [[decoder decodeObjectForKey:@"longitude"] intValue];
        self.szName = [decoder decodeObjectForKey:@"szName"];
        
        self.szTown = [decoder decodeObjectForKey:@"szTown"];
        self.szTel = [decoder decodeObjectForKey:@"szTel"];
        self.szAddr = [decoder decodeObjectForKey:@"szAddr"];
        
        self.lAdminCode = [[decoder decodeObjectForKey:@"lAdminCode"] intValue];
        self.Reserved = [[decoder decodeObjectForKey:@"Reserved"] intValue];
        self.lPoiIndex = [[decoder decodeObjectForKey:@"lPoiIndex"] intValue];
        
        self.lMatchCode = [[decoder decodeObjectForKey:@"lMatchCode"] intValue];
        self.lHilightFlag = [[decoder decodeObjectForKey:@"lHilightFlag"] intValue];
        self.netPoiId = [decoder decodeObjectForKey:@"netPoiId"];
        self.accountId = [decoder decodeObjectForKey:@"accountId"];
        self.actionType = [[decoder decodeObjectForKey:@"actionType"] intValue];
	}
	
	return self;
}

- (void)dealloc
{
    self.szTel = nil;
    self.szName = nil;
    self.szAddr = nil;
    self.szTown = nil;
    self.netPoiId = nil;
    self.accountId = nil;
    [super dealloc];
}

- (NSString *)szName
{
    if (szName == nil)
    {
        return @"";
    }
    return szName;
}

-(NSString *)szTel
{
    if (szTel == nil)
    {
        return @"";
    }
    return szTel;
}

- (NSString *)szAddr
{
    if (szAddr == nil)
    {
        return @"";
    }
    return szAddr;
}

- (NSString *)szTown
{
    if (szTown == nil)
    {
        return @"";
    }
    return szTown;
}

- (NSString *)netPoiId
{
    if (netPoiId == nil)
    {
        return @"";
    }
    return netPoiId;
}

- (NSString *)accountId
{
    if (accountId == nil)
    {
        return @"";
    }
    return accountId;
}

@end

@implementation MWSearchResult

@synthesize index,numberOfItemGet,numberOfTotalItem,pois,reserved;

- (void)dealloc
{
    self.pois = nil;
    [super dealloc];
}

@end

@implementation MWPoiCategoryList

@synthesize lNumberOfCategory,pCategoryArray;

- (void)dealloc
{
    self.pCategoryArray = nil;
    [super dealloc];
}

@end


@implementation MWPoiCategory

@synthesize szName,pnCategoryID,nCategoryIDNum,nNumberOfSubCategory,pSubCategoryArray,Reserved;

- (id)init
{
    self = [super init];
    if (self) {
        self.pnCategoryID = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.pnCategoryID = nil;
    self.szName = nil;
    self.pSubCategoryArray = nil;
    [super dealloc];
}

@end

