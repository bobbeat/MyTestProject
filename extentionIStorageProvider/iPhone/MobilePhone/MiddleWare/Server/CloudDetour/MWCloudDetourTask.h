//
//  MWCloudDetourTask.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-3-24.
//
//

#import <Foundation/Foundation.h>
#import "plugin-cdm-DownloadTask.h"

@interface MWCloudDetourTask : DownloadTask

@property(nonatomic,copy) NSString *md5;             //MD5值（非空）

@end
