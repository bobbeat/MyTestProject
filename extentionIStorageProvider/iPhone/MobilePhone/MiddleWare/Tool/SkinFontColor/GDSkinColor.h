//
//  GDSkinColor.h
//  AutoNavi
//
//  Created by jiangshu.fu on 13-11-21.
//
//

#import <Foundation/Foundation.h>

@interface GDSkinColor : NSObject
{

}

/***
 * @name    单例获取对象
 * @param
 * @author  by bazinga
 ***/
+ (GDSkinColor *) sharedInstance;
#pragma mark ---  根据所选皮肤，获取颜色数据等  ---
/***
 * @name    通过key值获取
 * @param
 * @author  by bazinga
 ***/
- (UIColor *) getColorByKey:(NSString *) key;

/***
 * @name    刷新获取单例对象中的字典属性值
 * @param   plisth文件的路径名称
 * @author  by bazinga
 ***/
- (void) refresh:(NSString *)plistUrl;

/***
 * @name    通过key值获取RGB的数值
 * @param   传入的key值
 * @return  RGB的数组
 * @author  by bazinga
 ***/
- (NSArray *) getArrayByKey:(NSString *) key;

/***
 * @name    获取当前使用皮肤的版本信息
 * @param
 * @author  by bazinga
 ***/
- (NSString *)getSkinVersion;

#pragma  mark -
#pragma  mark ---  辅助函数  ---
/***
 * @name    根据id获取皮肤名称
 * @param   皮肤id
 * @author  by bazinga
 ***/
- (NSString *)getSkinNameByID:(NSString *)skinId;

/***
 * @name    根据皮肤id，获取皮肤的文件夹
 * @param   皮肤id
 * @author  by bazinga
 ***/
- (NSString *)getFolderByID:(int)skinId;

/***
 * @name    根据传入的皮肤字符串，获取对应语言的皮肤名称
 * @param   传入皮肤字符串，使用“,”进行区分
 * @author  by bazinga
 ***/
- (NSString *)getSkinTitle:(NSString *)arrayString;

/***
 * @name    获取plist文件中的版本号
 * @param   plisth文件夹名称
 * @author  by bazinga
 ***/
- (NSString *)getVersionByPath:(NSString *)folder;

@end
