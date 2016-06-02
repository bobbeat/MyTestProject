//
//  POISearchHistory.m
//  AutoNavi
//
//  Created by huang on 13-8-16.
//
//

#import "POISearchHistory.h"
#import "POIDefine.h"

@implementation POISearchHistory
-(id)init
{
    self=[super init];
    if (self) {
        _historyArray=[[NSMutableArray alloc] init];
    }
    return self;
}
-(void)dealloc
{
    CRELEASE(_historyArray);
    CLOG_DEALLOC(self);
    [super dealloc];
}
-(void)removeAllHistory
{
    [_historyArray removeAllObjects];
    [self storeHistory];
}

+(void)removeAllHistory
{
    POISearchHistory *searchHisory = [[self alloc] init] ;
    [searchHisory removeAllHistory];
    [searchHisory release];
}

-(NSMutableArray*)restoreHistory
{
	NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *filename = [Path stringByAppendingPathComponent:POI_SEARCH_FILE_NAME];
    NSArray *array=nil;
	array = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
    if (array!=nil&&[array isKindOfClass:[NSArray class]]) {
        [_historyArray removeAllObjects];
        [_historyArray addObjectsFromArray:array];
    }
	
	return _historyArray;
}
-(BOOL)storeHistory
{
	NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *filename = [Path stringByAppendingPathComponent:POI_SEARCH_FILE_NAME];
	if (![NSKeyedArchiver archiveRootObject:_historyArray toFile:filename]){
		
		return NO;
	}
	else {
		
		return YES;
	}
}
-(BOOL)addHistory:(NSString*)text
{
	if (text.length<1) {
        return NO;
    }
    [self restoreHistory];
	int repeatFlag = 0;
	int repeatIndex = 0;
	for (int i = 0;i < [_historyArray count];i++) {
		NSString *name = [_historyArray objectAtIndex:i];
		if ([text caseInsensitiveCompare:name] == NSOrderedSame) {
			repeatIndex = i;
			repeatFlag = 1;
			break;
		}
	}
	if (repeatFlag == 0) {
		if ([_historyArray count] == 30) {
			[_historyArray removeLastObject];
		}
		
		[_historyArray insertObject:text atIndex:0];
		
		
	}
	else {
		[_historyArray removeObjectAtIndex:repeatIndex];
		[_historyArray insertObject:text atIndex:0];
		
	}
    [self storeHistory];
    return YES;
	
	
}
@end
