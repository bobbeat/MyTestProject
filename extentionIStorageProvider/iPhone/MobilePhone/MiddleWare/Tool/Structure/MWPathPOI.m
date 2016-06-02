//
//  MWPathPOI.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-4-4.
//
//

#import "MWPathPOI.h"


@implementation MWPathPOI

@synthesize userID,operate,operateTime,rule,waypointCount,poiArray,name;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.poiArray = [NSMutableArray array];
    }
    return self;
}

/*
 NSCoding协议内容(由龙峰填充)
 */

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:name  forKey:@"name"];
    [encoder encodeObject:userID forKey:@"tasklist1key"];
	[encoder encodeInt:operate forKey:@"tasklist2key"];
	[encoder encodeObject:operateTime forKey:@"tasklist3key"];
	[encoder encodeInt:rule forKey:@"tasklist4key"];
	[encoder encodeInt:waypointCount forKey:@"tasklist5key"];
	[encoder encodeObject:poiArray forKey:@"tasklist6key"];
    [encoder encodeObject:self.serviceID forKey:@"serviceID"];
    
}


- (id)initWithCoder:(NSCoder *) decoder
{
	if (self = [super init])
	{
        self.name = [decoder decodeObjectForKey:@"name"];
        self.userID = [decoder decodeObjectForKey:@"tasklist1key"];
		self.operate = [decoder decodeIntForKey:@"tasklist2key"];
		self.operateTime = [decoder decodeObjectForKey:@"tasklist3key"];
		self.rule = [decoder decodeIntForKey:@"tasklist4key"];
		self.waypointCount = [decoder decodeIntForKey:@"tasklist5key"];
		self.poiArray = [decoder decodeObjectForKey:@"tasklist6key"];
		self.serviceID = [decoder decodeObjectForKey:@"serviceID"];
        
	}
	
	return self;
}

- (void)dealloc
{
    CRELEASE(userID);
    CRELEASE(operateTime);
    CRELEASE(poiArray);
    CRELEASE(name);
    CRELEASE(_serviceID);
    
    [super dealloc];
}
@end
