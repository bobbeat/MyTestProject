
//
//  SectionInfo.h
//  AutoNavi
//
//  Created by huang longfeng on 11-12-14.
//  Copyright 2011 autonavi. All rights reserved.
//

#import "SectionInfo.h"
#import "SectionHeaderView.h"
#import "Play.h"


@implementation SectionInfo

@synthesize open, selected,rowHeights, play, headerView,mapv,status,updatedes,nomatchs,nocross;

- init {
	
	self = [super init];
	if (self) {
		rowHeights = [[NSMutableArray alloc] init];
	}
	return self;
}


- (NSUInteger)countOfRowHeights {
	return [rowHeights count];
}

- (void)getRowHeights:(id *)buffer range:(NSRange)inRange {
	[rowHeights getObjects:buffer range:inRange];
}

- (id)objectInRowHeightsAtIndex:(NSUInteger)idx {
	return [rowHeights objectAtIndex:idx];
}

- (void)insertObject:(id)anObject inRowHeightsAtIndex:(NSUInteger)idx {
	[rowHeights insertObject:anObject atIndex:idx];
}

- (void)insertRowHeights:(NSArray *)rowHeightArray atIndexes:(NSIndexSet *)indexes {
	[rowHeights insertObjects:rowHeightArray atIndexes:indexes];
}

- (void)removeObjectFromRowHeightsAtIndex:(NSUInteger)idx {
	[rowHeights removeObjectAtIndex:idx];
}

- (void)removeRowHeightsAtIndexes:(NSIndexSet *)indexes {
	[rowHeights removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInRowHeightsAtIndex:(NSUInteger)idx withObject:(id)anObject {
	[rowHeights replaceObjectAtIndex:idx withObject:anObject];
}

- (void)replaceRowHeightsAtIndexes:(NSIndexSet *)indexes withRowHeights:(NSArray *)rowHeightArray {
	[rowHeights replaceObjectsAtIndexes:indexes withObjects:rowHeightArray];
}


- (void)dealloc {
    CRELEASE(play);
    CRELEASE(rowHeights);
    CRELEASE(headerView);

    CRELEASE(mapv);
    CRELEASE(updatedes);
    CRELEASE(nomatchs);
    CRELEASE(nocross);
	[super dealloc];
}


@end
