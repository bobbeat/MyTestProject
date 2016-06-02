//
//  POIDesParking.h
//  AutoNavi
//
//  Created by weisheng on 14-4-4.
//
//

#import <Foundation/Foundation.h>
#import "MWPoiOperator.h"
@interface POIDesParking : NSObject
{  
}
+(POIDesParking*)sharedInstance;
/*
 *目的地停车场推送
 *@param 目的地关键字
 */
-(void)PDK_DestinationParking:(NSString *)keyWorld;
@end
