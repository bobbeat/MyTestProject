//
//  POIDataCache.m
//  AutoNavi
//
//  Created by huang on 13-8-19.
//
//

#import "POIDataCache.h"

static POIDataCache *instance = nil;
@implementation POIDataCache
@synthesize selectPOIDelegate,flag,layerController;
+(POIDataCache*)sharedInstance
{
    @synchronized(self)
    {
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}
-(void)setFlag:(EXAMINE_POI_TYPE)flag1
{
    flag=flag1;
}
-(void)clearData
{
    self.selectPOIDelegate=nil;
    self.viewControllerLocation=0;
    self.flag=0;
    self.layerController=nil;
}

@end
