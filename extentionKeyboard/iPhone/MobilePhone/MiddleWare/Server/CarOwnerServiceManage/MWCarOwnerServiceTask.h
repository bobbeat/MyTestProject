//
//  MWCarOwnerServiceTask.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-2-26.
//
//

#import <Foundation/Foundation.h>
#import "plugin-cdm-DownloadTask.h"

@interface MWCarOwnerServiceTask : DownloadTask

@property(nonatomic,copy) NSString *serviceID;       //服务id（非空）
@property(nonatomic,copy) NSString *versionCode;     //服务版本（非空）
@property(nonatomic,copy) NSString *serviceName;     //服务名称（非空）
@property(nonatomic,copy) NSString *versionName;     //版本名称（非空）
@property(nonatomic,copy) NSString *vendor;          //服务提供商名称（非空）
@property(nonatomic,copy) NSString *warning;         //版本与现有环境不匹配的警告（可空）
@property(nonatomic,copy) NSString *updatedesc;      //更新说明（可空）
@property(nonatomic,copy) NSString *releasetime;     //更新时间
@property(nonatomic,assign) int form;                //插件存在形式（非空0:SD 卡文件形式;1:安装形式;2:内置;3:宿主 apk 的 assets 中 4: 宿主 apk 的 assets 中的离线包;(web 形式) 5:宿主私有目录中的离 线包;(web 形式) 6:宿主 apk 的 assets 中 的在线包;(web 形式)7:宿主私有目录中的在线包(web 形式)）
@property(nonatomic,assign) int serviceStatus;              //服务状态（非空 0-已安装 1-未安装; 2-未安装,不适合安装; 3-有更新; 4-有更新,不适合安装; 5-强制更新6-禁用;7-非法）
@property(nonatomic,copy) NSString *iconUrl;         //小图标url（非空）
@property(nonatomic,assign) int vip;                 //vip服务下载地址（可空 1-推荐）
@property(nonatomic,copy) NSString *md5;             //MD5值（非空）
@property(nonatomic,copy) NSString *servicedesc;     //服务概述
@property(nonatomic,copy) NSString *folderName;     //解压文件名
@property(nonatomic,copy) NSString *installTime;     //安装时间
@property(nonatomic,copy) NSString *description;     //服务介绍      （服务详情）
@property(nonatomic,copy) NSString *usedesc;         //用户使用须知   （服务详情）

//检测是否有压缩文件未解压
- (void)checkZipFileAndUnZipFile;

@end
