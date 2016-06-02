//
//  GDCacheManager.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-1-7.
//
//

#import <Foundation/Foundation.h>

#define GDCacheType_LaunchImage         @"launchImage"
#define GDCacheType_PowerVoice          @"powerVoice.mp3"

@interface GDCacheManager : NSObject

+ (instancetype)globalCache;

@property(nonatomic,assign) NSTimeInterval defaultTimeoutInterval; //过期时间（默认一天）

/*!
  @brief  初始化缓存
  @param  cacheDirectory 缓存目录
  @return 缓存对象
  */
- (id)initWithCacheDirectory:(NSString*)cacheDirectory;

/*!
  @brief  清除缓存
  */
- (void)clearCache;

/*!
  @brief  清除对应key值缓存
  @param  key 缓存key
  @return 缓存对象
  */
- (void)removeCacheForKey:(NSString*)key;

/*!
  @brief  获取缓存路径
  @param  key 缓冲key
  @return 对应缓存路径
  */
- (NSString *)pathWithKey:(NSString *)key;

/*!
  @brief  判断是否有key对应的缓存
  @param  key 缓存key
  @return YES 有 NO 没有
  */
- (BOOL)hasCacheForKey:(NSString*)key;

/*!
  @brief  获取NSData类型缓存
  @param  key 缓存key
  @return 缓存值
  */
- (NSData*)dataForKey:(NSString*)key;

/*!
  @brief  设置NSData类型缓存（缓存时间默认一天）
 .@param  data 缓存数据
  @param  key 缓存key
  */
- (void)setData:(NSData*)data forKey:(NSString*)key;

/*!
  @brief  设置NSData类型缓存
 .@param  data 缓存数据
  @param  key 缓存key
  @param  timeoutInterval 缓存时间
  */
- (void)setData:(NSData*)data forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

/*!
  @brief  设置NSData类型缓存
 .@param  data 缓存数据
  @param  key 缓存key
  @param  timeoutString 过期时间（例：2014-01-10）
  */
- (void)setData:(NSData*)data forKey:(NSString*)key withTimeoutString:(NSString *)timeoutString;

/*!
  @brief  获取NSString类型缓存
  @param  key 缓存key
  @return 缓存值
  */
- (NSString*)stringForKey:(NSString*)key;

/*!
  @brief  设置NSString类型缓存（默认缓存一天）
 .@param  aString 缓存数据
  @param  key 缓存key
  */
- (void)setString:(NSString*)aString forKey:(NSString*)key;

/*!
  @brief  设置NSString类型缓存
 .@param  aString 缓存数据
  @param  key 缓存key
  @param  timeoutInterval 缓存时间
  */
- (void)setString:(NSString*)aString forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

/*!
  @brief  设置NSString类型缓存
 .@param  aString 缓存数据
  @param  key 缓存key
  @param  timeOutString 过期时间（例：2014-01-10）
  */
- (void)setString:(NSString*)aString forKey:(NSString*)key withTimeoutString:(NSString *)timeOutString;

/*!
  @brief  获取缓存过期时间
  @param  key 缓存key
  @return 缓存过期时间
  */
- (NSDate*)dateForKey:(NSString*)key;

/*!
  @brief  与缓存过期时间对比
  @param  dateString 对比时间
  @param  key 缓存key
  @return YES 时间一样 NO 时间不一样
  */
- (BOOL)isSameForDateWithString:(NSString *)dateString Key:(NSString *)key;

/*!
  @brief  获取所缓存key值
  @return 所有缓存key值
  */
- (NSArray*)allKeys;

/*!
  @brief  获取UIImage类型缓存
  @param  key 缓存key
  @return 缓存值
  */
- (UIImage*)imageForKey:(NSString*)key;

/*!
  @brief  设置UIImage类型缓存（默认缓存一天）
 .@param  anImage 缓存数据
  @param  key 缓存key
  */
- (void)setImage:(UIImage*)anImage forKey:(NSString*)key;

/*!
  @brief  设置UIImage类型缓存
 .@param  anImage 缓存数据
  @param  key 缓存key
  @param  timeoutInterval 缓存时间
  */
- (void)setImage:(UIImage*)anImage forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

/*!
  @brief  设置UIImage类型缓存
 .@param  anImage 缓存数据
  @param  key 缓存key
  @param  timeOutString 过期时间（例：2014-01-10）
  */
- (void)setImage:(UIImage*)anImage forKey:(NSString*)key withTimeoutString:(NSString *)timeoutString;

/*!
  @brief  获取plist类型缓存
  @param  key 缓存key
  @return 缓存值
  */
- (NSData*)plistForKey:(NSString*)key;

/*!
  @brief  设置plist类型缓存（默认缓存一天）
 .@param  plistObject 缓存数据
  @param  key 缓存key
  */
- (void)setPlist:(id)plistObject forKey:(NSString*)key;

/*!
  @brief  设置plist类型缓存
 .@param  plistObject 缓存数据
  @param  key 缓存key
  @param  timeoutInterval 缓存时间
  */
- (void)setPlist:(id)plistObject forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

/*!
  @brief  设置plist类型缓存
 .@param  plistObject 缓存数据
  @param  key 缓存key
  @param  timeOutString 过期时间（例：2014-01-10）
  */
- (void)setPlist:(id)plistObject forKey:(NSString*)key withTimeoutString:(NSString *)timeoutString;

/*!
  @brief  复制文件缓存 （默认缓冲一天）
 .@param  filePath 缓存文件路径
  @param  key 缓存key
  */
- (void)copyFilePath:(NSString*)filePath asKey:(NSString*)key;

/*!
  @brief  复制文件缓存
 .@param  filePath 缓存文件路径
  @param  key 缓存key
  @param  timeoutInterval 缓存时间
  */
- (void)copyFilePath:(NSString*)filePath asKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

/*!
  @brief  复制文件缓存
 .@param  filePath 缓存文件路径
  @param  key 缓存key
  @param  timeoutString 过期时间（例：2014-01-10）
  */
- (void)copyFilePath:(NSString*)filePath asKey:(NSString*)key withTimeoutString:(NSString *)timeoutString;

/*!
  @brief  获取对象类型缓存
  @param  key 缓存key
  @return 缓存值
  */
- (id<NSCoding>)objectForKey:(NSString*)key;

/*!
  @brief  对象缓存 （默认缓冲一天）
 .@param  anObject 缓存对象
  @param  key 缓存key
  */
- (void)setObject:(id<NSCoding>)anObject forKey:(NSString*)key;

/*!
  @brief  对象缓存
 .@param  anObject 缓存对象
  @param  key 缓存key
  @param  timeoutInterval 缓存时间
  */
- (void)setObject:(id<NSCoding>)anObject forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

/*!
  @brief  对象缓存
 .@param  anObject 缓存对象
  @param  key 缓存key
  @param  timeoutString 过期时间（例：2014-01-10）
  */
- (void)setObject:(id<NSCoding>)anObject forKey:(NSString*)key withTimeoutString:(NSString *)timeoutString;

/*!
  @brief  判断是否过期
  @param  dateString 传入时间（例：2014-01-10）
  */
- (BOOL)isExpiredWithString:(NSString *)dateString;

/*!
  @brief  传入时间与当前时间对比，判断先后关系
  @param  dateString 传入时间（例：20140511023033）
  */
- (NSComparisonResult)compareDateWithString:(NSString *)dateString;

@end
