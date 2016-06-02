//
//  MWPoiOperator.h
//  AutoNavi
//
//  Created by yu.liao on 13-7-29.
//
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "MWSearchOption.h"
#import "MWSearchResult.h"
#import "MWFavorite.h"
#import "MWSmartEyes.h"
#import "MWContact.h"
#import "NetKit.h"
#import "MWVoiceResult.h"
#import "RecognizeController.h"

#define MWPOISearchErrorDomain @"MWPOISearchErrorDomain"
#define MWFavoritemErrorDomain @"MWFavoritemErrorDomain"
@protocol MWPoiOperatorDelegate;

@interface MWPoiOperator : NSObject<NetRequestExtDelegate,SpeechServiceDelegate>

/*!
 @brief 实现了MWPoiOperatorDelegate协议的类指针
 */
@property(nonatomic,assign) id<MWPoiOperatorDelegate> poiDelegate;


/*!
 @brief MWPoiOperator类对象的初始化函数
 @param delegate 实现MWPoiOperatorDelegate协议的对象id
 @return MWPoiOperator类对象id
 */
-(id)initWithDelegate:(id<MWPoiOperatorDelegate>)delegate;


#pragma mark - search 接口

/*!
 @brief 将引擎poi和电子眼转换至本地保存  初始化引擎后调用
 */
+ (void)changeEnginePoiAndSafe;
/**
 **********************************************************************
 \brief 中止POI检索
 \details 该接口用于中止POI检索过程。
 \retval	GD_ERR_OK 成功
 \remarks
 - 在POI检索过程中，可以随时调用该接口告知中止检索过程。
 - 该函数返回时POI检索过程并不一定结束，只是进行通知结束。
 \since 6.0
 \see GDBL_StartSearchPOI
 **********************************************************************/
+ (GSTATUS)AbortSearchPOI;

/*!
 @brief  POI 本地查询接口函数，即根据 POI 参数选项进行 POI 查询。
 @param operationOption POI 查询选项
 @return YES:成功启动搜索。搜索成功将回调 -(void)poiLocalSearch:(MWSearchOption*)poiSearchOption Result:(MWSearchResult *)result;
 */
-(BOOL)poiLocalSearchWithOption:(MWSearchOption*)operationOption;

/*!
 @brief  POI 网络查询接口函数，即根据 POI 参数选项进行 POI 查询。
 @param operationOption POI 查询选项
 @return YES:成功启动搜索。回调有两种：
 一种：当前城市直接搜索到 -(void)poiNetSearch:(MWSearchOption*)poiSearchOption Result:(MWSearchResult *)result;
 另一种：转到其他城市 -(void)poiNetToOtherCitySearch:(MWSearchOption*)poiSearchOption Result:(MWAreaList *)result;
 */
-(BOOL)poiNetSearchWithOption:(MWSearchOption*)operationOption;

/*!
 @brief  请求获取当前点最近的POI点 只需传入经纬度
 @param operationOption POI 查询选项
 @return YES:成功启动搜索。搜索成功将回调 -(void)poiNearestSearch:(GCOORD)coord Poi:(MWPoi *)poi;
 */
-(BOOL)poiNearestSearchWithCoord:(GCOORD)coord;

/*!
 @brief  请求获取网络地图中心点信息
 */
-(BOOL)netPoiSearchWithCoord:(GCOORD)coord;

/*!
 @brief  获取周边类别列表接口
 @param  lCategoryID, 类别编码 0为获取所有类别列表
 @param  list, 输出 , 周边类别列表
 @return YES:获取成功。
 */
-(BOOL)getAroundListWith:(int)lCategoryID list:(MWPoiCategoryList **)list;

/*!
 @brief  网络搜索时，根据本地类别id获取类别名称  如：加油站|全部 。
 @param  lCategoryID, 本地类别id
 @return 中文名称
 */
+ (NSString *)getNetCategaryStringWithLocalID:(NSArray *)lCategoryID;

#pragma mark 语音搜索 接口

/*!
 @brief  语音搜索调用
 @param option 语音搜索选项
 @param superView 语音视图的父视图
 @return YES:成功启动搜索。搜索成功将回调 -(void)voiceSearchResult:(MWVoiceResult *)result;
 */

-(BOOL)voiceSearchWith:(MWVoiceOption *)option withSuperView:(UIView*)view;

/*!
 @brief  设置语音框的中心位置，  注意：该方法为类方法。
 @param center 中心点位置
 */
+(void)setRecognizeViewCenter:(CGPoint)center;

/*!
 @brief  开始语音，  注意：该方法为类方法。
 */
+(void)setRecognizeStart;

/*!
 @brief  停止语音，  注意：该方法为类方法。
 */
+(void)setRecognizeStop;

/*!
 @brief  设置语音识别参数，  注意：该方法为类方法。
 @param gaoLon 高德经度
 @param gaoLat 高德纬度
 @param adminCode 行政编码
 */
+(void)setPosition:(int)gaoLon Lat:(int)gaoLat AdminCode:(int)adminCode;


#pragma mark - 收藏 接口

/**
 **********************************************************************
 \brief	 升级收藏夹文件
 \details 升级收藏夹文件
 \retval  GD_OK 成功
 \retval  GD_FAILED 失败
 \remarks
 - 6.1和7.1的收藏夹名称不一样，升级完后需要上层进行删除操作
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)UpgradeFavoriteFiles;

/*!
 @brief  同步收藏夹兴趣点
 @param   eCategory 兴趣点类别GFAVORITECATEGORY，用于标识要上传的收藏夹类别。
 @param   type     请求类型
 @return	成功返回YES 否则返回NO
 */
+ (BOOL)synFavoritePoiWith:(MWFavoriteOption *)option requestType:(RequestType)type delegate:(id<MWPoiOperatorDelegate>)delegate;

/*!
 @brief  取消同步收藏兴趣点
 @param   type     请求类型
 @return	成功返回YES 否则返回NO
 */
+ (BOOL)cancelSynFavoritePoiWith:(RequestType)type;

/*!
 @brief  收藏指定条件兴趣点
 @return 收藏成功返回GD_ERR_OK，重复收藏返回GD_ERR_DUPLICATE_DATA。其他错误码请参见 GSTATUS
 */
+(GSTATUS)collectPoiWith:(GFAVORITECATEGORY)eCategory icon:(GFAVORITEICON)eIconID poi:(GPOI)gpoi;

/*!
 @brief  收藏指定条件兴趣点
 @param favoritePoi 收藏条件   注：（无需设置Date，Time两个参数）
 @return 收藏成功返回GD_ERR_OK，重复收藏返回GD_ERR_DUPLICATE_DATA。其他错误码请参见 GSTATUS
 */
+(GSTATUS)collectPoiWith:(MWFavoritePoi *)favoritePoi;

/*!
 @brief  编辑已收藏的兴趣点
 @param  favoritePoi 编辑后的兴趣点  注：（无需设置Date，Time两个参数）
 @return 编辑成功返回GD_ERR_OK。其他错误码请参见 GSTATUS
 */
+(GSTATUS)editeFavoritePoiWith:(MWFavoritePoi *)favoritePoi;

/*!
 @brief  获取已收藏的兴趣点列表
 @param   eCategory 收藏的兴趣点类别GFAVORITECATEGORY，用于标识要获取的收藏夹类别。
 @param   resultList 输出，用于返回收藏夹兴趣点列表。
 @return 收藏获取列表返回GD_ERR_OK。其他错误码请参见 GSTATUS
 */
+(GSTATUS)getPoiListWith:(GFAVORITECATEGORY)eCategory poiList:(MWFavorite **)resultList;

/*!
 @brief  删除收藏夹poi(参数为索引值)
 @param   eCategory 需要删除的类别 
 @param   index 收藏的兴趣点的索引 (即 MWFavoritePoi 类中的 nIndex)
 @return 删除成功返回GD_ERR_OK。其他错误码请参见 GSTATUS
 */
+(GSTATUS)deleteFavoriteWith:(GFAVORITECATEGORY)eCategory index:(int)index;

/*!
 @brief  清空收藏夹兴趣点
 @param   eCategory poi的类型
 @return 删除成功返回GD_ERR_OK。其他错误码请参见 GSTATUS
 */
+(GSTATUS)clearFavoriteWith:(GFAVORITECATEGORY)eCategory;

/**
 *	判断该点是否收藏
 *
 *	@param	favoritePoi	要判断的点
 *
 *	@return	已收藏返回YES，未收藏返回NO
 */
+ (BOOL)isCollect:(MWPoi *)favoritePoi;

/**
 *	若该点已收藏，则取消收藏该点，若未收藏则收藏该点
 *
 *	@param	favoritePoi	要收藏的点
 *
 *	@return	收藏，取消收藏成功返回YES 否则返回NO
 */
+ (BOOL)reverseCollectPoi:(MWFavoritePoi *)favoritePoi;

/**
 *	MWPoi 结构转 GPoi结构
 *
 *	@param	mwPoi 传入的值 gPoi 转化后的值
 *
 *	@return	转化成功返回YES 否则返回NO
 */
+ (BOOL)MWPoiToGPoi:(MWPoi *)mwPoi GPoi:(GPOI *)gPoi;

#pragma mark - 电子眼 接口

/*!
 @brief  同步电子眼
 @param   option 电子眼同步条件
 @param   type     请求类型
 @param   delegate     委托，同步结果的返回
 @return	成功返回YES 否则返回NO
 */
+ (BOOL)synSmartEyesWith:(MWSmartEyesOption *)option requestType:(RequestType)type delegate:(id<MWPoiOperatorDelegate>)delegate;

/*!
 @brief  取消同步收藏电子眼
 @param   type     请求类型
 @return	成功返回YES 否则返回NO
 */
+ (BOOL)cancelSynSmartEyesWith:(RequestType)type;

/*!
 @brief  收藏电子眼
 @param smartEyesItem 收藏条件   注：（无需设置Date，Time两个参数）
 @return 收藏成功返回GD_ERR_OK，重复收藏返回GD_ERR_DUPLICATE_DATA。其他错误码请参见 GSTATUS
 */
+(GSTATUS)collectSmartEyesWith:(MWSmartEyesItem *)smartEyesItem;

/*!
 @brief  编辑已收藏的电子眼
 @param  smartEyesItem 编辑后的电子眼  注：（无需设置Date，Time两个参数）
 @return 编辑成功返回GD_ERR_OK。其他错误码请参见 GSTATUS
 */
+(GSTATUS)editeSmartEyesWith:(MWSmartEyesItem *)smartEyesItem;

/*!
 @brief  获取已收藏的电子眼列表
 @param   eCategory 收藏的电子眼类别GSAFECATEGORY，用于标识要获取的电子眼类别。
 @param   resultList 输出，用于返回电子眼列表。
 @return  成功返回GD_ERR_OK。其他错误码请参见 GSTATUS
 */
+(GSTATUS)getSmartEyesListWith:(GSAFECATEGORY)eCategory poiList:(MWSmartEyes **)resultList;

/*!
 @brief  删除电子眼(参数为索引值)
 @param   index 收藏的电子眼的索引 (即 待删除数据在数组索引)
 @return 删除成功返回GD_ERR_OK。其他错误码请参见 GSTATUS
 */
+(GSTATUS)deleteSmartEyesWithIndex:(int)index;

/*!
 @brief  清空电子眼
 @param   eCategory 电子眼的类型
 @return 删除成功返回GD_ERR_OK。其他错误码请参见 GSTATUS
 */
+(GSTATUS)clearSmartEyesWith:(GSAFECATEGORY)eCategory;

#pragma mark - 联系人 接口

/*!
 @brief  上传联系人   回调：
 成功 -(void)uploadSuccessWith:(RequestType)type result:(id)result;
 失败 -(void)uploadFailWith:(RequestType)type error:(NSError *)error;
 @param   option 上传联系人时的条件
 @param   type 请求类型
 */
+(void)uploadContactWith:(MWContactOption *)option requestType:(RequestType)type delegate:(id<MWPoiOperatorDelegate>)delegate;

/*!
 @brief  下载联系人
 回调：
 成功 -(void)downloadSuccessWith:(RequestType)type result:(id)result;
 失败 -(void)downloadFailWith:(RequestType)type error:(NSError *)error;
 @param   option 下载联系人时的条件
 @param   type 请求类型
 */
+(void)downloadContactWith:(MWContactOption *)option requestType:(RequestType)type delegate:(id<MWPoiOperatorDelegate>)delegate;

/*!
 @brief  收藏联系人。
 @param recordRef 联系人信息
 @return YES:成功收藏联系人。
 */
+(BOOL)collectContactWith:(ABRecordRef)record;

/*!
 @brief  编辑联系人
 @param  record 编辑后的联系人信息
 @param  index  编辑的联系人在数组中所处的位置
 @return YES:成功编辑联系。
 */
+(BOOL)editContactWith:(ABRecordRef)record index:(int)index;

/*!
 @brief  获取已收藏的联系人列表
 @param   resultList 输出，用于返回联系人列表。
 @return  YES:成功获取联系人列表。
 */
+(BOOL)getContactList:(MWContact **)resultList;

/*!
 @brief  删除联系人(参数为索引值)
 @param   index 收藏的联系人的索引 (即 NameIndex 在数组中的索引)
 @return 删除成功返回YES。
 */
+(BOOL)deleteContactWithIndex:(int)index;

/*!
 @brief  清空联系人列表
 @return 删除成功返回YES。
 */
+(BOOL)clearContact;

/*!
 @brief  检测联系人是否已存在
 @param   name 联系人的姓名
 @return 存在返回YES。
 */
+(BOOL)bCheckContactInListWithName:(NSString *)name;

@end


@protocol MWPoiOperatorDelegate<NSObject>

@optional

/*!
 @brief 通知查询成功或失败的回调函数
 @param poiOperatorOption 发起查询的查询选项
 @param errCode 错误码 \n
 */
-(void)search:(id)poiOperatorOption Error:(NSError *)error;

/*!
 @brief 本地POI查询回调函数
 @param poiSearchOption 发起POI查询的查询选项(具体字段参考MWSearchOption类中的定义)
 @param result 查询结果(具体字段参考MWSearchResult类中的定义)
 */
-(void)poiLocalSearch:(MWSearchOption*)poiSearchOption Result:(MWSearchResult *)result;

/*!
 @brief 网络POI查询回调函数  注：当前城市搜索到的
 @param poiSearchOption 发起POI查询的查询选项(具体字段参考MWSearchOption类中的定义)
 @param result 查询结果(具体字段参考MWSearchResult类中的定义)
 */
-(void)poiNetSearch:(MWSearchOption*)poiSearchOption Result:(MWSearchResult *)result;

/*!
 @brief 网络POI查询回调函数  注：其他城市的搜索结果
 @param poiSearchOption 发起POI查询的查询选项(具体字段参考MWSearchOption类中的定义)
 @param result 查询结果(具体字段参考MWAreaList类中的定义)
 */
-(void)poiNetToOtherCitySearch:(MWSearchOption*)poiSearchOption Result:(MWAreaList *)result;

/*!
 @brief 当前点最近的POI点查询回调函数
 @param coord 发起POI查询的查询选项(具体字段参考GCOORD类中的定义)
 @param result 查询结果(具体字段参考MWPoi类中的定义)
 */
-(void)poiNearestSearch:(GCOORD)coord Poi:(MWPoi *)poi;


/*!
 @brief 语音点查询回调函数
 @param result 查询结果(具体字段参考MWVoiceResult类中的定义)
 */
-(void)voiceSearchResult:(MWVoiceResult *)result;

/*!
 @brief 语音点查询回调函数
 @param result 查询结果(具体字段参考MWVoiceResult类中的定义)
 */
-(void)voiceSearchFail:(int)errorCode;

/*
 同步中的message值
 失败：
 result['Message'] = 'xml data parse fail'          xml数据分解失败
 result['Message'] = 'xml node \'archive\' miss'    xml数据缺少节点archive
 result['Message'] = 'xml node \'context\' miss'    xml数据缺少节点contest
 result['Message'] = 'xml node \'item\' miss'       xml数据缺少节点item
 result['Message'] = 'operator fail'                操作数据失败
 result['Message'] = 'Miss longitude'               缺少经度
 result['Message'] = 'Miss latitude'		   缺少纬度
 result['Message'] == 'Miss item_id'                缺少item_id
 
 成功：
 result['Message'] = '%s item operator success'%upnum  成功上传uonum条记录
 result['Message'] = 'no operator item'                未操作数据，但返回差异数据
 */

/*!
 @brief 同步成功
 @param type 发起请求的类型
 @result 返回结果  具体如下
 请求类型（type）      返回结果（result）
 
 REQ_SYN_DES         MWFavorite类 @see MWFavorite
 REQ_SYN_FAV         MWFavorite类 @see MWFavorite
 REQ_SYN_DSP         MWSmartEyes类 @see MWSmartEyes
 */
-(void)synSuccessWith:(RequestType)type result:(id)result;


/*!
 @brief 同步失败
 @param type 发起请求的类型
 @param error 错误信息。
 
 若error中的code为0，则这类错误不属于系统错误。具体错误信息请看 error 中userinfo字典中message的值
 code        表示
 0          解析错误
 1          账户失效
 */
-(void)synFailWith:(RequestType)type error:(NSError *)error;
@end