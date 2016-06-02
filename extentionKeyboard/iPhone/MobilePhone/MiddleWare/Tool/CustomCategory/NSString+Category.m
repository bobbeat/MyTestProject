//
//  NSString+Category.m
//  AutoNavi
//
//  Created by GHY on 12-3-19.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+Category.h"
#import <CommonCrypto/CommonDigest.h>
#import "RegexKitLite.h"

#import "KeychainItemWrapper.h"

@implementation NSString(Category)

#pragma mark -
#pragma mark UTF32转换
+ (int)GMD_strlenWith32:(Guint32*)str
{
    if (str == NULL)
    {
        return 0;
    }
    int len = 0;
    
    Guint32 c = *str;
    while (c != 0)
    {
        len++;
        str ++;
        c = *str;
    }
    return len;
}

+ (int)GMD_convertUTF32to8With:(Gint8 *)dest orig:(Guint32 *)orig
{
    Guint32 c;
    int i, len = 0;
    
    while ((c = *orig++) != '\0')
    {
        if (c < 0x80) {
            i = 1;
        } else if (c < 0x800) {
            i = 2;
        } else if (c < 0x10000) {
            i = 3;
        } else if (c < 0x200000) {
            i = 4;
        } else if (c < 0x4000000) {
            i = 5;
        } else {
            i = 6;
        }
        if (i == 1) {
            *dest++ = (Guint32)c;
        } else {
            Gint8 *dp = dest = dest + i;
            for (int m = 0; m < i; ++m) {
                *--dp = (Guint32)((c | (m == i - 1 ? (~0 << (8 - i)) : 0x80))
                                  & (m == i - 1 ? (~(0x80 >> i)) : 0xbf));
                c >>= 6;
            }
        }
        len += i;
    }
    
    *dest = '\0';
    return len;
}

+ (NSString*)GMD_Cstring32ToNSString:(Guint32 *)orig
{
    int len = 0;
    Guint32 c, *cp = (Guint32 *)orig;
    while ((c = *cp++) != '\0') ++len;
    
    Gint8 *c8 = (Gint8 *)malloc(6 * len + sizeof(Gint8));
    [NSString GMD_convertUTF32to8With:c8 orig:(Guint32 *)orig];
    NSString *string = [NSString stringWithCString:(const char *)c8 encoding:NSUTF8StringEncoding];
    free(c8);
    return string;
}

+ (Guint32*)GMD_NSStringToCstring32:(NSString *)orig
{
    if (orig == nil)
    {
        return NULL;
    }
    Guint32 *temp = (Guint32 *)[orig cStringUsingEncoding:NSUTF32StringEncoding];
    return temp;
}

#pragma mark -
#pragma mark UTF16转换
+ (int)GMD_strlenWith16:(Guint16*)str;
{
    if (str == NULL)
    {
        return 0;
    }
    int len = 0;
    
    Guint16 c = *str;
    while (c != 0)
    {
        len++;
        str ++;
        c = *str;
    }
    return len;
}


+ (NSString*)GMD_Cstring16ToNSString:(Guint16 *)orig
{
    int len = 0;
    Guint16 c, *cp = (Guint16 *)orig;
    while ((c = *cp++) != 0) ++len;
    Gint8 *c8 = (Gint8 *)malloc(3 * len + sizeof(Gint8));
    memset(c8, 0, 3 * len + sizeof(Gint8));
    [NSString GMD_convertUTF16to8With:(Guint8*)c8 orig:(Guint16 *)orig];
    NSString *string = [NSString stringWithCString:(const char *)c8 encoding:NSUTF8StringEncoding];
    free(c8);
    
    /*modify by gzm for 未知道路，普通道路 都改成 无名道路 at 2014-7-22*/
    if ([string rangeOfString:STR(@"Main_NoDefinedRoad", Localize_Main)].length > 0)
    {
        string = [string stringByReplacingOccurrencesOfString:STR(@"Main_NoDefinedRoad", Localize_Main) withString:STR(@"Main_unNameRoad", Localize_Main)];
    }
    
    if ([string rangeOfString:STR(@"Main_NormalDefinedRoad", Localize_Main)].length > 0)
    {
        string = [string stringByReplacingOccurrencesOfString:STR(@"Main_NormalDefinedRoad", Localize_Main) withString:STR(@"Main_unNameRoad", Localize_Main)];
    }
    /*modify by gzm for 未知道路，普通道路 都改成 无名道路 at 2014-7-22*/
    return string;
}

+ (void)GMD_convertUTF16to8With:(Guint8*)dest orig:(Guint16*)orig
{
    Guint8* pTempUTF8 = dest;
    Guint16 c, *cp = (Guint16 *)orig;
    while ((c = *cp++) != 0)
    {
        if (c <= 0x007f)
        {
            //0000 - 007F  0xxxxxxx
            *pTempUTF8++ = (Guint8)c;
        }
        else if(c <= 0x07ff)
        {
            //0080 - 07FF 110xxxxx 10xxxxxx
            *pTempUTF8++ = (c >> 6) | 0xC0;
            *pTempUTF8++ = (c & 0x3F) | 0x80;
        }
        else if(c <= 0xffff)
        {
            //0800 - FFFF 1110xxxx 10xxxxxx 10xxxxxx
            *pTempUTF8++ = (c >> 12) | 0xE0;
            *pTempUTF8++ = ((c >> 6) & 0x3F) | 0x80;
            *pTempUTF8++ = (c & 0x3F) | 0x80;
        }
        else
        {
            break;
        }
    }
}

+ (void)GMD_convertUTF8to16With:(Guint16*)dest orig:(Guint8*)orig
{
    Guint16* pTempUTF16 = dest;
    Guint8 *cp = (Guint8 *)orig;
    while (*cp != '\0')
    {
        if (*cp >= 0xE0 && *cp <= 0xEF)//是3个字节的格式
        {
            //0800 - FFFF 1110xxxx 10xxxxxx 10xxxxxx
            *pTempUTF16 |= ((*cp++ & 0xEF) << 12);
            *pTempUTF16 |= ((*cp++ & 0x3F) << 6);
            *pTempUTF16 |= (*cp++ & 0x3F);
            
        }
        else if (*cp >= 0xC0 && *cp <= 0xDF)//是2个字节的格式
        {
            //0080 - 07FF 110xxxxx 10xxxxxx
            *pTempUTF16 |= ((*cp++ & 0x1F) << 6);
            *pTempUTF16 |= (*cp++ & 0x3F);
        }
        else if(*cp >= 0 && *cp <= 0x7F)//是1个字节的格式
        {
            //0000 - 007F  0xxxxxxx
            *pTempUTF16 = *cp++;
        }
        else
        {
            break;
        }
        pTempUTF16++;
    }
    *pTempUTF16 = 0;
}

+ (Guint16*)GMD_NSStringToCstring16:(NSString *)orig
{
    if (orig == nil)
    {
        return NULL;
    }
    Guint16 *temp = (Guint16 *)[orig cStringUsingEncoding:NSUTF16StringEncoding];
    return temp;
}


#pragma mark -
#pragma mark GcharMemcpy
+ (void)GMD_GcharMemcpyWih:(Gchar*)dest src:(Gchar *)src len:(Gint32)len
{
    if (dest == NULL || src == NULL || len <= 0)
    {
        return;
    }
    int src_len = StrlenWithGchar(src);
    if (src_len > len)
    {
        src_len = len;
    }
    memcpy(dest, src, sizeof(Gchar)*src_len);
}


+ (NSString *)chinaFontStringWithCString:(Gchar *)cString
{
    if (cString == NULL) {
        return @"";
    }
    NSString *string = GcharToNSString((Gchar *)cString);
    return string;
}

-(NSString*)CutFromNSString:(NSString*)Cutstring
{
	if (self == nil) 
	{
		return nil;
	}
	NSRange range = [self rangeOfString:Cutstring];
	if (range.length == 0) 
	{
		range.location = 0;
		return @"";
	}
	else 
	{
		return [self substringFromIndex:range.location+range.length];
	}	
	
}
-(NSString*)CutToNSString:(NSString*)Cutstring
{
	if (self == nil) 
	{
		return nil;
	}
	NSRange range = [self rangeOfString:Cutstring];
	if (range.length == 0) 
	{
		range.location = 0;
		return @"";
	}
	else 
	{
		return [self substringToIndex:range.location];
	}	
	
}
-(NSString*)CutFromNSString:(NSString*)CutFromstring Tostring:(NSString*)CutTostring
{
	if (self == nil) 
	{
		return nil;
	}
	NSString *temp = [self CutFromNSString:CutFromstring];
	temp = [temp CutToNSString:CutTostring];
	return temp;
    
}
-(NSString *)CutToNSStringBackWard:(NSString *)Cutstring
{
    if (self == nil) 
	{
		return nil;
	}
	NSRange range = [self rangeOfString:Cutstring options:NSBackwardsSearch];
	if (range.length == 0) 
	{
		range.location = 0;
		return @"";
	}
	else 
	{
		return [self substringToIndex:range.location +1];
	}	
}

//从字符串后面截取到指定字符，例：26.1.100005.0002 cutString如果为“.”,则截取出来的字符为0002
-(NSString *)CutNSStringFromBackWard:(NSString *)cutString
{
    if (!self)
	{
		return nil;
	}
    
	NSRange range = [self rangeOfString:cutString options:NSBackwardsSearch];
	if (range.length != 0)
	{
		
		return [self substringFromIndex:range.location +1];
	}
	else
	{
		return @"";
	}
}

- (NSString *) stringFromMD5{
    
    if(self == nil || [self length] == 0)
       return [NSString stringWithFormat:@"01234567890123456789012345678901"];
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return [outputString autorelease];
}

/**
 *	检测字符串标准 ： 汉字、字母、数字、@、&、_
 *
 *	@param	checkStr	要检测字符串
 *
 *	@return	符合标准返回yes 不符合标准 返回no
 */
+ (BOOL) checkStringStandardWith:(NSString *)checkStr
{
    if ([[checkStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) { return NO; }
    if (![checkStr isMatchedByRegex:@"^[\u4e00-\u9fa5A-Za-z0-9 @&_]+$"])
    {
        return NO;
    }
    return YES;
}

/**
 *	检测电话号码标准 ：数字、-、和“、”
 *
 *	@param	checkPhone	要检测电话字符串
 *
 *	@return	符合标准返回yes 不符合标准 返回no
 */
+ (BOOL) checkPhoneStandardWith:(NSString *)checkPhone
{
    if (![checkPhone isMatchedByRegex:@"^[0-9、;-]+$"])
    {
        return NO;
    }
    return YES;
}

#define FileHashDefaultChunkSizeForReadingData 1024*8

+(NSString*)getFileMD5WithPath:(NSString*)path

{
    
    return (NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)path,FileHashDefaultChunkSizeForReadingData);
    
}




NSString* FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    
    // Declare needed variables
    
    NSString* result = nil;
    
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    
    CFURLRef fileURL =
    
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  
                                  (CFStringRef)filePath,
                                  
                                  kCFURLPOSIXPathStyle,
                                  
                                  (Boolean)false);
    
    if (!fileURL) goto done;
    
    // Create and open the read stream
    
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            
                                            (CFURLRef)fileURL);
    
    if (!readStream) goto done;
    
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    
    CC_MD5_CTX hashObject;
    
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    
    if (!chunkSizeForReadingData) {
        
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
        
    }
    
    // Feed the data to the hash object
    
    bool hasMoreData = true;
    
    while (hasMoreData) {
        
        uint8_t buffer[chunkSizeForReadingData];
        
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        
        if (readBytesCount == -1) break;
        
        if (readBytesCount == 0) {
            
            hasMoreData = false;
            
            continue;
            
        }
        
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
        
    }
    
    // Check if the read operation succeeded
    
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    
    if (!didSucceed) goto done;
    
    // Compute the string result
    
    char hash[2 * sizeof(digest) + 1];
    
    for (size_t i = 0; i < sizeof(digest); ++i) {
        
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
        
    }
    
    result = [NSString stringWithCString:(const char *)hash encoding:NSUTF8StringEncoding];
    
done:
    
    if (readStream) {
        
        CFReadStreamClose(readStream);
        
        CFRelease(readStream);
        
    }
    
    if (fileURL) {
        
        CFRelease(fileURL);
        
    }
    
    return result;
    
}

#pragma mark -
#pragma mark JSONCategories

/*!
  @brief 将NSString转化为NSArray或者NSDictionary
  */
- (id)JSONValue
{
    if (!self) {
        return nil;
    }
    
    NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError* error = nil;
    
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if (error != nil) return nil;
    
    return result;
}

@end
