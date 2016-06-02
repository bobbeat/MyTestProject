//
//  GDTableCellArray.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-5-21.
//
//

#import "GDTableCellArray.h"

@implementation GDTableCellArray

- (void) dealloc
{
    CRELEASE(_stringHeader);
    CRELEASE(_arrayCellData);
    CRELEASE(_stringFoot);
    CLOG_DEALLOC(self);
    [super dealloc];
}

- (id) initWithHeader:(NSString *) stringHeader;
{
    self = [super init];
    if(self)
    {
        self.stringHeader = stringHeader;
        self.stringFoot = nil;
        _arrayCellData = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return  self;
}

- (id) initWithHeader:(NSString *)stringHeader withFoot:(NSString *)stringFoot
{
    self = [self initWithHeader:stringHeader];
    if(self)
    {
        self.stringFoot = stringFoot;
    }
    return self;
}

@end
