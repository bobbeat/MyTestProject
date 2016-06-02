//
//  UIDevice+Category.m
//  AutoNavi
//
//  Created by yu.liao on 13-9-5.
//
//

#import "UIDevice+Category.h"
#import "NSString+Category.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <AdSupport/AdSupport.h>
#import "KeychainItemWrapper.h"

#include <sys/param.h>
#include <sys/mount.h>

#include <sys/types.h>
#include <sys/sysctl.h>
#import"sys/utsname.h"

#include <mach/mach.h>
#include <mach/mach_host.h>

@implementation UIDevice (Category)
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
- (NSString *) macaddress{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return [NSString stringWithFormat:@"01234567890123456789012345678901"];
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return [NSString stringWithFormat:@"01234567890123456789012345678901"];
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return [NSString stringWithFormat:@"01234567890123456789012345678901"];
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return [NSString stringWithFormat:@"01234567890123456789012345678901"];
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    if (!outstring ||[outstring length] == 0)
    {
        return [NSString stringWithFormat:@"01234567890123456789012345678901"];
    }
    return outstring;
}


- (NSString *) uniqueDeviceIdentifier
{
    NSString *macaddress = [[UIDevice currentDevice] macaddress];
    NSString *uniqueIdentifier = [macaddress stringFromMD5];
    NSLog(@"%@",uniqueIdentifier);
    return uniqueIdentifier;
}

/*!
  @brief 当前设备分辨率类型
  */
+ (UIDeviceResolution) currentResolution
{
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)])
        {
            CGSize result = {0};
            result.width = SCREENWIDTH;
            result.height = SCREENHEIGHT;
            result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
            if (result.height <= 480.0f)
                return UIDevice_iPhoneStandardRes;
            else if (result.height <= 960.0f)
                return UIDevice_iPhoneHiRes;
            else if (result.height <= 1136.0f)
                return UIDevice_iPhoneTallerHiRes;
            return ((result.height > 1334.0f) ? UIDevice_iPhone6PlusHiRes : UIDevice_iPhone6HiRes);
            
            
        }
        else
            return UIDevice_iPhoneStandardRes;
    }
    else
        return (([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) ? UIDevice_iPadHiRes : UIDevice_iPadStandardRes);
}

/*!
  @brief 当前设备分辨率名称（iPhone3,iPhone4,iPhone5,iPad,NewPad）
  */
+ (NSString *) currentResolutionName
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)])
        {
            CGSize result = {0};
            result.width = SCREENWIDTH;
            result.height = SCREENHEIGHT;
            result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
            if (result.height <= 480.0f)
                return @"iPhone3";
            else if (result.height <= 960.0f)
                return @"iPhone4";
            else if (result.height <= 1136.0f)
                return @"iPhone5";
            return (result.height > 1334.0f ? @"iPhone6Plus" : @"iPhone6");
        }
        else
            return @"iPhone3";
    }
    else
        return (([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) ? @"NewPad" : @"iPad");
}

/*!
  @brief 当前设备分辨率字符串（640x960）
  */
+ (NSString *) getResolutionString
{
    NSString *string = [[[NSString alloc] init] autorelease];

    CGSize result = {0};
    result.width = SCREENWIDTH;
    result.height = SCREENHEIGHT;
    if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)])
    {
        
        result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
        
        return [string stringByAppendingFormat:@"%dx%d",(int)result.width,(int)result.height];
    }
    else
        return [string stringByAppendingFormat:@"%dx%d",(int)result.width,(int)result.height];
    
}

/*!
  @brief    ios 6及以下 ： 返回 mac  ios 7及以上返回 idfa
  @param
  @author   by bazinga
  */
+ (NSString *) ADDeviceIdentifier
{
    NSString *returnString = @"";
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
    {
        returnString = [self idfaString];
    }
    else
    {
        returnString = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    }
    return returnString;
}

/*!
  @brief    供应商 ID : ios 6及以下 ： 返回 mac  ios 7及以上返回 idfv
  @param
  @author   by bazinga
  */
+ (NSString *) vendorDeviceIdentifier
{
    NSString *returnString = @"";
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
    {
         KeychainItemWrapper *keychainItem = [[[KeychainItemWrapper alloc] initWithIdentifier:@"IDFA" accessGroup:@"com.autonavi.navigation"] autorelease];
        returnString = [keychainItem objectForKey:(id)kSecValueData];
        if (returnString.length == 0)
        {
            returnString = [self idfvString];
            if (returnString)
            {
                [keychainItem setObject:returnString forKey:(id)kSecValueData];
            }
        }
    }
    else
    {
        returnString = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    }
    return returnString;
}

/*!
  @brief    获取程序 idfa
  @param
  @author   by bazinga
  */
+ (NSString *)idfaString {
    
    NSBundle *adSupportBundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/AdSupport.framework"];
    [adSupportBundle load];
    
    if (adSupportBundle == nil) {
        return @"";
    }
    else{
        
        Class asIdentifierMClass = NSClassFromString(@"ASIdentifierManager");
        
        if(asIdentifierMClass == nil){
            return @"";
        }
        else{
            
            //for no arc
            ASIdentifierManager *asIM = [[[asIdentifierMClass alloc] init] autorelease];
            //for arc
            //            ASIdentifierManager *asIM = [[asIdentifierMClass alloc] init];
            
            if (asIM == nil) {
                return @"";
            }
            else{
                
                if(asIM.advertisingTrackingEnabled){
                    return [asIM.advertisingIdentifier UUIDString];
                }
                else{
                    return [asIM.advertisingIdentifier UUIDString];
                }
            }
        }
    }
}

+ (NSString *)idfvString
{
    if([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    
    return @"";
}

//获取剩余空间
+(float)getCurDiskSpaceInBytes
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    struct statfs tStats;
    statfs([[paths lastObject] cString], &tStats);
    float totalSpace = (float)(tStats.f_bsize * tStats.f_bfree);
    if (totalSpace > 206715200) {
        totalSpace = totalSpace - 206715200;
    }
    return totalSpace;
}


#pragma mark 获取udid
+(NSString *)GetVendorID
{
    NSString *str =nil;
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_6_0) {
        KeychainItemWrapper *keychainItem = [[[KeychainItemWrapper alloc] initWithIdentifier:@"UUID" accessGroup:@"com.autonavi.navigation"] autorelease];
        
        NSString *uuidStr = [keychainItem objectForKey:(id)kSecValueData];
        if (uuidStr.length == 0) {
            
            NSString *myUUIDStr = nil;
            if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)] ) {
                myUUIDStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            }
            if (myUUIDStr) {
                [keychainItem setObject:myUUIDStr forKey:(id)kSecValueData];
            }
            
            str = myUUIDStr;
        }
        else{
            str = [keychainItem objectForKey:(id)kSecValueData];
        }
    }
    else{

        str = [NSString stringWithFormat:@"%@0123",[[UIDevice currentDevice] uniqueDeviceIdentifier]];
    }
    if (str == nil)
    {
        str = @"012345678901234567890123456789012345";
    }
    NSLog(@"======vendorid:%@",str);
    return str;
}


+(NSString*)getDeviceAndOSInfo;
{
    //here use sys/utsname.h
    struct utsname systemInfo;
    uname(&systemInfo);
    //get the device model and the system version,iPad1,1
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (BOOL)isJail
{
    BOOL jailbroken = 0;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        jailbroken = 1;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = 1;
    }
    int res = system("ls");
    if (res == 0)
        jailbroken = 1;
    return jailbroken;
}


+(int)getDeviceOrientation
{
    int value = 0;
    UIInterfaceOrientation ori = [[UIApplication sharedApplication] statusBarOrientation];
    if (ori == UIInterfaceOrientationPortrait || ori == UIInterfaceOrientationPortraitUpsideDown)
    {
        value = 0;
    }
    else  if (ori == UIInterfaceOrientationLandscapeLeft || ori == UIInterfaceOrientationLandscapeRight)
    {
        value = 1;
    }
    return value;
}

@end
