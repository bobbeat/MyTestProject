//
//  MWContact.m
//  AutoNavi
//
//  Created by gaozhimin on 13-7-31.
//
//

#import "MWContact.h"

@implementation MWContact

@synthesize contactArray,nNumberOfItem;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    self.contactArray = nil;
    [super dealloc];
}

@end

@implementation MWContactOption

@synthesize userName,password;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    self.userName = nil;
    self.password = nil;
    [super dealloc];
}

@end

@implementation MWContactXMLParser


- (id)initWitharray:(NSMutableArray *)parray
{
	if (self = [super init])
	{
		if (parray!=nil)
		{
			result = parray;
		}
	}
	
	return self;
}


- (BOOL)parser:(NSData *)data
{
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
	if ([parser parserError])
	{
		UIAlertView *ParseFailedAlert;
		if (fontType == 0) {
			ParseFailedAlert = [[UIAlertView alloc] initWithTitle:@"Xml解析失败"
														  message:@"xml数据错误"
														 delegate:nil
												cancelButtonTitle:@"确定"
												otherButtonTitles:nil];
		}
		else if (fontType == 1) {
			ParseFailedAlert = [[UIAlertView alloc] initWithTitle:@"Xml解析失敗"
														  message:@"xml數據錯誤"
														 delegate:nil
												cancelButtonTitle:@"確定"
												otherButtonTitles:nil];
		}
		else if(fontType == 2)
		{
			ParseFailedAlert = [[UIAlertView alloc] initWithTitle:@"Xml parser fail"
														  message:@"xml data eror"
														 delegate:nil
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
		}
		[ParseFailedAlert show];
		[ParseFailedAlert release];
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
    if (urlItemNode)
    {
        if ([elementName isEqualToString:@"urltype"] || [elementName isEqualToString:@"urlstring"]  )
		{
            currentProperty = [NSMutableString string];
			
        }
		else if([elementName isEqualToString:@"lastedittime"]){
			currentProperty = [NSMutableString string];
		}
		
    }
	else if (urlNode)
    {
        if ([elementName isEqualToString:@"urlitem"] )
		{
            urlItemNode = [[NameIndex alloc] init];
        }
    }
    else if (emailItemNode)
    {
        if ([elementName isEqualToString:@"emailtype"] || [elementName isEqualToString:@"emailstring"] )
		{
            currentProperty = [NSMutableString string];
        }
    }
	else if (emailNode)
    {
        if ([elementName isEqualToString:@"emailitem"] )
		{
            emailItemNode = [[NameIndex alloc] init];
        }
    }
    else if (addressItemNode)
    {
        if ([elementName isEqualToString:@"addresstype"] || [elementName isEqualToString:@"city"] || [elementName isEqualToString:@"country"] || [elementName isEqualToString:@"countrycode"] || [elementName isEqualToString:@"state"] || [elementName isEqualToString:@"street"] || [elementName isEqualToString:@"zip"])
		{
            currentProperty = [NSMutableString string];
        }
    }
	else if (addressNode)
    {
        if ([elementName isEqualToString:@"addressitem"] )
		{
            addressItemNode = [[AddressItem alloc] init];
        }
    }
    else if (phoneItemNode)
    {
        if ([elementName isEqualToString:@"phonetype"] || [elementName isEqualToString:@"phonestring"] )
		{
            currentProperty = [NSMutableString string];
        }
    }
	else if (phoneNode)
    {
        if ([elementName isEqualToString:@"phoneitem"] )
		{
            phoneItemNode = [[NameIndex alloc] init];
        }
    }
    
	else if (itemNode)
	{
        if ([elementName isEqualToString:@"name"] )
		{
            currentProperty = [NSMutableString string];
        }
        else if ([elementName isEqualToString:@"phonenum"]) {
            phoneNode = [[NameIndex alloc] init];
        }
        else if ([elementName isEqualToString:@"address"]) {
            addressNode = [[NameIndex alloc] init];
        }
        else if ([elementName isEqualToString:@"email"]) {
            emailNode = [[NameIndex alloc] init];
        }
        else if ([elementName isEqualToString:@"url"]) {
            urlNode = [[NameIndex alloc] init];
        }
    }
	else
	{
        if ([elementName isEqualToString:@"item"])
		{
			itemNode = [[NameIndex alloc] init];// Create the element
        }
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
	//NSLog(@"elementName==%@",elementName);
    
	if (urlItemNode)
	{
		if ([elementName isEqualToString:@"urltype"])
		{
			[itemNode.URLTypeArray addObject:currentProperty];
        }
		else if ([elementName isEqualToString:@"urlstring"])
		{
            [itemNode.URLArray addObject:currentProperty];
        }
		else if ([elementName isEqualToString:@"lastedittime"])
		{
            itemNode.lastEditTime = (NSDate*)currentProperty;
			
        }
		if ([elementName isEqualToString:@"urlitem"])
		{
			
			[urlItemNode release];
			urlItemNode = nil;
        }
    }
    else if (urlNode)
	{
        if ([elementName isEqualToString:@"url"])
		{
			[urlNode release];
			urlNode = nil;
        }
    }
	else if (emailItemNode)
	{
		if ([elementName isEqualToString:@"emailtype"])
		{
			[itemNode.emailTypeArray addObject:currentProperty];
        }
		else if ([elementName isEqualToString:@"emailstring"])
		{
            [itemNode.emailArray addObject:currentProperty];
        }
        
		if ([elementName isEqualToString:@"emailitem"])
		{
			[emailItemNode release];
			emailItemNode = nil;
        }
    }
    else if (emailNode)
	{
        if ([elementName isEqualToString:@"email"])
		{
			[emailNode release];
			emailNode = nil;
        }
    }
    else if (addressItemNode)
	{
		if ([elementName isEqualToString:@"addresstype"])
		{
			addressItemNode.type = currentProperty;
        }
		else if ([elementName isEqualToString:@"city"])
		{
            addressItemNode.city = currentProperty;
        }
        else if ([elementName isEqualToString:@"country"])
		{
            addressItemNode.country = currentProperty;
        }
        else if ([elementName isEqualToString:@"countrycode"])
		{
            addressItemNode.countryCode = currentProperty;
        }
        else if ([elementName isEqualToString:@"state"])
		{
            addressItemNode.state = currentProperty;
        }
        else if ([elementName isEqualToString:@"street"])
		{
            addressItemNode.street = currentProperty;
        }
        else if ([elementName isEqualToString:@"zip"])
		{
            addressItemNode.zip = currentProperty;
        }
		if ([elementName isEqualToString:@"addressitem"])
		{
            [itemNode.addressArray addObject:addressItemNode];
			[addressItemNode release];
			addressItemNode = nil;
        }
    }
    else if (addressNode)
	{
        if ([elementName isEqualToString:@"address"])
		{
            
			[addressNode release];
			addressNode = nil;
        }
    }
    else if (phoneItemNode)
	{
		if ([elementName isEqualToString:@"phonetype"])
		{
			[itemNode.phoneTypeArray addObject:currentProperty];
        }
		else if ([elementName isEqualToString:@"phonestring"])
		{
            [itemNode.phoneArray addObject:currentProperty];
        }
        
		if ([elementName isEqualToString:@"phoneitem"])
		{
			[phoneItemNode release];
			phoneItemNode = nil;
        }
    }
	else if (phoneNode)
	{
        if ([elementName isEqualToString:@"phonenum"])
		{
			[phoneNode release];
			phoneNode = nil;
        }
    }
    else if (itemNode)
    {
        if ([elementName isEqualToString:@"name"]) {
            itemNode._fullName = currentProperty;
        }
        if ([elementName isEqualToString:@"item"])
		{
            [result addObject:itemNode];
			[itemNode release];
			itemNode = nil;
        }
    }
    
	currentProperty = nil;
}


@end
