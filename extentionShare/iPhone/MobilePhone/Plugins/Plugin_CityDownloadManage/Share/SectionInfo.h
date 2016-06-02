
//
//  SectionInfo.h
//  AutoNavi
//
//  Created by huang longfeng on 11-12-14.
//  Copyright 2011 autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SectionHeaderView;
@class Play;

@interface SectionInfo : NSObject {
	
}

@property (assign) BOOL open;
@property (assign) BOOL selected;
@property (retain) Play *play;

//add
@property (copy) NSString *mapv;
@property (assign) int status;
@property (retain) NSDictionary *updatedes;
@property (retain) NSArray *nomatchs;
@property (retain) NSArray *nocross;

@property (retain) SectionHeaderView *headerView;
@property (nonatomic,retain,readonly) NSMutableArray *rowHeights;

- (NSUInteger)countOfRowHeights;
- (id)objectInRowHeightsAtIndex:(NSUInteger)idx;
- (void)insertObject:(id)anObject inRowHeightsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRowHeightsAtIndex:(NSUInteger)idx;
- (void)replaceObjectInRowHeightsAtIndex:(NSUInteger)idx withObject:(id)anObject;
- (void)getRowHeights:(id *)buffer range:(NSRange)inRange;
- (void)insertRowHeights:(NSArray *)rowHeightArray atIndexes:(NSIndexSet *)indexes;
- (void)removeRowHeightsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceRowHeightsAtIndexes:(NSIndexSet *)indexes withRowHeights:(NSArray *)rowHeightArray;

@end
