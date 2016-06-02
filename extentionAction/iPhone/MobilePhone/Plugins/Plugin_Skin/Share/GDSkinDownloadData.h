//
//  GDSkinDownloadData.h
//  AutoNavi
//
//  Created by jiangshu-fu on 13-12-19.
//
//

#import <Foundation/Foundation.h>
@class MWSkinAndCarListRequest;

#define  SKIN_NO_DOWNLOAD_STATUS 0
#define  SKIN_DOWNLOAD_STATUS    1
#define  SKIN_UPDATE_STATUS      2

@protocol GDSkinDownloadDataDelegate <NSObject>

/***
 * @name    刷新皮肤的plist文件数据——并且更改界面
 * @param
 * @author  by bazinga
 ***/
- (void) refreshPlistData;

/***
 * @name    根据url去刷新皮肤下载界面的皮肤图片
 * @param   url —— 已下载完成的图片url值   image --
 * @author  by bazinga
 ***/
- (void) refreshImageByUrl:(NSString *)url withImage:(UIImage *)image;


@end

@interface GDSkinDownloadData : NSObject<NetReqToViewCtrDelegate>
{
    MWSkinAndCarListRequest* _skinAndCarRequest;
}

@property (nonatomic, retain) NSMutableArray *arrayData;
@property (nonatomic, assign) id<GDSkinDownloadDataDelegate> delegate;

#pragma  mark -
#pragma mark ---  向服务器请求数据  ---
/***
 * @name    服务器请求数据
 * @param
 * @author  by bazinga
 ***/
- (void) requestPlistData;

#pragma  mark -
#pragma  mark ---  数组数据设置读取修改  ---
/***
 * @name    获取皮肤的数据（皮肤界面的数据的数组）
 * @param
 * @author  by bazinga
 ***/
- (NSArray *) getSkinData;

/***
 * @name    获取皮肤的数据（皮肤界面的数据的数组）
 * @param
 * @author  by bazinga
 ***/
- (void) setSkinData:(NSArray *)setArray;

/***
 * @name    在皮肤的数组对象中，添加数据
 * @param
 * @author  by bazinga
 ***/
- (void) addData:(NSMutableDictionary *)dict;

/***
 * @name    更具key值，来替换数组对象中的字典数据
 * @param   key - 索引值   dict - 字典数据
 * @author  by bazinga
 ***/
- (void) replaceDataByKey:(NSString *)key withData:(NSMutableDictionary *)dict;



@end
