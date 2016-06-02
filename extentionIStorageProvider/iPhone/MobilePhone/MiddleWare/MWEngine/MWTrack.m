//
//  MWTrack.m
//  AutoNavi
//
//  Created by gaozhimin on 14-5-7.
//
//

#import "MWTrack.h"

@implementation MWTrack

/**
 **********************************************************************
 \brief 获取轨迹列表信息
 \details 该函数用于获取轨迹列表信息
 \param[out]	ppTrackList 用于返回系统轨迹列表
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_NO_DATA 无相关数据
 **********************************************************************/
+(GSTATUS)GetTrackList:(GTRACKINFOLIST **)ppTrackList
{
    return GDBL_GetTrackList(ppTrackList);
}

/**
 **********************************************************************
 \brief 删除一定个数轨迹
 \details 该函数用于删除一定个数的轨迹信息
 \param[in]	pIndex 轨迹索引数组
 \param[in]	count 索引个数
 只要成功删除一条，该接口均返回GD_ERR_OK。
 **********************************************************************/
+(GSTATUS)DelTrack:(Gint32 *)pIndex count:(Gint32)count
{
    return GDBL_DelTrack(pIndex, count);
}

/**
 **********************************************************************
 \brief 清空轨迹文件
 \details 该函数用于清空轨迹文件
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_FAILED 操作失败
 \retval GD_ERR_NO_DATA 无相关数据
 **********************************************************************/
+(GSTATUS)ClearTrack
{
    return GDBL_ClearTrack();
}

/**
 **********************************************************************
 \brief 编辑轨迹文件
 \details 该函数用于清空轨迹文件
 \param[in]	pTrackInfo 标识编辑后的轨迹信息
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_FAILED 操作失败
 \retval GD_ERR_INVALID_PARAM 参数无效
 \remarks
 1、	对于轨迹信息的编辑，nIndex字段必须不能编辑，该值只用作内部处理。
 2、	名称字段无需带路径和扩展名。
 \since 7.0
 \see
 **********************************************************************/
+(GSTATUS)EditTrack:(GTRACKINFO *)pTrackInfo
{
    return GDBL_EditTrack(pTrackInfo);
}

/**
 **********************************************************************
 \brief 加载指定轨迹
 \details 该函数用于加载指定轨迹
 \param[in]	szFileName 轨迹文件名
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_FAILED 操作失败
 \retval GD_ERR_INVALID_PARAM 参数无效
 \remarks
 \since 7.0
 \see
 **********************************************************************/
+(GSTATUS)LoadTrack:(Gchar *)szFileName
{
    return GDBL_LoadTrack(szFileName);
}

/**
 **********************************************************************
 \brief 卸载指定的轨迹
 \details 该函数用于卸载指定的轨迹
 \param[in]	szFileName 轨迹文件名
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_FAILED 操作失败
 \retval GD_ERR_INVALID_PARAM 参数无效
 \remarks
 \since 7.0
 \see
 **********************************************************************/
+(GSTATUS)UnloadTrack:(Gchar *)szFileName
{
    return GDBL_UnloadTrack(szFileName);
}

/**
 **********************************************************************
 \brief 开始回放指定轨迹
 \details 该函数用于开始回放指定轨迹
 \param[in]	szFileName 轨迹文件名
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_FAILED 操作失败
 \retval GD_ERR_INVALID_PARAM 参数无效
 \remarks
 \since 7.0
 \see
 **********************************************************************/
+(GSTATUS)StartTrackReplay:(Gchar *)szFileName
{
    return GDBL_StartTrackReplay(szFileName);
}

/**
 **********************************************************************
 \brief 暂停轨迹回放
 \details 该函数用于暂停轨迹回放
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_NOT_START 没有调用前序接口
 \remarks
 \since 7.0
 \see
 **********************************************************************/
+(GSTATUS)PauseTrackReplay
{
    return GDBL_PauseTrackReplay();
}

/**
 **********************************************************************
 \brief 继续轨迹回放
 \details 该函数用于继续轨迹回放
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_NOT_START 没有调用前序接口
 \remarks
 \since 7.0
 \see
 **********************************************************************/
+(GSTATUS)ContinueTrackReplay
{
    return GDBL_ContinueTrackReplay();
}

/**
 **********************************************************************
 \brief 停止轨迹回放
 \details 该函数用于停止轨迹回放
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_FAILED 操作失败
 \retval GD_ERR_NOT_START 没有调用前序接口
 \remarks
 \since 7.0
 \see
 **********************************************************************/
+(GSTATUS)StopTrackReplay
{
    return GDBL_StopTrackReplay();
}

/**
 **********************************************************************
 \brief 判断指定的轨迹文件是否已加载
 \details 该函数用于判断指定的轨迹文件是否已加载
 \param[in]	szFileName 轨迹文件名
 \param[in]	bLoaded Gtrue-已加载  Gfalse-未加载
 \retval	GD_ERR_OK 成功
 \retval	异常返回 GSTATUS 对应出错码
 \remarks
 **********************************************************************/
+ (GSTATUS)TrackIsLoaded:(Gchar *)szFileName bLoad:(Gbool *)bLoaded
{
    return GDBL_TrackIsLoaded(szFileName, bLoaded);
}

/**
 **********************************************************************
 \brief 设置轨迹线信息
 \details 该函数用于设置轨迹线信息
 \param[in]	pTrackLineInfo 轨迹线信息对象
 \param[in]	nNum 轨迹线信息对象个数
 \param[in]	stRect 最小矩形框
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_FAILED 操作失败
 \retval GD_ERR_NOT_START 没有调用前序接口
 \remarks
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)SetTrackLineInfo:(GTRACKLINEINFO *)pTrackLineInfo nNUm:(Gint32)nNum rect:(GRECT)stRect
{
    return GDBL_SetTrackLineInfo(pTrackLineInfo, nNum, &stRect);
}

/**
 **********************************************************************
 \brief     升级轨迹文件
 \details   升级轨迹文件
 \param[in] szFileName 轨迹文件名称
 \retval    GD_OK 成功
 \retval    GD_FAILED 失败
 \remarks
 -接口一次只支持升级一个轨迹文件，如果有多个轨迹文件需要HMI调用多次
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)UpgradeTrackFile:(Gchar*) szFileName
{
    return GDBL_UpgradeTrackFile(szFileName);
}
#pragma mark -
#pragma mark -以下接口包含逻辑

/**********************************************************************
 * 函数名称: MW_GetTrackList
 * 功能描述: 获取轨迹列表
 * 参    数:
 * 返 回 值: 轨迹列表
 * 其它说明:
 **********************************************************************/
+ (NSArray *)GetTrackList {
	
	GSTATUS res;
    GTRACKINFOLIST *ppTrackList = NULL;
	res = GDBL_GetTrackList(&ppTrackList);
	if (0!=res)
	{
		return nil;
	}
	NSMutableArray *trackList = [[NSMutableArray alloc] init];
	for (int i=0; i<ppTrackList->nNumberOfTrack; i++)
	{
        NSString *nameStr = GcharToNSString(ppTrackList->pTrackInfo[i].szTrackName);
        if (nameStr != nil)
        {
            [trackList addObject:nameStr];
        }
	}
	
	return [trackList autorelease];
}

#pragma mark 轨迹操作（设置，删除，清空，轨迹回放，加载轨迹，编辑轨迹，停止轨迹回放，卸载轨迹，判断是否加载）
/**********************************************************************
 * 函数名称: TrackOperationWithID
 * 功能描述: 轨迹操作（设置，删除，清空，轨迹回放，加载轨迹，编辑轨迹，停止轨迹回放，卸载轨迹，判断是否加载）
 * 参    数:[IN]ID:操作类型 index:轨迹索引
 * 返 回 值: 成功返回YES,失败返回NO
 * 其它说明:
 **********************************************************************/
+ (id)TrackOperationWithID:(NSInteger)ID Index:(NSInteger)index {
	
	static int trackIndex = 0;
	static int trackReplay = 0;
    static int trackReplaying = 0;
	GSTATUS res;
    GTRACKINFOLIST *ppTrackList = NULL;
	res = GDBL_GetTrackList(&ppTrackList);
	switch (ID)
	{
		case 0://设置
		{
			trackIndex = index;
			return [NSNumber numberWithBool:YES];
		}
			break;
			
		case 1://删除
		{
			Gint32 nIndex = ppTrackList->pTrackInfo[trackIndex].nIndex;
			GSTATUS res = GDBL_DelTrack(&nIndex, 1);
			if (GD_ERR_OK==res)
			{
				return [NSNumber numberWithBool:YES];
			}
		}
			break;
			
		case 2://清空
		{
			GSTATUS res;
			res = GDBL_ClearTrack();
			if (GD_ERR_OK==res)
			{
				return [NSNumber numberWithBool:YES];
			}
		}
			break;
			
		case 3://轨迹回放
		{
            if ([[ANParamValue sharedInstance] isPath]) {
                [MWRouteGuide GuidanceOperateWithMainID:1 GuideHandle:NULL];
            }
			trackReplay = 0;
            
			res = GDBL_LoadTrack(ppTrackList->pTrackInfo[trackIndex].szTrackName);
            
			if (GD_ERR_OK==res)
			{
                
				res = GDBL_StartTrackReplay(ppTrackList->pTrackInfo[trackIndex].szTrackName);
                
				if (GD_ERR_OK==res)
				{
                    trackReplaying = 1;
					[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_INSIMULATION object:
					 [NSNumber numberWithInt:2]];
					return [NSNumber numberWithBool:YES];
				}
			}
		}
			break;
			
		case 4://加载轨迹
		{
            
			res = GDBL_LoadTrack(ppTrackList->pTrackInfo[index].szTrackName);
			if (GD_ERR_OK==res)
			{
                
                ppTrackList->pTrackInfo[trackIndex].bLoaded = Gtrue;
				return [NSNumber numberWithBool:YES];
			}
		}
			break;
			
		case 5://编辑
		{
			return [NSNumber numberWithInt:trackIndex];
		}
			break;
			
		case 6://停止轨迹回放
		{
			
            if (trackReplaying == 1)
            {
                trackReplaying = 0;
                trackReplay = 0;
                
                res = GDBL_StopTrackReplay();
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_EXSIMULATION object:nil];
                if (GD_ERR_OK==res)
                {
                    
                    GDBL_UnloadTrack(ppTrackList->pTrackInfo[trackIndex].szTrackName);
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_STOPGUIDANCE object:nil];
                    return [NSNumber numberWithBool:YES];
				}
			}
        }
			
			break;
			
		case 7:
		{
			trackReplay++;
			if (trackReplay%2)
			{
				res = GDBL_PauseTrackReplay();
				if (GD_ERR_OK==res)
				{
					return [NSNumber numberWithBool:YES];
				}
			}
			else
			{
				res = GDBL_ContinueTrackReplay();
				if (GD_ERR_OK==res)
				{
					return [NSNumber numberWithBool:YES];
				}
			}
		}
			break;
			
		case 8:
		{
			
		}
			break;
			
		case 9://卸载轨迹
		{
            
			GSTATUS status = GDBL_UnloadTrack(ppTrackList->pTrackInfo[trackIndex].szTrackName);
            if (status == GD_ERR_OK)
            {
                ppTrackList->pTrackInfo[trackIndex].bLoaded = Gfalse;
                return [NSNumber numberWithBool:YES];
            }
            
		}
			break;
            
		case 10://判断是否加载
        {
            Gbool tmpBool = Gfalse;
            [MWTrack TrackIsLoaded:ppTrackList->pTrackInfo[trackIndex].szTrackName bLoad:&tmpBool];
            if(tmpBool == Gfalse)
            {
                return [NSNumber numberWithBool:NO];
            }
            else
            {
                return [NSNumber numberWithBool:YES];
            }
        }
            break;
		default:
			break;
	}
	
	return [NSNumber numberWithBool:NO];
}

@end
