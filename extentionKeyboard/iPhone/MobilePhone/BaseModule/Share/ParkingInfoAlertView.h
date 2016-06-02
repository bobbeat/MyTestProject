//
//  ParkingInfoAlertView.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-4-10.
//
//

#import <Foundation/Foundation.h>

typedef void (^SetDesToHandle)();
typedef void (^ViewMapInfoHandle)();

@class POIDesParkObj;

@interface ParkingInfoAlertView : NSObject

+ (void) showParkingInfo:(POIDesParkObj *)infoObject
               desHandle:(SetDesToHandle)desToHandle
              viewHandle:(ViewMapInfoHandle)viewHandle;

+ (void) hiddenParkingInfo;

@end
