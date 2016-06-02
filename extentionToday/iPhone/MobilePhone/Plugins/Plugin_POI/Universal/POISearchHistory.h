//
//  POISearchHistory.h
//  AutoNavi
//
//  Created by huang on 13-8-16.
//
//

#import <Foundation/Foundation.h>

@interface POISearchHistory : NSObject
{
    NSMutableArray *_historyArray;
}
-(NSMutableArray*)restoreHistory;
-(void)removeAllHistory;
-(BOOL)storeHistory;
-(BOOL)addHistory:(NSString*)text;
+(void)removeAllHistory;
@end
