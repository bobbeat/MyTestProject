
//
//  Quotation.h
//  AutoNavi
//
//  Created by huang longfeng on 11-12-14.
//  Copyright 2011 autonavi. All rights reserved.
//
#import "Quotation.h"


@implementation Quotation

@synthesize zhname,version,updatetype,all_suburl,all_size,all_unzipsize,all_md5,add_suburl,add_size,add_unzipsize,add_md5, admincode,checked,twname,enname;
+ (Quotation*) quotation
{
	return [[[self alloc] init] autorelease];
}
- (void)dealloc {
    CRELEASE(twname);
    CRELEASE(enname);
    CRELEASE(zhname);
    CRELEASE(add_suburl);
    CRELEASE(add_md5);
    CRELEASE(all_suburl);
    CRELEASE(all_md5);
    CRELEASE(version);
    
    [super dealloc];
}

@end
