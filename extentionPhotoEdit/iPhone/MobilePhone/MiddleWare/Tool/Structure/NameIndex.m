//
//  NameIndex.m
//  autonavi
//
//  Created by huang longfeng on 12-2-3.
//  Copyright 2012 autonavi. All rights reserved.
//

#import "NameIndex.h"

@implementation AddressItem

@synthesize city;
@synthesize country;
@synthesize countryCode;
@synthesize state;
@synthesize street;
@synthesize zip;
@synthesize type;

- (void)encodeWithCoder:(NSCoder *)encoder 
{
	[encoder encodeObject:city forKey:@"addresslist1key"];
	[encoder encodeObject:country forKey:@"addresslist2key"];
	[encoder encodeObject:countryCode forKey:@"addresslist3key"];
	[encoder encodeObject:state forKey:@"addresslist4key"];
	[encoder encodeObject:street forKey:@"addresslist5key"];
	[encoder encodeObject:zip forKey:@"addresslist6key"];
    [encoder encodeObject:type forKey:@"addresslist7key"];
	
}


- (id)initWithCoder:(NSCoder *) decoder 
{
	if (self = [super init]) 
	{
		self.city = [decoder decodeObjectForKey:@"addresslist1key"];
		self.country = [decoder decodeObjectForKey:@"addresslist2key"];
		self.countryCode = [decoder decodeObjectForKey:@"addresslist3key"];
		self.state = [decoder decodeObjectForKey:@"addresslist4key"];
		self.street = [decoder decodeObjectForKey:@"addresslist5key"];
		self.zip = [decoder decodeObjectForKey:@"addresslist6key"];
        self.type = [decoder decodeObjectForKey:@"addresslist7key"];
		
	}
	
	return self;
}

- (void)dealloc
{
    self.city = nil;
    self.country = nil;
    self.countryCode = nil;
    self.state = nil;
    self.street = nil;
    self.zip = nil;
    self.type = nil;
    [super dealloc];
}
@end


@implementation NameIndex  
@synthesize _fullName;  
@synthesize lastEditTime;
@synthesize phoneArray;
@synthesize emailArray;
@synthesize URLArray;
@synthesize addressArray;
@synthesize URLTypeArray;
@synthesize emailTypeArray;
@synthesize phoneTypeArray;
//@synthesize addressItem;

- (void)encodeWithCoder:(NSCoder *)encoder 
{
	[encoder encodeObject:_fullName forKey:@"contactlist1key"];
	[encoder encodeObject:phoneArray forKey:@"contactlist2key"];
	[encoder encodeObject:addressArray forKey:@"contactlist3key"];
	[encoder encodeObject:emailArray forKey:@"contactlist4key"];
	[encoder encodeObject:URLArray forKey:@"contactlist5key"];
	[encoder encodeObject:phoneTypeArray forKey:@"contactlist6key"];
    [encoder encodeObject:URLTypeArray forKey:@"contactlist7key"];
	[encoder encodeObject:emailTypeArray forKey:@"contactlist8key"];
	[encoder encodeObject:lastEditTime forKey:@"contactlist9key"];

}


- (id)initWithCoder:(NSCoder *) decoder 
{
	if (self = [super init]) 
	{
		self._fullName = [decoder decodeObjectForKey:@"contactlist1key"];
		self.phoneArray = [decoder decodeObjectForKey:@"contactlist2key"];
		self.addressArray = [decoder decodeObjectForKey:@"contactlist3key"];
		self.emailArray = [decoder decodeObjectForKey:@"contactlist4key"];
		self.URLArray = [decoder decodeObjectForKey:@"contactlist5key"];
		self.phoneTypeArray = [decoder decodeObjectForKey:@"contactlist6key"];
        self.URLTypeArray = [decoder decodeObjectForKey:@"contactlist7key"];
		self.emailTypeArray = [decoder decodeObjectForKey:@"contactlist8key"];
		self.lastEditTime = [decoder decodeObjectForKey:@"contactlist9key"];

	}
	
	return self;
}
- (id)init {
    self = [super init];
    if (self) {
        phoneArray = [[NSMutableArray alloc] init];
		addressArray = [[NSMutableArray alloc] init];
        emailArray = [[NSMutableArray alloc] init];
        URLArray = [[NSMutableArray alloc] init];
        phoneTypeArray = [[NSMutableArray alloc] init];
        emailTypeArray = [[NSMutableArray alloc] init];
        URLTypeArray = [[NSMutableArray alloc] init];
		lastEditTime = [[NSDate alloc] init];
        //addressItem = [[AddressItem alloc] init];
    }
    return self;
}
//- (NSString *) getFullName {  
//    if ([_fullName canBeConvertedToEncoding: NSASCIIStringEncoding]) {//如果是英语  
//        return _fullName;  
//    }  
//    else { //如果是非英语  
//        return [NSString stringWithFormat:@"%c",pinyinFirstLetter([_fullName characterAtIndex:0])];  
//    }  
//	
//}  
//- (NSString *) getLastName {  
//    if ([_lastName canBeConvertedToEncoding:NSASCIIStringEncoding]) {  
//        return _lastName;  
//    }  
//    else {  
//        return [NSString stringWithFormat:@"%c",pinyinFirstLetter([_lastName characterAtIndex:0])];  
//    }  
//	
//}  
- (void)dealloc {  
    [_fullName release]; 
	[lastEditTime release];
    lastEditTime = nil;
	
	[phoneArray release];
	phoneArray = nil;
	
	[addressArray release];
    addressArray = nil;
	
    [emailArray release];
	emailArray = nil;
    
    [URLArray release];
    URLArray = nil;
    
    [phoneTypeArray release];
    phoneTypeArray = nil;
    
    [emailTypeArray release];
    emailTypeArray = nil;
    
    [URLTypeArray release];
    URLTypeArray = nil;
    
    //[addressItem release];
   // addressItem = nil;
    [super dealloc];  
}  
@end  
