//
//  MWEngineInit.m
//  AutoNavi
//
//  Created by gaozhimin on 14-5-7.
//
//

#import "MWEngineInit.h"

@implementation MWEngineInit

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
+ (GSTATUS)Startup:(Guint32)wnd
{
    return GDBL_Startup(wnd);
}

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
+ (GSTATUS)Cleanup
{
    return GDBL_Cleanup();
}

/**
 **********************************************************************
 \brief 设置运行程序的当前路径
 \details 该函数用于设置运行程序的当前路径
 \param[in] pzAppPath 缓冲区
 \param[in] nSize 缓冲区大小
 \retval	程序当前路径
 \remarks
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)SetAppPath:(NSString *)path
{
    Gchar gpath[260] = {0};
    Gchar *temp = NSStringToGchar(path);
    memcpy(gpath, temp, sizeof(Gchar)*260);
    return GDBL_SetAppPath(gpath,260);
}

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
+ (GSTATUS)CreateView
{
    return GDBL_CreateView();
}

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
+ (GSTATUS)DestroyView
{
    return GDBL_DestroyView();
}

/**
 **********************************************************************
 \brief 基础数据初始化
 \details 该函数用于基础数据初始化
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_FAILED 失败
 \remarks
 GDBL_Startup须保证调用GDBL_UninitData反初始化，该接口必须在引擎未初始化前
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)InitData
{
    return GDBL_InitData(NSStringToGchar(Map_Data_Path));
}

/**
 **********************************************************************
 \brief 基础数据反初始化
 \details 该函数用于基础数据反初始化
 \retval	GD_ERR_OK 成功
 \remarks 该接口必须在引擎未初始化前
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)UninitData
{
    return GDBL_UninitData();
}

/**
 **********************************************************************
 \brief 设置图片大小
 \since 7.0
 \see
 **********************************************************************/
+ (void)SetImagePixs
{
    [MWEngineInit SetImagePixsWithType:eGIMAGETYPE_3DMASK];
    [MWEngineInit SetImagePixsWithType:eGIMAGETYPE_LOGO];
}
/* 分辨率对应图标关系
屏幕分辨率   logo图标尺寸    2.5D图标尺寸
通用        32              32
960*640     32              32
1136*640    32              32
1334*750    32              32
2208*1242   48              64
1024*768    32              32
2048*1536   48              64
 */
+ (void)SetImagePixsWithType:(enumGMAPIMAGETYPE)type
{
    GIMAGEPIX *ppOutImagePixs = NULL;
    Gint32 pnNum = 0;
    GSTATUS res = GDBL_GetImagePixs(type, &ppOutImagePixs, &pnNum);
    if (res == GD_ERR_OK)
    {
        int value = 0;
        if (pnNum == 1)
        {
            value = 0;
            if (type == eGIMAGETYPE_3DMASK)
            {
                GDBL_SetParam(G_MAP_25DMARK_SIZE, &value);
            }
            else if (type == eGIMAGETYPE_LOGO)
            {
                GDBL_SetParam(G_MAP_ICON_SIZE, &value);
            }
        }
        else if (pnNum > 1)
        {
            int icon_size = 32;  // 默认选择32图标大小
            CGSize size = {0};
            size.width = SCREENWIDTH;
            size.height = SCREENHEIGHT;
            CGFloat scale_screen = [UIScreen mainScreen].scale;
            if (size.width * scale_screen >= 1536 && size.height * scale_screen >= 2048)  //按照函数上面的分辨率修改对应尺寸
            {
                if (type == eGIMAGETYPE_LOGO)
                {
                    icon_size = 48;
                }
                else
                {
                    icon_size = 64;
                }
            }
            else if (size.width * scale_screen == 1242 && size.height * scale_screen == 2208)  //按照函数上面的分辨率修改对应尺寸
            {
                if (type == eGIMAGETYPE_LOGO)
                {
                    icon_size = 48;
                }
                else
                {
                    icon_size = 64;
                }
            }
            for (int i = 0; i < pnNum; i++)
            {
                if (icon_size == ppOutImagePixs[i].u16ImageH)
                {
                    value = i;
                    break;
                }
            }
            if (type == eGIMAGETYPE_3DMASK)
            {
                GDBL_SetParam(G_MAP_25DMARK_SIZE, &value);
            }
            else if (type == eGIMAGETYPE_LOGO)
            {
                GDBL_SetParam(G_MAP_ICON_SIZE, &value);
            }
        }
    }
}

@end
