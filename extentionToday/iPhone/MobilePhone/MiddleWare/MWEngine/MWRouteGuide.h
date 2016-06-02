//
//  MWRouteDetail.h
//  AutoNavi
//
//  Created by gaozhimin on 14-5-7.
//
//

#import <Foundation/Foundation.h>
#import "CustomRoadInfo.h"
/*!
  @brief 路线详情模块
  */

@interface MWRouteGuide : NSObject

/**
 **********************************************************************
 \brief 添加引导路径
 \details 该函数用于添加一条引导路径到引导路径管理表。
 \param[in] hGuideRoute 引导路径句柄。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM 参数无效
 \retval	GD_ERR_FAILED 操作失败
 \remarks
 - 该接口不允许传空句柄
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)AddGuideRoute:(GHGUIDEROUTE) hGuideRoute;

/**
 **********************************************************************
 \brief 移除引导路径
 \details 该函数用于从引导路径管理表中移除一条引导路径。
 \param[in] hGuideRoute 引导路径句柄。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM 参数无效
 \remarks
 - 1.移除操作并不做实际的删除引导路径。
 - 2.正在引导的引导路径不能移除。
 - 3.要移除正在引导的引导路径，必须先停止引导。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)RemoveGuideRoute:(GHGUIDEROUTE)hGuideRoute;

/**
 **********************************************************************
 \brief 删除引导路径
 \details 该函数用于从路径管理列表中删除一条引导路径。
 \param[in] hGuideRoute 引导路径句柄。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM 参数无效
 \retval	GD_ERR_FAILED 操作失败
 \remarks
 - 1.删除该条引导路径，同时从路径管理表中移除。
 - 2.删除后该条引导路径将不可再用。
 - 3.正在引导的引导路径不能删除。
 - 4.要删除正在引导的引导路径，必须先停止引导。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)DelGuideRoute:(GHGUIDEROUTE) hGuideRoute;

/**
 **********************************************************************
 \brief 清空引导路径
 \details 该函数用于清空引导路径管理表。
 \retval	GD_ERR_OK 成功
 \remarks
 - 1.清空操作是对引导路径管理表中的路径做删除操作。
 - 2.如果有引导路径正在引导，则该条引导路径不做删除。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)ClearGuideRoute;

/**
 **********************************************************************
 \brief 获取引导路径列表
 \details 该函数用于获取引导路径列表。
 \param[in] nCount        引导路径句柄缓冲区大小。
 \param[out] phGuideRoute 引导路径句柄缓冲区。
 \param[out] returnCount    实际获取的引导路径条数。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM 参数无效
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetGuideRouteList:(GHGUIDEROUTE *)phGuideRoute count:(Gint32)nCount returnCount:(Gint32 *)returnCount;

/**
 **********************************************************************
 \brief 改变引导路径句柄
 \details 该函数用于改变引导路径句柄
 \param[in] hGuideRoute     路径句柄
 \retval	GD_ERR_OK 成功
 \remarks
 - 1.选择一条引导路径并不代表引导的就是这条路径。
 - 2.选择功能在多条路径时，选择一条后，可以高亮显示，以供查看。
 - 3.该接口不允许传空的句柄
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)ChangeGuideRoute:(GHGUIDEROUTE) hGuideRoute;

/**
 **********************************************************************
 \brief 获取引导路径经过的城市信息
 \details 该函数用于获取引导路径所经过城市的相关信息。
 \param[in] eGuideRouteType        获取路径经过城市的信息类型
 \param[out] pGuideRouteCityInfo   返回的城市信息
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_MEMORY 内存不足
 \retval	GD_ERR_FAILED 操作失败
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetGuideRouteCityInfo:(GGUIDEROUTETYPE)eGuideRouteType citiInfo:(GGUIDEROUTECITYINFO **)pGuideRouteCityInfo;

/**
 **********************************************************************
 \brief 获取引导路径信息
 \details 该函数用于获取引导路径相关信息。
 \param[in] hGuideRoute        引导路径句柄
 \param[out] pGuideRouteInfo    引导路径信息
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM 参数无效
 \retval	GD_ERR_FAILED 操作失败
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetGuideRouteInfo:(GHGUIDEROUTE)hGuideRoute routeInfo:(GGUIDEROUTEINFO *)pGuideRouteInfo;

/**
 **********************************************************************
 \brief 启动引导
 \details 该函数用于启动驾驶引导。
 \param[in] hGuideRoute 引导路径句柄
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE	没有引导路径
 \remarks
 - 1.引导指定的路径，上一个路径引导将被自动停止。
 - 2.启动驾驶引导，生成引导路径信息。
 \since 6.0
 \see GDBL_StartGuidance
 **********************************************************************/
+ (GSTATUS)StartGuide:(GHGUIDEROUTE)hGuideRoute;

/**
 **********************************************************************
 \brief 结束引导
 \details 该函数用于结束驾驶引导。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE	没有引导路径
 \remarks
 - 1.bClearAllRoute：Gfalse 停止路径引导，不删除引导路径。
 - 2.bClearAllRoute：Gtrue  结束路径引导，清空引导路径列表。
 \since 6.0
 \see GDBL_StopGuidance
 **********************************************************************/
+ (GSTATUS)StopGuide:(Gbool)bClearAllRoute;

/**
 **********************************************************************
 \brief 获取机动引导信息
 \details 该函数用于获取机动引导信息。
 \param[out] pManeuverInfo	机动引导信息
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \remarks
 - 机动车信息内存由内部分配，每次调用均将上次内容替换。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetManeuverInfo:(GMANEUVERINFO **)pManeuverInfo;

/**
 **********************************************************************
 \brief 获取高速机动信息
 \details 该函数用于获取高速机动引导信息。
 \param[out] pManeuverInfo	高速机动信息
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \retval	GD_ERR_NO_DATA	  当前无高速机动点信息
 \remarks
 - 1.机动车信息内存由内部分配，每次调用均将上次内容替换。
 - 2.只有当前车位在高速路上时，该接口才返回有数据。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetHighwayManeuverInfo:(GHIGHWAYMANEUVERINFO **)pManeuverInfo;

/**
 **********************************************************************
 \brief 获取多个机动车信息
 \details 该函数用于获取从当前车位处多个机动引导信息。
 \param[in] nNumberOfManeuversToGet	需要获取的机动信息个数
 \param[in] bAutoCheck	            是否自动判定获取的结束条件
 \param[out] pManeuverInfo	        用于获取当前机动点信息
 \param[out] pNumberOfManeuversGet	实际获取的机动信息个数
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE	没有引导路径
 \remarks
 - 1.获取的机动信息从当前车位开始。
 - 2.bAutoCheck为Gfalse时，无附加条件获取nNumberOfManeuversToGet个；
 为Gtrue时，GNaviServer自动判定结束条件，即只获取到距离近的路口机动信息。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetMultiManeuverInfo:(GMANEUVERINFO *)pManeuverInfo getCount:(Guint32)nNumberOfManeuversToGet autoCheck:(Gbool)bAutoCheck
                   realGetCount:(Guint32 *)pNumberOfManeuversGet;

/**
 **********************************************************************
 \brief 关闭放大路口
 \details 该函数用于主动关闭当前放大路口视图。
 \retval	GD_ERR_OK 成功
 \remarks
 - 1.只能关闭当前放大路口视图，下一个放大路口视图仍然会自动出现。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)CloseZoomView;

/**
 **********************************************************************
 \brief 主动播报引导语音
 \details 该函数用于主动触发一次引导语音播报。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE	没有引导路径
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)SpeakNaviSound;

/**
 **********************************************************************
 \brief 重播引导语音
 \details 该函数用于重复最近一次引导语音播报。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE	没有引导路径
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)RepeatNaviSound;

/**
 **********************************************************************
 \brief  获取路径列表
 \details 该函数用于获取引导道路列表。
 \param[in] hGuideRoute	引导路径句柄
 \param[in] bGetAllRoad	是否获取每一条道路
 \param[out] pGuideRoadList	用于返回引导道路列表
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE   没有引导路径
 \retval	GD_ERR_NO_MEMORY  内存不足
 \remarks
 - 引导道路列表内存由内部开辟，每次调用均会替换上次数据。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetGuideRoadList:(GHGUIDEROUTE)hGuideRoute allRoad:(Gbool) bGetAllRoad list:(GGUIDEROADLIST **)ppGuideRoadList;

/**
 **********************************************************************
 \brief  获取机动文本列表
 \details 该函数用于获取引导机动文本列表。
 \param[in]  hGuideRoute	引导路径句柄
 \param[out] pManeuverTextList	返回引导机动文本列表
 \param[out] pbMainRoad 返回Gtrue表示存在主要道路，返回Gfalse表示不存在主要道路
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE   没有引导路径
 \retval	GD_ERR_NO_MEMORY  内存不足
 \remarks
 - 描述文本起止标记定义（起始和终止标记相同且配对出现）
 当前道路名- [c]
 方位      - [a]
 距离值    - [d]
 转向语句  - [t]
 下一道路名- [n]
 如：沿[c]厦禾路[c]向[a]西北[a]方向，行驶...
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetManeuverTextList:(GHGUIDEROUTE) hGuideRoute list:(GMANEUVERTEXTLIST *)pManeuverTextList bMainRoad:(Gbool *)pbMainRoad;

/**
 **********************************************************************
 \brief  获取路径统计信息
 \details 该函数用于获取路径统计信息。
 \param[in] hGuideRoute	引导路径句柄
 \param[in] bWholeJourney Gtrue获取整个行程统计信息，Gfalse获取到下一个中途点
 \param[in] bMultiStat Gtrue获取多条路径统计信息，Gfalse获取当前选中的路径统计信息
 \param[out] ppStatInfoList	路径统计信息
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE   没有引导路径
 \remarks
 - 路径统计信息内存由内部开辟，每次调用均会替换上次数据。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetPathStatisticInfo:(GHGUIDEROUTE) hGuideRoute whole:(Gbool)bWholeJourney multi:(Gbool)bMultiStat list:(GPATHSTATISTICLIST **)ppStatInfoList;

/**
 **********************************************************************
 \brief  路径保存
 \details 该函数用于保存当前的引导路径到文件szFileName中。
 \param[in] hGuideRoute	路径句柄
 \param[in] szFileName	需要保存的文件名
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE   没有引导路径
 \retval	GD_ERR_TOO_NEAR   车位距终点不足20m
 \remarks
 - 文件路径一定要传绝对路径。
 - 起点中间层已经改为以当前车位为起点。
 - 如果车位距中途点不足20m，中间层会自动舍弃中途点
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)SaveGuideRoute:(GHGUIDEROUTE)hGuideRoute name:(NSString *)szFileName;

/**
 **********************************************************************
 \brief  路径加载
 \details 该函数用于加载一条事先存储的引导路径行程点。
 \param[in]  szFileName	  需要加载的文件名
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_FAILED   操作失败
 \remarks
 - 文件名是绝对路径。
 - HMI调用该接口后，中间层不再进行路径演算，因此还需要调用路径演算接口进行进一步算路。
 - HMI调用路径演算可以自由决定算单路径、多路径、或者只返回路径句柄而不进行引导。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)LoadGuideRoute:(NSString *)szFileName;

/**
 **********************************************************************
 \brief 获取引导状态标识
 \details 该函数用于获取当前引导的一些状态信息标识。
 \retval  引导状态标识 (G_GUIDE_FLAGS_CROSSZOOM:路口放大 G_GUIDE_FLAGS_GUIDEPOST:高速路牌 G_GUIDE_FLAGS_SIGNPOST:蓝色看板)
 **********************************************************************/
+ (GGUIDEFLAGS)GetGuideFlags;

/**
 **********************************************************************
 \brief 获取目的地方向
 \details 该函数用于获取当前车位指向目的地的方向角度。
 \param[in] bNextWaypoint	  Gtrue下一个中途点作为计算参考对象，Gfalse最终目的地作为计算参考对象。
 \param[in] pAngle	 当前车位指向目的地的方向角度（正东0，逆时针）。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE   没有引导路径
 \remarks
 \since 6.0
 \see 
 **********************************************************************/
+ (GSTATUS)GetDestinationAngle:(Gbool)bNextWaypoint angle:(Gint32 *)pAngle;

/**
 **********************************************************************
 \brief 获取当前路口放大视图信息
 \details 该函数用于获取当前路口放大视图的信息。
 \param[out] pViewInfo 用于返回当前路口的放大路口信息。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_DATA   无相关数据
 \remarks
 \since 6.0
 \see 
 **********************************************************************/
+ (GSTATUS)GetCurrentZoomViewInfo:(GZOOMVIEWINFO *)pViewInfo;

/**
 **********************************************************************
 \brief 获取引导道路TMC列表
 \details 该函数用于获取引导道路TMC相关信息。
 \param[out] pList 引导道路TMC列表。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_DATA 没有相关数据
 \retval GD_ERR_NO_MEMORY 内存不足
 \retval GD_ERR_NO_ROUTE 没有引导路径
 \remarks
 \since 6.0
 \see 
 **********************************************************************/
+ (GSTATUS)GetGuideRoadTMCList:(GGUIDEROADTMCLIST *)pList;

/**
 **********************************************************************
 \brief 获取最近一个被跳过的途经点索引号
 \details 该函数用于获取最近一个被跳过的途经点索引号
 \param[out]	pnMissedIndex 途经点索引号
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM 参数异常
 \retval	GD_ERR_FAILED        失败
 \remarks
 -用于获取最近一个被跳过的中途点。该接口只有在中途点被绕过后首次调用才返回正确值
 此后再调用该接口返回值都是0。如果HMI有其他地方需要使用到需要做备份。
 \since 7.0
 \see 
 **********************************************************************/	
+ (GSTATUS)GetLastMissedWaypoint:(Gint32 *)pnMissedIndex;

/**
 **********************************************************************
 \brief 获取当前车位对应道路id的道路属性
 \details 该函数用于获取当前车位对应道路id的道路属性
 \param[out] pstRoadAttr     道路属性
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_FAILED 失败
 \remarks
 -1.引导状态的行车线有推荐的状态，如果需要获取车位所在路段的行车线，调用GDMID_GetCarLanes。
 -2.该接口涉及到对文件的访问，考虑到效率问题只有当RoadID改变才需要调用。
 -3.为了提高灵活性，mid不对最近一次获取的道路属性进行备份。
 -4.行车线给出的是数组，需要HMI自行判断有多少个（不为0代表的是有效的行车线）
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)GetCarRoadAttr:(GROADATTR *)pstRoadAttr;

/**
 **********************************************************************
 \brief 多路线概览点击路线切换高亮,点击图标返回事件，交通流信息,参数number大于0表示点击了图标，touchNumber为－1说明未点击到路径，否则返回相应的路径规划原则
 **********************************************************************/
+ (NSString *)guideRouteAndIconTouch:(GMAPVIEWTYPE)mapViewType TouchPoint:(CGPoint)touchPoint Elements:(GEVENTINFO **)elements EventNumber:(int *)number TouchRouteNumber:(int *)touchNumber;

/**
 **********************************************************************
 \brief 获取机动引导信息
 \details 获取机动引导信息
 \param[in]	mainID 0:当前道路名 1:路口距离 2:剩余距离 3:剩余时间 10下路口名称 11：剩余距离 12：出现放大路口时获取距离下一路口的距离
 \retval	相关信息
 **********************************************************************/
+ (NSString *)GetManeuverInfoWithMainID:(int)mainID;

/**
 **********************************************************************
 \brief 单路线－获取路线信息
 \details 单路线－获取路线信息
 \retval	相关信息
 **********************************************************************/
+ (NSString *)GetPathStatisticInfoWithMainID:(int)mainID GuideHandel:(GHGUIDEROUTE)tmpGuideRouteHandle;

/**
 **********************************************************************
 \brief 多路线－获取路线信息 0：收费站 1：总距离 2：红绿灯个数 3：总耗时
 \details 多路线－获取路线信息
 \retval	相关信息
 **********************************************************************/
+ (NSString *)GetPathStatisticInfoWithMainID:(int)mainID index:(int)index;

/**
 **********************************************************************
 \brief 获取主要道路列表
 \details 获取主要道路列表
 \retval	数组 元素为 MainRoadInfo 对象
 **********************************************************************/
+ (NSArray *)GetMainGuideRoadList;


/**
 **********************************************************************
 \brief 获取车位所在道路索引
 \details 获取车位所在道路索引
 \retval	道路索引
 **********************************************************************/
+ (int)GetCarOnRoadIndex;

#pragma mark 获取当前车位的道路id
/**********************************************************************
 * 函数名称: GetRoadIDCarPositon
 * 功能描述: 获取当前车位的道路id
 * 参    数:
 * 返 回 值: 道路id
 * 其它说明:
 **********************************************************************/
+ (int) GetRoadIDCarPositon;

/**********************************************************************
 * 函数名称: MW_GetGuideRoadListInfoWithID
 * 功能描述: 获取路线详情列表
 * 参    数:[IN] ID:信息类别 0-转向ID 1-下路口距离和路口名称 2-转向ID图片 3-下路口距离 4-路口名称 5-路口ID 6-交通信息情况
 * 返 回 值: 返回相对应的数组信息
 * 其它说明:
 **********************************************************************/
+ (NSArray *)GetGuideRoadListInfoWithID:(NSInteger)ID;

#pragma mark 获取转向ID的图片(参数为转向ID)
/**********************************************************************
 * 函数名称: MW_GetTurnIconWithID
 * 功能描述: 获取转向ID的图片(参数为转向ID)
 * 参    数:
 * 返 回 值: 图片
 * 其它说明:
 **********************************************************************/
+ (UIImage *)GetTurnIconWithID:(NSInteger)ID flag:(NSInteger)nflag;

#pragma mark 导航操作(参数mainID:0:开始导航,1:停止导航)
/**********************************************************************
 * 函数名称: GuidanceOperateWithMainID
 * 功能描述: 导航操作(参数mainID:0:开始导航,1:停止导航)
 * 参    数: mainID：0:开始导航,1:停止导航 guideHandle:句柄
 * 返 回 值:
 * 其它说明:
 **********************************************************************/
+ (void)GuidanceOperateWithMainID:(NSInteger)mainID GuideHandle:(GHGUIDEROUTE)guideHandle;

/**
 **********************************************************************
 \brief  获取机动文本列表
 \details 该函数用于获取引导机动文本列表。
 \param[in]  hGuideRoute	引导路径句柄
 \retval	ManeuverInfoList  机动文本列表
 \remarks
 - 描述文本起止标记定义（起始和终止标记相同且配对出现）
 当前道路名- [c]
 方位      - [a]
 距离值    - [d]
 转向语句  - [t]
 下一道路名- [n]
 如：沿[c]厦禾路[c]向[a]西北[a]方向，行驶...
 **********************************************************************/
+(ManeuverInfoList *)GetManeuverTextList:(GHGUIDEROUTE)hGuideRoute;

#pragma mark -
#pragma mark 路径演算失败（无数据），获取缺失城市信息
/**
 **********************************************************************
 \brief 获取路径演算缺失城市列表
 \retval	缺失城市列表 数组里面的对象为MWAreaInfo
 **********************************************************************/
+ (NSArray *)GetRouteErrorInfo;

#pragma mark -
#pragma mark 播报全程概览语音
/**
 **********************************************************************
 \brief 播报全程概览语音
 \retval	播报全程概览语音
 **********************************************************************/
+ (void)PlayWholeRouteSound;

/**
 **********************************************************************
 \brief 返回当前引导句柄
 \retval	返回当前引导句柄
 *****************************/
+ (GHGUIDEROUTE)getCurrentRouteHandler;

/**
 **********************************************************************
 \brief 重新添加remove的路径句柄
 *****************************/
+ (void)readdRouteHandler;

/**
 **********************************************************************
 \brief 清空路径句柄
 *****************************/
+ (void)clearRouteHandler;
@end
