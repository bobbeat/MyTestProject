//
//  SkinDefine.h
//  AutoNavi
//
//  Created by jiangshu.fu on 13-11-22.
//
//

#import "MWDefine.h"


#ifndef AutoNavi_SKINDEFINE_H
#define AutoNavi_SKINDEFINE_H

#pragma mark ---  皮肤配置文件plist（skinConfig） 的key值定义  ---

#define CONFIG_SKIN_ID                      @"id"
#define CONFIG_SKIN_NAME                    @"name"
#define CONFIG_SKIN_FLODER                  @"folder"
#define CONFIG_SKIN_PREIMAGE                @"preImage"
#define CONFIG_SKIN_DOWNLOADURL             @"downloadUrl"
#define CONFIG_SKIN_MD5                     @"MD5"
#define CONFIG_SKIN_SIZE                    @"size"
#define CONFIG_SKIN_HASDOWNLOAD             @"hasDownload"
#define CONFIG_SKIN_VERSION                 @"version"
#define CONFIG_SKIN_VERSIONTOFITPROGRAM     @"versionToFitProgram"
#define CONFIG_SKIN_SMALLPIC                @"smallPicUrl"             //小图URL
#define CONFIG_SKIN_PORTRAIT_PIC            @"portraitLargePicUrl"          //大图竖屏URL
#define CONFIG_SKIN_LANDSCAPE_PIC           @"landscapeLargePicUrl"          //大图横屏URL


#define skinConfigDownload @"download_source/skin/?"

typedef enum SKIN_STATUS_TYPE {
    SKIN_STATUS_NO = 0,
    SKIN_STATUS_COMPLETE = 1,
    SKIN_STATUS_UPDATE = 2,
}SKIN_STATUS_TYPE;

//皮肤所属文件夹
//#define SKIN_PINK_FOLDER                    @"com.skin.pink"
//#define SKIN_NEW_YEAR_FOLDER                @"com.skin.horseNewYear"
//
//
////不同类型主题的设置东西
//#define SKIN_SMALL_DEFAUL_PIC               @"skinDefault.png"
//#define SKIN_SMALL_PINK_PIC                 @"skinPink.png"
//#define SKIN_SMALL_NEW_YEAR                 @"skinNewYear.png"
//
#define SKIN_DEFAULT_ID       @"0"
//#define SKIN_PINK_ID          @"1"
//#define SKIN_NEW_YEAR_ID      @"2"
//
//#define SKIN_DEFAULT_VERSION  @"1.0"
//#define SKIN_PINK_VERSION     @"1.1"
//#define SKIN_NEW_YEAR_VESION  @"1.0"


//皮肤下载的类型
//下载的类型，方言下载类型也用这些枚举了，修改请注意！！！
typedef enum SKIN_DOWNLOAD_TYPE {
    DOWNLOAD_NO = 0,
    DOWNLOAD_COMPLETE = 4,
    DOWNLOAD_UPDATE = 5,
    DOWNLOAD_WAITING = 6,
    DOWNLOAD_ING = 1,
    DOWNLOAD_UNZIP = 2,
    DOWNLOAD_STOP  = 3,
}SKIN_DOWNLOAD_TYPE;



#pragma mark -
#pragma mark ---  换肤使用的颜色定义（获取方式不同- -）  ---

#define TEXTCOLOR        GETSKINCOLOR(@"TextLabelColor")//通用Text颜色
#define TEXTDETAILCOLOR  GETSKINCOLOR(@"DetailTextLabelColor1")//通用DetailText颜色
#define TITLECOLOR      GETSKINCOLOR(@"DetailTextLabelColor2")//headView的颜色
#define FOOTERCOLOR     GETSKINCOLOR(@"FooterViewColor") //footer颜色
#define SWITCHCOLOR     GETSKINCOLOR(@"SwitchColor")//switch颜色
#define TOOLBARBUTTONCOLOR    GETSKINCOLOR(@"ToolbarButtonColor")
#define TOOLBARBUTTONDISABLEDCOLOR GETSKINCOLOR(@"ToolBarSliderColor")//GETSKINCOLOR(@"ToolbarButtonDisabledColor")
#define USERPOICOLOR   GETSKINCOLOR(@"UserPOIColor")   //本地搜索颜色
#define STARTDOWNLOADCOLOR GETSKINCOLOR(@"StartDownloadColor")
#define STOPDOWNLOADCOLOR GETSKINCOLOR(@"StopDownloadColor")
#define DOWNLOADINGCOLOR GETSKINCOLOR(@"DownloadingColor")
#define NAVIGATIONBARTITLECOLOR  GETSKINCOLOR(@"NavigationBarTitleColor")//导航条标题颜色
#define DATADOWNLOADBUTTONTEXTCOLOR  GETSKINCOLOR(@"CityDownloadButtonTextColor")  //数据下载管理界面按钮字体颜色
#define DATADOWNLOADBUTTONALLCLICKTEXTCOLOR  GETSKINCOLOR(@"CityDownloadButtonAllClickTextColor")  //数据下载管理界面全部按钮点击字体颜色
#define DATADOWNLOADBUTTONALLCLICKTEXTGRAYCOLOR  GETSKINCOLOR(@"CityDownloadButtonTextGrayColor")

#pragma mark ---  地图界面字体颜色  ---
#define CONTROL_BACKGROUND_COLOR    @"ShareControlBackgroundColor"  //背景灰化颜色



#define MAIN_DAY_BOTTOMMENU_COLOR   @"MainBottomMenuDayColor"       //白天主界面底栏字体颜色
#define MAIN_NIGHT_BOTTOMMENU_COLOR @"MainBottomMenuNightColor"     //黑夜主界面底栏字体颜色

#define MAIN_MODELABEL_COLOR        @"MainModelLabelColor"          //主地图模式选择字体颜色

#define MAIN_DAY_TOPSEARCH_COLOR    @"MainTopSearchDayColor"        //白天模式下，主界面顶部搜索灰化颜色
#define MAIN_NIGHT_TOPSEARCH_COLOR  @"MainTopSearchNightColor"      //黑夜模式下，主界面顶部搜索颜色

#define LEFTROAD_LABEL_COLOR        @"ShareLeftLabelColor"          //下一个路口距离字体颜色

#define MAIN_NIGHT_METER_COLOR      @"MainMeterNightColor"          //黑夜模式下，比例尺数字颜色
#define MAIN_DAY_METER_COLOR        @"MainMeterDayColor"            //白天模式下，比例尺数字颜色

#define MAIN_NIGHT_NORMAL_COLOR     @"MainNormalButtonNightColor"    //黑夜模式下，取消周边，当前道路名，等按钮字体颜色
#define MAIN_DAY_NORMAL_COLOR       @"MainNormalButtonDayColor"      //白天模式下，取消周边，当前道路名，等按钮字体颜色

#define MAIN_CANCELDETOUR_DAY_POR_COLOR     @"MainCancelDetourDayPorColor"         //白天 竖屏取消周边
#define MAIN_CANCELDETOUR_DAY_LAND_COLOR    @"MainCancelDetourDayLandColor"       //白天横屏取消周边
#define MAIN_CANCELDETOUR_NIGHT_POR_COLOR   @"MainCancelDetourNightPorColor"     //黑夜 竖屏取消周边
#define MAIN_CANCELDETOUR_NIGHT_LAND_COLOR  @"MainCancelDetourNightLandColor"   //黑夜 横屏取消周边

#define SHARE_BUTTON_TITLE_DAY_COLOR        @"ShareButtonTitleDayColor"         //按钮文字 白天，颜色
#define SHARE_BUTTON_TITLE_DAY_DIS_COLOR    @"ShareButtonTitleDayDisColor"      //按钮文字，白点，灰化颜色
#define SHARE_BUTTON_TITLE_NIGHT_COLOR      @"ShareButtonTitleNightColor"       //按钮文字，黑夜，颜色
#define SHARE_BUTTON_TITLE_NIGHT_DIS_COLOR  @"ShareButtonTitleNightDisColor"    //按钮文字，黑夜，灰化颜色

#define MAIN_QCSY_LABEL_COLOR       @"MainQCSYLabelColor"            //主地图全程剩余颜色
#define MAIN_LABEL_CLEARBACK_COLOR  @"MainLabelClearBackColor"        //主地图全程剩余label的透明背景颜色

#define MAIN_ZOOMDIS_COLOR          @"MainZoomDisColor"              //放大路口的下一道路距离显示颜色
#define MAIN_NEXTLROAD_COLOR        @"MainNextRoadColor"             //下一个道路名字体颜色
#define MAIN_ROADINFO_COLOR         @"MainRoadInfoColor"             //导航时，底栏路线信息有颜色字体
#define MAIN_SIM_CLEAR_COLOR        @"MainSimClearBackColor"         //模拟导航底部整体view背景色
#define MAIN_SIM_SELECT_COLOR       @"MainSimSelectColor"            //模拟导航选择速度字的颜色
#define MAIN_MENU_CLICK_COLOR       @"MainMenuClickColor"            //可点击菜单栏中字的颜色
#define MAIN_MENU_NOCLICK_COLOR     @"MainMenuNoClickColor"          //不可点击菜单栏中文字颜色（灰化）

#define MAIN_USER_TIP_COLOR         @"MainUserTipsColor"              //用户特别提示文字颜色
#define HUD_DIVING_LINE_COLOR       @"HUDDivingColor"                 //HUD界面的分割线的背景色
#define HUD_BOTTOM_LABEL_COLOR      @"HUDBottomColor"                 //HUD界面底栏字体的颜色
#define HUD_BOTTOM_LABEL_BACK_COLOR @"HUDBottomLabelBackColor"        //HUD界面底栏label背景颜色
#define HUD_BLACK_BACKGROUND_COLOR  @"HUDBlackBackgroundColor"        //HUD界面黑色背景
#define HUD_CLEAR_BACKGROUND_COLOR  @"HUDClearBackgroundColor"        //HUD界面透明背景色
#define HUD_LABEL_CLEAR_BACK_COLOR  @"HUDLabelClearBackColor"         //HUD显示字的背景透明色
#define HUD_LABEL_TEXT_COLOR        @"HUDLabelTextColor"              //HUD显示字的颜色
#define ROUTE_WAY_CALC_COLOR        @"RouteWayCalcColor"              //添加途经点，计算按钮字体颜色
#define ROUTE_NO_ADDRESS_COLOR      @"RouteNoAddressInfoColor"        //添加途经点，POI点无数据（灰色）
#define ROUTE_ADDRESS_COLOR         @"RouteAddressInfoColor"          //添加途经点，POI点有数据（黑色）
#define ROUTE_CUSTOMER_LABEL_COLOR  @"RoutePlaneLabelCustomerColor"   //路线规划(详情)，底栏特殊数字显示颜色
#define ROUTE_LABEL_COLOR           @"RoutePlaneLabelColor"           //路线规划（详情），底栏正常数字显示颜色
#define ROUTE_TOLL_COLOR            @"RoutePlaneTollColor"            //路线规划(详情)，收费站颜色
#define ROUTE_BLACK_TOP_BAR_COLOR   @"RouteBlackTopBarColor"          ////路线避让的半透明黑色栏(顶部)
#define ROUTE_BLACK_BAR_COLOR       @"RouteBlackBarColor"             //路线避让的半透明黑色栏(底部)
#define ROUTE_BEFORE_COLOR          @"RouteBeforeColor"               //路线避让避让前按钮颜色
#define ROUTE_AFTER_COLOR           @"RouteAfterColor"                //路线避让避让后按钮颜色
#define ROUTE_DETOUR_CUSTOMER_COLOR @"RouteDetourCustomerColor"       //路线避让上方的黄色
#define ROUTE_PLANE_TOPMENU_COLOR   @"RoutePlaneTopMenuColor"         //路线规划顶部四个按钮的字体颜色
#define ROUTE_PLANE_BEGIN_NAVI_COLOR @"RoutePlaneBeginNaviColor"      //路线规划界面导航按钮文字的颜色

#define ROUTE_POINT_BUTTON_COLOR    @"RoutePointButtonColor"          //节点按钮字体颜色
#define ROUTE_POINT_BUTTON_CLICK_COLOR @"RoutePointButtonClickColor"  //节点按钮点击字体颜色

#define WARNING_TITLE_COLOR         @"WarningTitleColor"              //特别提示标题颜色

#define ROUTE_CALC_TEXT_COLOR       @"RouteCalcTextColor"             //计算路线的文字颜色

#define ROUTE_DETAIL_BUTTON_COLOR   @"RouteDetailCellButtonColor"     //路线详情 ，避让按钮文字颜色
#define ROUTE_DETAIL_ROADINFO_COLOR @"RouteDetailRoadInfo"            //路線詳情，路線信息詳情顏色

#define ACCOUNT_BUTTON_TITLE_COLOR  @"AccountButtonTitleColor"        //账户按钮颜色()
#define ACCOUNT_REGIST_COLOR        @"AccountRegistColor"             //账户注册红色按钮
#define ACCOUNT_LINE_COLOR          @"AccountLineColor"               //账户分割线
#define ACCOUNT_PICKVIEW_BACK_COLOR @"AccountPickViewBackColor"       //账户选择框的背景颜色

#define TRACK_INFOCELL_BACK_COLOR   @"TrackInfoCellBackColor"         //轨迹查看的cell的背景颜色
#define TRACK_MANAGE_LABEL_COLOR    @"TrackManageLabelColor"          //轨迹查看label颜色
#define STORE_LABEL_COLOR           @"StoreLabelColor"                //商店label的title颜色
#define BOTTOM_HEADER_BACK_COLOR    @"BottomHeaderBackColor"          //bottommenubar顶栏可滑动的颜色条
#define MAIN_TIPS_SETDES_COLOR      @"MainTipsSetdesColor"            //主界面 tips 设置终点颜色
#define ROUTE_DETAIL_BACKCOLOR      @"RouteDetailBackColor"           //路线详情界面背景色
#define ACCOUNT_GET_VERIFICATION    @"AccountGetVerification"         //获取验证码
#define MENU_LIST_BACK              @"MenuListBack"                   //导航的菜单背景颜色
#define WARNING_TIP_COLOR           @"WarningTipColor"                //敬告界面tip的颜色
#define WARNING_PRESS_COLOR         @"WarningPressColor"              //敬告界面超链接颜色

#define CAR_SERVICE_LABEL_TEXT_COLOR @"CarServiceLabelTextColor"      //车主服务界面，每一项的label的字体颜色

#define SETTING_RESET_BUTTON_COLOR  @"SettingResetButtonColor"        //设置界面，全部恢复默认设置按钮颜色  

#define PERSONAL_CLICKSET_COLOR  @"PersonalClickSetColor"        //个人界面，点击设置
#define PERSONAL_TRACKSCORE_COLOR  @"PersonalTrackScoreColor"        //个人界面，轨迹分数
#define PERSONAL_MINUTES_LABEL_COLOR @"PersonalMinutesLabelColor"    //个人界面，轨迹分数
#define PERSONAL_SEEMORE_COLOR  @"PersonalSeeMoreColor"        //个人界面，查看更多
#define SETTING_CELL_DETAIL_TEXT_COLOR @"SettingCellDetailTextColor"        //设置 detailtextcolor
#define SETTING_NORMAL_BUTTON_TITLE_COLOR @"SettingNormalButtonTitleColor"  //设置，多选按钮的正常颜色
#define SETTING_HIGHLIGHTED_BUTTON_TITLE_COLOR @"SettingHighlightedButtonTitleColor"    //设置，多选按钮的高亮颜色

#pragma mark --- end  地图界面字体颜色  ---


#endif