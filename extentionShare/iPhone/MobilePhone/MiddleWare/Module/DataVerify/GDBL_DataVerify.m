//
//  GDBL_DataVerify.m
//  plugin_DataVerify
//
//  Created by Autonavi on 12-5-4.
//  Copyright 2012 autonavi.com. All rights reserved.
//

#import "GDBL_DataVerify.h"

static GDBL_DataVerify* instance = nil;

@implementation GDBL_DataVerify

+(GDBL_DataVerify *)sharedInstance
{
    @synchronized(self)
    {
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

GSTATUS GDBL_CheckData()
{
	DataVerify *dataVerify = [[[DataVerify alloc] init] autorelease];
	DATAVERIFYRESULT nResult = [dataVerify runCheckData];
    
	if (nResult == DATAVERITY_CHECK_SUCCESS)
	{
		return GD_ER_OK;
	}
	else if (nResult == DATAVERITY_UNCOMPRESS_CITYS_ZLIB)
	{
		return GD_ER_DATAUNCOMPRESS;
	}
	else if (nResult == DATAVERITY_BASE_ROAD_DATA_DOWNLAODING)
	{
		return GD_ER_BASELOADDOWNLOADING;
	}
	else if (nResult == DATAVERITY_BASE_ROAD_DATA_NOT_EXIST)
	{
		return GD_ER_BASELOADNOTEXIST;
	}
	else
	{
		return GD_ER_FAILED;
	}

}

GSTATUS GDBL_GetDataZlibs(NSArray **dataZlibs)
{
	DataVerify *dataVerify = [[[DataVerify alloc] init] autorelease];
	if ([dataVerify checkZlibOfCitysExist])
	{
		*dataZlibs = [[dataVerify.zlibCitysList retain] autorelease];
		return GD_ERR_OK;
	}
	else
	{
		*dataZlibs = nil;
		return GD_ERR_FAILED;
	}
}

void GDBL_EntryNaviApp()
{
	DataVerify *dataVerify = [[[DataVerify alloc] init] autorelease];
	[dataVerify handlerEntryNaviApp];
}

//检测基础资源是否存在
+ (BOOL)checkBaseRoadDataExist
{
    BOOL bExist = NO;
    
    DataVerify *dataVerify = [[DataVerify alloc] init];
    bExist = [dataVerify checkBaseRoadDataExist];
    [dataVerify release];
    
    return bExist;
}

-(void)dealloc
{
    
    [super dealloc];
}
@end
