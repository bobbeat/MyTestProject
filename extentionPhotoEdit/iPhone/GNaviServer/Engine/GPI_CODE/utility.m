//
//  utility.mm
//  AutoNavi
//
//  Created by gaozhimin on 13-10-14.
//
//

#include "utility.h"
#include <stdlib.h>
#include "stdio.h"
#include <unistd.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <CommonCrypto/CommonDigest.h>


//#define g_data_path (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)?([UIScreen instancesRespondToSelector:@selector(scale)] ? (([[UIScreen mainScreen] scale] == 2.0)?(([[UIScreen mainScreen] currentMode].size.height == 960)?[[NSHomeDirectory() stringByAppendingString:@"/Documents/navi/640x960/"]  UTF8String]:[[NSHomeDirectory() stringByAppendingString:@"/Documents/navi/640x960/"]  UTF8String]):[[NSHomeDirectory() stringByAppendingString:@"/Documents/navi/320x480/"]  UTF8String]) : [[NSHomeDirectory() stringByAppendingString:@"/Documents/navi/320x480/"]  UTF8String]):([UIScreen instancesRespondToSelector:@selector(scale)] ? (([[UIScreen mainScreen] scale] == 2.0)?[[NSHomeDirectory() stringByAppendingString:@"/Documents/navi/1536x2048/"]  UTF8String]:[[NSHomeDirectory() stringByAppendingString:@"/Documents/navi/768x1024/"]  UTF8String]) : [[NSHomeDirectory() stringByAppendingString:@"/Documents/navi/768x1024/"]  UTF8String])

//#define g_data_path (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)?([UIScreen instancesRespondToSelector:@selector(scale)] ? (([[UIScreen mainScreen] scale] == 2.0)?(([[UIScreen mainScreen] currentMode].size.height == 960)?[[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/iPhone4/"]  UTF8String]:[[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/iPhone5/"]  UTF8String]):[[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/iPhone3/"]  UTF8String]) : [[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/iPhone3/"]  UTF8String]):([UIScreen instancesRespondToSelector:@selector(scale)] ? (([[UIScreen mainScreen] scale] == 2.0)?[[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/NewiPad/"]  UTF8String]:[[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/iPad/"]  UTF8String]) : [[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/iPad/"]  UTF8String])

static Gchar path[128] = {0};

NSString *stringFromMD5(NSString *str)
{
    
    if(str == nil || [str length] == 0)
        return nil;
    
    const char *value = [str UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return [outputString autorelease];
}


/**
 **********************************************************************
 \brief 获取设备id
 \details
 \param[out] pn8DeviceID		设备id缓冲区
 \remarks
 - PC上直接固定为12345678
 \since 6.0
 \see
 **********************************************************************/
void GPI_GetDeviceID(Gint8 *pn8DeviceID)
{
 
    if (pn8DeviceID == NULL)
    {
        return;
    }
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
    {
        NSString *temp_uuid = @"";
        if([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
            temp_uuid = [[UIDevice currentDevice].identifierForVendor UUIDString];
        }
        if ([temp_uuid length] == 0)
        {
            temp_uuid = @"01234567890123456789012345678901";
        }
        memset(pn8DeviceID, 0, strlen((const char*)pn8DeviceID));
        const char *uuidstr = [stringFromMD5(temp_uuid) UTF8String];
        if (strlen(uuidstr) >= 32)
        {
            for(int i=0;i<32;i++)
            {
                pn8DeviceID[i] = uuidstr[i];
            }
        }
    }
    else
    {
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
        NSString *temp = @"01234567890123456789012345678901";
        
        const char *mac = [stringFromMD5(temp) UTF8String];
        if (strlen(mac) >= 32)
        {
            for(int i=0;i<32;i++)
            {
                pn8DeviceID[i] = mac[i];
            }
        }
        
        if ((mib[5] = if_nametoindex("en0")) == 0) {
            printf("Error: if_nametoindex error\n");
            return;
        }
        
        if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
            printf("Error: sysctl, take 1\n");
            return;
        }
        
        if ((buf = (char *)malloc(len)) == NULL) {
            printf("Could not allocate memory. error!\n");
            return;
        }
        
        if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
            printf("Error: sysctl, take 2");
            free(buf);
            return;
        }
        
        
        ifm = (struct if_msghdr *)buf;
        sdl = (struct sockaddr_dl *)(ifm + 1);
        ptr = (unsigned char *)LLADDR(sdl);
        NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                               *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
        if (buf)
        {
            free(buf);
            buf = NULL;
        }
        if (!outstring || [outstring length] == 0)
        {
            return;
        }
        memset(pn8DeviceID, 0, strlen((const char*)pn8DeviceID));
        mac = [stringFromMD5(outstring) UTF8String];
        if (strlen(mac) >= 32)
        {
            for(int i=0;i<32;i++)
            {
                pn8DeviceID[i] = mac[i];
            }
        }
        pn8DeviceID[32] = 0;
    }
    
}

/**
 **********************************************************************
 \brief 获取UUID
 \details 获取wince设备的唯一识别码。
 \param[out] pn8UUID ID缓冲区
 \remarks
 \since 6.0
 \see
 **********************************************************************/
void GPI_GetUUID(Gint8 *pn8UUID)
{
    
}

/**
 **********************************************************************
 \brief 获取SD卡ID
 \details 获取SD卡ID信息。
 \param[out] pn8SDCardID SD卡ID号缓冲区
 \remarks
 \since 6.0
 \see
 **********************************************************************/
void GPI_GetSDCardID(Gint8 *pn8SDCardID)
{
	
}

/**
 **********************************************************************
 \brief 设置窗口句柄
 \details 保存窗口句柄到全局变量中。
 \param[in] hWnd	 窗口句柄
 \remarks
 - BL层启动，调用此接口，保存窗口句柄
 \since 6.0
 \see
 **********************************************************************/
void GPI_SetWndHandle(Guint32 hWnd)
{
    
}

/**
 **********************************************************************
 \brief 截屏
 \details 以bmp文件格式保存当前操作界面。
 \param[in] pzFileName 文件名
 \param[in] nWidth 横竖屏的宽度
 \param[in] nHeight 横竖屏的高度
 \retval	Gtrue	保存成功
 \retval	Gfalse	保存失败
 \remarks
 - 1.调用windows平台接口，实现截屏。
 - 2.文件以bmp格式保持在当前目录下的snapshot中，以当前系统时间命名。
 \since 6.0
 \see DIG_SnapshotScreen
 **********************************************************************/
Gbool GPI_SnapScreen(const Gchar *pzFileName)
{
	return Gfalse;
}

/**
 **********************************************************************
 \brief 获取server模块路径
 \details 调用平台相关接口获取运行程序的当前路径。
 \param[in] nSize 缓冲区大小
 \param[out] szAppPath 缓冲区
 \retval	szAppPath server模块路径
 \remarks
 - 调用windows平台接口，实现路径获取。
 \since 6.0
 \see DIG_SnapshotScreen DIG_DumpNMEA LOC_Create
 **********************************************************************/
Gchar* GPI_GetAppPath(Gchar* szAppPath, Gint32 nSize)
{
     return path;
    if (path[0] != 0)
    {
        return path;
    }
    NSMutableString	*tmp;
    tmp= [[NSMutableString alloc] initWithUTF8String:g_data_path];
	if ([tmp hasSuffix:@"/"]==NO)
	{
		[tmp appendString:@"/"];
	}
    memset(path, 0, 128*sizeof(Gchar));
    memcpy(path, [tmp cStringUsingEncoding:NSUTF32StringEncoding], 128*sizeof(Gchar));
    if (szAppPath && nSize > 0)
    {
        memcpy(szAppPath, path, nSize);
    }
    return path;
}


/* below this line DO NOT add anything */
/** \} */
