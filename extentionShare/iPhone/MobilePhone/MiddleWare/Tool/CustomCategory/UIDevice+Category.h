//
//  UIDevice+Category.h
//  AutoNavi
//
//  Created by yu.liao on 13-9-5.
//
//

#import <UIKit/UIKit.h>

enum {
    
    
    UIDevice_iPhoneStandardRes      = 1,  // iPhone 1,3,3GS 标准分辨率(320x480)
    
    UIDevice_iPhoneHiRes            = 2,  // iPhone 4,4S    高清分辨率(640x960)
    
    UIDevice_iPhoneTallerHiRes      = 3,  // iPhone 5,5S    高清分辨率(640x1136)
    
    UIDevice_iPadStandardRes        = 4,  // iPad 1,2,mini  标准分辨率(1024x768)
    
    UIDevice_iPadHiRes              = 5,  // NewPad         高清分辨率(2048x1536)
    
    UIDevice_iPhone6HiRes           = 6,  //iphone 6        高清分辨率(750x1334)
    
    UIDevice_iPhone6PlusHiRes       = 7,  //iphone 6 plus   高清分辨率(1242x2208)
    
}; typedef NSUInteger UIDeviceResolution;

@interface UIDevice (Category)

- (NSString *) uniqueDeviceIdentifier;

/*!
  @brief 当前设备分辨率类型
  */
+ (UIDeviceResolution) currentResolution;

/*!
  @brief 当前设备分辨率名称（iPhone3,iPhone4,iPhone5,iPad,NewPad）
  */
+ (NSString *) currentResolutionName;

/*!
  @brief 当前设备分辨率字符串（640x960）
  */
+ (NSString *) getResolutionString;

/*!
  @brief    ios 6及以下 ： 返回 mac  ios 7及以上返回 idfa
  @param
  @author   by bazinga
  */
+ (NSString *) ADDeviceIdentifier;

/*!
  @brief    供应商 ID : ios 6及以下 ： 返回 mac  ios 7及以上返回 idfv
  @param
  @author   by bazinga
  */
+ (NSString *) vendorDeviceIdentifier;


//获取剩余空间
+(float)getCurDiskSpaceInBytes;

#pragma mark 获取udid
+(NSString *)GetVendorID;

+(NSString*)getDeviceAndOSInfo;

/*!
  @brief    是否越狱
  @param
  @author   by bazinga
  */
+ (BOOL)isJail;

/*!
  @brief 获取设备的方向，0:竖屏 1:横屏
  */
+(int)getDeviceOrientation;

@end
