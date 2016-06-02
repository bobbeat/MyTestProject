//
//  POICommon.h
//  AutoNavi
//
//  Created by huang on 13-8-21.
//
//

#import <Foundation/Foundation.h>
#import "POIDefine.h"
@class MWFavoritePoi,MWPoi;
@interface POICommon : NSObject

+(NSArray*)getCollectList:(SEARCH_POI_TYPE)tag;                     //获取收藏
+(BOOL)deleteCollectList:(SEARCH_POI_TYPE)tag;                      //删除收藏
+(BOOL)deleteOneCollect:(SEARCH_POI_TYPE)tag withIndex:(int)index;  //删除一条收藏
+(BOOL)deleteAddress:(BOOL)isHomeAddress;                           //删除家跟公司的地址 1表示公司地址，0表示家地址
+(BOOL)collectFavorite:(BOOL)isHome withPOI:(MWFavoritePoi*)favoritePoi;    //收藏家或公司 0表示收藏家1表示收藏地址
+(NSArray *)getFavorite:(GFAVORITECATEGORY)type;                            //收获收藏数组
+(NSString*)getFavoriteAddress:(MWFavoritePoi*)favoritePoi;                 //获取地址
+(NSString*)getPoiAddress:(MWPoi*)poi;                                      //获取poi的地址
+(NSString*)getHomeAddress;                                                 //获取家的地址
+(NSString*)getCompantAddress;                                              //获取公司地址
+(NSString*)addressNameTransition:(NSString *)address withAdminCode:(int)adminCode;//名字转换成区
//进入POI查看模块
+(UIViewController*)intoPOIViewController:(UIViewController*)viewController withIndex:(int)index withViewFlag:(int)flag withPOIArray:(NSArray*)arr;
+(UIViewController*)intoPOIViewController:(UIViewController*)viewController withIndex:(int)index withViewFlag:(int)flag withPOIArray:(NSArray*)arr withTitle:(NSString*)title;

+(void)showAutoHideAlertView:(NSString*)message;                            //弹出提示框 默认2秒消失
+(void)showAutoHideAlertView:(NSString*)message showTime:(CGFloat)time;     //弹出提示框
+(void)copyWMPoiValutToSubclass:(MWPoi*)poi withPoiSubclass:(id)object;     //将一个MWPoi的数据赋值给子类
+(NSString *)getCityName;                                                   //获取城市名称
+(int)convertToInt:(NSString*)string;                                                   //统计字节数
+ (BOOL)countCharacter:(NSString*)character withLimitCount:(int)count;                  //是否超过限制数 YES表示超过，NO表示没超过
+(NSArray*)rangeArray:(int) index withArray:(NSArray*)array withRangeCount:(int)count;  //截取数组中的数据
+(NSArray*)rangeArray:(int) index withArray:(NSArray*)array;                            //截取数组中的数据 100个
+(NSString *)deleteMoreSpacing:(NSString*)string;                                       //清除多余空格
+(UINavigationBar*)allocNavigationBar:(NSString*)title;
+(UINavigationBar*)allocNavigationBar:(NSString*)title withFrame:(CGRect)naviFrame;
+(UINavigationItem*)allocNavigationItem:(NSString*)title rightTitle:(NSString *)rightTitle;
+(NSString *)netGetKey:(NSString *)key;     //中英文，获取关键字时，开头是否有"e"
+(NSString *)netGetTel:(NSString *)string;  //对网络电话进行特殊处理 获取前两个电话
+(BOOL)isCanVoiceInput;                     //判断当前是不是符合语音输入的条件
+(int)netCarToPOIDistance:(MWPoi*)poi;      //计算两点的距离车位到POI点的距离
+(int)getPoiadCode:(MWPoi *)poi;            //获取POI点的adCode
/**
 *	判断导航终点和家或公司的经纬度是否一样
 *	@param	poi 导航终点的poi
 *	@return	一样返回 YES
 */
+(BOOL)isEqualToCompanyAndHome:(MWPoi *)poi;
@end
