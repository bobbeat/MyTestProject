//
//  POIDefine.h
//  AutoNavi
//
//  Created by huang on 13-8-15.
//
//

#ifndef AutoNavi_POIDefine_h
#define AutoNavi_POIDefine_h



#endif
typedef enum
{
    SEARCH_FAVORITES=0,                     //收藏
    SEARCH_RECENTDESTINATIONS,              //历史目地的
    SEARCH_CAMERA,                          //摄像头
    SEARCH_ADDRESSBOOK,                      //通讯录
    SEARCH_HISTORYLINE,                     //历史路线
}SEARCH_POI_TYPE;

typedef enum
{
    SETTING_INTO=0,//个人中心
    COMMON_INTO,
    WHERE_INTO
    
}COLLECT_INTO_TYPE;

#import "GDAlertView.h"
#import "POICommon.h"
#import "GDTableViewCell.h"

#define  CLOG_DEALLOC(x) NSLog(@"%@ is dealloc",NSStringFromClass(x.class))
#define  POIANERRORFEEDBACKKEY   @"POIAnErrorFeedBackKey"
typedef void (^ TableCellTouchBlock)(id object);
typedef NSString *(^ GetTableDetailTilteBlock)(int type);

#define CALLOC_WITH_NAME(className,object)  Class class=NSClassFromString(className);if (class) { object= [[class alloc] init];}else{NSString *string=[NSString stringWithFormat:@"%@ 该类名不存在",className];NSLog(@"%@",string); }/*NSAssert(!class,string);*/

#define CIPAD_GAP 35    //iphone 跟ipad 距左边的差距
#define CTABLEVIEW_SPACE (isPad?CIPAD_GAP:0)
#define CTABLE_VIEW_STYLE (1?UITableViewStyleGrouped:UITableViewStylePlain)

#define CCOMMON_TABLE_X (CTABLE_VIEW_STYLE==UITableViewStyleGrouped?0:10)
#define CCOMMON_SPACE (isPad?(CTABLE_VIEW_STYLE==UITableViewStyleGrouped?45:10):10)


#define CCTABLE_VIEW_HEAD_HEIGHT 7
#define CCTABLE_VIEW_SPACE_HEIGHT 12




#define CCOMMON_APP_WIDTH (Interface_Flag==0?APPWIDTH:APPHEIGHT)
#define CCOMMON_APP_HEIGHT (Interface_Flag==0?APPHEIGHT:APPWIDTH)
#define CCOMMON_CONTENT_HEIGHT (Interface_Flag==0?CONTENTHEIGHT_V:CONTENTHEIGHT_H)

#define SearchBar_Weight 10 //搜索框接屏幕左边的距离

//flag 8 表示 去哪里，9，周边，附近，10家的设置，添加途径点，11常用，数据管理 12常用添加
typedef enum
{
    INTO_TYPE_NORMAL=8,                         //普通进入
    INTO_TYPE_NEARBY,                           //周边附近进入
    INTO_TYPE_FAV,                              //兴趣点进入（常用）
    INTO_TYPE_CUSTOM_TITLE ,                    //自定义title
    
    INTO_TYPE_ADD_COMMON,                       //添加常用
    INTO_TYPE_SELECT_POINT,                     //地图选点
    INTO_TYPE_ADD_THROUGH_POINT_FROM_FAV,       //收藏夹添加途经点
    INTO_TYPE_ADD_THROUGH_POINT_FROM_HISTORY,   //历史目的地添加途经点
    
    INTO_TYPE_ADD_THROUGH_POINT,                //检索的时候添加途经点
    INTO_TYPE_ADD_THROUGH_START,                //检索的时候添加起点
    INTO_TYPE_ADD_THROUGH_END,                  //检索的时候添加终点
    INTO_TYPE_ADD_FAV,                          //检索得时候 家或公司设置
    
    INTO_TYPE_ADD_THROUGH_POINT_FROM_MAPMARK,   //地图选点添加途经点
    INFO_TYPE_ADD_THROUGH_POINT_FROM_START,     //地图选点添加起点
    INFO_TYPE_ADD_THROUGH_POINT_FROM_END,       //地图选点添加终点
    INTO_TYPE_ADD_FAVANDCHOOSEMAP,              //地图选点得时候家或公司设置

    INTO_TYPE_ADD_FeedBack_Point,               //地图选点POI报错添加点
   
}INTO_POI_VIEW_TYPE;




