//
//  XMLDictionary.h
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

#import <Foundation/Foundation.h>


#define COLLAPSE_TEXT_NODES		YES
#define TRIM_WHITE_SPACE		YES

#define XML_ATTRIBUTES_KEY		@"__attributes"
#define XML_COMMENTS_KEY		@"__comments"
#define XML_TEXT_KEY			@"__text"
#define XML_NAME_KEY			@""

#define XML_ATTRIBUTE_PREFIX	@"_"

/**
 *  @brief	XML数据，字符串，文件转字典
 */
@interface NSDictionary (XMLDictionary)

/**
 *  @brief	将数据data转换字典
 *
 *	@param	data	xml数据
 *
 *	@return	返回NSDictionary对象
 */

+ (NSDictionary *)dictionaryWithXMLData:(NSData *)data;

/**
 *  @brief	将xml字符串转换字典
 *
 *	@param	string	xml字符串
 *
 *	@return	返回NSDictionary对象
 */
+ (NSDictionary *)dictionaryWithXMLString:(NSString *)string;

/**
 *  @brief	将文件转换字典
 *
 *	@param	path	文件位置
 *
 *	@return	返回NSDictionary对象
 */
+ (NSDictionary *)dictionaryWithXMLFile:(NSString *)path;



@end

/**
 *  @brief	字典转换成字符串
 */
@interface GD_NSObjectToXML : NSObject

/**
 *  @brief	获取xml头部字符串
 *
 *	@return	返回字符串 @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
 */
+ (NSString *)xmlHeadString;

/**
 *  @brief	将对象转换成键值字符串如 <key>value<key>
 *
 *	@param	value	要转换的对象
 *
 *	@param	rootName	父节点名称
 *
 *	@return	返回转换后的字符串
 */
+ (NSString*)convertToXML:(id)value rootName:(NSString *)rootName;

/**
 *  @brief	将字典转换成xml
 *
 *	@param	dictionary	待转换的字典
 *
 *	@param	rootName	根节点名称
 *
 *	@return	返回xml字符串
 */
+ (NSString*)convertDictionaryToXML:(NSDictionary*)dictionary rootName:(NSString*)rootName;
@end

