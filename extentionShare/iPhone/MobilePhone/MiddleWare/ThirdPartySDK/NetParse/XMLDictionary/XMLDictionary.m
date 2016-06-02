//
//  XMLDictionary.m
//
//  Version 1.1
//
//  Created by Nick Lockwood on 15/11/2010.
//  Copyright 2010 Charcoal Design. All rights reserved.
//
//  Get the latest version of XMLDictionary from here:
//
//  https://github.com/nicklockwood/XMLDictionary
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "XMLDictionary.h"


#import <Availability.h>

@interface NSDictionary(XMLDictionaryPrivate)

- (NSString *)attributeForKey:(NSString *)key;
- (NSDictionary *)attributes;
- (NSDictionary *)childNodes;
- (NSArray *)comments;
- (NSString *)nodeName;
- (NSString *)innerText;
- (NSString *)innerXML;
- (NSString *)xmlString;

@end

@interface NSString (XMLDictionary)

- (NSString *)xmlEncodedString;

@end


@interface XMLDictionaryParser : NSObject<NSXMLParserDelegate>
{
    NSMutableArray *_stack;
    NSMutableString *_text;
}

@property (nonatomic, retain) NSMutableDictionary *root;
@property (nonatomic, retain) NSMutableArray *stack;
@property (nonatomic, assign, readonly) NSMutableDictionary *top;

+ (NSMutableDictionary *)dictionaryWithXMLData:(NSData *)data;
+ (NSMutableDictionary *)dictionaryWithXMLFile:(NSString *)path;
+ (NSString *)xmlStringForNode:(id)node withNodeName:(NSString *)nodeName;

@end


@implementation XMLDictionaryParser

@synthesize root,stack = _stack,top;

- (XMLDictionaryParser *)initWithXMLData:(NSData *)data
{
	if ((self = [super init]))
	{
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
		[parser setDelegate:self];
		[parser parse];
        [parser release];
	}
	return self;
}
-(void)dealloc
{
    self.root = nil;
    self.stack=nil;
    [super dealloc];
}

+ (NSMutableDictionary *)dictionaryWithXMLData:(NSData *)data
{
    XMLDictionaryParser *parser=[[[XMLDictionaryParser alloc] initWithXMLData:data] autorelease];
	return [parser root];
}

+ (NSMutableDictionary *)dictionaryWithXMLFile:(NSString *)path
{	
	NSData *data = [NSData dataWithContentsOfFile:path];
	return [self dictionaryWithXMLData:data];
}

+ (NSString *)xmlStringForNode:(id)node withNodeName:(NSString *)nodeName
{	
    if ([node isKindOfClass:[NSArray class]])
    {
        NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:[node count]];
        for (id individualNode in node)
        {
            [nodes addObject:[self xmlStringForNode:individualNode withNodeName:nodeName]];
        }
        return [nodes componentsJoinedByString:@"\n"];
    }
    else if ([node isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *attributes = [(NSDictionary *)node attributes];
        NSMutableString *attributeString = [NSMutableString string];
        for (NSString *key in [attributes allKeys])
        {
            [attributeString appendFormat:@" %@=\"%@\"", [key xmlEncodedString], [[attributes objectForKey:key] xmlEncodedString]];
        }
        
        NSString *innerXML = [node innerXML];
        if ([innerXML length])
        {
            return [NSString stringWithFormat:@"<%1$@%2$@>%3$@</%1$@>", nodeName, attributeString, innerXML];
        }
        else
        {
            return [NSString stringWithFormat:@"<%@%@/>", nodeName, attributeString];
        }
    }
    else
    {
        return [NSString stringWithFormat:@"<%1$@>%2$@</%1$@>", nodeName, [[node description] xmlEncodedString]];
    }
}

- (NSMutableDictionary *)top
{
	return [_stack lastObject];
}

- (void)endText
{
	if (TRIM_WHITE_SPACE && _text)
	{
        NSMutableString *temp = [[NSMutableString alloc] initWithString:[_text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        [_text release];
        _text = temp;
	}
	if (_text && ![_text isEqualToString:@""] && [XML_TEXT_KEY length])
	{
		id existing = [self.top objectForKey:XML_TEXT_KEY];
		if (existing)
		{
			if ([existing isKindOfClass:[NSMutableArray class]])
			{
				[(NSMutableArray *)existing addObject:_text];
			}
			else
			{
				[self.top setObject:[NSMutableArray arrayWithObjects:existing, _text, nil] forKey:XML_TEXT_KEY];
			}
		}
		else
		{
			[self.top setObject:_text forKey:XML_TEXT_KEY];
		}
	}
	[_text release];
    _text = nil;
}

- (void)addText:(NSString *)text
{	
	if (!_text)
	{
		_text = [[NSMutableString alloc] initWithString:text];
	}
	else
	{
		[_text appendString:text];
	}
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{	
	[self endText];
	
	NSMutableDictionary *node = [NSMutableDictionary dictionary];
	if ([XML_NAME_KEY length])
	{
		[node setObject:elementName forKey:XML_NAME_KEY];
	}
	if ([attributeDict count])
	{
		if ([XML_ATTRIBUTE_PREFIX length])
		{
			for (NSString *key in [attributeDict allKeys])
			{
				[node setObject:[attributeDict objectForKey:key]
						  forKey:[XML_ATTRIBUTE_PREFIX stringByAppendingString:key]];
			}
		}
		else if ([XML_ATTRIBUTES_KEY length])
		{
			[node setObject:attributeDict forKey:XML_ATTRIBUTES_KEY];
		}
		else
		{
			[node addEntriesFromDictionary:attributeDict];
		}
	}
	
	if (!self.top)
	{
		self.root = node;
		self.stack = [NSMutableArray arrayWithObject:node];
	}
	else
	{
		id existing = [self.top objectForKey:elementName];
		if (existing)
		{
			if ([existing isKindOfClass:[NSMutableArray class]])
			{
				[(NSMutableArray *)existing addObject:node];
			}
			else
			{
				[self.top setObject:[NSMutableArray arrayWithObjects:existing, node, nil]
							  forKey:elementName];
			}
		}
		else
		{
			[self.top setObject:node forKey:elementName];
		}
		[_stack addObject:node];
	}
}

- (NSString *)nameForNode:(NSDictionary *)node inDictionary:(NSDictionary *)dict
{
	if (node.nodeName)
	{
		return node.nodeName;
	}
	else
	{
		for (NSString *name in dict)
		{
			id object = [dict objectForKey:name];
			if (object == node)
			{
				return name;
			}
			else if ([object isKindOfClass:[NSArray class]])
			{
				if ([(NSArray *)object containsObject:node])
				{
					return name;
				}
			}
		}
	}
	return nil;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{	
	[self endText];
	if (COLLAPSE_TEXT_NODES &&
		!self.top.attributes &&
		!self.top.childNodes &&
        !self.top.comments &&
		self.top.innerText)
	{
		NSDictionary *node = self.top;
		[_stack removeLastObject];
		NSString *nodeName = [self nameForNode:node inDictionary:self.top];
		if (nodeName)
		{
			id parentNode = [self.top objectForKey:nodeName];
			if ([parentNode isKindOfClass:[NSMutableArray class]])
			{
				[parentNode replaceObjectAtIndex:[parentNode count] - 1 withObject:node.innerText];
			}
			else
			{
				[self.top setObject:node.innerText forKey:nodeName];
			}
		}
	}
	else
	{
		[_stack removeLastObject];
        NSDictionary *node = self.top;
        NSDictionary *temp = [node objectForKey:elementName];
        if (temp && [temp isKindOfClass:[NSDictionary class]])  
        {
            if ([temp count] == 0)
            {
                [node setValue:@"" forKey:elementName];
            }
        }
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	[self addText:string];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	[self addText:[[[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding] autorelease]];
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
	if ([XML_COMMENTS_KEY length])
	{
		NSMutableArray *comments = [self.top objectForKey:XML_COMMENTS_KEY];
		if (!comments)
		{
			comments = [NSMutableArray arrayWithObject:comment];
			[self.top setObject:comments forKey:XML_COMMENTS_KEY];
		}
		else
		{
			[comments addObject:comment];
		}
	}
}

@end

@implementation NSDictionary(XMLDictionary)

+ (NSDictionary *)dictionaryWithXMLData:(NSData *)data
{
	return [XMLDictionaryParser dictionaryWithXMLData:data];
}

+ (NSDictionary *)dictionaryWithXMLString:(NSString *)string
{
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	return [XMLDictionaryParser dictionaryWithXMLData:data];
}

+ (NSDictionary *)dictionaryWithXMLFile:(NSString *)path
{
	return [XMLDictionaryParser dictionaryWithXMLFile:path];
}

- (id)attributeForKey:(NSString *)key
{
	return [[self attributes] objectForKey:key];
}

- (NSDictionary *)attributes
{
	NSDictionary *attributes = [self objectForKey:XML_ATTRIBUTES_KEY];
	if (attributes)
	{
		return [attributes count]? attributes: nil;
	}
	else if ([XML_ATTRIBUTE_PREFIX length])
	{
		NSMutableDictionary *filteredDict = [NSMutableDictionary dictionaryWithDictionary:self];
        [filteredDict removeObjectsForKeys:[NSArray arrayWithObjects:XML_COMMENTS_KEY, XML_TEXT_KEY, XML_NAME_KEY, nil]];
        for (NSString *key in [filteredDict allKeys])
        {
            [filteredDict removeObjectForKey:key];
            if ([key hasPrefix:XML_ATTRIBUTE_PREFIX])
            {
                [filteredDict setObject:[self objectForKey:key] forKey:[key substringFromIndex:[XML_ATTRIBUTE_PREFIX length]]];
            }
        }
        return [filteredDict count]? filteredDict: nil;
	}
	return nil;
}

- (NSDictionary *)childNodes
{	
	NSMutableDictionary *filteredDict = [NSMutableDictionary dictionaryWithDictionary:self];
	[filteredDict removeObjectsForKeys:[NSArray arrayWithObjects:XML_ATTRIBUTES_KEY, XML_COMMENTS_KEY, XML_TEXT_KEY, XML_NAME_KEY, nil]];
	if ([XML_ATTRIBUTE_PREFIX length])
    {
        for (NSString *key in [filteredDict allKeys])
        {
            if ([key hasPrefix:XML_ATTRIBUTE_PREFIX])
            {
                [filteredDict removeObjectForKey:key];
            }
        }
    }
    return [filteredDict count]? filteredDict: nil;
}

- (NSArray *)comments
{
	return [self objectForKey:XML_COMMENTS_KEY];
}

- (NSString *)nodeName
{
	return [self objectForKey:XML_NAME_KEY];
}

- (id)innerText
{	
	id text = [self objectForKey:XML_TEXT_KEY];
	if ([text isKindOfClass:[NSArray class]])
	{
		return [text componentsJoinedByString:@"\n"];
	}
	else
	{
		return text;
	}
}

- (NSString *)innerXML
{	
	NSMutableArray *nodes = [NSMutableArray array];
	
	for (NSString *comment in [self comments])
	{
        [nodes addObject:[NSString stringWithFormat:@"<!--%@-->", [comment xmlEncodedString]]];
	}
    
    NSDictionary *childNodes = [self childNodes];
	for (NSString *key in childNodes)
	{
		[nodes addObject:[XMLDictionaryParser xmlStringForNode:[childNodes objectForKey:key] withNodeName:key]];
	}
	
    NSString *text = [self innerText];
    if (text)
    {
        [nodes addObject:[text xmlEncodedString]];
    }
	
	return [nodes componentsJoinedByString:@"\n"];
}

- (NSString *)xmlString
{	
	return [XMLDictionaryParser xmlStringForNode:self withNodeName:[self nodeName] ?: @"root"];
}

@end


@implementation NSString (XMLDictionary)

- (NSString *)xmlEncodedString
{	
	return [[[[self stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]
			  stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"]
			 stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"]
			stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
}

@end


#define XML_ELEMENT         @"<%@>%@</%@>"
#define XML_ELEMENT_CDATA   @"<![CDATA[%@]]>"
#define XML_ELEMENT_OPEN    @"<%@>"
#define XML_ELEMENT_CLOSE   @"</%@>"
#define XML_ROOT_NAME       @"root"

#define DATE_FORMAT         @"yyyy-MM-dd"

#import <objc/runtime.h>

@interface GD_NSObjectToXML()

+ (NSString*)convertDictionaryToXML:(NSDictionary*)dictionary rootName:(NSString*)rootName;
+ (NSString*)convertArrayToXML:(NSArray*)array rootName:(NSString*)rootName;
+ (NSString*)convertObjectToXML:(id)object rootName:(NSString*)rootName;

@end

@implementation GD_NSObjectToXML

+ (NSString*)convertToXML:(id)value rootName:(NSString *)rootName
{
    NSMutableString *xml = [[NSMutableString alloc] init];
    
    if (value == nil) {
        [xml appendFormat:XML_ELEMENT, rootName, @"", rootName];
    }
    else if ([value isKindOfClass:[NSString class]]) {
        [xml appendFormat:XML_ELEMENT, rootName, value, rootName];
    }
    else if ([value isKindOfClass:[NSData class]]) {
        NSString *s_value = [[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] autorelease];
        s_value = [NSString stringWithFormat:XML_ELEMENT_CDATA, s_value];
        [xml appendFormat:XML_ELEMENT, rootName, s_value, rootName];
    }
    else if ([value isKindOfClass:[NSDate class]]) {
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        formatter.dateFormat = DATE_FORMAT;
        NSString *s_value = [formatter stringFromDate:value];
        [xml appendFormat:XML_ELEMENT, rootName, s_value, rootName];
    }
    else if ([value isKindOfClass:[NSNumber class]]) {
        NSString *s_value = [(NSNumber*)value stringValue];
        [xml appendFormat:XML_ELEMENT, rootName, s_value, rootName];
    }
    else if ([value isKindOfClass:[NSDictionary class]]) {
        [xml appendString:[self convertDictionaryToXML:value rootName:rootName ? rootName : XML_ROOT_NAME]];
    }
    else if ([value isKindOfClass:[NSArray class]]) {
        [xml appendString:[self convertArrayToXML:value rootName:rootName ? rootName : XML_ROOT_NAME]];
    }
    else if ([value isKindOfClass:[NSObject class]]) {
        [xml appendString:[self convertObjectToXML:value rootName:rootName ? rootName : XML_ROOT_NAME]];
    }
    else {
        NSString *msg = [NSString stringWithFormat:@"NSObjectToXML invalid type of value for key '%@'!", rootName];
        NSAssert(YES, msg);
    }
    
    return [xml autorelease];
}

+ (NSString *)xmlHeadString
{
    return @"<?xml version=\"1.0\" encoding=\"utf-8\"?>";
}

+ (NSString*)convertDictionaryToXML:(NSDictionary*)dictionary rootName:(NSString*)rootName
{
    NSMutableString *xml = [[NSMutableString alloc] init];
    if (rootName)
        [xml appendFormat:XML_ELEMENT_OPEN, rootName];
    
    NSArray *keys = dictionary.allKeys;
    for (int i = 0; i < keys.count; i++) {
        NSString *key = [keys objectAtIndex:i];
        [xml appendString:[self convertToXML:[dictionary objectForKey:key] rootName:key]];
    }
    
    if (rootName)
        [xml appendFormat:XML_ELEMENT_CLOSE, rootName];
    return [xml autorelease];
}

+ (NSString*)convertArrayToXML:(NSArray*)array rootName:(NSString*)rootName
{
    NSMutableString *xml = [[NSMutableString alloc] init];
    
    for (int i = 0; i < array.count; i++) {
        id value = [array objectAtIndex:i];
        if (value == nil) {
            [xml appendString:[self convertToXML:@"" rootName:@"string"]];
        }
        else if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSData class]]) {
            [xml appendString:[self convertToXML:value rootName:@"string"]];
        }
        else if ([value isKindOfClass:[NSDate class]]) {
            [xml appendString:[self convertToXML:value rootName:@"dateTime"]];
        }
        else if ([value isKindOfClass:[NSNumber class]]) {
            NSString *s_value = [(NSNumber*)value stringValue];
            CFNumberType numberType = CFNumberGetType((CFNumberRef)value);
            switch (numberType) {
                case kCFNumberIntType:
                case kCFNumberNSIntegerType:
                    [xml appendFormat:XML_ELEMENT, @"int", s_value, @"int"];
                    break;
                case kCFNumberFloatType:
                case kCFNumberCGFloatType:
                    [xml appendFormat:XML_ELEMENT, @"float", s_value, @"float"];
                    break;
                default:
                    [xml appendFormat:XML_ELEMENT, @"double", s_value, @"double"];
                    break;
            }
        }
        else if ([value isKindOfClass:[NSDictionary class]]
                 || [value isKindOfClass:[NSArray class]]) {
            [xml appendString:[self convertToXML:value rootName:rootName]];
        }
        else if ([value isKindOfClass:[NSObject class]]) {
            NSString *name = [NSString stringWithCString:class_getName([value class]) encoding:NSUTF8StringEncoding];
            [xml appendString:[self convertToXML:value rootName:name]];
        }
        else {
            NSAssert(YES, @"NSObjectToXML invalid type of value on array values at index #%d!", i);
        }
    }
    return [xml autorelease];
}

+ (NSString*)convertObjectToXML:(id)object rootName:(NSString*)rootName
{
    NSMutableString *xml = [[NSMutableString alloc] init];
    if (rootName)
        [xml appendFormat:XML_ELEMENT_OPEN, rootName];
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([object class], &count);
    for (int i = 0; i < count; ++i) {
        
        // name and attributes of properties
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSString *propertyAttributes = [[[NSString alloc] initWithUTF8String:property_getAttributes(property)] autorelease];
        NSArray *propertyAttributeArray = [propertyAttributes componentsSeparatedByString:@","];
        
        // is a primitive C type (int, float, double) ?
        NSString *cType = nil;
        for (NSString *string in propertyAttributeArray) {
            if ([@"Ti Tf Td" rangeOfString:string].location != NSNotFound) {
                cType = [NSString stringWithString:string];
                break;
            }
        }
        
        id value = [object valueForKey:name];
        if (cType) {
            // primitive C type
            if ([cType isEqualToString:@"Ti"]) {
                NSString *s_value = [[NSNumber numberWithInt:[value integerValue]] stringValue];
                [xml appendFormat:XML_ELEMENT, name, s_value, name];
            } else if ([cType isEqualToString:@"Tf"]) {
                NSString *s_value = [[NSNumber numberWithFloat:[value floatValue]] stringValue];
                [xml appendFormat:XML_ELEMENT, name, s_value, name];
            } else if ([cType isEqualToString:@"Td"]) {
                NSString *s_value = [[NSNumber numberWithDouble:[value doubleValue]] stringValue];
                [xml appendFormat:XML_ELEMENT, name, s_value, name];
            }
        } else {
            // class or nsobject
            [xml appendString:[self convertToXML:value rootName:name]];
        }
    }
    free(properties);
    
    if (rootName)
        [xml appendFormat:XML_ELEMENT_CLOSE, rootName];
    return [xml autorelease];
}

@end
