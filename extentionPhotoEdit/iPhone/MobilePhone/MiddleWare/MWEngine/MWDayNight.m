//
//  MWDayNight.m
//  AutoNavi
//
//  Created by gaozhimin on 14-5-7.
//
//

#import "MWDayNight.h"

@implementation MWDayNight

/*!
 @brief 白天黑夜色盘同步
 */
+ (void)SyncDayNightTheme
{
    int theme = 0;
    
    GMAPDAYNIGHTMODE eMapDayNightMode = {0};
    GDBL_GetParam(G_MAP_DAYNIGHT_MODE, &eMapDayNightMode);
    if (eMapDayNightMode == GMAP_DAYNIGHT_MODE_DAY) {
        
        GDBL_GetParam(G_DAY_PALETTE_INDEX,&theme);
        
        GPALETTELIST *nightPalette;
        GDBL_GetPaletteList(Gfalse,&nightPalette);
        if (theme > (int)(nightPalette->nNumberOfPalette - 1)) {
            theme = 0;
        }
        
        //设置夜晚色盘
        GDBL_SetParam(G_NIGHT_PALETTE_INDEX,&theme);
        GDBL_SetParam(G_DAY_PALETTE_INDEX,&theme);
        
    }
    else if(eMapDayNightMode == GMAP_DAYNIGHT_MODE_NIGHT){
        
        GDBL_GetParam(G_NIGHT_PALETTE_INDEX,&theme);
        
        GPALETTELIST *dayPalette;
        GDBL_GetPaletteList(Gtrue,&dayPalette);
        if (theme > (int)(dayPalette->nNumberOfPalette - 1)) {
            theme = 0;
        }
        
        //设置白天色盘
        GDBL_SetParam(G_DAY_PALETTE_INDEX,&theme);
        GDBL_SetParam(G_NIGHT_PALETTE_INDEX,&theme);
    }
    else if(eMapDayNightMode == GMAP_DAYNIGHT_MODE_AUTO){
        
        GMAPDAYNIGHTMODE dayNight = {0};
        GDBL_GetParam(G_AUTO_MODE_DAYNIGHT, &dayNight);
        if (dayNight == GMAP_DAYNIGHT_MODE_DAY) {
            
            GDBL_GetParam(G_DAY_PALETTE_INDEX,&theme);
            
            GPALETTELIST *nightPalette;
            GDBL_GetPaletteList(Gfalse,&nightPalette);
            if (theme > (int)(nightPalette->nNumberOfPalette - 1)) {
                theme = 0;
            }
            
            //设置夜晚色盘
            GDBL_SetParam(G_NIGHT_PALETTE_INDEX,&theme);
            GDBL_SetParam(G_DAY_PALETTE_INDEX,&theme);
            
        }
        else if(dayNight == GMAP_DAYNIGHT_MODE_NIGHT)
        {
            GDBL_GetParam(G_NIGHT_PALETTE_INDEX,&theme);
            
            GPALETTELIST *dayPalette;
            GDBL_GetPaletteList(Gtrue,&dayPalette);
            if (theme > (int)(dayPalette->nNumberOfPalette - 1)) {
                theme = 0;
            }
            //设置白天色盘
            GDBL_SetParam(G_DAY_PALETTE_INDEX,&theme);
            GDBL_SetParam(G_NIGHT_PALETTE_INDEX,&theme);
        }
    }
    
    if([[MWPreference sharedInstance] getValue:PREF_MAPDAYNIGHTMODE] == GMAP_DAYNIGHT_MODE_AUTO)
    {
        [[MWPreference sharedInstance] setValue:PREF_MAPDAYNIGHTMODE Value:GMAP_DAYNIGHT_MODE_AUTO];
    }
}

/*!
 @brief 白天黑夜切换,更新界面ui
 */
+ (void)SetDayNightModeCallback
{
    if ([[ANParamValue sharedInstance] isInit]) {
        static GMAPDAYNIGHTMODE currentMapDayNightMode = {0};
        
        GMAPDAYNIGHTMODE dayNight = {0};
        GDBL_GetParam(G_AUTO_MODE_DAYNIGHT, &dayNight);
        
        if (dayNight != currentMapDayNightMode) {
            currentMapDayNightMode = dayNight;
            if (dayNight == GMAP_DAYNIGHT_MODE_DAY) {
                [UIImage setImageDayNightMode:NO];
                
            }
            else{
                [UIImage setImageDayNightMode:YES];
                
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDayNightModeChange] userInfo:@{@"dayNightMode": [NSNumber numberWithInt:dayNight]}];
        }
    }
}

/*!
 @brief 获取白天黑夜色盘数组
 */
+ (NSArray *)getDayNightArray
{
    NSArray *daySchemeArray = @[STR(@"Setting_WinterSunshine", Localize_Setting),STR(@"Setting_Sunshine", Localize_Setting),STR(@"Setting_Sakura", Localize_Setting)];
    NSArray *nightSchemeArray = @[STR(@"Setting_LightofDarkness", Localize_Setting),STR(@"Setting_Moonlight", Localize_Setting),STR(@"Setting_Cappuccino", Localize_Setting)];
    
    if([[MWPreference sharedInstance] getValue:PREF_MAPDAYNIGHTMODE] == GMAP_DAYNIGHT_MODE_DAY)
    {
        return daySchemeArray;
    }
    else if ([[MWPreference sharedInstance] getValue:PREF_MAPDAYNIGHTMODE] == GMAP_DAYNIGHT_MODE_NIGHT)
    {
        return nightSchemeArray;
    }
    else if ([[MWPreference sharedInstance] getValue:PREF_MAPDAYNIGHTMODE] == GMAP_DAYNIGHT_MODE_AUTO)
    {
        if ([[MWPreference sharedInstance] getValue:PREF_DAYNIGHTMODE] == GMAP_DAYNIGHT_MODE_DAY) {
            return daySchemeArray;
        }
        else {
            return nightSchemeArray;
        }
    }
    
    return nil;
    
}

/*!
 @brief 获取白天黑夜色盘索引
 */
+ (int)getDayNightSchemeIndex
{
    int themeIndex = 0;
    
    GMAPDAYNIGHTMODE eMapDayNightMode = {0};
    GDBL_GetParam(G_MAP_DAYNIGHT_MODE, &eMapDayNightMode);
    
    if (eMapDayNightMode == GMAP_DAYNIGHT_MODE_DAY) {
        
        GDBL_GetParam(G_DAY_PALETTE_INDEX,&themeIndex);
        
        GPALETTELIST *nightPalette;
        GDBL_GetPaletteList(Gfalse,&nightPalette);
        if (themeIndex > (int)(nightPalette->nNumberOfPalette - 1)) {
            themeIndex = 0;
        }
        
    }
    else if(eMapDayNightMode == GMAP_DAYNIGHT_MODE_NIGHT){
        
        GDBL_GetParam(G_NIGHT_PALETTE_INDEX,&themeIndex);
        
        GPALETTELIST *dayPalette;
        GDBL_GetPaletteList(Gtrue,&dayPalette);
        if (themeIndex > (int)(dayPalette->nNumberOfPalette - 1)) {
            themeIndex = 0;
        }
        
    }
    else if(eMapDayNightMode == GMAP_DAYNIGHT_MODE_AUTO){
        
        GMAPDAYNIGHTMODE dayNight = {0};
        GDBL_GetParam(G_AUTO_MODE_DAYNIGHT, &dayNight);
        
        if (dayNight == GMAP_DAYNIGHT_MODE_DAY) {
            
            GDBL_GetParam(G_DAY_PALETTE_INDEX,&themeIndex);
            
            GPALETTELIST *nightPalette;
            GDBL_GetPaletteList(Gfalse,&nightPalette);
            if (themeIndex > (int)(nightPalette->nNumberOfPalette - 1)) {
                themeIndex = 0;
            }
            
        }
        else if(dayNight == GMAP_DAYNIGHT_MODE_NIGHT)
        {
            GDBL_GetParam(G_NIGHT_PALETTE_INDEX,&themeIndex);
            
            GPALETTELIST *dayPalette;
            GDBL_GetPaletteList(Gtrue,&dayPalette);
            if (themeIndex > (int)(dayPalette->nNumberOfPalette - 1)) {
                themeIndex = 0;
            }
            
        }
    }
    
    return themeIndex;
}

/*!
 @brief 设置白天黑夜色盘索引
 */
+ (GSTATUS)setDayNightSchemeWithIndex:(int)schemeIndex
{
    
    GMAPDAYNIGHTMODE eMapDayNightMode = {0};
    GDBL_GetParam(G_MAP_DAYNIGHT_MODE, &eMapDayNightMode);
    if (eMapDayNightMode == GMAP_DAYNIGHT_MODE_DAY) {
        
        GPALETTELIST *nightPalette;
        GDBL_GetPaletteList(Gfalse,&nightPalette);
        if (schemeIndex > (int)(nightPalette->nNumberOfPalette - 1)) {
            return GD_ERR_FAILED;
        }
        GDBL_SetParam(G_NIGHT_PALETTE_INDEX,&schemeIndex);
        GDBL_SetParam(G_DAY_PALETTE_INDEX,&schemeIndex);
        
    }
    else if(eMapDayNightMode == GMAP_DAYNIGHT_MODE_NIGHT){
        
        
        GPALETTELIST *dayPalette;
        GDBL_GetPaletteList(Gtrue,&dayPalette);
        if (schemeIndex > (int)(dayPalette->nNumberOfPalette - 1)) {
            return GD_ERR_FAILED;
        }
        
        GDBL_SetParam(G_DAY_PALETTE_INDEX,&schemeIndex);
        GDBL_SetParam(G_NIGHT_PALETTE_INDEX,&schemeIndex);
    }
    else if(eMapDayNightMode == GMAP_DAYNIGHT_MODE_AUTO){
        
        GMAPDAYNIGHTMODE dayNight = {0};
        GDBL_GetParam(G_AUTO_MODE_DAYNIGHT, &dayNight);
        if (dayNight == GMAP_DAYNIGHT_MODE_DAY) {
            
            GPALETTELIST *nightPalette;
            GDBL_GetPaletteList(Gfalse,&nightPalette);
            if (schemeIndex > (int)(nightPalette->nNumberOfPalette - 1)) {
                return GD_ERR_FAILED;
            }
            
            GDBL_SetParam(G_NIGHT_PALETTE_INDEX,&schemeIndex);
            GDBL_SetParam(G_DAY_PALETTE_INDEX,&schemeIndex);
            
        }
        else if(dayNight == GMAP_DAYNIGHT_MODE_NIGHT)
        {
            
            GPALETTELIST *dayPalette;
            GDBL_GetPaletteList(Gtrue,&dayPalette);
            if (schemeIndex > (int)(dayPalette->nNumberOfPalette - 1)) {
                return GD_ERR_FAILED;
            }
            
            GDBL_SetParam(G_DAY_PALETTE_INDEX,&schemeIndex);
            GDBL_SetParam(G_NIGHT_PALETTE_INDEX,&schemeIndex);
        }
    }
    
    if([[MWPreference sharedInstance] getValue:PREF_MAPDAYNIGHTMODE] == GMAP_DAYNIGHT_MODE_AUTO)
    {
        [[MWPreference sharedInstance] setValue:PREF_MAPDAYNIGHTMODE Value:GMAP_DAYNIGHT_MODE_AUTO];
    }
    
    return GD_ERR_OK;
}

@end
