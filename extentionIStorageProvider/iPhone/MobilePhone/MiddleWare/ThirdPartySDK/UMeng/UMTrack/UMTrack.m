//
//  UMTrack.m
//  AutoNavi
//
//  Created by gaozhimin on 14-4-3.
//
//

#import "UMTrack.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

//for idfa
#import <AdSupport/AdSupport.h>

@implementation UMTrack




+ (NSString * )macString{
    
	int 				mib[6];
	size_t 				len;
	char 				*buf;
	unsigned char	 	*ptr;
	struct if_msghdr 	*ifm;
	struct sockaddr_dl 	*sdl;
    
	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;
    
	if ((mib[5] = if_nametoindex("en0")) == 0) {
		printf("Error: if_nametoindex error\n");
		return NULL;
	}
    
	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 1\n");
		return NULL;
	}
    
	if ((buf = malloc(len)) == NULL) {
		printf("Could not allocate memory. error!\n");
		return NULL;
	}
    
	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 2");
		free(buf);
		return NULL;
	}
    
	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
	NSString *macString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	free(buf);
    
	return macString;
}

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

+ (void)UMTrackMethod
{
    NSString * appKey = @"2e69d9d578d8c37942bb0c1dfc2a1201";
    NSString * deviceName = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * mac = [UMTrack macString];
    NSString * idfa = [UMTrack idfaString];
    NSString * idfv = [UMTrack idfvString];
    
    NSString * urlString = [NSString stringWithFormat:@"http://log.umtrack.com/ping/%@/?devicename=%@&mac=%@&idfa=%@&idfv=%@", appKey,deviceName,mac,idfa,idfv];
    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:urlString]] delegate:nil];
}
@end
