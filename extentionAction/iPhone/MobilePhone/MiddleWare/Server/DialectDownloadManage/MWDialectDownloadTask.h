//
//  MWDialectDownloadTask.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-1-15.
//
//

#import <Foundation/Foundation.h>
#import "plugin-cdm-DownloadTask.h"

@interface MWDialectDownloadTask : DownloadTask
{
    
@protected
    NSString *version;           //版本
    NSString *folderName;        //解压文件名
    NSString *md5;
    int       dialectRoleID;     //角色id
    int       dialectPlaySpeed;  //播报语速
    BOOL      dialectHasRecord;  //是否包含录音
    BOOL      beNeedUpdate;      //是否需要升级
    int       dialectFontType;   //语言类型
}

@property (nonatomic,copy) NSString *version;
@property (nonatomic,copy) NSString *folderName;
@property (nonatomic,copy) NSString *md5;
@property (nonatomic,assign) int     dialectRoleID;
@property (nonatomic,assign) int     dialectPlaySpeed;
@property (nonatomic,assign) BOOL    dialectHasRecord;
@property (nonatomic,assign) BOOL    beNeedUpdate;
@property (nonatomic,assign) int     dialectFontType;

- (void)checkZipFileAndUnZipFile;

@end
