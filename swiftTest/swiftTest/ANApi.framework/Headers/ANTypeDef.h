//
//  ANTypeDef.h
//  ProjectDemoOnlyCode
//
//  Created by yuhang on 14-11-6.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#ifndef ProjectDemoOnlyCode_ANTypeDef_h
#define ProjectDemoOnlyCode_ANTypeDef_h


#ifdef MacroFoFramework
    #import <ANApi/ANTMapShowTypeDef.h>
#else
    #import "ANMapShowTypeDef.h"
#endif

/**
 * 错误码枚举类型
 * 定义错误码枚举值
 */

/**
 * @brief: 错误码枚举类型
 */

typedef NS_ENUM(NSInteger, ANErrStatus)
{
    
    AN_ERR_OK                       =0x00000000,		///< 操作成功
    AN_ERR_INVALID_PARAM			=0x00000001,		///< 参数无效
    AN_ERR_NO_MEMORY				=0x00000002,		///< 内存不足
    AN_ERR_NO_DATA					=0x00000003,		///< 无相关数据
    AN_ERR_VER_INCOMPATIBLE			=0x00000004,		///< 版本不匹配
    AN_ERR_IN_PROCESS				=0x00000005,		///< 正在处理
    AN_ERR_NO_ROUTE					=0x00000006,		///< 没有引导路径
    AN_ERR_RUNNING					=0x00000007,		///< 正在进行，如模拟导航已经在进行，没有结束又开始模拟。
    AN_ERR_DUPLICATE_DATA			=0x00000008,		///< 重复数据
    AN_ERR_NOT_SUPPORT				=0x00000009,		///< 不支持该功能
    AN_ERR_NOT_START				=0x0000000a,		///< 没有调用前序接口
    AN_ERR_NO_GPS					=0x0000000b,		///< 没有GPS信息
    AN_ERR_NO_SPACE					=0x0000000c,		///< 没有足够的空间做添加操作
    AN_ERR_OUT_OF_RANGE				=0x0000000d,		///< 超出范围
    AN_ERR_INVALID_USER				=0x0000000e,		///< 未授权用户
    AN_ERR_OP_CANCELED				=0x0000000f,		///< 操作取消
    AN_ERR_OP_END					=0x00000010,		///< 操作完成
    AN_ERR_TOO_NEAR					=0x00000011,		///< 起点终点距离太近，无法规划路径
    AN_ERR_TOO_FAR					=0x00000012,		///< 距离太长，无法规划路径
    
    AN_ERR_BUS_BOTH_WALK_TOO_FAR	=0x00000013,		///< 起点终点步行距离超过4km
    AN_ERR_BUS_START_WALK_TOO_FAR	=0x00000014,		///< 起点步行距离超过2km
    AN_ERR_BUS_END_WALK_TOO_FAR		=0x00000015,		///< 终点步行距离超过2km
    
    AN_ERR_NETPOI_DECODEFAILED		=0x00000016,		///< XML请求语句构造失败
    AN_ERR_NETPOI_IMPORTFAILED		=0x00000017,		///< 注入数据失败
    AN_ERR_NETPOI_GETDATAFAILED		=0x00000018,		///< 获取数据失败
    AN_ERR_NET_REQUESTFAILED		=0X00000019,		///< 网络请求失败
    AN_ERR_NET_TIMEOUT				=0X0000001a,		///< 网络超时
    AN_ERR_NET_FAILED				=0X0000001b,		///< 网络错误
    AN_ERR_NET_SUGGESTION			=0X0000001c,		///< 无搜索数据，但有推荐数据，可通过GDBL_GetNetCandidateAdareaList获取
    AN_ERR_ROUTE_CALCULATING        =0x0000001d,        ///< 正在路径计算
    AN_ERR_FAILED					=0x0fffffff,		///< 操作失败，暂无具体错误码
};

/**
 *  下载状态
 */
typedef NS_ENUM(NSUInteger, NetDownloadStatus)
{
    NDS_Sucess = 0, ///< 成功
    NDS_Failed = 1, ///< 失败
    NDS_Downloading = 2, ///< 正在下载
};

/**
 *  资源下载block
 *
 *  @param eNetWorkStatus 网路状态
 *  @param fProcess       进度
 */
typedef void  (^ResourceManagerBlock)(NetDownloadStatus eNetWorkStatus, float fProcess);


#endif
