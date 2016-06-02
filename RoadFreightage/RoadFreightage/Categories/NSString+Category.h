//
//  NSString+Category.h
//  AutoNavi
//
//  Created by GHY on 12-3-19.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef signed int      Gint32;     /**< -2147483648 ~ 2147483647             */
typedef unsigned int    Guint32;    /**< 0 ~ 4294967295(0xffffffff)           */
typedef signed short    Gint16;     /**< -32768 ~ 32767                       */
typedef unsigned short  Guint16;    /**< 0 ~ 65535(0xffff)                    */
typedef signed char     Gint8;      /**< -128 ~ 127                           */
typedef unsigned char   Guint8;     /**< 0 ~ 255(0xff)                        */
typedef float           Gfloat32;   /**< -3.40E+38 ~ +3.40E+38 精度为6~7位    */
typedef double          Gfloat64;   /**< -1.79E+308 ~ +1.79E+308 精度为15~16位*/
typedef Guint16        Gchar;

@interface NSString(Category)
+ (void)GMD_GcharMemcpyWih:(Gchar*)dest src:(Gchar *)src len:(Gint32)len;
//utf32转换
+ (NSString*)GMD_Cstring32ToNSString:(Guint32 *)orig;
+ (Guint32*)GMD_NSStringToCstring32:(NSString *)orig;
+ (int)GMD_convertUTF32to8With:(Gint8 *)dest orig:(Guint32 *)orig;
+ (int)GMD_strlenWith32:(Guint32*)str;

//utf16转换
+ (NSString*)GMD_Cstring16ToNSString:(Guint16 *)orig;
+ (Guint16*)GMD_NSStringToCstring16:(NSString *)orig;
+ (void)GMD_convertUTF16to8With:(Guint8*)dest orig:(Guint16*)orig;
+ (int)GMD_strlenWith16:(Guint16*)str;
+ (void)GMD_convertUTF8to16With:(Guint16*)dest orig:(Guint8*)orig;


+(NSString*)getFileMD5WithPath:(NSString*)path;
+ (NSString*)chinaFontStringWithCString:(Gchar *)cString;
-(NSString*)CutFromNSString:(NSString*)Cutstring;
-(NSString*)CutToNSString:(NSString*)Cutstring;
-(NSString*)CutFromNSString:(NSString*)CutFromstring Tostring:(NSString*)CutTostring;
-(NSString *)CutToNSStringBackWard:(NSString *)Cutstring;
//从字符串后面截取到指定字符，例：26.1.100005.0002 cutString如果为“.”,则截取出来的字符为0002
-(NSString *)CutNSStringFromBackWard:(NSString *)cutString;
- (NSString *) stringFromMD5;

/**
 *	检测字符串标准 ： 汉字、字母、数字、@、&、_
 *
 *	@param	checkStr	要检测字符串
 *
 *	@return	符合标准返回yes 不符合标准 返回no
 */
+ (BOOL) checkStringStandardWith:(NSString *)checkStr;

/**
 *	检测电话号码标准 ：数字、-、和“、”
 *
 *	@param	checkPhone	要检测电话字符串
 *
 *	@return	符合标准返回yes 不符合标准 返回no
 */
+ (BOOL) checkPhoneStandardWith:(NSString *)checkPhone;

/*!
  @brief 将NSString转化为NSArray或者NSDictionary
  */
- (id)JSONValue;

@end
