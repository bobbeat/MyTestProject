//
//  GDCacheManager.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-1-7.
//
//

#import "GDCacheManager.h"
#import "NSString+Category.h"

#define CachePath               @"ResCache"
#define CacheInfoQueue          "com.gdcache.info"
#define FrozenCacheInfoQueue    "com.egocache.info.frozen"
#define DiskQueue               "com.gdcache.disk"
#define MP3Subfix               @".mp3"
#define WAVSubfix               @".wav"

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

static inline NSString* cachePathForKey(NSString* directory, NSString* key) {
	return [directory stringByAppendingPathComponent:key];
}

@interface GDCacheManager () {
    
	dispatch_queue_t       _cacheInfoQueue;       //缓存信息线程
	dispatch_queue_t       _frozenCacheInfoQueue; //快速缓存线程（缓存在内存,方便快速读取）
	dispatch_queue_t       _diskQueue;            //磁盘缓存线程
	NSMutableDictionary   *_cacheInfo;
	NSString              *_directory;
    
	BOOL _needsSave;
}

@property(nonatomic,copy) NSDictionary* frozenCacheInfo;

@end

@implementation GDCacheManager

+ (instancetype)globalCache {
    
	static id instance;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[[self class] alloc] init];
	});
	
	return instance;
}

- (id)init {
    
	NSString* cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
	NSString* oldCachesDirectory = [[cachesDirectory stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]] stringByAppendingPathComponent:CachePath];
    
	if([[NSFileManager defaultManager] fileExistsAtPath:oldCachesDirectory]) {
		[[NSFileManager defaultManager] removeItemAtPath:oldCachesDirectory error:NULL];
	}
    
	//创建缓存目录
	cachesDirectory = [[cachesDirectory stringByAppendingPathComponent:CachePath] copy];
	return [self initWithCacheDirectory:cachesDirectory];
}

- (id)initWithCacheDirectory:(NSString*)cacheDirectory {
	if((self = [super init])) {
        
        //创建线程
		_cacheInfoQueue = dispatch_queue_create(CacheInfoQueue, DISPATCH_QUEUE_SERIAL);
		dispatch_queue_t priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
		dispatch_set_target_queue(priority, _cacheInfoQueue);
		
		_frozenCacheInfoQueue = dispatch_queue_create(FrozenCacheInfoQueue, DISPATCH_QUEUE_SERIAL);
		priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
		dispatch_set_target_queue(priority, _frozenCacheInfoQueue);
		
		_diskQueue = dispatch_queue_create(DiskQueue, DISPATCH_QUEUE_CONCURRENT);
		priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
		dispatch_set_target_queue(priority, _cacheInfoQueue);
		
		
		_directory = cacheDirectory;
        
		_cacheInfo = [[NSDictionary dictionaryWithContentsOfFile:cachePathForKey(_directory, CacheFileName)] mutableCopy];
		
		if(!_cacheInfo) {
			_cacheInfo = [[NSMutableDictionary alloc] init];
		}
		
		[[NSFileManager defaultManager] createDirectoryAtPath:_directory withIntermediateDirectories:YES attributes:nil error:NULL];
		
		NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
		NSMutableArray* removedKeys = [[NSMutableArray alloc] init];
		
		for(NSString* key in _cacheInfo) {
			if(([_cacheInfo[key] timeIntervalSinceReferenceDate] <= now) && [[NSFileManager defaultManager] fileExistsAtPath:cachePathForKey(_directory, key)]) {//过期则清除缓存
                
                    [[NSFileManager defaultManager] removeItemAtPath:cachePathForKey(_directory, key) error:NULL];
                    [removedKeys addObject:key];
                
				
			}
		}
		
		[_cacheInfo removeObjectsForKeys:removedKeys];
//        [removedKeys release];
        
		self.frozenCacheInfo = _cacheInfo;
        
		[self setDefaultTimeoutInterval:86400]; //默认缓存一天
	}
	
	return self;
}

- (void)clearCache {
    
	dispatch_sync(_cacheInfoQueue, ^{
		for(NSString* key in _cacheInfo) {
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:cachePathForKey(_directory, key)]) {
                [[NSFileManager defaultManager] removeItemAtPath:cachePathForKey(_directory, key) error:NULL];
            }
			
		}
		
		[_cacheInfo removeAllObjects];
		
		dispatch_sync(_frozenCacheInfoQueue, ^{
			self.frozenCacheInfo = _cacheInfo;
		});
        
		[self setNeedsSave];
	});
}

- (void)removeCacheForKey:(NSString*)key {
    
	if([key isEqualToString:CacheFileName]) return;
    
    NSString *MD5Key = [self stringToMD5:key];
    
	dispatch_async(_diskQueue, ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:cachePathForKey(_directory, MD5Key)]) {
		    [[NSFileManager defaultManager] removeItemAtPath:cachePathForKey(_directory, MD5Key) error:NULL];
        }
	});
    
	[self setCacheTimeoutInterval:0 forKey:key];
}

- (BOOL)hasCacheForKey:(NSString*)key {
    
    NSString *MD5Key = [self stringToMD5:key];
    
    NSDate* date = [self dateForKey:key];
	if(!date) return NO;
	if([date compare:[NSDate date]] != NSOrderedDescending) return NO;
	
	return [[NSFileManager defaultManager] fileExistsAtPath:cachePathForKey(_directory, MD5Key)];
}

- (BOOL)isExpiredWithString:(NSString *)dateString
{
    NSDateFormatter *formatterqtime = [[NSDateFormatter alloc] init];
    
    NSRange dateRange = [dateString rangeOfString:@"-"];
    if (dateRange.length != 0) {
        [formatterqtime setDateFormat:@"yyyy-MM-dd"];
    }
    else {
        [formatterqtime setDateFormat:@"yyyyMMddHHmmss"];
    }
    
    [formatterqtime setTimeZone:[[NSCalendar currentCalendar]timeZone]];
    NSDate *qtimeDate = [formatterqtime dateFromString:dateString];
    
    if (!qtimeDate) {
        return YES;
    }
    
    if ([qtimeDate compare:[NSDate date]] != NSOrderedDescending) {
        return YES;
    }
    
    return NO;
    
}

- (NSComparisonResult)compareDateWithString:(NSString *)dateString
{
    if (!dateString) {
        return -2;
    }
    NSDateFormatter *formatterqtime = [[NSDateFormatter alloc] init];
    [formatterqtime setDateFormat:@"yyyyMMddHHmmss"];
    [formatterqtime setTimeZone:[[NSCalendar currentCalendar]timeZone]];
    NSDate *qtimeDate = [formatterqtime dateFromString:dateString];
    
    if (!qtimeDate) {
        return -2;
    }
    
    return [qtimeDate compare:[NSDate date]];
}
- (BOOL)isSameForDateWithString:(NSString *)dateString Key:(NSString *)key
{
    NSDateFormatter *formatterqtime = [[NSDateFormatter alloc] init];
    NSRange dateRange = [dateString rangeOfString:@"-"];
    if (dateRange.length != 0) {
        [formatterqtime setDateFormat:@"yyyy-MM-dd"];
    }
    else {
        [formatterqtime setDateFormat:@"yyyyMMddHHmmss"];
    }
    [formatterqtime setTimeZone:[[NSCalendar currentCalendar]timeZone]];
    NSDate *qtimeDate = [formatterqtime dateFromString:dateString];
    
    NSDate *cacheDate = [self dateForKey:key];
    
    if (!qtimeDate || !cacheDate) {
        return NO;
    }
    
    if ([qtimeDate compare:cacheDate] == NSOrderedSame) {
        return YES;
    }
    
    return NO;
    
}

- (NSDate*)dateForKey:(NSString*)key {
    
    NSString *MD5Key = [self stringToMD5:key];
    
	__block NSDate* date = nil;
    
	dispatch_sync(_frozenCacheInfoQueue, ^{
		date = (self.frozenCacheInfo)[MD5Key];
	});
    
    return date;
}

- (NSArray*)allKeys
{
    
    __block NSArray* keys = nil;
    
    dispatch_sync(_frozenCacheInfoQueue, ^{
        keys = [self.frozenCacheInfo allKeys];
    });
    
    return keys;
}

- (void)setCacheTimeoutInterval:(NSTimeInterval)timeoutInterval forKey:(NSString*)key
{
    
    NSString *MD5Key = [self stringToMD5:key];
    
	NSDate* date = timeoutInterval > 0 ? [NSDate dateWithTimeIntervalSinceNow:timeoutInterval] : nil;
	
	
	dispatch_sync(_frozenCacheInfoQueue, ^{
		NSMutableDictionary* info = [self.frozenCacheInfo mutableCopy];
		
		if(date) {
            
			info[MD5Key] = date;
		}
        else {
            
			[info removeObjectForKey:MD5Key];
		}
		
		self.frozenCacheInfo = info;
	});
	
	
	dispatch_async(_cacheInfoQueue, ^{
		if(date) {
			_cacheInfo[MD5Key] = date;
		} else {
			[_cacheInfo removeObjectForKey:MD5Key];
		}
		
		dispatch_sync(_frozenCacheInfoQueue, ^{
			self.frozenCacheInfo = _cacheInfo;
		});
        
		[self setNeedsSave];
	});
}

- (NSTimeInterval)dateStringTimeIntervalSinceNow:(NSString *)timeOutString
{
    if (!timeOutString) {
        return 0;
    }
    
    NSDateFormatter *formatterqtime = [[NSDateFormatter alloc] init];
    NSRange dateRange = [timeOutString rangeOfString:@"-"];
    if (dateRange.length != 0) {
        [formatterqtime setDateFormat:@"yyyy-MM-dd"];
    }
    else {
        [formatterqtime setDateFormat:@"yyyyMMddHHmmss"];
    }
    [formatterqtime setTimeZone:[[NSCalendar currentCalendar]timeZone]];
    NSDate *qtimeDate = [formatterqtime dateFromString:timeOutString];
    
    NSTimeInterval expired = [qtimeDate timeIntervalSinceNow];
    
    return expired;
}

- (NSString *)pathWithKey:(NSString *)key
{
    NSString *MD5Key = [self stringToMD5:key];
    
    NSString* cachePath = cachePathForKey(_directory, MD5Key);
    return cachePath;
}

- (NSString *)stringToMD5:(NSString *)string
{
    if (!string) {
        return nil;
    }
    NSString *MD5String = nil;
    
    NSMutableString *tmpString = [string mutableCopy];
    
    NSRange extension = [tmpString rangeOfString:MP3Subfix options:NSBackwardsSearch];
    
    if (extension.location != NSNotFound) {
        
        [tmpString deleteCharactersInRange:extension];
        
        MD5String = [NSString stringWithFormat:@"%@%@",[tmpString stringFromMD5],MP3Subfix];
        
    }
    else{
        
        MD5String = [tmpString stringFromMD5];
    }
    
    if (tmpString) {
//        [tmpString release];
        tmpString = nil;
    }
    
    
    return MD5String;
    
}
#pragma mark -
#pragma mark 缓存文件

- (void)copyFilePath:(NSString*)filePath asKey:(NSString*)key {
	[self copyFilePath:filePath asKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)copyFilePath:(NSString*)filePath asKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
    
    NSString *MD5Key = [self stringToMD5:key];
    
	dispatch_async(_diskQueue, ^{
		[[NSFileManager defaultManager] copyItemAtPath:filePath toPath:cachePathForKey(_directory, MD5Key) error:NULL];
	});
	
	[self setCacheTimeoutInterval:timeoutInterval forKey:key];
}

- (void)copyFilePath:(NSString*)filePath asKey:(NSString*)key withTimeoutString:(NSString *)timeoutString {
    
    NSString *MD5Key = [self stringToMD5:key];
    
    NSTimeInterval expired = [self dateStringTimeIntervalSinceNow:timeoutString];
    
	dispatch_async(_diskQueue, ^{
		[[NSFileManager defaultManager] copyItemAtPath:filePath toPath:cachePathForKey(_directory, MD5Key) error:NULL];
	});
	
	[self setCacheTimeoutInterval:expired forKey:key];
}


#pragma mark -
#pragma mark 缓存，读取 NSData

- (void)setData:(NSData*)data forKey:(NSString*)key {
	[self setData:data forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setData:(NSData*)data forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
	if([key isEqualToString:CacheFileName]) return;
	
    NSString *MD5Key = [self stringToMD5:key];
    
	NSString* cachePath = cachePathForKey(_directory, MD5Key);
	
	dispatch_async(_diskQueue, ^{
        
		[data writeToFile:cachePath atomically:YES];
        
	});
	
	[self setCacheTimeoutInterval:timeoutInterval forKey:key];
}

- (void)setData:(NSData*)data forKey:(NSString*)key withTimeoutString:(NSString *)timeoutString {
	if([key isEqualToString:CacheFileName]) return;
	
    NSString *MD5Key = [self stringToMD5:key];
    
    NSTimeInterval timeoutInterval = [self dateStringTimeIntervalSinceNow:timeoutString];
    
	NSString* cachePath = cachePathForKey(_directory, MD5Key);
	
	dispatch_async(_diskQueue, ^{
		[data writeToFile:cachePath atomically:YES];
	});
	
	[self setCacheTimeoutInterval:timeoutInterval forKey:key];
}

- (void)setNeedsSave {
    
	dispatch_async(_cacheInfoQueue, ^{
        
		if(_needsSave) return;
		_needsSave = YES;
		
		double delayInSeconds = 0.5;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, _cacheInfoQueue, ^(void){
            
			if(!_needsSave) return;
			[_cacheInfo writeToFile:cachePathForKey(_directory, CacheFileName) atomically:YES];
			_needsSave = NO;
		});
	});
}

- (NSData*)dataForKey:(NSString*)key {
    
    NSString *MD5Key = [self stringToMD5:key];
    
	if([self hasCacheForKey:key]) {
		return [NSData dataWithContentsOfFile:cachePathForKey(_directory, MD5Key) options:0 error:NULL];
	} else {
		return nil;
	}
}

#pragma mark -
#pragma mark 缓存，读取 String

- (NSString*)stringForKey:(NSString*)key {
    
    NSData *data = [self dataForKey:key];
   
	return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
}

- (void)setString:(NSString*)aString forKey:(NSString*)key {
	[self setString:aString forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setString:(NSString*)aString forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
	[self setData:[aString dataUsingEncoding:NSUTF8StringEncoding] forKey:key withTimeoutInterval:timeoutInterval];
}

- (void)setString:(NSString*)aString forKey:(NSString*)key withTimeoutString:(NSString *)timeOutString {
    
    NSTimeInterval timeoutInterval = [self dateStringTimeIntervalSinceNow:timeOutString];
    
	[self setData:[aString dataUsingEncoding:NSUTF8StringEncoding] forKey:key withTimeoutInterval:timeoutInterval];
}
#pragma mark -
#pragma mark 缓存，读取 Image

- (UIImage*)imageForKey:(NSString*)key {
    
    NSString *MD5Key = [self stringToMD5:key];
    
	UIImage* image = nil;
	
	@try {
		image = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePathForKey(_directory, MD5Key)];
	} @catch (NSException* e) {
		
	}
	
	return image;
}

- (void)setImage:(UIImage*)anImage forKey:(NSString*)key {
    
	[self setImage:anImage forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setImage:(UIImage*)anImage forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
    
    
	@try {
        
        dispatch_async(_diskQueue, ^{
            
            [self setData:[NSKeyedArchiver archivedDataWithRootObject:anImage] forKey:key withTimeoutInterval:timeoutInterval];
            
        });
		
        
	} @catch (NSException* e) {
		
	}
}

- (void)setImage:(UIImage*)anImage forKey:(NSString*)key withTimeoutString:(NSString *)timeoutString {
    
	@try {
		NSTimeInterval timeoutInterval = [self dateStringTimeIntervalSinceNow:timeoutString];
        
        dispatch_async(_diskQueue, ^{
            
            [self setData:[NSKeyedArchiver archivedDataWithRootObject:anImage] forKey:key withTimeoutInterval:timeoutInterval];
            
        });
		
        
	} @catch (NSException* e) {
		
	}
}

#pragma mark -
#pragma mark 缓存，读取 List

- (NSData*)plistForKey:(NSString*)key; {
	NSData* plistData = [self dataForKey:key];
	
	return [NSPropertyListSerialization propertyListFromData:plistData
											mutabilityOption:NSPropertyListImmutable
													  format:nil
											errorDescription:nil];
}

- (void)setPlist:(id)plistObject forKey:(NSString*)key; {
	[self setPlist:plistObject forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setPlist:(id)plistObject forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval; {
	
	NSData* plistData = [NSPropertyListSerialization dataFromPropertyList:plistObject
																   format:NSPropertyListBinaryFormat_v1_0
														 errorDescription:NULL];
	
	[self setData:plistData forKey:key withTimeoutInterval:timeoutInterval];
}

- (void)setPlist:(id)plistObject forKey:(NSString*)key withTimeoutString:(NSString *)timeoutString; {
	
    NSTimeInterval timeoutInterval = [self dateStringTimeIntervalSinceNow:timeoutString];
    
	NSData* plistData = [NSPropertyListSerialization dataFromPropertyList:plistObject
																   format:NSPropertyListBinaryFormat_v1_0
														 errorDescription:NULL];
	
	[self setData:plistData forKey:key withTimeoutInterval:timeoutInterval];
}

#pragma mark -
#pragma mark 缓存，读取 Object

- (id<NSCoding>)objectForKey:(NSString*)key {
	if([self hasCacheForKey:key]) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:[self dataForKey:key]];
	} else {
		return nil;
	}
}

- (void)setObject:(id<NSCoding>)anObject forKey:(NSString*)key {
    
	[self setObject:anObject forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setObject:(id<NSCoding>)anObject forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
    
    if (!anObject) {
        return;
    }
    
    dispatch_async(_diskQueue, ^{
        
        [self setData:[NSKeyedArchiver archivedDataWithRootObject:anObject] forKey:key withTimeoutInterval:timeoutInterval];
        
    });
	
}

- (void)setObject:(id<NSCoding>)anObject forKey:(NSString*)key withTimeoutString:(NSString *)timeoutString {
    
    if (!anObject) {
        return;
    }
    
    NSTimeInterval timeoutInterval = [self dateStringTimeIntervalSinceNow:timeoutString];
    
    dispatch_async(_diskQueue, ^{
        
        [self setData:[NSKeyedArchiver archivedDataWithRootObject:anObject] forKey:key withTimeoutInterval:timeoutInterval];
        
    });
	
}

#pragma mark -

- (void)dealloc {
    _cacheInfo = nil;
  
}

@end
