//
//  MWEngineInit.h
//  AutoNavi
//
//  Created by gaozhimin on 14-5-7.
//
//

#import <Foundation/Foundation.h>

/*!
  @brief 引擎初始化相关
  */
@interface MWEngineInit : NSObject

/**
 **********************************************************************
 \brief 启动GDBL服务
 \details 该函数用于启动GDBL服务
 \param[in] Wnd HMI窗口句柄
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \retval	GD_ERR_NO_DATA	无相关数据
 \retval	GD_ERR_INVALID_USER 非法用户
 \remarks
 - 负责启动所有模块
 \since 6.0
 \see GDBL_Cleanup
 **********************************************************************/
+ (GSTATUS)Startup:(Guint32)wnd;

/**
 **********************************************************************
 \brief 卸载GDBL服务
 \details 该函数用于卸载GDBL服务
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_NO_DATA	无相关数据
 \retval	GD_ERR_FAILED 失败
 \remarks
 - 卸载所有模块服务
 \since 6.0
 \see GDBL_Startup
 **********************************************************************/
+ (GSTATUS)Cleanup;

/**
 **********************************************************************
 \brief 设置运行程序的当前路径
 \details 该函数用于设置运行程序的当前路径
 \param[in] pzAppPath 运行程序的当前路径
 \retval	程序当前路径
 \remarks
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)SetAppPath:(NSString *)path;

/**
 **********************************************************************
 \brief 创建视图
 \details 该函数用于创建视图
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_FAILED	失败
 \remarks
 - 在所有的模块启动之后，启动绘图模块GGI，必须在GDBL_Startup之后调用
 \since 6.0
 \see GDBL_DestroyView
 **********************************************************************/
+ (GSTATUS)CreateView;

/**
 **********************************************************************
 \brief 销毁视图
 \details 该函数用于销毁视图
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_FAILED	失败
 \remarks
 - 在所有的模块卸载之前卸载绘图模块GGI，必须在GDBL_Cleanup之前调用
 \since 6.0
 \see GDBL_CreateView
 **********************************************************************/
+ (GSTATUS)DestroyView;

/**
 **********************************************************************
 \brief 基础数据初始化
 \details 该函数用于基础数据初始化
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_FAILED 失败
 \remarks
 GDBL_Startup须保证调用GDBL_UninitData反初始化后调用，该接口必须在引擎未初始化前调用
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)InitData;

/**
 **********************************************************************
 \brief 基础数据反初始化
 \details 该函数用于基础数据反初始化
 \retval	GD_ERR_OK 成功
 \remarks 该接口必须在引擎未初始化前调用
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)UninitData;

/**
 **********************************************************************
 \brief 设置图片大小
 \since 7.0
 \see
 **********************************************************************/
+ (void)SetImagePixs;
@end
