
//
//  play.h
//  AutoNavi
//
//  Created by huang longfeng on 11-12-14.
//  Copyright 2011 autonavi. All rights reserved.
//

#import "Play.h"


@implementation Play


@synthesize zhname,status,updatedes,version,updatetype,all_suburl,all_size,all_unzipsize,all_md5,add_suburl,add_size,add_unzipsize,add_md5,admincode, quotations,size,twname,enname,unzipsize;

- (void)dealloc {
    CRELEASE(twname);
    CRELEASE(enname);
    CRELEASE(zhname);
    CRELEASE(add_suburl);
    CRELEASE(add_md5);
    CRELEASE(all_suburl);
    CRELEASE(all_md5);
    CRELEASE(version);
    CRELEASE(updatedes);
    CRELEASE(quotations);
    
    [super dealloc];
}

@end
