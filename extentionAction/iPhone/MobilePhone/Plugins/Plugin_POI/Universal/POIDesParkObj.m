//
//  POIDesParkObj.m
//  AutoNavi
//
//  Created by weisheng on 14-4-8.
//
//

#import "POIDesParkObj.h"

@implementation POIDesParkObj
@synthesize charge;
@synthesize prc_t_d_e;
@synthesize time;
@synthesize prc_c_d_e;
@synthesize prc_c_d_f;
@synthesize prc_c_n_e;
@synthesize prc_c_wd;
@synthesize prc_t_n_e;
@synthesize bParkDetail;


-(void)dealloc
{
    self.charge=nil;
    self.time=nil;
    [super dealloc];
}
@end
