//
//  MWPoiOperator.m
//  AutoNavi
//
//  Created by yu.liao on 13-7-29.
//
//

#import "MWPoiOperator.h"
#import "NSString+Category.h"
#import "NameIndex.h"
#import "Account.h"
#import "JSON.h"
#import "GDAlertView.h"
#import "XMLDictionary.h"
#import "ThreeDes.h"
#import <sys/time.h>

#define Syn_Favorite @"favorites/difuploadaddr_v2/?"
#define Syn_History @"favorites/difuploadhistory_v2/?"
#define Syn_SmartEye @"favorites/difuploadeleceye_v2/?"

static RecognizeController *gRecognizeController = nil;
static GSAFECATEGORY	g_smartEyesCategory;     //保存每次获取电子眼的类别，删除时使用
static BOOL bSynNetData = YES;                       //是否在同步网络数据中

#define LimitCount_Fav 200
#define LimitCount_His 50
#define LimitCount_Save 200

Class object_getClass(id object);


@interface MWPoiOperator ()
{
    MWSearchOption *_poiOperationOption;
    GCOORD _coordForNearest;
    int mResultType;
}

@property (nonatomic,copy) NSString *userId;
@property (nonatomic,assign) Class originalClass;

@end

@implementation MWPoiOperator

@synthesize poiDelegate,userId,originalClass;



- (id)initWithDelegate:(id<MWPoiOperatorDelegate>)delegate
{
    if (self = [super init])
    {
        self.poiDelegate = delegate;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if (![fileMgr fileExistsAtPath:Collect_Directory])      //检测document下address文件夹是否存在，不存在则创建
        {
            BOOL sign = [fileMgr createDirectoryAtPath:Collect_Directory withIntermediateDirectories:nil attributes:nil error:nil];
            if (!sign)
            {
                NSLog(@"收藏夹文件夹创建失败");
            }
        }
        self.originalClass = object_getClass(delegate);
        bSynNetData = NO;
    }
    return self;
}

- (id)init
{
    return [self initWithDelegate:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.userId = nil;
    if (_poiOperationOption)
    {
        [_poiOperationOption release];
        _poiOperationOption = nil;
    }
    if (gRecognizeController)
    {
        [gRecognizeController setDelegate:nil];
        [gRecognizeController release];
        gRecognizeController = nil;
    }
    self.originalClass = nil;
    [super dealloc];
}

#pragma mark - public method

#define CheckOldPoiSynFile @"CheckOldPoiSynFile" //第一启动程序时，将引擎poi转至本地保存
/*!
 @brief 将引擎poi和电子眼转换至本地保存 初始化引擎后调用
 */
+ (void)changeEnginePoiAndSafe
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:CheckOldPoiSynFile])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:CheckOldPoiSynFile];
        //第一启动程序时，将引擎poi转至本地保存
        [MWPoiOperator changeEnginePoiTolocal:GFAVORITE_CATEGORY_DEFAULT];
        [MWPoiOperator changeEnginePoiTolocal:GFAVORITE_CATEGORY_HISTORY];
        [MWPoiOperator changeEnginePoiTolocal:GFAVORITE_CATEGORY_HOME];
        [MWPoiOperator changeEnginePoiTolocal:GFAVORITE_CATEGORY_COMPANY];
        [MWPoiOperator changeEngineSafeTolocal];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:Favorite_Path])
        {
            [manager removeItemAtPath:Favorite_Path error:nil];
        }
        if ([manager fileExistsAtPath:History_Path])
        {
            [manager removeItemAtPath:History_Path error:nil];
        }
        if ([manager fileExistsAtPath:SmartEye_Path])
        {
            [manager removeItemAtPath:SmartEye_Path error:nil];
        }
    }
    
}
/*!
 @brief 将引擎poi转换至本地保存
 */
+ (void)changeEnginePoiTolocal:(GFAVORITECATEGORY)eCategory
{
    GFAVORITEPOILIST *ppFavoritePOIList = {0};
    GSTATUS res;
    NSString *file_path = nil;
    res = GDBL_GetFavoriteList(eCategory, &ppFavoritePOIList);
    if (res == GD_ERR_OK)
    {
        file_path = [Collect_Directory stringByAppendingFormat:@"/FavoriteList%d.plist",eCategory];
        MWFavorite *favoriteList = nil;
        favoriteList = [[[MWFavorite alloc] init] autorelease];
        for (int i = 0; i < ppFavoritePOIList->nNumberOfItem; i++)
        {
            GFAVORITEPOI gFavePoi = ppFavoritePOIList->pFavoritePOI[i];
            MWFavoritePoi *poi = [[[MWFavoritePoi alloc] init] autorelease];
            poi.eCategory = gFavePoi.eCategory;
            poi.eIconID = gFavePoi.eIconID;
            GPOI gpoi = gFavePoi.Poi;
            poi.lAdminCode = gpoi.lAdminCode;
            poi.latitude = gpoi.Coord.y;
            poi.longitude = gpoi.Coord.x;
            poi.lCategoryID = gpoi.lCategoryID;
            poi.lDistance = gpoi.lDistance;
            poi.lHilightFlag = gpoi.lHilightFlag;
            poi.lMatchCode = gpoi.lMatchCode;
            poi.stPoiId = gpoi.stPoiId;
            poi.lPoiIndex = gpoi.lPoiIndex;
            poi.ucFlag = gpoi.ucFlag;
            poi.Reserved = gpoi.Reserved;
            poi.lNaviLon = gpoi.lNaviLon;
            poi.lNaviLat = gpoi.lNaviLat;
            poi.szName = GcharToNSString(gpoi.szName);
            poi.szAddr = GcharToNSString(gpoi.szAddr);
            poi.szTel = GcharToNSString(gpoi.szTel);
            poi.actionType = 1;
            [favoriteList.pFavoritePOIArray addObject:poi];
        }
        if (![NSKeyedArchiver archiveRootObject:favoriteList toFile:file_path])
        {
            NSLog(@"-------------同步至本地文件失败-----------------");
        }
        else
        {
            NSLog(@"-------------同步至本地文件成功-----------------");
        }
    }
}

/*!
 @brief 将引擎电子眼转换至本地保存
 */
+ (void)changeEngineSafeTolocal
{
    GUSERSAFEINFOLIST  *ppSafeInfoList;
    GSTATUS res = GDBL_GetUserSafeInfoList(GSAFE_CATEGORY_ALL,&ppSafeInfoList);
    if (res == GD_ERR_OK)
    {
        NSString *file_path = nil;
        file_path = [Collect_Directory stringByAppendingFormat:@"/SafeList.plist"];
        MWSmartEyes *safeList = nil;
        safeList = [[[MWSmartEyes alloc] init] autorelease];
        for (int i = 0; i < ppSafeInfoList->nNumberOfItem; i++)
        {
            GUSERSAFEINFO gpoi = ppSafeInfoList->pSafeInfo[i];
            MWSmartEyesItem *poi = [[[MWSmartEyesItem alloc] init] autorelease];
            poi.lAdminCode = gpoi.lAdminCode;
            poi.latitude = gpoi.coord.y;
            poi.longitude = gpoi.coord.x;
            poi.eCategory = gpoi.eCategory;
            poi.nSpeed = gpoi.nSpeed;
            poi.nAngle = gpoi.nAngle;
            poi.nIndex = gpoi.nIndex;
            poi.nId = gpoi.nId;
            poi.szName = GcharToNSString(gpoi.szName);
            poi.actionType = 1;
            [safeList.smartEyesArray addObject:poi];
        }
        if (![NSKeyedArchiver archiveRootObject:safeList toFile:file_path])
        {
            NSLog(@"-------------同步至本地文件失败-----------------");
        }
        else
        {
            NSLog(@"-------------同步至本地文件成功-----------------");
        }
    }
}

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
+ (GSTATUS)AbortSearchPOI
{
    return GDBL_AbortSearchPOI();
}

///*
// GSEARCHTYPE	eSearchType;				/**< 检索类型 */
//GPOICATCODE	stCatCode;					/**< 类别编码组合 */
//Gint32   	lAroundRange;				/**< 周边检索半径，单位：米 */
//Gbool		bUsePoiIndex;				/**< 使用使用POI索引，通过道路名搜索门址，十字路口 */
//Gint32		nPoiIndex;					/**< POI索引值 */
//GCOORD		Coord;						/**< 经纬度坐标 */
//Gchar   	szKeyword[GMAX_KEYWORD_LEN+1];		/**< 关键字 */
//GROUTEPOITYPE eRoutePoiType;			/**< 指定沿路径POI搜索类型 */
// */
#pragma mark   搜索接口
/*!
 @brief  POI 查询接口函数，即根据 POI 参数选项进行 POI 查询。
 @param operationOption POI 查询选项,具体属性字段请参考 MAPoiSearchOption 类。
 */
-(BOOL)poiLocalSearchWithOption:(MWSearchOption*)operationOption
{
    
    GSEARCHCONDITION pSearchCondition;
    memset(&pSearchCondition, 0, sizeof(GSEARCHCONDITION));
    pSearchCondition.Coord.x = operationOption.longitude;
    pSearchCondition.Coord.y = operationOption.latitude;
    pSearchCondition.eRoutePoiType = operationOption.routePoiTpe;
    pSearchCondition.eSearchType = operationOption.operatorType;
    pSearchCondition.lAroundRange = operationOption.aroundRange;
    
    GPOICATCODE stcatcode = operationOption.stCatCode;
    memcpy(&pSearchCondition.stCatCode, &stcatcode, sizeof(GPOICATCODE));
    
    
    Gchar *string = NSStringToGchar(operationOption.keyWord);
    if(string)
    {
        GcharMemcpy(pSearchCondition.szKeyword, string, GMAX_KEYWORD_LEN+1);
    }
    GSTATUS ret =  GDBL_StartSearchPOI(&pSearchCondition);
    if(ret != GD_ERR_OK)
    {
        return NO;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_GETPOIDATA object:nil];
    _poiOperationOption = [operationOption retain];
    [self retain];
    return YES;
    
}

/*!
 @brief  POI 网络查询接口函数，即根据 POI 参数选项进行 POI 查询。
 @param operationOption POI 查询选项,具体属性字段请参考 MWSearchOption 类。
 */
-(BOOL)poiNetSearchWithOption:(MWSearchOption*)operationOption
{
    GSEARCHCONDITION pSearchCondition;
    memset(&pSearchCondition, 0, sizeof(GSEARCHCONDITION));
    
    pSearchCondition.Coord.x = operationOption.longitude;
    pSearchCondition.Coord.y = operationOption.latitude;
    pSearchCondition.eRoutePoiType = operationOption.routePoiTpe;
    pSearchCondition.eSearchType = operationOption.operatorType;
    pSearchCondition.lAroundRange = operationOption.aroundRange;
    
    GPOICATCODE stcatcode = operationOption.stCatCode;
    memcpy(&pSearchCondition.stCatCode, &stcatcode, sizeof(GPOICATCODE));
    
    Gchar *string = NSStringToGchar(operationOption.keyWord);
    if(string)
    {
        GcharMemcpy(pSearchCondition.szKeyword, string, GMAX_KEYWORD_LEN+1);
    }
    GSTATUS ret =  GDBL_StartSearchPOINet(&pSearchCondition);
    if(ret != GD_ERR_OK)
    {
        return NO;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_GETPOIDATA object:nil];
    _poiOperationOption = [operationOption retain];
    [self retain];
    
    return YES;
}

/*!
 @brief  请求获取当前点最近的POI点 只需传入经纬度
 @param operationOption POI 查询选项,具体属性字段请参考 MWSearchOption 类。GDBL_RequestNearestPOI
 */
-(BOOL)poiNearestSearchWithCoord:(GCOORD)coord
{
    GSTATUS ret =  GDBL_RequestNearestPOI(&coord);
    if(ret != GD_ERR_OK)
    {
        return NO;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_GETPOIDATA object:nil];
    _coordForNearest = coord;
    [self retain];
    return YES;
}

/*!
 @brief  获取周边类别列表接口
 @param  lCategoryID, 类别编码 0为获取所有类别列表
 @param  list, 输出 , 周边类别列表
 @return YES:获取成功。
 */

-(BOOL)getAroundListWith:(int)lCategoryID list:(MWPoiCategoryList **)list
{
    GPOICATEGORYLIST *ppCategoryList = NULL;
    GSTATUS res = GDBL_GetPOICategoryList(lCategoryID, &ppCategoryList);
    if (res != GD_ERR_OK || ppCategoryList == NULL)
    {
        return NO;
    }
    MWPoiCategoryList *temp = [[[MWPoiCategoryList alloc] init] autorelease];
    temp.lNumberOfCategory = ppCategoryList->lNumberOfCategory;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < temp.lNumberOfCategory; i++)
    {
        GDBL_GetPOICategoryList(lCategoryID, &ppCategoryList);
        
        GPOICATEGORY gPoiCategory = ppCategoryList->pCategory[i];
        MWPoiCategory  *poiCategory = [self recursiveForCategory:gPoiCategory];
        [array addObject:poiCategory];
    }
    temp.pCategoryArray = [NSArray arrayWithArray:array];
    [array release];
    
    *list = temp;
    
    return YES;
}

/*!
 @brief  网络搜索时，根据本地类别id获取类别名称  如：加油站|全部 。
 @param  lCategoryID, 本地类别id
 @return 中文名称
 */
+ (NSString *)getNetCategaryStringWithLocalID:(NSArray *)lCategoryID
{
    GLANGUAGE nMapLanguage;
    GDBL_GetParam(G_LANGUAGE, &nMapLanguage);
    
    if (nMapLanguage != GLANGUAGE_SIMPLE_CHINESE)  //繁体转简体
    {
        GLANGUAGE temp = GLANGUAGE_SIMPLE_CHINESE;
        GDBL_SetParam(G_LANGUAGE, &temp);
    }
    
    NSString *categary = @"";
    
    MWPoiOperator *poiOperator=[[MWPoiOperator alloc] init];
    MWPoiCategoryList *poiCategoryList = nil;
    BOOL sign =  [poiOperator getAroundListWith:0 list:&poiCategoryList];
    [poiOperator release];
    if (sign)
    {
        for (int i = 0; i < poiCategoryList.lNumberOfCategory; i++)
        {
            MWPoiCategory *gPoiCategory = [poiCategoryList.pCategoryArray objectAtIndex:i];
            categary = gPoiCategory.szName;
            if ([gPoiCategory.pnCategoryID count] > 0)
            {
                NSPredicate * thePredicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", lCategoryID];
                [gPoiCategory.pnCategoryID filterUsingPredicate:thePredicate];
                if ([gPoiCategory.pnCategoryID count] == 0)
                {
                    break;
                }else
                {
                    categary = [MWPoiOperator findCategary:gPoiCategory withStr:categary withLocalID:lCategoryID];
                    if ([categary length] > 0)
                    {
                        break;
                    }
                }
            }
            else
            {
                categary = [MWPoiOperator findCategary:gPoiCategory withStr:categary withLocalID:lCategoryID];
                if ([categary length] > 0)
                {
                    break;
                }
            }
        }
        
    }
    GDBL_SetParam(G_LANGUAGE, &nMapLanguage);
    NSLog(@"categary %@",categary);
    return categary;
}

+ (NSString *)findCategary:(MWPoiCategory *)gPoiCategory withStr:(NSString *)str withLocalID:(NSArray *)localID
{
    if (gPoiCategory == nil)
    {
        return @"";
    }
    for (int i = 0; i < gPoiCategory.nNumberOfSubCategory; i++)
    {
        MWPoiCategory *sub = [gPoiCategory.pSubCategoryArray objectAtIndex:i];
        if ([sub.pnCategoryID count] > 0)
        {
            NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", localID];
            [sub.pnCategoryID filterUsingPredicate:thePredicate];
            if ([sub.pnCategoryID count] == 0)
            {
                return [str stringByAppendingFormat:@"|%@",sub.szName];
            }
        }
        else
        {
            [MWPoiOperator findCategary:sub withStr:str withLocalID:localID];
        }
    }
    return @"";
}


#pragma mark poi与帐号绑定相关函数

/*!
 @brief  将poi数组与帐号绑定
 @param  poiArray poi数组
 @return BOOL 是否改变
 */
+ (BOOL)bindPoiForAccountWithPoi:(MWPoi *)poi
{
    BOOL sign = NO;
    int logintype = [[Plugin_Account getAccountInfoWith:1] intValue];  //登陆状态
    NSString *userid = [Plugin_Account getAccountInfoWith:2];  //获取用户id
    if (logintype && [userid length] > 0)
    {
        if ([poi.accountId length] == 0)
        {
            poi.accountId = userid;
            sign = YES;
        }
    }
    return sign;
}
/*!
 @brief  将poi数组与帐号绑定
 @param  poiArray poi数组
 @return NSArray 返回与当前帐号绑定的poi数组
 */
+ (BOOL)bindPoiForAccountWithArray:(NSArray *)poiArray
{
    BOOL sign = NO;
    int logintype = [[Plugin_Account getAccountInfoWith:1] intValue];  //登陆状态
    NSString *userid = [Plugin_Account getAccountInfoWith:2];  //获取用户id
    if (logintype && [userid length] > 0)
    {
        //已登陆
        MWPoi *poi = nil;
        for (int i = 0; i < [poiArray count]; i++)
        {
            poi = [poiArray caObjectsAtIndex:i];
            if ([poi.accountId length] == 0)
            {
                poi.accountId = userid;
                sign = YES;
            }
        }
    }
    return sign;
}

/*!
 @brief  获取与当前帐号绑定的poi
 @param  poiArray poi数组
 @return NSArray 返回与当前帐号绑定的poi数组
 */
+ (NSMutableArray *)getPoiForAccountWithArray:(NSArray *)poiArray
{
    int logintype = [[Plugin_Account getAccountInfoWith:1] intValue];  //登陆状态
    NSString *userid = [Plugin_Account getAccountInfoWith:2];  //获取用户id
    NSMutableArray *accountArray = [NSMutableArray array];
    if (logintype && [userid length] > 0)
    {
        //已登陆
        MWPoi *poi = nil;
        for (int i = 0; i < [poiArray count]; i++)
        {
            poi = [poiArray caObjectsAtIndex:i];
            if ([poi.accountId length] == 0)
            {
                poi.accountId = userid;
                [accountArray addObject:poi];
            }
            else
            {
                if ([poi.accountId isEqualToString:userid])
                {
                    [accountArray addObject:poi];
                }
            }
        }
        
    }
    else
    {
        //未登陆
        MWPoi *poi = nil;
        for (int i = 0; i < [poiArray count]; i++)
        {
            poi = [poiArray caObjectsAtIndex:i];
            if ([poi.accountId length] == 0)
            {
                [accountArray addObject:poi];
            }
            
        }
    }
    return accountArray;
}

+ (BOOL)isTwoPoiEqual:(MWPoi *)poiOne two:(MWPoi *)poiTwo
{
    if (poiOne.longitude == poiTwo.longitude && poiOne.latitude == poiTwo.latitude)
    {
        return YES;
    }
    return NO;
}
#pragma mark  语音搜索
/*!
 @brief  语音搜索调用
 @param option 语音搜索选项
 @param superView 语音视图的父视图
 @return YES:成功启动搜索。搜索成功将回调
 */

-(BOOL)voiceSearchWith:(MWVoiceOption *)option withSuperView:(UIView*)view

{
    if (view == nil)
    {
        NSLog(@"view is nil");
        return NO;
    }
    if (gRecognizeController == nil)
    {
        gRecognizeController = [[RecognizeController alloc] initWithView:view Lon:option.longitude Lat:option.latitude AdminCode:option.lAdminCode];
    }
    [gRecognizeController setDelegate:self];
    [gRecognizeController setResultType:option.resultType];
    [gRecognizeController start];
    [self retain];
    mResultType = option.resultType;
    return YES;
}


/*!
 @brief  设置语音框的中心位置，  注意：该方法为类方法。
 @param center 中心点位置
 */
+(void)setRecognizeViewCenter:(CGPoint)center
{
    if (gRecognizeController)
    {
        
    }
}

/*!
 @brief  开始语音，  注意：该方法为类方法。
 */
+(void)setRecognizeStart
{
    if (gRecognizeController)
    {
        [gRecognizeController start];
    }
}

/*!
 @brief  设置语音识别参数，  注意：该方法为类方法。
 @param gaoLon 高德经度
 @param gaoLat 高德纬度
 @param adminCode 行政编码
 */
+(void)setPosition:(int)gaoLon Lat:(int)gaoLat AdminCode:(int)adminCode
{
    if (gRecognizeController)
    {
        [gRecognizeController setPosition:gaoLon Lat:gaoLat AdminCode:adminCode];
    }
}

/*!
 @brief  停止语音，  注意：该方法为类方法。
 */
+(void)setRecognizeStop
{
    if (gRecognizeController)
    {
        [gRecognizeController stop];
    }
}

#pragma mark  地址簿，历史目的地接口

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
+ (GSTATUS)UpgradeFavoriteFiles
{
    return GDBL_UpgradeFavoriteFiles();
}

/*!
 @brief  同步收藏夹兴趣点
 @param   eCategory 兴趣点类别GFAVORITECATEGORY，用于标识要上传的收藏夹类别。
 @param   type     请求类型
 */
+ (BOOL)synFavoritePoiWith:(MWFavoriteOption *)option requestType:(RequestType)type delegate:(id<MWPoiOperatorDelegate>)delegate
{
    NSArray *array;
    GDBL_GetAccountInfo(&array);
    int loginType = [[array caObjectsAtIndex:0] intValue];
    if (loginType == 0)
    {
        return NO;
    }
    if (loginType == 1 || loginType == 2)  //登陆状态1 2表示在北京服务器登陆
    {
        [MWPoiOperator synBeijingFavoritePoiWith:option requestType:type delegate:delegate];
    }
    else
    {
        [MWPoiOperator synXiamenFavoritePoiWith:option requestType:type delegate:delegate];
    }
    return YES;
}

/*!
 @brief  同步厦门服务器收藏夹兴趣点
 @param   eCategory 兴趣点类别GFAVORITECATEGORY，用于标识要上传的收藏夹类别。
 @param   type     请求类型
 */
+ (BOOL)synXiamenFavoritePoiWith:(MWFavoriteOption *)option requestType:(RequestType)type delegate:(id<MWPoiOperatorDelegate>)delegate
{
    MWFavorite *favorite = nil;
    NSString *file_path = nil;
    file_path = [Collect_Directory stringByAppendingFormat:@"/FavoriteList%d.plist",option.eCategory];
    favorite = [NSKeyedUnarchiver unarchiveObjectWithFile:file_path];
    if (favorite == nil)
    {
        NSLog(@"无文件数据");
        favorite = [[[MWFavorite alloc] init] autorelease];
    }
    NSArray *poiList = favorite.pFavoritePOIArray;  //上传改动的poi信息
    NSArray *array;
    GDBL_GetAccountInfo(&array);
    int loginType = [[array caObjectsAtIndex:0] intValue];
    NSString *userId = nil;
    NSString *url = nil;
    if (option.eCategory == GFAVORITE_CATEGORY_DEFAULT) //我的收藏夹
    {
        if (loginType == 3 || loginType == 5)
        {
            url = [NSString stringWithFormat:@"%@%@out=xml&tpuserid=%@&tptype=1",kNetDomain,Syn_Favorite,[array objectAtIndex:5]];
        }
        else if (loginType == 4 || loginType == 6)
        {
            url = [NSString stringWithFormat:@"%@%@out=xml&tpuserid=%@&tptype=2",kNetDomain,Syn_Favorite,[array objectAtIndex:5]];
        }
    }
    else if (option.eCategory == GFAVORITE_CATEGORY_HISTORY) //历史目的地
    {
        if (loginType == 3 || loginType == 5)
        {
            url = [NSString stringWithFormat:@"%@%@out=xml&tpuserid=%@&tptype=1",kNetDomain,Syn_History,[array objectAtIndex:5]];
        }
        else if (loginType == 4 || loginType == 6)
        {
            url = [NSString stringWithFormat:@"%@%@out=xml&tpuserid=%@&tptype=2",kNetDomain,Syn_History,[array objectAtIndex:5]];
        }
    }
    userId = [array caObjectsAtIndex:7];  //记录用户id
    //判断上次同步的 用户与此次是否相同，不同则将时间置为较早时间
    if (![favorite.userId isEqualToString:userId])
    {
        GDATE	Date_tmp = {1975,1,1};
        favorite.Date	= Date_tmp;
        GTIME	Time_tmp = {1,1,1};
        favorite.Time	= Time_tmp;
        MWFavorite *allFavorite;
        [self getPoiListWith:option.eCategory poiList:&allFavorite];
        for (MWFavoritePoi *temp in allFavorite.pFavoritePOIArray)
        {
            temp.actionType = 1;
        }
        poiList = allFavorite.pFavoritePOIArray;
    }
    
    NSString *temp = @"<?xml version=\"1.0\" encoding=\"utf-8\"?><archive>";
    temp = [temp stringByAppendingFormat:@"<lasttime>%d-%02d-%02d %02d:%02d:%02d</lasttime><context>",favorite.Date.year,favorite.Date.month,favorite.Date.day,favorite.Time.hour,favorite.Time.minute,favorite.Time.second];
    int operatorCount = 0;
    for(int i = 0; i < [poiList count]; i++)
    {
        MWFavoritePoi *tmp = [poiList objectAtIndex:i];
        if (tmp.actionType > 0)
        {
            NSString *name =(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                (CFStringRef)tmp.szName,
                                                                                NULL,
                                                                                CFSTR(":/?#[]@!$&’()*+,;="),
                                                                                kCFStringEncodingUTF8);
            temp = [temp stringByAppendingFormat:@"<item><item_id>%d</item_id><longitude>%ld</longitude>",0,tmp.longitude];
            temp = [temp stringByAppendingFormat:@"<latitude>%ld</latitude><longitude_off>%d</longitude_off>",tmp.latitude,0];
            temp = [temp stringByAppendingFormat:@"<latitude_off>%d</latitude_off><name>%@</name>",0,name];
            temp = [temp stringByAppendingFormat:@"<type>0001</type><origen_type>0001</origen_type><admin_code>%d</admin_code>",tmp.lAdminCode];
            temp = [temp stringByAppendingFormat:@"<from_type>%d</from_type><town>%@</town><address>%@</address>",tmp.lCategoryID,tmp.szTown,tmp.szAddr];
            temp = [temp stringByAppendingFormat:@"<telephone>%@</telephone><detail></detail><state>%d</state></item>",tmp.szTel,tmp.actionType];
            [name release];
            operatorCount++;
        }
    }
    
    if (operatorCount == 0)
    {
        temp = [temp stringByAppendingString:@"<item></item>"];
    }
    temp = [temp stringByAppendingString:@"</context></archive>"];
    
    NSData *requstBody = [temp dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    /**
     组转上传数据
     */
    MWPoiOperator *operator = [[MWPoiOperator alloc] initWithDelegate:delegate];    //回调中释放
    operator.userId = userId;
    operator.originalClass = object_getClass(delegate);
    
    NetBaseRequestCondition *net_condition = [NetBaseRequestCondition requestCondition];
    net_condition.requestType = type;
    net_condition.baceURL = url;
    net_condition.bodyData = requstBody;
    net_condition.httpMethod = @"POST";
    
    
    [[NetExt sharedInstance] requestWithCondition:net_condition delegate:operator];

    return YES;
}

/*!
 @brief  同步北京服务器收藏夹兴趣点
 @param   eCategory 兴趣点类别GFAVORITECATEGORY，用于标识要上传的收藏夹类别。
 @param   type     请求类型
 */
+ (BOOL)synBeijingFavoritePoiWith:(MWFavoriteOption *)option requestType:(RequestType)type delegate:(id<MWPoiOperatorDelegate>)delegate
{
    MWFavorite *favorite = nil;
    NSString *file_path = nil;
    file_path = [Collect_Directory stringByAppendingFormat:@"/FavoriteList%d.plist",option.eCategory];
    favorite = [NSKeyedUnarchiver unarchiveObjectWithFile:file_path];
    if (favorite == nil)
    {
        NSLog(@"无文件数据");
        favorite = [[[MWFavorite alloc] init] autorelease];
    }
    
    MWFavorite *favoriteHome = nil;
    NSString *file_pathHome = nil;
    file_pathHome = [Collect_Directory stringByAppendingFormat:@"/FavoriteList%d.plist",GFAVORITE_CATEGORY_HOME];
    favoriteHome = [NSKeyedUnarchiver unarchiveObjectWithFile:file_pathHome];
    if (favoriteHome == nil)
    {
        NSLog(@"无文件数据");
        favoriteHome = [[[MWFavorite alloc] init] autorelease];
    }
    
    MWFavorite *favoriteCom = nil;
    NSString *file_pathCom = nil;
    file_pathCom = [Collect_Directory stringByAppendingFormat:@"/FavoriteList%d.plist",GFAVORITE_CATEGORY_COMPANY];
    favoriteCom = [NSKeyedUnarchiver unarchiveObjectWithFile:file_pathCom];
    if (favoriteCom == nil)
    {
        NSLog(@"无文件数据");
        favoriteCom = [[[MWFavorite alloc] init] autorelease];
    }
    NSMutableArray *temparray = [[NSMutableArray alloc] init];
    
    NSArray *array;
    GDBL_GetAccountInfo(&array);
    NSString *userId = [array caObjectsAtIndex:7];
    //判断上次同步的 用户与此次是否相同，不同则将时间置为较早时间
    if (![favorite.userId isEqualToString:userId])
    {
        GDATE	Date_tmp = {1975,1,1};
        favorite.Date	= Date_tmp;
        GTIME	Time_tmp = {1,1,1};
        favorite.Time	= Time_tmp;
        MWFavorite *allFavorite;
        [self getPoiListWith:option.eCategory poiList:&allFavorite];
        for (MWFavoritePoi *temp in allFavorite.pFavoritePOIArray)
        {
            temp.actionType = 1;
        }
        for (MWFavoritePoi *temp in favoriteHome.pFavoritePOIArray)
        {
            temp.actionType = 1;
        }
        for (MWFavoritePoi *temp in favoriteCom.pFavoritePOIArray)
        {
            temp.actionType = 1;
        }
        [temparray addObjectsFromArray:allFavorite.pFavoritePOIArray];
    }
    else
    {
        [temparray addObjectsFromArray:favorite.pFavoritePOIArray];
    }
    
    if (type == REQ_SYN_FAV)  //同步收藏夹，把家和公司加上
    {
        [temparray addObjectsFromArray:favoriteHome.pFavoritePOIArray];
        [temparray addObjectsFromArray:favoriteCom.pFavoritePOIArray];
    }
    NSArray *poiList = [NSArray arrayWithArray:temparray];  //上传改动的poi信息
    [temparray release];

   
    NSString *xmlHead = [GD_NSObjectToXML xmlHeadString];
    NSMutableDictionary *svccont = [NSMutableDictionary dictionary];
    NSMutableDictionary *bodyDic = [NSMutableDictionary dictionary];
    [svccont setValue:bodyDic forKey:@"svccont"];
    
    [bodyDic setValue:IDFA forKey:@"imei"];
    [bodyDic setValue:KNetChannelID forKey:@"syscode"];
    [bodyDic setValue:UserID_Account forKey:@"userid"];
    [bodyDic setValue:UserSID forKey:@"sessionid"];
    
    NSMutableDictionary *list = [NSMutableDictionary dictionary];
    [bodyDic setValue:list forKey:@"list"];
    NSMutableArray *poiArray = [NSMutableArray array];
    for (int i = 0; i < [poiList count]; i ++)
    {
        MWFavoritePoi *poi = [poiList objectAtIndex:i];
        if (poi.actionType > 0)
        {
            NSMutableDictionary *poiDic = [NSMutableDictionary dictionary];
            [poiDic setValue:poi.netPoiId forKey:@"id"];
            [poiDic setValue:[NSString stringWithFormat:@"%ld",poi.longitude] forKey:@"x"];
            [poiDic setValue:[NSString stringWithFormat:@"%ld",poi.latitude] forKey:@"y"];
            [poiDic setValue:[poi.szName dataUsingEncoding:NSUTF8StringEncoding] forKey:@"name"];
            [poiDic setValue:[poi.szAddr dataUsingEncoding:NSUTF8StringEncoding] forKey:@"address"];
            [poiDic setValue:poi.szTel forKey:@"tel"];
            [poiDic setValue:[NSString stringWithFormat:@"%d",poi.lAdminCode] forKey:@"adcode"];
            
            if (poi.actionType == 2)
            {
                [poiDic setValue:[NSString stringWithFormat:@"%d",3] forKey:@"opr"];
            }
            else if (poi.actionType == 3)
            {
                [poiDic setValue:[NSString stringWithFormat:@"%d",2] forKey:@"opr"];
            }
            else
            {
                [poiDic setValue:[NSString stringWithFormat:@"%d",poi.actionType] forKey:@"opr"];
            }
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyyMMddHHmmss"];
            NSString *dateStr = [formatter stringFromDate:[NSDate date]];
            [poiDic setValue:dateStr forKey:@"oprtime"];
            [formatter release];
            if (poi.eCategory == GFAVORITE_CATEGORY_HOME)
            {
                [poiDic setValue:[NSString stringWithFormat:@"%d",2] forKey:@"subtype"];
            }
            else if (poi.eCategory == GFAVORITE_CATEGORY_COMPANY)
            {
                [poiDic setValue:[NSString stringWithFormat:@"%d",3] forKey:@"subtype"];
            }
            else
            {
                 [poiDic setValue:[NSString stringWithFormat:@"%d",1] forKey:@"subtype"];
            }
            [poiArray addObject:poiDic];
        }
    }
    if ([poiArray count] > 0)
    {
        [list setValue:poiArray forKey:@"poi"];
    }
    NSString *xmlBody = [GD_NSObjectToXML convertDictionaryToXML:svccont rootName:@"opg"];
    int listtype = (REQ_SYN_FAV == type)?0:1;
    xmlBody = [xmlBody stringByReplacingOccurrencesOfString:@"<list>" withString:[NSString stringWithFormat:@"<list type=\"%d\">",listtype]];
    
    NSString *temp = [xmlHead stringByAppendingString:xmlBody];
//    NSString *encrypt = [ThreeDes encrypt:temp]; //加密
    NSData *requstBody = [temp dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    /**
     组转上传数据
     */
    Guint64 t;
    struct timeval tv_begin;
    gettimeofday(&tv_begin, NULL);
    t = (Guint64)1000000 * (tv_begin.tv_sec) + tv_begin.tv_usec;
    t = t/1000;
    
    NSMutableDictionary *urlParams = [NSMutableDictionary dictionary];
    [urlParams setValue:[NSString stringWithFormat:@"%llu",t] forKey:@"timestamp"];
    [urlParams setValue:@"0" forKey:@"en"];
    [urlParams setValue:IDFA forKey:@"imei"];
    [urlParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [urlParams setValue:MapVersionNoV forKey:@"mapversion"];
    [urlParams setValue:deviceModel forKey:@"model"];
    [urlParams setValue:DeviceResolutionString forKey:@"resolution"];
    [urlParams setValue:CurrentSystemVersion forKey:@"os"];
    [urlParams setValue:UserSID forKey:@"sid"];
    [urlParams setValue:UserID_Account forKey:@"userid"];
    [urlParams setValue:KNetChannelID forKey:@"syscode"];
    [urlParams setValue:PID forKey:@"pid"];
    NSString *signString = [[NSString stringWithFormat:@"%@%@%@@%@",KNetChannelID,@"/nis/syncdata",[NSString stringWithFormat:@"%llu",t],kNetSignKey] stringFromMD5];
    if (signString)
    {
        [urlParams setValue:signString forKey:@"sign"];
    }
    
    
    MWPoiOperator *operator = [[MWPoiOperator alloc] initWithDelegate:delegate];    //回调中释放
    operator.userId = userId;
    operator.originalClass = object_getClass(delegate);
    
    NetBaseRequestCondition *net_condition = [NetBaseRequestCondition requestCondition];
    net_condition.requestType = type;
    net_condition.baceURL = kSynFavPoiRequestURL;
    net_condition.bodyData = requstBody;
    net_condition.httpMethod = @"POST";
    net_condition.httpHeaderFieldParams = urlParams;
    
    
    [[NetExt sharedInstance] requestWithCondition:net_condition delegate:operator];
    return YES;
}

/*!
 @brief  取消同步收藏兴趣点
 @param   type     请求类型
 @return	成功返回YES 否则返回NO
 */
+ (BOOL)cancelSynFavoritePoiWith:(RequestType)type
{
    [[NetExt sharedInstance] Net_CancelRequestWithType:type];
    return YES;
}

+ (MWFavoritePoi *)getPoiWith:(GFAVORITECATEGORY)eCategory icon:(GFAVORITEICON)eIconID poi:(GPOI)gpoi
{
    MWFavoritePoi *poi = [[[MWFavoritePoi alloc] init] autorelease];
    poi.eCategory = eCategory;
    poi.eIconID = eIconID;
    poi.lAdminCode = gpoi.lAdminCode;
    poi.latitude = gpoi.Coord.y;
    poi.longitude = gpoi.Coord.x;
    poi.lCategoryID = gpoi.lCategoryID;
    poi.lDistance = gpoi.lDistance;
    poi.lHilightFlag = gpoi.lHilightFlag;
    poi.lMatchCode = gpoi.lMatchCode;
    poi.stPoiId = gpoi.stPoiId;
    poi.lPoiIndex = gpoi.lPoiIndex;
    //    poi.usNodeId = gpoi.usNodeId;
    poi.ucFlag = gpoi.ucFlag;
    poi.Reserved = gpoi.Reserved;
    poi.lNaviLon = gpoi.lNaviLon;
    poi.lNaviLat = gpoi.lNaviLat;
    poi.szName = GcharToNSString(gpoi.szName);
    poi.szAddr = GcharToNSString(gpoi.szAddr);
    poi.szTel = GcharToNSString(gpoi.szTel);
    return poi;
}

/*!
 @brief  收藏指定条件兴趣点
 @return 收藏成功返回GD_ERR_OK，重复收藏返回GD_ERR_DUPLICATE_DATA。其他错误码请参见 GSTATUS
 */
+(GSTATUS)collectPoiWith:(GFAVORITECATEGORY)eCategory icon:(GFAVORITEICON)eIconID poi:(GPOI)gpoi
{
    MWFavoritePoi *poi = [[[MWFavoritePoi alloc] init] autorelease];
    poi.eCategory = eCategory;
    poi.eIconID = eIconID;
    poi.lAdminCode = gpoi.lAdminCode;
    poi.latitude = gpoi.Coord.y;
    poi.longitude = gpoi.Coord.x;
    poi.lCategoryID = gpoi.lCategoryID;
    poi.lDistance = gpoi.lDistance;
    poi.lHilightFlag = gpoi.lHilightFlag;
    poi.lMatchCode = gpoi.lMatchCode;
    poi.stPoiId = gpoi.stPoiId;
    poi.lPoiIndex = gpoi.lPoiIndex;
    //    poi.usNodeId = gpoi.usNodeId;
    poi.ucFlag = gpoi.ucFlag;
    poi.Reserved = gpoi.Reserved;
    poi.lNaviLon = gpoi.lNaviLon;
    poi.lNaviLat = gpoi.lNaviLat;
    poi.szName = GcharToNSString(gpoi.szName);
    poi.szAddr = GcharToNSString(gpoi.szAddr);
    poi.szTel = GcharToNSString(gpoi.szTel);
    return [self collectPoiWith:poi];
}

/*!
 @brief  收藏指定条件兴趣点
 @param favoritePoi POI 收藏条件
 @return 收藏成功返回GD_ERR_OK，重复收藏返回GD_ERR_DUPLICATE_DATA。其他错误码请参见 GSTATUS
 */
+(GSTATUS)collectPoiWith:(MWFavoritePoi *)favoritePoi
{
    if (favoritePoi == nil)
    {
        return GD_ERR_FAILED;
    }
    GPOI pPOI = {0};
    pPOI.Coord.x = favoritePoi.longitude;
    pPOI.Coord.y = favoritePoi.latitude;
    pPOI.lCategoryID = favoritePoi.lCategoryID;
    pPOI.lDistance = favoritePoi.lDistance;
    pPOI.lMatchCode = favoritePoi.lMatchCode;
    pPOI.lHilightFlag = favoritePoi.lHilightFlag;
    pPOI.lAdminCode = favoritePoi.lAdminCode;
    pPOI.stPoiId = favoritePoi.stPoiId;
    pPOI.lNaviLat = favoritePoi.lNaviLat;
    pPOI.lNaviLon = favoritePoi.lNaviLon;
    
    Gchar *str =  NSStringToGchar(favoritePoi.szName);
    if(str)
    {
        GcharMemcpy(pPOI.szName, str, GMAX_POI_NAME_LEN+1);
    }
    str = NSStringToGchar(favoritePoi.szAddr);
    if(str)
    {
        GcharMemcpy(pPOI.szAddr, str, GMAX_POI_ADDR_LEN+1);
    }
    str = NSStringToGchar(favoritePoi.szTel);
    if(str)
    {
        GcharMemcpy(pPOI.szTel, str,GMAX_POI_TEL_LEN + 1);
    }
    
    pPOI.lPoiIndex = favoritePoi.lPoiIndex;
    pPOI.ucFlag = favoritePoi.ucFlag;
    pPOI.Reserved = favoritePoi.Reserved;
    //    pPOI.usNodeId = favoritePoi.usNodeId;
    
    
    GSTATUS res = GDBL_AddFavorite(favoritePoi.eCategory,favoritePoi.eIconID,&pPOI);
    if (bSynNetData == NO)
    {
        if (res == GD_ERR_OK || res == GD_ERR_DUPLICATE_DATA)               //成功，则将点同步至本地文件
        {
            NSString *file_path = nil;
            file_path = [Collect_Directory stringByAppendingFormat:@"/FavoriteList%d.plist",favoritePoi.eCategory];
            if (favoritePoi.eCategory == GFAVORITE_CATEGORY_HOME || favoritePoi.eCategory == GFAVORITE_CATEGORY_COMPANY)
            {
                //家和公司直接替换无需去重，因为家和公司只有一个
                MWFavorite *favoriteList = nil;
                favoriteList = [[[MWFavorite alloc] init] autorelease];
                favoritePoi.actionType = 1; //新增
                [favoriteList.pFavoritePOIArray addObject:favoritePoi];
                favoriteList.nNumberOfItem = [favoriteList.pFavoritePOIArray count];
                favoritePoi.nIndex = 0;
                if (![NSKeyedArchiver archiveRootObject:favoriteList toFile:file_path])
                {
                    NSLog(@"-------------同步至本地文件失败-----------------");
                }
                else
                {
                    NSLog(@"-------------同步至本地文件成功-----------------");
                }
            }
            else
            {
                favoritePoi.actionType = 1; //新增
                MWFavorite *favoriteList = nil;
                favoriteList = [NSKeyedUnarchiver unarchiveObjectWithFile:file_path];
                if (favoriteList == nil)
                {
                    favoriteList = [[[MWFavorite alloc] init] autorelease];
                }
                for (int i = 0 ; i < [favoriteList.pFavoritePOIArray count]; i++)
                {
                    MWFavoritePoi *poi = [favoriteList.pFavoritePOIArray objectAtIndex:i];
                    if ([MWPoiOperator isTwoPoiEqual:poi two:favoritePoi])
                    {
                        favoritePoi.actionType = 3; //修改
                            [favoriteList.pFavoritePOIArray removeObject:poi];
                        break;
                    }
                }
                    [favoriteList.pFavoritePOIArray insertObject:favoritePoi atIndex:0];  //modify by gzm for 最新收藏的poi应该显示在最上面 at 2014-10-30
                    favoriteList.nNumberOfItem = [favoriteList.pFavoritePOIArray count];
                
                if (![NSKeyedArchiver archiveRootObject:favoriteList toFile:file_path])
                {
                    NSLog(@"-------------同步至本地文件失败-----------------");
                }
                else
                {
                    NSLog(@"-------------同步至本地文件成功-----------------");
                }
            }
        }
        else if (res == GD_ERR_NO_SPACE)
        {
            GDAlertView *alert = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_FavoriteFull", Localize_POI)];
            [alert addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
            [alert show];
            [alert release];
        }
    }
    
    return res;
}

/*!
 @brief  编辑已收藏的兴趣点
 @param  favoritePoi 编辑后的兴趣点
 @return 编辑成功返回GD_ERR_OK。其他错误码请参见 GSTATUS
 */
+(GSTATUS)editeFavoritePoiWith:(MWFavoritePoi *)favoritePoi
{
    if (favoritePoi == nil)
    {
        return GD_ERR_FAILED;
    }
    
    GFAVORITEPOILIST *ppFavoritePOIList = {0};
    GSTATUS sign;
    sign = GDBL_GetFavoriteList(favoritePoi.eCategory, &ppFavoritePOIList);  //编辑前要先获取列表，要不编辑不了
    if (sign != GD_ERR_OK)
    {
        return sign;
    }
    
    GFAVORITEPOI pFavoritePOI = {0};
    
    NSDate *localDate = [NSDate date];
    NSCalendar  * cal=[NSCalendar  currentCalendar];
    NSUInteger  unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:localDate];
    NSInteger year=[conponent year];
    NSInteger month=[conponent month];
    NSInteger day=[conponent day];
    
    NSDateFormatter *timeFormatter = [[[NSDateFormatter alloc]init]autorelease];
    timeFormatter.dateFormat = @"HH:mm:ss";
    NSString *dateString = [timeFormatter stringFromDate:localDate];
    NSInteger hour = [[dateString CutToNSString:@":"] intValue];
    NSInteger min = [[dateString CutFromNSString:@":" Tostring:@":"] intValue];
    NSInteger second = [[dateString CutToNSStringBackWard:@":"] intValue];
    
    pFavoritePOI.Date.year = year;
    pFavoritePOI.Date.month = month;
    pFavoritePOI.Date.day = day;
    pFavoritePOI.Time.hour = hour;
    pFavoritePOI.Time.minute = min;
    pFavoritePOI.Time.second = second;
    
    pFavoritePOI.eCategory = favoritePoi.eCategory;
    pFavoritePOI.eIconID = favoritePoi.eIconID;
    pFavoritePOI.nIndex = favoritePoi.nIndex;
    
    pFavoritePOI.Poi.Coord.x = favoritePoi.longitude;
    pFavoritePOI.Poi.Coord.y = favoritePoi.latitude;
    pFavoritePOI.Poi.lCategoryID = favoritePoi.lCategoryID;
    pFavoritePOI.Poi.lDistance = favoritePoi.lDistance;
    pFavoritePOI.Poi.lMatchCode = favoritePoi.lMatchCode;
    pFavoritePOI.Poi.lHilightFlag = favoritePoi.lHilightFlag;
    pFavoritePOI.Poi.lAdminCode = favoritePoi.lAdminCode;
    pFavoritePOI.Poi.stPoiId = favoritePoi.stPoiId;
    pFavoritePOI.Poi.lNaviLat = favoritePoi.lNaviLat;
    pFavoritePOI.Poi.lNaviLon = favoritePoi.lNaviLon;
    Gchar *str = NSStringToGchar(favoritePoi.szName) ;
    if(str)
    {
        GcharMemcpy(pFavoritePOI.Poi.szName, str, GMAX_POI_NAME_LEN+1);
    }
    str = NSStringToGchar(favoritePoi.szAddr) ;
    if(str)
    {
        GcharMemcpy(pFavoritePOI.Poi.szAddr, str, GMAX_POI_ADDR_LEN+1);
    }
    str = NSStringToGchar(favoritePoi.szTel);
    if(str)
    {
        GcharMemcpy(pFavoritePOI.Poi.szTel, str, GMAX_POI_TEL_LEN+1);
    }
    
    pFavoritePOI.Poi.lPoiIndex = favoritePoi.lPoiIndex;
    pFavoritePOI.Poi.ucFlag = favoritePoi.ucFlag;
    pFavoritePOI.Poi.Reserved = favoritePoi.Reserved;
    
    GSTATUS res = GDBL_EditFavorite(&pFavoritePOI);
    if (res == GD_ERR_OK)           //成功，则将点同步至本地文件
    {
        NSString *file_path = nil;
        file_path = [Collect_Directory stringByAppendingFormat:@"/FavoriteList%d.plist",favoritePoi.eCategory];
        MWFavorite *favoriteList = nil;
        favoriteList = [NSKeyedUnarchiver unarchiveObjectWithFile:file_path];
        MWFavorite *replacePoi = [favoriteList.pFavoritePOIArray caObjectsAtIndex:favoritePoi.nIndex];;
        if (replacePoi)
        {
            [favoriteList.pFavoritePOIArray replaceObjectAtIndex:favoritePoi.nIndex withObject:favoritePoi];
            favoritePoi.actionType = 3; //修改
            if (![NSKeyedArchiver archiveRootObject:favoriteList toFile:file_path])
            {
                NSLog(@"-------------同步至本地文件失败-----------------");
                return GD_ERR_FAILED;
            }
            else
            {
                NSLog(@"-------------同步至本地文件成功-----------------");
            }
        }
        else
        {
            return GD_ERR_NO_DATA;
        }
        return GD_ERR_OK;
    }
    return res;
}

+(GSTATUS)getPoiListWith:(GFAVORITECATEGORY)eCategory poiList:(MWFavorite **)resultList
{
    GFAVORITEPOILIST *ppFavoritePOIList = GNULL;
    NSString *file_path = nil;
    file_path = [Collect_Directory stringByAppendingFormat:@"/FavoriteList%d.plist",eCategory];
    MWFavorite *favoriteList = nil;
    favoriteList = [NSKeyedUnarchiver unarchiveObjectWithFile:file_path];
    
    BOOL isResafe = NO;  //是否需要重新保存
    
    int limitCount = LimitCount_Fav;
    if (eCategory == GFAVORITE_CATEGORY_DEFAULT) {
        limitCount = LimitCount_Fav;
    }
    else if (eCategory == GFAVORITE_CATEGORY_HISTORY) {
        limitCount = LimitCount_His;
    }
        
    if (favoriteList)
    {
        NSMutableArray *arrayPoi = [NSMutableArray array];
        for (int i = 0;i < [favoriteList.pFavoritePOIArray count];i++)
        {
            MWFavoritePoi *poi = [favoriteList.pFavoritePOIArray caObjectsAtIndex:i];
            poi.nIndex = i;
            if (poi.actionType != 2) //不为删除状态则显示
            {
                if ([arrayPoi count] < limitCount)
                {
                    [arrayPoi addObject:poi];
                }
                else
                {
                    isResafe = YES;
                    poi.actionType = 2; //超过限制置为删除状态
                }
            }
        }
        MWFavorite *returnFav = [[[MWFavorite alloc] init]autorelease];
        returnFav.pFavoritePOIArray = arrayPoi;
        returnFav.nNumberOfItem = [arrayPoi count];
        *resultList = returnFav;
    }
    else
    {
        favoriteList = [[[MWFavorite alloc] init]autorelease];
        *resultList = favoriteList;
    }
    
    GSTATUS res =  GDBL_GetFavoriteList(eCategory, &ppFavoritePOIList);
    if( GD_ERR_OK == res)
    {
        GFAVORITEICON favIcon = GFAVORITE_ICON_DEFAULT;
        if (eCategory == GFAVORITE_CATEGORY_HOME)
        {
            favIcon = GFAVORITE_ICON_HOME;
        }
        else if (eCategory == GFAVORITE_CATEGORY_COMPANY)
        {
            favIcon = GFAVORITE_ICON_COMPANY;
        }
        else if (eCategory == GFAVORITE_CATEGORY_HISTORY)
        {
            favIcon = GFAVORITE_ICON_HISTORY;
        }
        
        BOOL isAdd = NO;
        for (int i = 0; i < ppFavoritePOIList->nNumberOfItem; i++)
        {
            GFAVORITEPOI gfavePoi = ppFavoritePOIList->pFavoritePOI[i];
            GPOI gpoi = gfavePoi.Poi;
            BOOL isExit = NO;
            for (int j = 0; j < [favoriteList.pFavoritePOIArray count]; j++)
            {
                MWFavoritePoi *poi = [favoriteList.pFavoritePOIArray objectAtIndex:j];
                if (gpoi.Coord.x == poi.longitude && gpoi.Coord.y == poi.latitude)
                {
                    isExit = YES;
                    break;
                }
            }
            if (!isExit)
            {
                isAdd = YES;
                [favoriteList.pFavoritePOIArray addObject:[MWPoiOperator getPoiWith:eCategory icon:favIcon poi:gpoi]];
            }
            if (isAdd)
            {
                if (favoriteList)
                {
                    NSMutableArray *arrayPoi = [NSMutableArray array];
                    for (int i = 0;i < [favoriteList.pFavoritePOIArray count];i++)
                    {
                        MWFavoritePoi *poi = [favoriteList.pFavoritePOIArray caObjectsAtIndex:i];
                        poi.nIndex = i;
                        if (poi.actionType != 2) //不为删除状态则显示
                        {
                            if ([arrayPoi count] < limitCount)
                            {
                                [arrayPoi addObject:poi];
                            }
                            else
                            {
                                isResafe = YES;
                                poi.actionType = 2; //超过限制置为删除状态
                            }
                        }
                    }
                    MWFavorite *returnFav = [[[MWFavorite alloc] init]autorelease];
                    returnFav.pFavoritePOIArray = arrayPoi;
                    returnFav.nNumberOfItem = [arrayPoi count];
                    *resultList = returnFav;
                }
            }
        }
    }
    if (isResafe) {
        [NSKeyedArchiver archiveRootObject:favoriteList toFile:file_path];
    }
    return GD_ERR_OK;
}

/*!
 @brief  删除收藏夹poi(参数为索引值)
 @param   index 收藏的兴趣点的索引 (即 MWFavoritePoi 类中的 nIndex)
 @return 删除成功返回GD_ERR_OK。其他错误码请参见 GSTATUS
 */
+(GSTATUS)deleteFavoriteWith:(GFAVORITECATEGORY)eCategory index:(int)index;
{
    NSString *file_path = nil;
    file_path = [Collect_Directory stringByAppendingFormat:@"/FavoriteList%d.plist",eCategory];
    MWFavorite *favoriteList = nil;
    favoriteList = [NSKeyedUnarchiver unarchiveObjectWithFile:file_path];
    if (favoriteList)
    {
        MWFavoritePoi *poi = [favoriteList.pFavoritePOIArray caObjectsAtIndex:index];
        if (poi)
        {
            poi.actionType = 2;
            if (![NSKeyedArchiver archiveRootObject:favoriteList toFile:file_path])
            {
                NSLog(@"-------------同步至本地文件失败-----------------");
                return GD_ERR_FAILED;
            }
            else
            {
                NSLog(@"-------------同步至本地文件成功-----------------");
                //删除引擎电子眼
                GFAVORITEPOILIST *ppFavoritePOIList = GNULL;
                GSTATUS res = GDBL_GetFavoriteList(eCategory, &ppFavoritePOIList);
                if( GD_ERR_OK == res)
                {
                    for (int i = 0; i < ppFavoritePOIList->nNumberOfItem; i++)
                    {
                        GFAVORITEPOI gfavePoi = ppFavoritePOIList->pFavoritePOI[i];
                        GPOI gpoi = gfavePoi.Poi;
                        if (gpoi.Coord.x == poi.longitude && gpoi.Coord.y == poi.latitude && [GcharToNSString(gpoi.szName) isEqualToString:poi.szName])
                        {
                            int deleteIndex = gfavePoi.nIndex;
                            res = GDBL_DelFavoriteByIndex(&deleteIndex,1);
                            break;
                        }
                    }
                    return res;
                }
            }
        }
        else
        {
            return GD_ERR_NO_DATA;
        }
    }
    else
    {
        return GD_ERR_NO_DATA;
    }
    return GD_ERR_OK;
}

/*!
 @brief  清空收藏夹兴趣点
 @param   eCategory poi的类型
 @return 删除成功返回GD_ERR_OK。其他错误码请参见 GSTATUS
 */
+(GSTATUS)clearFavoriteWith:(GFAVORITECATEGORY)eCategory
{
    GFAVORITEPOILIST *ppFavoritePOIList = GNULL;
    GDBL_GetFavoriteList(eCategory, &ppFavoritePOIList);
    GSTATUS res = GDBL_ClearFavorite(eCategory);
    if (res == GD_ERR_OK)
    {
        NSString *file_path = nil;
        file_path = [Collect_Directory stringByAppendingFormat:@"/FavoriteList%d.plist",eCategory];
        if (bSynNetData)
        {
            if ([[NSFileManager defaultManager] fileExistsAtPath:file_path])
            {
                [[NSFileManager defaultManager] removeItemAtPath:file_path error:nil];
            }
        }
        else
        {
            MWFavorite *favoriteList = nil;
            favoriteList = [NSKeyedUnarchiver unarchiveObjectWithFile:file_path];
            if (favoriteList)
            {
                for (MWFavoritePoi *poi in favoriteList.pFavoritePOIArray)
                {
                    poi.actionType = 2;
                }
                if (![NSKeyedArchiver archiveRootObject:favoriteList toFile:file_path])
                {
                    NSLog(@"-------------同步至本地文件失败-----------------");
                    return GD_ERR_FAILED;
                }
                else
                {
                    NSLog(@"-------------同步至本地文件成功-----------------");
                }
            }
            else
            {
                return GD_ERR_NO_DATA;
            }
        }
        return GD_ERR_OK;
    }
    return res;
}

/**
 *	判断该点是否收藏
 *
 *	@param	favoritePoi	要判断的点
 *
 *	@return	已收藏返回YES，未收藏返回NO
 */
+ (BOOL)isCollect:(MWPoi *)favoritePoi
{
    if (favoritePoi == nil)
    {
        return NO;
    }
    NSString *file_path = nil;
    file_path = [Collect_Directory stringByAppendingFormat:@"/FavoriteList%d.plist",GFAVORITE_CATEGORY_DEFAULT];
    MWFavorite *favoriteList = nil;
    favoriteList = [NSKeyedUnarchiver unarchiveObjectWithFile:file_path];
    if (favoriteList)
    {
        for (int i = 0 ; i < [favoriteList.pFavoritePOIArray count]; i++)
        {
            MWFavoritePoi *poi = [favoriteList.pFavoritePOIArray objectAtIndex:i];
            if ([MWPoiOperator isTwoPoiEqual:poi two:favoritePoi])
            {
                if (poi.actionType != 2)  //是否为删除标志
                {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

/**
 *	若该点已收藏，则取消收藏该点，若未收藏则收藏该点
 *
 *	@param	favoritePoi	要收藏的点
 *
 *	@return	收藏，取消收藏成功返回YES 否则返回NO
 */
+ (BOOL)reverseCollectPoi:(MWPoi *)favoritePoi
{
    if (favoritePoi == nil)
    {
        return NO;
    }
    if ([MWPoiOperator isCollect:favoritePoi])
    {
        NSString *file_path = nil;
        file_path = [Collect_Directory stringByAppendingFormat:@"/FavoriteList%d.plist",GFAVORITE_CATEGORY_DEFAULT];
        MWFavorite *favoriteList = nil;
        favoriteList = [NSKeyedUnarchiver unarchiveObjectWithFile:file_path];
        if (favoriteList)
        {
            for (int i = 0 ; i < [favoriteList.pFavoritePOIArray count]; i++)
            {
                MWFavoritePoi *poi = [favoriteList.pFavoritePOIArray objectAtIndex:i];
                if ([MWPoiOperator isTwoPoiEqual:poi two:favoritePoi])
                {
                    if (poi.actionType != 2)  //是否为删除标志
                    {
                        GSTATUS res = [MWPoiOperator deleteFavoriteWith:GFAVORITE_CATEGORY_DEFAULT index:poi.nIndex];
                        if (res == GD_ERR_OK)
                        {
                            return YES;
                        }
                    }
                }
            }
        }
    }
    else
    {
        MWFavoritePoi *favorite_temp = [[[MWFavoritePoi alloc] init] autorelease];
        favorite_temp.eCategory = GFAVORITE_CATEGORY_DEFAULT;
        favorite_temp.eIconID = GFAVORITE_ICON_DEFAULT;
        favorite_temp.longitude = favoritePoi.longitude;
        favorite_temp.latitude = favoritePoi.latitude;
        favorite_temp.lCategoryID = favoritePoi.lCategoryID;
        favorite_temp.lDistance = favoritePoi.lDistance;
        favorite_temp.lMatchCode = favoritePoi.lMatchCode;
        favorite_temp.lHilightFlag = favoritePoi.lHilightFlag;
        favorite_temp.lAdminCode = favoritePoi.lAdminCode;
        favorite_temp.stPoiId = favoritePoi.stPoiId;
        favorite_temp.lNaviLat = favoritePoi.lNaviLat;
        favorite_temp.lNaviLon = favoritePoi.lNaviLon;
        favorite_temp.lPoiIndex = favoritePoi.lPoiIndex;
        favorite_temp.ucFlag = favoritePoi.ucFlag;
        favorite_temp.Reserved = favoritePoi.Reserved;
        favorite_temp.usNodeId = favoritePoi.usNodeId;
        favorite_temp.szAddr = favoritePoi.szAddr;
        favorite_temp.szName = favoritePoi.szName;
        favorite_temp.szTel = favoritePoi.szTel;
        favorite_temp.szTown = favoritePoi.szTown;
        GSTATUS res = [self collectPoiWith:favorite_temp];
        if (res == GD_ERR_OK)
        {
            return YES;
        }
    }
    return NO;
}

/**
 *	MWPoi 结构转 GPoi结构
 *
 *	@param	mwPoi 传入的值 gPoi 转化后的值
 *
 *	@return	转化成功返回YES 否则返回NO
 */
+ (BOOL)MWPoiToGPoi:(MWPoi *)mwPoi GPoi:(GPOI *)gPoi
{
    if (mwPoi == nil)
    {
        return NO;
    }
    
    gPoi->Coord.x = mwPoi.longitude;
    gPoi->Coord.y = mwPoi.latitude;
    gPoi->lCategoryID = mwPoi.lCategoryID;
    gPoi->lDistance = mwPoi.lDistance;
    gPoi->lMatchCode = mwPoi.lMatchCode;
    gPoi->lHilightFlag = mwPoi.lHilightFlag;
    gPoi->lAdminCode = mwPoi.lAdminCode;
    gPoi->stPoiId = mwPoi.stPoiId;
    gPoi->lNaviLat = mwPoi.lNaviLat;
    gPoi->lNaviLon = mwPoi.lNaviLon;
    
    Gchar *str =  NSStringToGchar(mwPoi.szName);
    if(str)
    {
        GcharMemcpy(gPoi->szName, str, GMAX_POI_NAME_LEN+1);
    }
    str = NSStringToGchar(mwPoi.szAddr);
    if(str)
    {
        GcharMemcpy(gPoi->szAddr, str, GMAX_POI_NAME_LEN+1);
    }
    str = NSStringToGchar(mwPoi.szTel);
    if(str)
    {
        GcharMemcpy(gPoi->szTel, str, GMAX_POI_NAME_LEN+1);
    }
    
    gPoi->lPoiIndex = mwPoi.lPoiIndex;
    gPoi->ucFlag = mwPoi.ucFlag;
    gPoi->Reserved = mwPoi.Reserved;
    return YES;
}

#pragma mark 电子眼接口

/*!
 @brief  同步电子眼
 @param   option 电子眼同步条件
 @param   type     请求类型
 @param   delegate     委托，同步结果的返回
 */
+ (BOOL)synSmartEyesWith:(MWSmartEyesOption *)option requestType:(RequestType)type delegate:(id<MWPoiOperatorDelegate>)delegate
{
    NSArray *array;
    GDBL_GetAccountInfo(&array);
    int loginType = [[array caObjectsAtIndex:0] intValue];
    if (loginType == 0)
    {
        return NO;
    }
    if (loginType == 1 || loginType == 2)
    {
        [MWPoiOperator synBeijingSmartEyesWith:option requestType:type delegate:delegate];
    }
    else
    {
        [MWPoiOperator synXiamenSmartEyesWith:option requestType:type delegate:delegate];
    }
    return YES;
}

/*!
 @brief  同步厦门服务器电子眼
 @param   option 电子眼同步条件
 @param   type     请求类型
 @param   delegate     委托，同步结果的返回
 */
+ (BOOL)synXiamenSmartEyesWith:(MWSmartEyesOption *)option requestType:(RequestType)type delegate:(id<MWPoiOperatorDelegate>)delegate
{
    MWSmartEyes *smartEyes = nil;
    NSString *file_path = [Collect_Directory stringByAppendingFormat:@"/SafeList.plist"];
    smartEyes = [NSKeyedUnarchiver unarchiveObjectWithFile:file_path];
    if (smartEyes == nil)
    {
        NSLog(@"无文件数据");
        smartEyes = [[[MWSmartEyes alloc] init ]autorelease];
    }
    /**
     组转上传数据
     */
    NSArray *poiList = smartEyes.smartEyesArray;  //上传改动的poi信息
    NSArray *array;
    GDBL_GetAccountInfo(&array);
    int loginType = [[array objectAtIndex:0] intValue];
    NSString *url = nil;
    NSString *userId = nil;
    if (loginType == 3 || loginType == 5)
    {
        url = [NSString stringWithFormat:@"%@%@out=xml&tpuserid=%@&tptype=1",kNetDomain,Syn_SmartEye,[array objectAtIndex:5]];
    }
    else if (loginType == 4 || loginType == 6)
    {
        url = [NSString stringWithFormat:@"%@%@out=xml&tpuserid=%@&tptype=2",kNetDomain,Syn_SmartEye,[array objectAtIndex:5]];
    }
    userId = [array caObjectsAtIndex:7];  //记录用户id
    //判断上次同步的 用户与此次是否相同，不同则将时间置为较早时间
    if (![smartEyes.userId isEqualToString:userId])
    {
        GDATE	Date_tmp = {1975,1,1};
        smartEyes.Date	= Date_tmp;
        GTIME	Time_tmp = {1,1,1};
        smartEyes.Time	= Time_tmp;
        MWSmartEyes *allSmartEyes;
        [self getSmartEyesListWith:GSAFE_CATEGORY_ALL poiList:&allSmartEyes];
        for (MWSmartEyesItem *temp in allSmartEyes.smartEyesArray)
        {
            temp.actionType = 1;
        }
        poiList = allSmartEyes.smartEyesArray;
    }
    
    NSString *temp = @"<?xml version=\"1.0\" encoding=\"utf-8\"?><archive>";
    temp = [temp stringByAppendingFormat:@"<lasttime>%d-%02d-%02d %02d:%02d:%02d</lasttime><context>",smartEyes.Date.year,smartEyes.Date.month,smartEyes.Date.day,smartEyes.Time.hour,smartEyes.Time.minute,smartEyes.Time.second];
    int operatorCount = 0;
    for(int i = 0; i < [poiList count]; i++)
    {
        MWSmartEyesItem *tmp = [poiList objectAtIndex:i];
        if (tmp.actionType > 0)
        {
            temp = [temp stringByAppendingFormat:@"<item><item_id>%d</item_id><longitude>%ld</longitude>",tmp.nId,tmp.longitude];
            temp = [temp stringByAppendingFormat:@"<latitude>%ld</latitude>",tmp.latitude];
            temp = [temp stringByAppendingFormat:@"<name>%@</name>",tmp.szName];
            temp = [temp stringByAppendingFormat:@"<type>0001</type>"];
            temp = [temp stringByAppendingFormat:@"<flag>%d</flag><town>%@</town><angle>%d</angle>",tmp.eCategory,@"",tmp.nAngle];
            temp = [temp stringByAppendingFormat:@"<speed>%d</speed><detail></detail><state>%d</state></item>",tmp.nSpeed,tmp.actionType];
            operatorCount++;
        }
    }
    if (operatorCount == 0)
    {
        temp = [temp stringByAppendingString:@"<item></item>"];
    }
    temp = [temp stringByAppendingString:@"</context></archive>"];
    NSData *requstBody = [temp dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    MWPoiOperator *operator = [[MWPoiOperator alloc] initWithDelegate:delegate];    //回调中释放
    operator.userId = userId;
    operator.originalClass = object_getClass(delegate);
    
    NetBaseRequestCondition *net_condition = [NetBaseRequestCondition requestCondition];
    net_condition.requestType = type;
    net_condition.baceURL = url;
    net_condition.bodyData = requstBody;
    net_condition.httpMethod = @"POST";
    [[NetExt sharedInstance] requestWithCondition:net_condition delegate:operator];
    
    return YES;
}

/*!
 @brief  同步北京服务器电子眼
 @param   option 电子眼同步条件
 @param   type     请求类型
 @param   delegate     委托，同步结果的返回
 */
+ (BOOL)synBeijingSmartEyesWith:(MWSmartEyesOption *)option requestType:(RequestType)type delegate:(id<MWPoiOperatorDelegate>)delegate
{
    MWSmartEyes *safeList = nil;
    NSString *file_path = [Collect_Directory stringByAppendingFormat:@"/SafeList.plist"];
    safeList = [NSKeyedUnarchiver unarchiveObjectWithFile:file_path];
    if (safeList == nil)
    {
        NSLog(@"无文件数据");
        safeList = [[[MWSmartEyes alloc] init] autorelease];
    }
    NSArray *poiList = safeList.smartEyesArray;  //上传改动的poi信息
    NSArray *array;
    GDBL_GetAccountInfo(&array);
    NSString* userId = [array caObjectsAtIndex:7];  //记录用户id
    //判断上次同步的 用户与此次是否相同，不同则将时间置为较早时间
    if (![safeList.userId isEqualToString:userId])
    {
        GDATE	Date_tmp = {1975,1,1};
        safeList.Date	= Date_tmp;
        GTIME	Time_tmp = {1,1,1};
        safeList.Time	= Time_tmp;
        MWSmartEyes *allSmartEyes;
        [self getSmartEyesListWith:GSAFE_CATEGORY_ALL poiList:&allSmartEyes];
        for (MWSmartEyesItem *temp in allSmartEyes.smartEyesArray)
        {
            temp.actionType = 1;
        }
        poiList = allSmartEyes.smartEyesArray;
    }
    NSString *xmlHead = [GD_NSObjectToXML xmlHeadString];
    NSMutableDictionary *svccont = [NSMutableDictionary dictionary];
    NSMutableDictionary *bodyDic = [NSMutableDictionary dictionary];
    [svccont setValue:bodyDic forKey:@"svccont"];
    [bodyDic setValue:IDFA forKey:@"imei"];
    [bodyDic setValue:KNetChannelID forKey:@"syscode"];
    [bodyDic setValue:UserID_Account forKey:@"userid"];
    [bodyDic setValue:UserSID forKey:@"sessionid"];
    NSMutableDictionary *list = [NSMutableDictionary dictionary];
    [bodyDic setValue:list forKey:@"list"];
    NSMutableArray *poiArray = [NSMutableArray array];
    for (int i = 0; i < [poiList count]; i ++)
    {
        MWSmartEyesItem *poi = [poiList objectAtIndex:i];
        if (poi.actionType > 0)
        {
            NSMutableDictionary *poiDic = [NSMutableDictionary dictionary];
            [poiDic setValue:poi.netPoiId forKey:@"id"];
            [poiDic setValue:[NSString stringWithFormat:@"%ld",poi.longitude] forKey:@"x"];
            [poiDic setValue:[NSString stringWithFormat:@"%ld",poi.latitude] forKey:@"y"];
            [poiDic setValue:[poi.szName dataUsingEncoding:NSUTF8StringEncoding] forKey:@"name"];
            [poiDic setValue:[poi.szAddr dataUsingEncoding:NSUTF8StringEncoding] forKey:@"address"];
            [poiDic setValue:poi.szTel forKey:@"tel"];
            [poiDic setValue:[NSString stringWithFormat:@"%d",poi.lAdminCode] forKey:@"adcode"];
            int safeCategory = 0;
            if (poi.eCategory == GSAFE_CATEGORY_SPEEDLIMIT)
            {
                safeCategory = 1;
            }
            else if (poi.eCategory == GSAFE_CATEGORY_RESTRICTION_CAMERA)
            {
                safeCategory = 4;
            }
            else if (poi.eCategory == GSAFE_CATEGORY_ILLEGAL_CAMERA)
            {
                safeCategory = 2;
            }
            else if (poi.eCategory == GSAFE_CATEGORY_SURVEILLANCE_CAMERA)
            {
                safeCategory = 3;
            }
            else if (poi.eCategory == GSAFE_CATEGORY_LANE_CAMERA)
            {
                safeCategory = 5;
            }
            else
            {
                safeCategory = 1;
            }
            [poiDic setValue:[NSString stringWithFormat:@"%d",safeCategory] forKey:@"edogtype"];
            [poiDic setValue:[NSString stringWithFormat:@"%d",poi.nSpeed] forKey:@"v"];
            if (poi.actionType == 2)
            {
                [poiDic setValue:[NSString stringWithFormat:@"%d",3] forKey:@"opr"];
            }
            else if (poi.actionType == 3)
            {
                [poiDic setValue:[NSString stringWithFormat:@"%d",2] forKey:@"opr"];
            }
            else
            {
                [poiDic setValue:[NSString stringWithFormat:@"%d",poi.actionType] forKey:@"opr"];
            }
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyyMMddHHmmss"];
            NSString *dateStr = [formatter stringFromDate:[NSDate date]];
            [poiDic setValue:dateStr forKey:@"oprtime"];
            [formatter release];
            [poiDic setValue:[NSString stringWithFormat:@"%d",1] forKey:@"subtype"];
            [poiArray addObject:poiDic];
        }
    }
    if ([poiArray count] > 0)
    {
        [list setValue:poiArray forKey:@"poi"];
    }
    NSString *xmlBody = [GD_NSObjectToXML convertDictionaryToXML:svccont rootName:@"opg"];
    xmlBody = [xmlBody stringByReplacingOccurrencesOfString:@"<list>" withString:[NSString stringWithFormat:@"<list type=\"2\">"]];
    
    NSString *temp = [xmlHead stringByAppendingString:xmlBody];
//    NSString *encrypt = [ThreeDes encrypt:temp]; //加密
    NSData *requstBody = [temp dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    /**
     组转上传数据
     */
    Guint64 t;
    struct timeval tv_begin;
    gettimeofday(&tv_begin, NULL);
    t = (Guint64)1000000 * (tv_begin.tv_sec) + tv_begin.tv_usec;
    t = t/1000;
    
    NSMutableDictionary *urlParams = [NSMutableDictionary dictionary];
    [urlParams setValue:[NSString stringWithFormat:@"%llu",t] forKey:@"timestamp"];
    [urlParams setValue:@"0" forKey:@"en"];
    [urlParams setValue:IDFA forKey:@"imei"];
    [urlParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [urlParams setValue:MapVersionNoV forKey:@"mapversion"];
    [urlParams setValue:deviceModel forKey:@"model"];
    [urlParams setValue:DeviceResolutionString forKey:@"resolution"];
    [urlParams setValue:CurrentSystemVersion forKey:@"os"];
    [urlParams setValue:UserSID forKey:@"sid"];
    [urlParams setValue:UserID_Account forKey:@"userid"];
    [urlParams setValue:KNetChannelID forKey:@"syscode"];
    [urlParams setValue:PID forKey:@"pid"];
    NSString *signString = [[NSString stringWithFormat:@"%@%@%@@%@",KNetChannelID,@"/nis/syncdata",[NSString stringWithFormat:@"%llu",t],kNetSignKey] stringFromMD5];
    if (signString)
    {
        [urlParams setValue:signString forKey:@"sign"];
    }
    
    
    MWPoiOperator *operator = [[MWPoiOperator alloc] initWithDelegate:delegate];    //回调中释放
    operator.userId = userId;
    operator.originalClass = object_getClass(delegate);
    
    NetBaseRequestCondition *net_condition = [NetBaseRequestCondition requestCondition];
    net_condition.requestType = type;
    net_condition.baceURL = kSynFavPoiRequestURL;
    net_condition.bodyData = requstBody;
    net_condition.httpMethod = @"POST";
    net_condition.httpHeaderFieldParams = urlParams;
    
    
    [[NetExt sharedInstance] requestWithCondition:net_condition delegate:operator];
    
    return YES;
}

/*!
 @brief  取消同步收藏电子眼
 @param   type     请求类型
 @return	成功返回YES 否则返回NO
 */
+ (BOOL)cancelSynSmartEyesWith:(RequestType)type
{
    [[NetExt sharedInstance] Net_CancelRequestWithType:type];
    return YES;
}

/*!
 @brief  收藏电子眼
 @param smartEyesItem 收藏条件   注：（无需设置Date，Time两个参数）
 @return 收藏成功返回GD_ERR_OK，重复收藏返回GD_ERR_DUPLICATE_DATA。其他错误码请参见 GSTATUS
 */
+(GSTATUS)collectSmartEyesWith:(MWSmartEyesItem *)smartEyesItem
{
    if (smartEyesItem == nil)
    {
        return GD_ERR_FAILED;
    }
    GUSERSAFEINFO pSafeInfo = {0};
    pSafeInfo.nIndex = smartEyesItem.nIndex;
    pSafeInfo.nId = smartEyesItem.nId;
    pSafeInfo.lAdminCode = smartEyesItem.lAdminCode;
    pSafeInfo.eCategory = smartEyesItem.eCategory;
    pSafeInfo.coord.x = smartEyesItem.longitude;
    pSafeInfo.coord.y = smartEyesItem.latitude;
    pSafeInfo.nSpeed = smartEyesItem.nSpeed;
    pSafeInfo.nAngle = 360;         //添加用户电子眼，需要对角度赋值nAngle =360，360指360个方向监控
    
    Gchar *str = NSStringToGchar(smartEyesItem.szName) ;
    if(str)
    {
        GcharMemcpy(pSafeInfo.szName, str, GMAX_USAFE_NAME_LEN + 1);
    }
    
    
    NSDate *localDate = [NSDate date];
    NSCalendar  * cal=[NSCalendar  currentCalendar];
    NSUInteger  unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:localDate];
    NSInteger year=[conponent year];
    NSInteger month=[conponent month];
    NSInteger day=[conponent day];
    
    NSDateFormatter *timeFormatter = [[[NSDateFormatter alloc]init]autorelease];
    timeFormatter.dateFormat = @"HH:mm:ss";
    NSString *dateString = [timeFormatter stringFromDate:localDate];
    NSInteger hour = [[dateString CutToNSString:@":"] intValue];
    NSInteger min = [[dateString CutFromNSString:@":" Tostring:@":"] intValue];
    NSInteger second = [[dateString CutToNSStringBackWard:@":"] intValue];
    
    pSafeInfo.Date.year = year;
    pSafeInfo.Date.month = month;
    pSafeInfo.Date.day = day;
    pSafeInfo.Time.hour = hour;
    pSafeInfo.Time.minute = min;
    pSafeInfo.Time.second = second;
    
    
    GSTATUS res = GDBL_AddUserSafeInfo(&pSafeInfo);  //引擎中同坐标、同类型、角度差30以内，被视为已存在
    if (bSynNetData == NO)
    {
        if (res == GD_ERR_OK || res == GD_ERR_DUPLICATE_DATA)
        {
            GDBL_FlushFileUserSafe();  //保存电子眼数据到文件里
            /***将MWFavorite类 保存至本地文件 用于同步收藏夹内容 路径见宏 Favorite_Path History_Path***/
            NSString *file_path = [Collect_Directory stringByAppendingFormat:@"/SafeList.plist"];
            smartEyesItem.actionType = 1;     //添加
            MWSmartEyes *smartEyes = nil;
            smartEyes = [NSKeyedUnarchiver unarchiveObjectWithFile:file_path];
            for (int i = 0 ; i < [smartEyes.smartEyesArray count]; i++)
            {
                MWSmartEyesItem *poi = [smartEyes.smartEyesArray objectAtIndex:i];
                if (poi.longitude == smartEyesItem.longitude && poi.latitude == smartEyesItem.latitude  && poi.eCategory == smartEyesItem.eCategory) //引擎中同坐标、同类型、角度差30以内，被视为已存在
                {
                    smartEyesItem.actionType = 3;     //更新
                        [smartEyes.smartEyesArray removeObject:poi];
                    break;
                }
            }
                if (smartEyes == nil)
                {
                    smartEyes = [[[MWSmartEyes alloc] init] autorelease];
                    smartEyes.smartEyesArray = [NSMutableArray array];
                }
                [smartEyes.smartEyesArray insertObject:smartEyesItem atIndex:0];   //modify by gzm for 最新收藏的poi应该显示在最上面 at 2014-10-30
            smartEyes.nNumberOfItem = [smartEyes.smartEyesArray count];
            if (![NSKeyedArchiver archiveRootObject:smartEyes toFile:file_path])
            {
                NSLog(@"-------------同步至本地文件失败-----------------");
            }
            else
            {
                NSLog(@"-------------同步至本地文件成功-----------------");
            }
            /******/
        }
    }
    return res;
}


/*!
 @brief  编辑已收藏的电子眼
 @param  favoritePoi 编辑后的电子眼  注：（无需设置Date，Time两个参数）
 @return 编辑成功返回GD_ERR_OK。其他错误码请参见 GSTATUS
 */
+(GSTATUS)editeSmartEyesWith:(MWSmartEyesItem *)smartEyesItem
{
    GUSERSAFEINFO pSafeInfo = {0};
    pSafeInfo.nIndex = smartEyesItem.nIndex;
    pSafeInfo.nId = smartEyesItem.nId;
    pSafeInfo.lAdminCode = smartEyesItem.lAdminCode;
    pSafeInfo.eCategory = smartEyesItem.eCategory;
    pSafeInfo.coord.x = smartEyesItem.longitude;
    pSafeInfo.coord.y = smartEyesItem.latitude;
    pSafeInfo.nSpeed = smartEyesItem.nSpeed;
    pSafeInfo.nAngle = smartEyesItem.nAngle;
    
    Gchar *str = NSStringToGchar(smartEyesItem.szName)  ;
    if(str)
    {
        GcharMemcpy(pSafeInfo.szName, str, GMAX_USAFE_NAME_LEN+1);
    }
    NSDate *localDate = [NSDate date];
    NSCalendar  * cal=[NSCalendar  currentCalendar];
    NSUInteger  unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:localDate];
    NSInteger year=[conponent year];
    NSInteger month=[conponent month];
    NSInteger day=[conponent day];
    
    NSDateFormatter *timeFormatter = [[[NSDateFormatter alloc]init]autorelease];
    timeFormatter.dateFormat = @"HH:mm:ss";
    NSString *dateString = [timeFormatter stringFromDate:localDate];
    NSInteger hour = [[dateString CutToNSString:@":"] intValue];
    NSInteger min = [[dateString CutFromNSString:@":" Tostring:@":"] intValue];
    NSInteger second = [[dateString CutToNSStringBackWard:@":"] intValue];
    
    pSafeInfo.Date.year = year;
    pSafeInfo.Date.month = month;
    pSafeInfo.Date.day = day;
    pSafeInfo.Time.hour = hour;
    pSafeInfo.Time.minute = min;
    pSafeInfo.Time.second = second;

    BOOL isSafeExist = NO;
    GUSERSAFEINFOLIST  *ppSafeInfoList = GNULL;
    GSTATUS sign = GDBL_GetUserSafeInfoList(smartEyesItem.eCategory,&ppSafeInfoList);//在编辑电子眼前需要获取电子眼列表
    if (sign == GD_ERR_OK && ppSafeInfoList)
    {
        for (int i = 0; i < ppSafeInfoList->nNumberOfItem; i++)
        {
            GUSERSAFEINFO pSafeInfo_temp = ppSafeInfoList->pSafeInfo[i];
            if (pSafeInfo_temp.coord.x == smartEyesItem.longitude && pSafeInfo_temp.coord.y == smartEyesItem.latitude)
            {
                pSafeInfo.nIndex = pSafeInfo_temp.nIndex;
                pSafeInfo.nId = pSafeInfo_temp.nId;
                isSafeExist = YES;
                break;
            }
        }
        if (isSafeExist == NO)  //引擎中不存在这个电子眼则加入
        {
            GDBL_AddUserSafeInfo(&pSafeInfo);
        }
    }
    GSTATUS res = GDBL_EditUserSafeInfo(&pSafeInfo);
    if (res == GD_ERR_OK || isSafeExist == NO)
    {
        res = GD_ERR_OK;
        GDBL_FlushFileUserSafe();  //保存电子眼数据到文件里
        /***将MWFavorite类 保存至本地文件 用于同步收藏夹内容 ***/
        NSString *file_path = [Collect_Directory stringByAppendingFormat:@"/SafeList.plist"];

        MWSmartEyes *safeList = nil;
        safeList = [NSKeyedUnarchiver unarchiveObjectWithFile:file_path];
        MWSmartEyesItem *replacePoi = [safeList.smartEyesArray caObjectsAtIndex:smartEyesItem.nIndex];;
        if (replacePoi)
        {
            smartEyesItem.actionType = 3;     //修改
            [safeList.smartEyesArray replaceObjectAtIndex:smartEyesItem.nIndex withObject:smartEyesItem];
            if (![NSKeyedArchiver archiveRootObject:safeList toFile:file_path])
            {
                NSLog(@"-------------同步至本地文件失败-----------------");
                return GD_ERR_FAILED;
            }
            else
            {
                NSLog(@"-------------同步至本地文件成功-----------------");
            }
        }
        else
        {
            return GD_ERR_NO_DATA;
        }
    }
    return res;
}

/*!
 @brief  获取已收藏的电子眼列表
 @param   eCategory 收藏的电子眼类别GSAFECATEGORY，用于标识要获取的收藏夹类别。
 @param   resultList 输出，用于返回收藏夹兴趣点列表。
 @return 收藏获取列表返回GD_ERR_OK。其他错误码请参见 GSTATUS
 */
+(GSTATUS)getSmartEyesListWith:(GSAFECATEGORY)eCategory poiList:(MWSmartEyes **)resultList
{
    NSString *file_path = nil;
    file_path = [Collect_Directory stringByAppendingFormat:@"/SafeList.plist"];
    MWSmartEyes *safeList = nil;
    safeList = [NSKeyedUnarchiver unarchiveObjectWithFile:file_path];
    
    BOOL isResafe = NO;  //是否需要重新保存
    int limitCount = LimitCount_Save;
    if (safeList)
    {
        NSMutableArray *arrayPoi = [NSMutableArray array];
        for (int i = 0;i < [safeList.smartEyesArray count];i++)
        {
            MWSmartEyesItem *poi = [safeList.smartEyesArray caObjectsAtIndex:i];
            poi.nIndex = i;
            if (poi.actionType != 2) //不为删除状态则显示
            {
                if ([arrayPoi count] < limitCount)
                {
                    [arrayPoi addObject:poi];
                }
                else
                {
                    isResafe = YES;
                    poi.actionType = 2; //超过限制置为删除状态
                }
            }
        }
        MWSmartEyes *returnSmart = [[[MWSmartEyes alloc] init] autorelease];
        returnSmart.smartEyesArray = arrayPoi;
        returnSmart.nNumberOfItem = [arrayPoi count];
        *resultList = returnSmart;
    }
    else
    {
        safeList = [[[MWSmartEyes alloc] init] autorelease];
        *resultList = safeList;
    }
    
    BOOL isAdd = NO;
    GUSERSAFEINFOLIST  *ppSafeInfoList;
    GSTATUS res = GDBL_GetUserSafeInfoList(GSAFE_CATEGORY_ALL,&ppSafeInfoList);
    if (res == GD_ERR_OK)
    {
        for (int i = 0; i < ppSafeInfoList->nNumberOfItem; i++)
        {
            GUSERSAFEINFO pSafeInfo = ppSafeInfoList->pSafeInfo[i];
            BOOL isExist = NO;
            for (int j = 0; j < [safeList.smartEyesArray count] ; j++)
            {
                MWSmartEyesItem *poi = [safeList.smartEyesArray objectAtIndex:j];
                if (pSafeInfo.coord.x == poi.longitude && pSafeInfo.coord.y == poi.latitude)
                {
                    isExist = YES;
                    break;
                }
            }
            if (isExist == NO)
            {
                GUSERSAFEINFO pSafeInfo = ppSafeInfoList->pSafeInfo[i];
                MWSmartEyesItem *poi = [[MWSmartEyesItem alloc] init];
                poi.longitude = pSafeInfo.coord.x;
                poi.latitude = pSafeInfo.coord.y;
                poi.lAdminCode = pSafeInfo.lAdminCode;
                poi.nSpeed = pSafeInfo.nSpeed;
                poi.eCategory = pSafeInfo.eCategory;
                poi.netPoiId = 0;
                poi.szName = GcharToNSString(pSafeInfo.szName);
                [safeList.smartEyesArray addObject:poi];
                [poi release];
                isAdd = YES;
            }
        }
        if (isAdd)
        {
            if (safeList)
            {
                NSMutableArray *arrayPoi = [NSMutableArray array];
                for (int i = 0;i < [safeList.smartEyesArray count];i++)
                {
                    MWSmartEyesItem *poi = [safeList.smartEyesArray caObjectsAtIndex:i];
                    poi.nIndex = i;
                    if (poi.actionType != 2) //不为删除状态则显示
                    {
                        if ([arrayPoi count] < limitCount)
                        {
                            [arrayPoi addObject:poi];
                        }
                        else
                        {
                            isResafe = YES;
                            poi.actionType = 2; //超过限制置为删除状态
                        }
                    }
                }
                MWSmartEyes *returnSmart = [[[MWSmartEyes alloc] init] autorelease];
                returnSmart.smartEyesArray = arrayPoi;
                returnSmart.nNumberOfItem = [arrayPoi count];
                *resultList = returnSmart;
            }
        }

    }
    
    if (isResafe)
    {
        [NSKeyedArchiver archiveRootObject:safeList toFile:file_path];
    }
    return GD_ERR_OK;

}

/*!
 @brief  删除收藏夹poi(参数为索引值)
 @param   index 收藏的电子眼的索引 (即 MWSmartEyesItem 类中的 nIndex)
 @return 删除成功返回GD_ERR_OK。其他错误码请参见 GSTATUS
 */
+(GSTATUS)deleteSmartEyesWithIndex:(int)index
{
    NSString *file_path = nil;
    file_path = [Collect_Directory stringByAppendingFormat:@"/SafeList.plist"];
    MWSmartEyes *safeList = nil;
    safeList = [NSKeyedUnarchiver unarchiveObjectWithFile:file_path];
    if (safeList)
    {
        MWSmartEyesItem *poi = [safeList.smartEyesArray caObjectsAtIndex:index];
        if (poi)
        {
            poi.actionType = 2;
            if (![NSKeyedArchiver archiveRootObject:safeList toFile:file_path])
            {
                NSLog(@"-------------同步至本地文件失败-----------------");
            }
            else
            {
                NSLog(@"-------------同步至本地文件成功-----------------");
                //删除引擎电子眼
                GUSERSAFEINFOLIST  *ppSafeInfoList;
                GSTATUS res = GDBL_GetUserSafeInfoList(GSAFE_CATEGORY_ALL,&ppSafeInfoList);
                if( GD_ERR_OK == res)
                {
                    for (int i = 0; i < ppSafeInfoList->nNumberOfItem; i++)
                    {
                        GUSERSAFEINFO pSafeInfo = ppSafeInfoList->pSafeInfo[i];
                        if (pSafeInfo.coord.x == poi.longitude && pSafeInfo.coord.y == poi.latitude && pSafeInfo.eCategory == poi.eCategory && pSafeInfo.nSpeed == poi.nSpeed && [GcharToNSString(pSafeInfo.szName) isEqualToString:poi.szName])
                        {
                            int deleteIndex = pSafeInfo.nIndex;
                            res = GDBL_DelUserSafeInfo(&deleteIndex, 1);
                            if (res == GD_ERR_OK)
                            {
                                GDBL_FlushFileUserSafe();  //保存电子眼数据到文件里
                            }
                            break;
                        }
                    }
                    return res;
                }
            }
        }
        else
        {
            return GD_ERR_NO_DATA;
        }
    }
    else
    {
        return GD_ERR_NO_DATA;
    }
    return GD_ERR_OK;
}

/*!
 @brief  清空收藏夹兴趣点
 @param   eCategory 电子眼的类型
 @return 删除成功返回GD_ERR_OK。其他错误码请参见 GSTATUS
 */
+(GSTATUS)clearSmartEyesWith:(GSAFECATEGORY)eCategory
{
    GUSERSAFEINFOLIST  *ppSafeInfoList;
    GDBL_GetUserSafeInfoList(GSAFE_CATEGORY_ALL,&ppSafeInfoList);
    GSTATUS res = GDBL_ClearUserSafeInfo(eCategory);
    if (res == GD_ERR_OK)
    {
        GDBL_FlushFileUserSafe();  //保存电子眼数据到文件里
        /***将MWFavorite类 保存至本地文件 用于同步收藏夹内容 路径见宏 Favorite_Path History_Path***/
        NSString *file_path = nil;
        file_path = [Collect_Directory stringByAppendingFormat:@"/SafeList.plist"];
        
        if (bSynNetData)
        {
            if ([[NSFileManager defaultManager] fileExistsAtPath:file_path])
            {
                [[NSFileManager defaultManager] removeItemAtPath:file_path error:nil];
            }
        }
        else
        {
            MWSmartEyes *safeList = [NSKeyedUnarchiver unarchiveObjectWithFile:file_path];
            if (safeList)
            {
                for (MWSmartEyesItem *poi in safeList.smartEyesArray)
                {
                    poi.actionType = 2;
                }
                if (![NSKeyedArchiver archiveRootObject:safeList toFile:file_path])
                {
                    NSLog(@"-------------同步至本地文件失败-----------------");
                }
                else
                {
                    NSLog(@"-------------同步至本地文件成功-----------------");
                }
            }
            /******/
        }
    }
    return res;
}

#pragma mark  联系人 接口

/*!
 @brief  上传联系人   回调：
 成功 -(void)uploadSuccessWith:(RequestType)type result:(id)result;
 失败 -(void)uploadFailWith:(RequestType)type error:(NSError *)error;
 @param   option 上传联系人时的条件
 @param   type 请求类型
 */
+(void)uploadContactWith:(MWContactOption *)option requestType:(RequestType)type delegate:(id<MWPoiOperatorDelegate>)delegate
{
    MWContact *contact = nil;
    [self getContactList:&contact];
    
    NSArray *poiList = contact.contactArray;
    
    NSArray *array = [[Account AccountInstance] getAccountInfo];
    int loginType = [[array objectAtIndex:0] intValue];
    
    NSString *url;
    
    if (loginType == 3 || loginType == 5)
    {
        url = [NSString stringWithFormat:@"%@favorites/uploadphonebook_v2/?out=xml&tpuserid=%@&tptype=1",kNetDomain,[array objectAtIndex:5]];
    }
    else if (loginType == 4 || loginType == 6)
    {
        url = [NSString stringWithFormat:@"%@favorites/uploadphonebook_v2/?out=xml&tpuserid=%@&tptype=2",kNetDomain,[array objectAtIndex:5]];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@favorites/uploadphonebook_v2/?out=xml&username=%@&password=%@",kNetDomain,option.userName,option.password];
    }
    
    NSString *temp = @"<?xml version=\"1.0\" encoding=\"utf-8\"?><archive><context>";
    
    for(int i = 0; i < [poiList count]; i++)
    {
        NameIndex *tmp = [poiList objectAtIndex:i];
        if (tmp._fullName == nil) {
            tmp._fullName = @"";
        }
        temp = [temp stringByAppendingFormat:@"<item><item_id>%d</item_id><name>%@</name>",i+1,tmp._fullName];
        
        
        
        temp = [temp stringByAppendingString:@"<phonenum>"];
        for (int j = 0; j < [tmp.phoneArray count]; j++) {
            temp = [temp stringByAppendingFormat:@"<phoneitem><phonetype>%@</phonetype><phonestring>%@</phonestring></phoneitem>",[tmp.phoneTypeArray objectAtIndex:j],[tmp.phoneArray objectAtIndex:j]];
        }
        temp = [temp stringByAppendingString:@"</phonenum>"];
        
        temp = [temp stringByAppendingString:@"<address>"];
        for (int j = 0; j < [tmp.addressArray count]; j++) {
            AddressItem *addressItem = [tmp.addressArray objectAtIndex:j];
            if (addressItem.type == nil) {
                addressItem.type = @"";
            }
            if (addressItem.city == nil) {
                addressItem.city = @"";
            }
            if (addressItem.country == nil) {
                addressItem.country = @"";
            }
            if (addressItem.countryCode == nil) {
                addressItem.countryCode = @"";
            }
            if (addressItem.state == nil) {
                addressItem.state = @"";
            }
            if (addressItem.street == nil) {
                addressItem.street = @"";
            }
            if (addressItem.zip == nil) {
                addressItem.zip = @"";
            }
            temp = [temp stringByAppendingFormat:@"<addressitem><addresstype>%@</addresstype><city>%@</city><country>%@</country><countrycode>%@</countrycode><state>%@</state><street>%@</street><zip>%@</zip></addressitem>",addressItem.type ,addressItem.city,addressItem.country,addressItem.countryCode,addressItem.state,addressItem.street,addressItem.zip];
        }
        temp = [temp stringByAppendingString:@"</address>"];
        
        temp = [temp stringByAppendingString:@"<email>"];
        for (int j = 0; j < [tmp.emailArray count]; j++) {
            temp = [temp stringByAppendingFormat:@"<emailitem><emailtype>%@</emailtype><emailstring>%@</emailstring></emailitem>",[tmp.emailTypeArray objectAtIndex:j],[tmp.emailArray objectAtIndex:j]];
        }
        temp = [temp stringByAppendingString:@"</email>"];
        
        temp = [temp stringByAppendingString:@"<url>"];
        for (int j = 0; j < [tmp.URLArray count]; j++) {
            temp = [temp stringByAppendingFormat:@"<urlitem><urltype>%@</urltype><urlstring>%@</urlstring><lastedittime>%@</lastedittime></urlitem>",[tmp.URLTypeArray objectAtIndex:j],[tmp.URLArray objectAtIndex:j],tmp.lastEditTime];
        }
        temp = [temp stringByAppendingString:@"</url></item>"];
        
    }
    if ([poiList count] == 0)
    {
        temp = [temp stringByAppendingString:@"<item></item>"];
    }
    temp = [temp stringByAppendingString:@"</context></archive>"];
    //NSLog(@"temp===%@",temp);
    
    NSData *requstBody = [temp dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    MWPoiOperator *operator = [[MWPoiOperator alloc] initWithDelegate:delegate];
    
    NetBaseRequestCondition *net_condition = [NetBaseRequestCondition requestCondition];
    net_condition.requestType = type;
    net_condition.baceURL = url;
    net_condition.bodyData = requstBody;
    net_condition.httpMethod = @"POST";
    
    [[NetExt sharedInstance] requestWithCondition:net_condition delegate:operator];
}

/*!
 @brief  下载联系人
 回调：
 成功 -(void)downloadSuccessWith:(RequestType)type result:(id)result;
 失败 -(void)downloadFailWith:(RequestType)type error:(NSError *)error;
 @param   option 下载联系人时的条件
 @param   type 请求类型
 */
+(void)downloadContactWith:(MWContactOption *)option requestType:(RequestType)type delegate:(id<MWPoiOperatorDelegate>)delegate
{
    NSArray *array = [[Account AccountInstance] getAccountInfo];
    int loginType = [[array objectAtIndex:0] intValue];
    
    NSString *url;
    
    if (loginType == 3 || loginType == 5)
    {
        url = [NSString stringWithFormat:@"%@favorites/downloadphonebook_v2/?out=xml&tpuserid=%@&tptype=1",kNetDomain,[array objectAtIndex:5]];
    }
    else if (loginType == 4 || loginType == 6)
    {
        url = [NSString stringWithFormat:@"%@favorites/downloadphonebook_v2/?out=xml&tpuserid=%@&tptype=2",kNetDomain,[array objectAtIndex:5]];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@favorites/downloadphonebook_v2/?out=xml&username=%@&password=%@",kNetDomain,option.userName,option.password];
    }
    
    MWPoiOperator *operator = [[MWPoiOperator alloc] initWithDelegate:delegate];
    
    NetBaseRequestCondition *net_condition = [NetBaseRequestCondition requestCondition];
    net_condition.requestType = type;
    net_condition.baceURL = url;
    
    [[NetExt sharedInstance] requestWithCondition:net_condition delegate:operator];
    
}

/*!
 @brief  收藏联系人。
 @param operationOption POI 查询选项
 @return YES:成功启动搜索。搜索成功将回调 -(void)poiLocalSearch:(MWSearchOption*)poiSearchOption Result:(MWSearchResult *)result;
 */
+(BOOL)collectContactWith:(ABRecordRef)record
{
    NSMutableArray *poiList = [[NSMutableArray alloc] init];
    
    NameIndex *item = [[NameIndex alloc] init];//NameIndex是一个用于给UILocalizedIndexedCollation类对象做索引的类，代码见下个代码块
    
    item._fullName = (NSString*)ABRecordCopyCompositeName(record);
    item.lastEditTime = (NSDate*)ABRecordCopyValue(record, kABPersonModificationDateProperty);
    
    ABMultiValueRef phones = (ABMultiValueRef) ABRecordCopyValue(record, kABPersonPhoneProperty);
    for(int i = 0 ;i < ABMultiValueGetCount(phones); i++)
    {
        NSString *phone = (NSString *)ABMultiValueCopyValueAtIndex(phones, i);
        NSString *labelName = (NSString *)ABMultiValueCopyLabelAtIndex(phones,i);
        NSString *phoneType;
        if ([labelName rangeOfString:@"Mobile"].length > 0) {
            phoneType = [NSString stringWithFormat:@"移动"];
        }
        else if([labelName rangeOfString:@"iPhone"].length > 0) {
            phoneType = [NSString stringWithFormat:@"iPhone"];
        }
        else if([labelName rangeOfString:@"Home"].length > 0) {
            phoneType = [NSString stringWithFormat:@"住宅"];
        }
        else if([labelName rangeOfString:@"Work"].length > 0) {
            phoneType = [NSString stringWithFormat:@"工作"];
        }
        else if([labelName rangeOfString:Localize_Main].length > 0) {
            phoneType = [NSString stringWithFormat:@"主要"];
        }
        else if([labelName rangeOfString:@"HomeFAX"].length > 0) {
            phoneType = [NSString stringWithFormat:@"住宅传真"];
        }
        else if([labelName rangeOfString:@"WorkFAX"].length > 0) {
            phoneType = [NSString stringWithFormat:@"工作传真"];
        }
        else if([labelName rangeOfString:@"Pager"].length > 0) {
            phoneType = [NSString stringWithFormat:@"传呼"];
        }
        else if([labelName rangeOfString:@"Other"].length > 0) {
            phoneType = [NSString stringWithFormat:@"其他"];
        }
        else {
            phoneType = [NSString stringWithFormat:@"%@",labelName];
        }
        
        //NSLog(@"电话=%@,%d,%@",labelName,i,item._fullName);
        [item.phoneTypeArray addObject:phoneType];
        [item.phoneArray addObject:phone];
        
        
    }
    
    ABMultiValueRef mails = (ABMultiValueRef) ABRecordCopyValue(record, kABPersonEmailProperty);
    for(int i = 0 ;i < ABMultiValueGetCount(mails); i++)
    {
        NSString *mail = (NSString *)ABMultiValueCopyValueAtIndex(mails, i);
        NSString *labelName = (NSString *)ABMultiValueCopyLabelAtIndex(mails,i);
        NSString *mailType;
        
        if([labelName rangeOfString:@"Home"].length > 0) {
            mailType = [NSString stringWithFormat:@"住宅"];
        }
        else if([labelName rangeOfString:@"Work"].length > 0) {
            mailType = [NSString stringWithFormat:@"工作"];
        }
        else if([labelName rangeOfString:@"Other"].length > 0) {
            mailType = [NSString stringWithFormat:@"其他"];
        }
        else {
            mailType = [NSString stringWithFormat:@"%@",labelName];
        }
        
        // NSLog(@"邮件=%@,%d,%@",labelName,i,item._fullName);
        [item.emailTypeArray addObject:mailType];
        [item.emailArray addObject:mail];
    }
    
    ABMultiValueRef url = (ABMultiValueRef) ABRecordCopyValue(record, kABPersonURLProperty);
    for(int i = 0 ;i < ABMultiValueGetCount(url); i++)
    {
        NSString *myurl = (NSString *)ABMultiValueCopyValueAtIndex(url, i);
        NSString *labelName = (NSString *)ABMultiValueCopyLabelAtIndex(url,i);
        
        NSString *urlType;
        
        if([labelName rangeOfString:@"HomePage"].length > 0) {
            urlType = [NSString stringWithFormat:@"首页"];
        }
        else if([labelName rangeOfString:@"Home"].length > 0) {
            urlType = [NSString stringWithFormat:@"住宅"];
        }
        else if([labelName rangeOfString:@"Work"].length > 0) {
            urlType = [NSString stringWithFormat:@"工作"];
        }
        else if([labelName rangeOfString:@"Other"].length > 0) {
            urlType = [NSString stringWithFormat:@"其他"];
        }
        else
        {
            urlType = [NSString stringWithFormat:@"%@",labelName];
        }
        //NSLog(@"url=%@,%d,%@",labelName,i,item._fullName);
        [item.URLTypeArray addObject:urlType];
        [item.URLArray addObject:myurl];
    }
    
    ABMultiValueRef address = (ABMultiValueRef) ABRecordCopyValue(record, kABPersonAddressProperty);
    for(int i = 0 ;i < ABMultiValueGetCount(address); i++)
    {
        // NSString *addres = (NSString *)ABMultiValueCopyValueAtIndex(address, i);
        NSString *labelName = (NSString *)ABMultiValueCopyLabelAtIndex(address,i);
        AddressItem *addressItem = [[AddressItem alloc] init];
        NSString *addressType;
        
        if([labelName rangeOfString:@"Home"].length > 0) {
            addressType = [NSString stringWithFormat:@"住宅"];
        }
        else if([labelName rangeOfString:@"Work"].length > 0) {
            addressType = [NSString stringWithFormat:@"工作"];
        }
        else if([labelName rangeOfString:@"Other"].length > 0) {
            addressType = [NSString stringWithFormat:@"其他"];
        }
        else {
            addressType = [NSString stringWithFormat:@"%@",labelName];
        }
        //NSLog(@"地址=%@,%d,%@",labelname,i,item._fullName);
        addressItem.type = addressType;
        
        //获取地址的spcode属性
        NSDictionary* personaddress =(NSDictionary*) ABMultiValueCopyValueAtIndex(address, i);
        
        
        addressItem.zip = (NSString *)[personaddress valueForKey:(NSString *)kABPersonAddressZIPKey];
        addressItem.city = (NSString *)[personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
        addressItem.street = (NSString *)[personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
        addressItem.country =  (NSString *)[personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
        addressItem.countryCode = (NSString *)[personaddress valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
        addressItem.state = (NSString *)[personaddress valueForKey:(NSString *)kABPersonAddressStateKey];
        [item.addressArray addObject:addressItem];
        [addressItem release];
        [personaddress release];
    }
    
    [poiList addObject:item];
    
    [item release];
    
    BOOL sign = [MWPoiOperator saveFile:poiList];
    
    [poiList release];
    
    return sign;
}

/*!
 @brief  编辑联系人
 @param  record 编辑后的联系人信息
 @param  index  编辑的联系人在数组中所处的位置
 @return YES:成功编辑联系。
 */
+ (BOOL)editContactWith:(ABRecordRef)record index:(int)index
{
    if (index < 0)
    {
        return NO;
    }
    
    NSMutableArray *poiList = [[NSMutableArray alloc] init];
    NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [Path stringByAppendingPathComponent:CONTACT_FILE_NAME];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
    [poiList addObjectsFromArray:array];
    
    if (index >= [poiList count])
    {
        return NO;
    }
    
    
    NameIndex *item = [[NameIndex alloc] init];//NameIndex是一个用于给UILocalizedIndexedCollation类对象做索引的类，代码见下个代码块
    
    item._fullName = (NSString*)ABRecordCopyCompositeName(record);
    item.lastEditTime = (NSDate*)ABRecordCopyValue(record, kABPersonModificationDateProperty);
    
    ABMultiValueRef phones = (ABMultiValueRef) ABRecordCopyValue(record, kABPersonPhoneProperty);
    for(int i = 0 ;i < ABMultiValueGetCount(phones); i++)
    {
        NSString *phone = (NSString *)ABMultiValueCopyValueAtIndex(phones, i);
        NSString *labelName = (NSString *)ABMultiValueCopyLabelAtIndex(phones,i);
        NSString *phoneType;
        if ([labelName rangeOfString:@"Mobile"].length > 0) {
            phoneType = [NSString stringWithFormat:@"移动"];
        }
        else if([labelName rangeOfString:@"iPhone"].length > 0) {
            phoneType = [NSString stringWithFormat:@"iPhone"];
        }
        else if([labelName rangeOfString:@"Home"].length > 0) {
            phoneType = [NSString stringWithFormat:@"住宅"];
        }
        else if([labelName rangeOfString:@"Work"].length > 0) {
            phoneType = [NSString stringWithFormat:@"工作"];
        }
        else if([labelName rangeOfString:Localize_Main].length > 0) {
            phoneType = [NSString stringWithFormat:@"主要"];
        }
        else if([labelName rangeOfString:@"HomeFAX"].length > 0) {
            phoneType = [NSString stringWithFormat:@"住宅传真"];
        }
        else if([labelName rangeOfString:@"WorkFAX"].length > 0) {
            phoneType = [NSString stringWithFormat:@"工作传真"];
        }
        else if([labelName rangeOfString:@"Pager"].length > 0) {
            phoneType = [NSString stringWithFormat:@"传呼"];
        }
        else if([labelName rangeOfString:@"Other"].length > 0) {
            phoneType = [NSString stringWithFormat:@"其他"];
        }
        else
        {
            phoneType = [NSString stringWithFormat:@"%@",labelName];
        }
        //NSLog(@"电话=%@,%d,%@",labelName,i,item._fullName);
        [item.phoneTypeArray addObject:phoneType];
        [item.phoneArray addObject:phone];
        
        
    }
    
    ABMultiValueRef mails = (ABMultiValueRef) ABRecordCopyValue(record, kABPersonEmailProperty);
    for(int i = 0 ;i < ABMultiValueGetCount(mails); i++)
    {
        NSString *mail = (NSString *)ABMultiValueCopyValueAtIndex(mails, i);
        NSString *labelName = (NSString *)ABMultiValueCopyLabelAtIndex(mails,i);
        NSString *mailType;
        
        if([labelName rangeOfString:@"Home"].length > 0) {
            mailType = [NSString stringWithFormat:@"住宅"];
        }
        else if([labelName rangeOfString:@"Work"].length > 0) {
            mailType = [NSString stringWithFormat:@"工作"];
        }
        else if([labelName rangeOfString:@"Other"].length > 0) {
            mailType = [NSString stringWithFormat:@"其他"];
        }
        else {
            mailType = [NSString stringWithFormat:@"%@",labelName];
        }
        
        // NSLog(@"邮件=%@,%d,%@",labelName,i,item._fullName);
        [item.emailTypeArray addObject:mailType];
        [item.emailArray addObject:mail];
    }
    
    ABMultiValueRef url = (ABMultiValueRef) ABRecordCopyValue(record, kABPersonURLProperty);
    for(int i = 0 ;i < ABMultiValueGetCount(url); i++)
    {
        NSString *myurl = (NSString *)ABMultiValueCopyValueAtIndex(url, i);
        NSString *labelName = (NSString *)ABMultiValueCopyLabelAtIndex(url,i);
        
        NSString *urlType;
        
        if([labelName rangeOfString:@"HomePage"].length > 0) {
            urlType = [NSString stringWithFormat:@"首页"];
        }
        else if([labelName rangeOfString:@"Home"].length > 0) {
            urlType = [NSString stringWithFormat:@"住宅"];
        }
        else if([labelName rangeOfString:@"Work"].length > 0) {
            urlType = [NSString stringWithFormat:@"工作"];
        }
        else if([labelName rangeOfString:@"Other"].length > 0) {
            urlType = [NSString stringWithFormat:@"其他"];
        }
        else
        {
            urlType = [NSString stringWithFormat:@"%@",labelName];
        }
        //NSLog(@"url=%@,%d,%@",labelName,i,item._fullName);
        [item.URLTypeArray addObject:urlType];
        [item.URLArray addObject:myurl];
    }
    
    ABMultiValueRef address = (ABMultiValueRef) ABRecordCopyValue(record, kABPersonAddressProperty);
    for(int i = 0 ;i < ABMultiValueGetCount(address); i++)
    {
        // NSString *addres = (NSString *)ABMultiValueCopyValueAtIndex(address, i);
        NSString *labelName = (NSString *)ABMultiValueCopyLabelAtIndex(address,i);
        AddressItem *addressItem = [[AddressItem alloc] init];
        NSString *addressType;
        
        if([labelName rangeOfString:@"Home"].length > 0) {
            addressType = [NSString stringWithFormat:@"住宅"];
        }
        else if([labelName rangeOfString:@"Work"].length > 0) {
            addressType = [NSString stringWithFormat:@"工作"];
        }
        else if([labelName rangeOfString:@"Other"].length > 0) {
            addressType = [NSString stringWithFormat:@"其他"];
        }
        else {
            addressType = [NSString stringWithFormat:@"%@",labelName];
        }
        //NSLog(@"地址=%@,%d,%@",labelname,i,item._fullName);
        addressItem.type = addressType;
        
        //获取地址的spcode属性
        NSDictionary* personaddress =(NSDictionary*) ABMultiValueCopyValueAtIndex(address, i);
        
        
        addressItem.zip = (NSString *)[personaddress valueForKey:(NSString *)kABPersonAddressZIPKey];
        addressItem.city = (NSString *)[personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
        addressItem.street = (NSString *)[personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
        addressItem.country =  (NSString *)[personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
        addressItem.countryCode = (NSString *)[personaddress valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
        addressItem.state = (NSString *)[personaddress valueForKey:(NSString *)kABPersonAddressStateKey];
        [item.addressArray addObject:addressItem];
        [addressItem release];
        
    }
    
    [poiList replaceObjectAtIndex:index withObject:item];
    
    [item release];
    
    int sign = [self saveFile:poiList];
    
    [poiList release];
    
    return sign;
}

/*!
 @brief  获取已收藏的联系人列表
 @param   resultList 输出，用于返回联系人列表。
 @return  YES:成功获取联系人列表。
 */
+(BOOL)getContactList:(MWContact **)resultList
{
    MWContact *temp = [[[MWContact alloc] init] autorelease];
    
    NSMutableArray *poiList = [[NSMutableArray alloc] init];
    NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [Path stringByAppendingPathComponent:CONTACT_FILE_NAME];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
    [poiList addObjectsFromArray:array];
    
    if ([poiList count] == 0)
    {
        [poiList release];
        return NO;
    }
    
    temp.nNumberOfItem = [poiList count];
    temp.contactArray = poiList;
    [poiList release];
    
    *resultList = temp;
    return YES;
}

/*!
 @brief  删除联系人(参数为索引值)
 @param   index 收藏的联系人的索引 (即 NameIndex 在数组中的索引)
 @return 删除成功返回YES。
 */
+(BOOL)deleteContactWithIndex:(int)index
{
    if (index < 0)
    {
        return NO;
    }
    NSMutableArray *poiList = [[NSMutableArray alloc] init];
    NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [Path stringByAppendingPathComponent:CONTACT_FILE_NAME];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
    [poiList addObjectsFromArray:array];
    
    if ([poiList count] == 0)
    {
        [poiList release];
        return NO;
    }
    
    if (index < [poiList count])
    {
        [poiList removeObjectAtIndex:index];
        int sign = [self saveFile:poiList];
        [poiList release];
        return sign;
    }
    
    return NO;
}

/*!
 @brief  清空联系人列表
 @return 删除成功返回YES。
 */
+ (BOOL)clearContact
{
    NSMutableArray *poiList = [[[NSMutableArray alloc] init] autorelease];
    return [self saveFile:poiList];
}

/*!
 @brief  检测联系人是否在本地文件中
 @param   name 联系人的姓名
 @return 存在返回YES。
 */
+ (BOOL)bCheckContactInListWithName:(NSString *)name
{
    NSMutableArray *poiList = [[NSMutableArray alloc] init];
    NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [Path stringByAppendingPathComponent:CONTACT_FILE_NAME];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
    [poiList addObjectsFromArray:array];
    
    
    for (int i=0; i<[poiList count]; i++)
    {
        NameIndex *tmp = [poiList objectAtIndex:i];
        if ([name isEqualToString:tmp._fullName])
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark - private method
#pragma mark search method
/*!
 @brief  递归将GPOICATEGORY转化成MWPoiCategory
 @param  gPoiCategory, 将要转化的GPOICATEGORY
 @return 转化后的 MWPoiCategory。
 */
-(MWPoiCategory *)recursiveForCategory:(GPOICATEGORY)gPoiCategory
{
    if (&gPoiCategory == NULL)
    {
        return nil;
    }
    MWPoiCategory  *poiCategory = [[MWPoiCategory alloc] init];
    
    if (gPoiCategory.nCategoryIDNum == 0)
    {
        poiCategory.Reserved = gPoiCategory.Reserved;
        poiCategory.nCategoryIDNum = gPoiCategory.nCategoryIDNum;
        for (int i = 0; i < gPoiCategory.nCategoryIDNum; i++)
        {
            [poiCategory.pnCategoryID addObject:[NSNumber numberWithInt:gPoiCategory.pnCategoryID[i]]];
        }
        poiCategory.szName = GcharToNSString(gPoiCategory.szName);
        
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        GPOICATEGORYLIST *ppCategoryList = NULL;
        NSLog(@"%d,%@",gPoiCategory.nCategoryIndex,poiCategory.szName);
        GSTATUS res = GDBL_GetPOICategoryList(gPoiCategory.nCategoryIndex, &ppCategoryList);
        if (res == GD_ERR_OK)
        {
            poiCategory.nNumberOfSubCategory = ppCategoryList->lNumberOfCategory;
            int number = ppCategoryList->lNumberOfCategory;
            
            for (int i = 0; i < number; i++)
            {
                ppCategoryList = NULL;
                res = GDBL_GetPOICategoryList(gPoiCategory.nCategoryIndex, &ppCategoryList);
                if (res == GD_ERR_OK)
                {
                    GPOICATEGORY gPoiCategory_temp = ppCategoryList->pCategory[i];
                    MWPoiCategory  *poi_temp = [self recursiveForCategory:gPoiCategory_temp];
                    [array addObject:poi_temp];
                }
                
            }
            poiCategory.pSubCategoryArray = [NSArray arrayWithArray:array];
            if ([poiCategory.pSubCategoryArray count] > 0)
            {
                MWPoiCategory *subCategory = [poiCategory.pSubCategoryArray objectAtIndex:0];
                poiCategory.nCategoryIDNum = subCategory.nCategoryIDNum;
                [poiCategory.pnCategoryID addObjectsFromArray:subCategory.pnCategoryID];
            }
        }
        [array release];
    }
    else
    {
        poiCategory.Reserved = gPoiCategory.Reserved;
        poiCategory.nCategoryIDNum = gPoiCategory.nCategoryIDNum;
        for (int i = 0; i < gPoiCategory.nCategoryIDNum; i++)
        {
            [poiCategory.pnCategoryID addObject:[NSNumber numberWithInt:gPoiCategory.pnCategoryID[i]]];
        }
        poiCategory.szName = GcharToNSString(gPoiCategory.szName);
        
    }
    return [poiCategory autorelease];
}

/*!
 @brief  按距离排序 冒泡排序。
 @param  pResult:需要排序的GPOIRESULT结构体，由引擎给出。
 */
- (void)sortDistanceWith:(GPOIRESULT *)pResult
{
    GPOI temp;
    int kk = pResult->sNumberOfItemGet;
    for (int j = 0; j < kk-1;j++)
    {
        for (int k = 0; k < kk - j - 1;k++)
        {
            if (pResult->pPOI[k].lDistance > pResult->pPOI[k+1].lDistance)
            {
                temp = pResult->pPOI[k];
                pResult->pPOI[k] = pResult->pPOI[k + 1];
                pResult->pPOI[k + 1] = temp;
            }
        }
    }
}

/*!
 @brief  计算距离。
 @param  pResult:需要排序的GPOIRESULT结构体，由引擎给出。
 */
- (void)setDistanceWith:(GPOIRESULT *)pResult
{
    GCARINFO pCarInfo = {};
    GDBL_GetCarInfo(&pCarInfo);
    int kk = pResult->sNumberOfItemGet;
    for (int j = 0; j < kk;j++)
    {
        pResult->pPOI[j].lDistance =  [MWEngineTools CalcDistanceFrom:pCarInfo.Coord To:pResult->pPOI[j].Coord];
        pResult->pPOI[j].lHilightFlag = 0;
    }
}

/*!
 @brief  获取MWPoi对象。
 @param  gpoi : gpoi结构体
 @param  enc : 传入数据的编码方式
 @return 返回自动释放的MWPoi对象。
 */
- (MWPoi *)getMWPoiWith:(GPOI)gpoi encoding:(NSStringEncoding)enc
{
    MWPoi *poi = [[MWPoi alloc] init];
    poi.lAdminCode = gpoi.lAdminCode;
    poi.latitude = gpoi.Coord.y;
    poi.longitude = gpoi.Coord.x;
    poi.lCategoryID = gpoi.lCategoryID;
    poi.lDistance = gpoi.lDistance;
    poi.lHilightFlag = gpoi.lHilightFlag;
    poi.lMatchCode = gpoi.lMatchCode;
    poi.stPoiId = gpoi.stPoiId;
    poi.lPoiIndex = gpoi.lPoiIndex;
    //    poi.usNodeId = gpoi.usNodeId;
    poi.ucFlag = gpoi.ucFlag;
    poi.Reserved = gpoi.Reserved;
    poi.lNaviLon = gpoi.lNaviLon;
    poi.lNaviLat = gpoi.lNaviLat;
    poi.szName = GcharToNSString(gpoi.szName);
    poi.szAddr = GcharToNSString(gpoi.szAddr);
    poi.szTel = GcharToNSString(gpoi.szTel);
    return [poi autorelease];
}
/*!
 @brief  获取MWSearchResult对象。
 @param  pResult:GPOIRESULT结构体，由引擎给出。
 @param  enc:传入数据的编码方式
 @return 返回自动释放的MWSearchResult对象。
 */
- (MWSearchResult *)getSearchResultWith:(GPOIRESULT *)pResult encoding:(NSStringEncoding)enc
{
    MWSearchResult *operatorResult = [[MWSearchResult alloc] init];
    operatorResult.index = pResult->sIndex;
    operatorResult.numberOfItemGet = pResult->sNumberOfItemGet;
    operatorResult.numberOfTotalItem = pResult->sNumberOfTotalItem;
    operatorResult.reserved = pResult->Reserved;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < pResult->sNumberOfItemGet; i++)
    {
        GPOI temp = pResult->pPOI[i];
        MWPoi *poi = [self getMWPoiWith:temp encoding:enc];
        [array addObject:poi];
    }
    
    /*筛选禁用POI start*/
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:ForbiddenPoi_Path];
    NSArray *forbiddenArray = nil;
    LANGUAGE language = [[MWPreference sharedInstance] getValue:PREF_UILANGUAGE];
    if (language == LANGUAGE_SIMPLE_CHINESE)
    {
        forbiddenArray = [dic objectForKey:@"zh-hans"];
    }
    else if (language == LANGUAGE_TRADITIONAL_CHINESE)
    {
        forbiddenArray = [dic objectForKey:@"zh-hant"];
    }
    else if (language == LANGUAGE_ENGLISH)
    {
        forbiddenArray = [dic objectForKey:@"en"];
    }
    NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"NOT (szName in %@)", forbiddenArray];    //筛选禁用POI
    [array filterUsingPredicate:thePredicate];
    /*筛选禁用POI end*/
    
    operatorResult.pois = [NSArray arrayWithArray:array];
    [array release];
    
    return [operatorResult autorelease];
}

/*!
 @brief  搜索失败，处理函数
 @param  errcode 错误码。
 */
- (void)searchLocalPoifail:(NSError *)errcode
{
    Class currentClass = object_getClass(self.poiDelegate);
    if (currentClass == self.originalClass)
    {
        if (self.poiDelegate && [self.poiDelegate respondsToSelector:@selector(search:Error:)])
        {
            [self.poiDelegate search:_poiOperationOption Error:errcode];
        }
    }
    else
    {
        NSLog(@"delegate dealloc");
    }
    if (_poiOperationOption)
    {
        [_poiOperationOption release];
        _poiOperationOption = nil;
    }
    [self release];
}

/*!
 @brief  搜索失败，处理函数
 @param  errcode 错误码。
 */
- (void)searchNetPoifail:(NSError *)errcode
{
    Class currentClass = object_getClass(self.poiDelegate);
    if (currentClass == self.originalClass)
    {
        if (self.poiDelegate && [self.poiDelegate respondsToSelector:@selector(search:Error:)])
        {
            [self.poiDelegate search:_poiOperationOption Error:errcode];
        }
    }
    else
    {
        NSLog(@"delegate dealloc");
    }
    if (_poiOperationOption)
    {
        [_poiOperationOption release];
        _poiOperationOption = nil;
    }
    [self release];
}

/*!
 @brief  搜索失败，处理函数
 @param  errcode 错误码。
 */
- (void)searchNearestPoifail:(NSError *)errcode
{
    Class currentClass = object_getClass(self.poiDelegate);
    if (currentClass == self.originalClass)
    {
        if (self.poiDelegate && [self.poiDelegate respondsToSelector:@selector(search:Error:)])
        {
            MWSearchOption *temp = [[[MWSearchOption alloc] init] autorelease];
            temp.longitude = _coordForNearest.x;
            temp.latitude = _coordForNearest.y;
            [self.poiDelegate search:temp Error:errcode];
        }
    }
    else
    {
        NSLog(@"delegate dealloc");
    }
    [self release];
}

/*!
 @brief  本地搜索成功，处理函数
 @param  result 搜索成功后，获取的poi结构对象。
 */
- (void)searchPoiItemSuccess:(MWSearchResult *)result
{
    Class currentClass = object_getClass(self.poiDelegate);
    if (currentClass == self.originalClass)
    {
        if (self.poiDelegate && [self.poiDelegate respondsToSelector:@selector(poiLocalSearch:Result:)])
        {
            [self.poiDelegate poiLocalSearch:_poiOperationOption Result:result];
        }
    }
    else
    {
        NSLog(@"delegate dealloc");
    }
    if (_poiOperationOption)
    {
        [_poiOperationOption release];
        _poiOperationOption = nil;
    }
    [self release];
}

/*!
 @brief  网络搜索成功，处理函数 （当前城市搜索成功）
 @param  result 搜索成功后，获取的poi结构对象。
 */
- (void)searchNetPoiItemSuccess:(MWSearchResult *)result
{
    
}

/*!
 @brief  网络搜索成功，处理函数  （转其他城市搜索）
 */
- (void)searchNetPoiItemToOtherCitySuccess
{
    
}

/*!
 @brief  当前点最近的POI点搜索成功，处理函数
 @param  result 搜索成功后，获取的poi结构对象。
 */
- (void)searchNearestPoiItemSuccess:(MWPoi *)poi
{
    Class currentClass = object_getClass(self.poiDelegate);
    if (currentClass == self.originalClass)
    {
        if (self.poiDelegate && [self.poiDelegate respondsToSelector:@selector(poiNearestSearch:Poi:)])
        {
            [self.poiDelegate poiNearestSearch:_coordForNearest Poi:poi];
        }
    }
    [self release];
}

- (void)onlineMapSearchCenterWith:(MWPoi *)poi
{
    Class currentClass = object_getClass(self.poiDelegate);
    if (currentClass == self.originalClass)
    {
        if (self.poiDelegate && [self.poiDelegate respondsToSelector:@selector(poiNearestSearch:Poi:)])
        {
            [self.poiDelegate poiNearestSearch:_coordForNearest Poi:poi];
        }
    }
    [self release];
}

- (void)listenNotification:(NSNotification *)notification
{
    NSLog(@"%@",notification);
    NSArray * result = [notification object];
    if ([[result objectAtIndex:0] intValue]== 4)
    {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([notification.name isEqual:NOTIFY_GETPOIDATA])
    {
        NSLog(@"ddd--%@",[notification.object objectAtIndex:0]);
        if ([[result objectAtIndex:0] intValue] == 0)
        {
            if ([[result objectAtIndex:1] intValue] == 0)  //成功
            {
                GETPOIINPUT input;
                input.sIndex = 0;//首次默认从第0条开始获取
                input.sNumberOfItemToGet= 500; //从开始条数序号起，要获取的条数
                
                GPOIRESULT * pResult;
                GSTATUS res;
                res = GDBL_GetPOIResult(&input, &pResult);
                if (res == GD_ERR_OK)
                {
                    MWSearchResult * operatorResult = [self getSearchResultWith:pResult encoding:0x80000632]; //0x80000632 GBK编码
                    [self performSelectorOnMainThread:@selector(searchPoiItemSuccess:) withObject:operatorResult waitUntilDone:NO];
                }
                else
                {
                    
                    [self performSelectorOnMainThread:@selector(searchLocalPoifail:) withObject:[self searchErrorWithCode:0 userInfo:nil] waitUntilDone:NO];
                }
                
            }
            else
            {
                
                [self performSelectorOnMainThread:@selector(searchLocalPoifail:) withObject:[self searchErrorWithCode:0 userInfo:nil] waitUntilDone:NO];
            }
        }
        else  if ([[result objectAtIndex:0] intValue] == 1)
        {
            if ([[result objectAtIndex:1] intValue] == 0)  //成功
            {
                GPOI pNearestPOI = {0};
                GDBL_GetNearestPOI(&pNearestPOI);
                
                MWPoi *poi = [self getMWPoiWith:pNearestPOI encoding:0x80000632];
                [self performSelectorOnMainThread:@selector(searchNearestPoiItemSuccess:) withObject:poi waitUntilDone:NO];
            }
            else
            {
                [self performSelectorOnMainThread:@selector(searchNearestPoifail:) withObject:[self searchErrorWithCode:0 userInfo:nil] waitUntilDone:NO];
            }
        }
    }
}
- (id)searchErrorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo
{
    
    return [NSError errorWithDomain:MWPOISearchErrorDomain code:code userInfo:userInfo];
}
#pragma mark  contact private method
//序列化联系人列表
+ (BOOL)saveFile:(NSMutableArray *)array
{
    NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [Path stringByAppendingPathComponent:CONTACT_FILE_NAME];
    if (![NSKeyedArchiver archiveRootObject:array toFile:filename])
    {
        return NO;
    }
    else {
        return YES;
    }
    
}
//添加邮件字段
+ (BOOL)addEmail:(ABRecordRef)person email:(NSString*)email type:(NSString *)emailtype
{
    ABMultiValueRef immutableMultiAddress = (ABMultiValueRef) ABRecordCopyValue(person, kABPersonEmailProperty);
    ABMutableMultiValueRef multi;
    if (immutableMultiAddress)
    {
        
        multi = ABMultiValueCreateMutableCopy(immutableMultiAddress);
        
    }
    else
    {
        
        multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    }
    
    CFErrorRef anError = NULL;
    
    ABMultiValueIdentifier multivalueIdentifier;
    
    if (!ABMultiValueAddValueAndLabel(multi, (CFStringRef)email, (CFStringRef)emailtype, &multivalueIdentifier)){
        if(multi)CFRelease(multi);
        return NO;
    }
    
    if (!ABRecordSetValue(person, kABPersonEmailProperty, multi, &anError)){
        if(multi)CFRelease(multi);
        return NO;
    }
    
    if(multi)CFRelease(multi);
    return YES;
}
//添加电话字段
+ (BOOL)addPhone:(ABRecordRef)person phone:(NSString*)phone type:(NSString *)phonetype
{
    ABMultiValueRef immutableMultiAddress = (ABMultiValueRef) ABRecordCopyValue(person, kABPersonPhoneProperty);
    ABMutableMultiValueRef multi;
    if (immutableMultiAddress)
    {
        
        multi = ABMultiValueCreateMutableCopy(immutableMultiAddress);
        
    }
    else
    {
        
        multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    }
    
    CFErrorRef anError = NULL;
    
    ABMultiValueIdentifier multivalueIdentifier;
    
    if (!ABMultiValueAddValueAndLabel(multi, (CFStringRef)phone, (CFStringRef)phonetype, &multivalueIdentifier)){
        if(multi)CFRelease(multi);
        return NO;
    }
    
    if (!ABRecordSetValue(person, kABPersonPhoneProperty, multi, &anError)){
        if(multi)CFRelease(multi);
        return NO;
    }
    
    if(multi)CFRelease(multi);
    return YES;
}
//通讯录添加地址字段
+ (BOOL)addAddress:(ABRecordRef)person address:(AddressItem*)addr
{
    
    ABMultiValueRef immutableMultiAddress = (ABMultiValueRef) ABRecordCopyValue(person, kABPersonAddressProperty);
    ABMutableMultiValueRef addres;
    if (immutableMultiAddress)
        
    {
        
        addres= ABMultiValueCreateMutableCopy(immutableMultiAddress);
        
    }
    else
        
    {
        
        addres = ABMultiValueCreateMutable(kABDictionaryPropertyType);
    }
    
    
    static int  homeLableValueCount = 6;
    
    // 设置字典的keys和value
    CFStringRef keys[homeLableValueCount];
    CFStringRef values[homeLableValueCount];
    keys[0]      = kABPersonAddressStreetKey;
    keys[1]      = kABPersonAddressCityKey;
    keys[2]      = kABPersonAddressStateKey;
    keys[3]      = kABPersonAddressZIPKey;
    keys[4]      = kABPersonAddressCountryKey;
    keys[5]      = kABPersonAddressCountryCodeKey;
    
    values[0]    = (CFStringRef)addr.street;
    values[1]    = (CFStringRef)addr.city;
    values[2]    = (CFStringRef)addr.state;
    values[3]    = (CFStringRef)addr.zip;
    values[4]    = (CFStringRef)addr.country;
    values[5]    = (CFStringRef)addr.countryCode;
    
    CFDictionaryRef aDict = CFDictionaryCreate(
                                               kCFAllocatorDefault,
                                               (void *)keys,
                                               (void *)values,
                                               homeLableValueCount,
                                               &kCFCopyStringDictionaryKeyCallBacks,
                                               &kCFTypeDictionaryValueCallBacks
                                               );
    
    // 添加地址到 person 纪录.
    ABMultiValueIdentifier identifier;
    
    BOOL result = ABMultiValueAddValueAndLabel(addres, aDict, (CFStringRef)addr.type, &identifier);
    
    CFErrorRef error = NULL;
    result = ABRecordSetValue(person, kABPersonAddressProperty, addres, &error);
    
    if(aDict)CFRelease(aDict);
    if(addres)CFRelease(addres);
    
    return result;
}
//添加url字段
+ (BOOL)addURL:(ABRecordRef)person url:(NSString*)url type:(NSString*)urltype
{
    
    ABMultiValueRef immutableMultiURL = (ABMultiValueRef) ABRecordCopyValue(person, kABPersonURLProperty);
    ABMutableMultiValueRef multi;
    CFErrorRef anError = NULL;
    ABMultiValueIdentifier multivalueIdentifier;
    if (immutableMultiURL)
    {
        
        multi= ABMultiValueCreateMutableCopy(immutableMultiURL);
        
    }
    else
    {
        
        multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    }
    //添加url属性值
    if (!ABMultiValueAddValueAndLabel(multi, (CFStringRef)url, (CFStringRef)urltype,
                                      &multivalueIdentifier)){
        if(multi)CFRelease(multi);
        return NO;
    }
    //设置url属性值
    if (!ABRecordSetValue(person, kABPersonURLProperty, multi, &anError)){
        if(multi)CFRelease(multi);
        return NO;
    }
    
    if(multi)CFRelease(multi);
    return YES;
}

//添加到系统联系人
+(BOOL)addtoSystemContact:(NSArray *)contextArray
{
    //ios6.0-bug
    
    ABRecordRef person = ABPersonCreate();
    if(person) CFRelease(person);
    
    //添加到系统中
    for (int t = 0; t<[contextArray count]; t++) {
        NameIndex *tmpnode = [contextArray objectAtIndex:t];
        
        ABAddressBookRef addressBook = nil;
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
        {
            
            addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            
            //等待同意后向下执行
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                                     {
                                                         dispatch_semaphore_signal(sema);
                                                     });
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            dispatch_release(sema);
            
        }
        else
        {
            addressBook = ABAddressBookCreate();
        }
        CFArrayRef friendList = ABAddressBookCopyArrayOfAllPeople(addressBook);
        BOOL isSame = NO;
        
        for (id record in (NSArray *)friendList) {
            BOOL addFlag = NO;
            BOOL URLFlag = NO;
            BOOL emailFlag = NO;
            BOOL PhoneFlag = NO;
            NSString *temp = [NSString stringWithFormat:@"%@",(NSString*)ABRecordCopyCompositeName(record)];
            if ([tmpnode._fullName isEqualToString:temp]) {//对比名字
                
                //对比地址字段
                ABMultiValueRef address = (ABMultiValueRef)ABRecordCopyValue(record, kABPersonAddressProperty);
                int addressCount = ABMultiValueGetCount(address);
                if (addressCount != [tmpnode.addressArray count]) {//地址个数不一样则对比下一个记录
                    continue;
                }
                else {
                    for (int i = 0; i<[tmpnode.addressArray count]; i++) {
                        AddressItem *item = [tmpnode.addressArray objectAtIndex:i];
                        NSString *addressTmp = [NSString stringWithFormat:@"%@%@%@%@%@%@",item.country,item.city,item.state,item.street,item.zip,item.countryCode];
                        NSDictionary *personaddress = (NSDictionary*)ABMultiValueCopyValueAtIndex(address, i);
                        NSString* country = [personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
                        NSString* city = [personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
                        NSString* state = [personaddress valueForKey:(NSString *)kABPersonAddressStateKey];
                        NSString* street = [personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
                        NSString* zip = [personaddress valueForKey:(NSString *)kABPersonAddressZIPKey];
                        NSString* coutntrycode = [personaddress valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
                        NSString* addressAll = [NSString stringWithFormat:@"%@%@%@%@%@%@",country,city,state,street,zip,coutntrycode];
                        if (![addressTmp isEqualToString:addressAll]) {
                            addFlag = YES;
                            break;
                        }
                        
                    }
                    if (addFlag == YES) {//地址字段不一样则对比下一个记录
                        if(address) CFRelease(address);
                        
                        continue;
                    }
                }
                if(address) CFRelease(address);
                //对比邮件字段
                ABMultiValueRef email = (ABMultiValueRef)ABRecordCopyValue(record, kABPersonEmailProperty);
                int emailcount = ABMultiValueGetCount(email);
                if (emailcount != [tmpnode.emailArray count]) {
                    continue;
                }
                else {
                    for (int j = 0; j<[tmpnode.emailArray count]; j++) {
                        NSString *emailString = [tmpnode.emailArray objectAtIndex:j];
                        NSString* emailContent = (NSString*)ABMultiValueCopyValueAtIndex(email, j);
                        if (![emailString isEqualToString:emailContent]) {
                            emailFlag = YES;
                            break;
                        }
                        
                    }
                    if (emailFlag == YES) {
                        if(email) CFRelease(email);
                        continue;
                    }
                }
                if(email) CFRelease(email);
                //对比url字段
                ABMultiValueRef URL = (ABMultiValueRef)ABRecordCopyValue(record, kABPersonURLProperty);
                int URLcount = ABMultiValueGetCount(URL);
                if (URLcount != [tmpnode.URLArray count]) {
                    continue;
                }
                else {
                    for (int k = 0; k<[tmpnode.URLArray count]; k++) {
                        NSString *URLString = [tmpnode.URLArray objectAtIndex:k];
                        NSString* URLContent = (NSString*)ABMultiValueCopyValueAtIndex(URL, k);
                        if (![URLString isEqualToString:URLContent]) {
                            URLFlag = YES;
                            break;
                        }
                        
                    }
                    if (URLFlag == YES) {
                        if(URL) CFRelease(URL);
                        continue;
                    }
                }
                if(URL) CFRelease(URL);
                //对比电话字段
                ABMultiValueRef phone = (ABMultiValueRef)ABRecordCopyValue(record, kABPersonPhoneProperty);
                int phonecount = ABMultiValueGetCount(phone);
                if (phonecount != [tmpnode.phoneArray count]) {
                    continue;
                }
                else {
                    for (int r = 0; r<[tmpnode.phoneArray count]; r++) {
                        NSString *phoneString = [tmpnode.phoneArray objectAtIndex:r];
                        NSString* phoneContent = (NSString*)ABMultiValueCopyValueAtIndex(phone, r);
                        if (![phoneString isEqualToString:phoneContent]) {
                            PhoneFlag = YES;
                            break;
                        }
                        
                    }
                    if (PhoneFlag == YES) {
                        if(phone) CFRelease(phone);
                        continue;
                    }
                }
                if(phone) CFRelease(phone);
                isSame = YES;
                break;
            }
            
        }
        //通讯录中无相同记录则添加
        if (isSame == NO) {
            CFErrorRef error = NULL;
            bool result;
            //创建一个空记 录
            ABRecordRef person = ABPersonCreate();
            result = ABRecordSetValue(person, kABPersonFirstNameProperty, tmpnode._fullName, &error) ;
            
            for (int q = 0; q < [tmpnode.phoneArray count]; q++) {
                [MWPoiOperator addPhone:person phone:[tmpnode.phoneArray objectAtIndex:q] type:[tmpnode.phoneTypeArray objectAtIndex:q]];
            }
            for (int w = 0; w < [tmpnode.emailArray count]; w++) {
                [MWPoiOperator addEmail:person email:[tmpnode.emailArray objectAtIndex:w] type:[tmpnode.emailTypeArray objectAtIndex:w]];
            }
            for (int e = 0; e < [tmpnode.addressArray count]; e++) {
                [MWPoiOperator addAddress:person address:[tmpnode.addressArray objectAtIndex:e]];
            }
            for (int y = 0; y < [tmpnode.URLArray count]; y++) {
                [MWPoiOperator addURL:person url:[tmpnode.URLArray objectAtIndex:y] type:[tmpnode.URLTypeArray objectAtIndex:y]];
            }
            //增加记录
            result = ABAddressBookAddRecord(addressBook, person, &error);
            // 保存到地址本
            result = ABAddressBookSave(addressBook, &error);
            if (!result) {
                return NO;
            }
        }
        if(friendList) CFRelease(friendList);
        //释放内存
        if (addressBook) CFRelease(addressBook);
        
    }
    return YES;
    
}
#pragma mark -
#pragma mark 语音委托
- (void)speechResultText:(NSString *)resultText
{
    NSLog(@"resultText = %@",resultText);
    if (resultText.length == 0) {
        return;
    }
    [self result:resultText];
}
-(void)errorOccur:(int)errorCode
{
    if (gRecognizeController)
    {
        [gRecognizeController setDelegate:nil];
        [gRecognizeController release];
        gRecognizeController = nil;
    }
    Class currentClass = object_getClass(self.poiDelegate);
    if (currentClass == self.originalClass)
    {
        //        if (self.poiDelegate && [self.poiDelegate respondsToSelector:@selector(voiceSearchFail:)])
        //        {
        //            [self.poiDelegate voiceSearchFail:errorCode];
        //        }
    }
    else
    {
        NSLog(@"delegate dealloc");
    }
    [self release];
}
-(void)result:(NSString *)keyword
{
    MWVoiceResult * result = [[MWVoiceResult alloc] init];
    result.voiceDataType = MWVOICE_DATA_CMDERR;
    result.cmdtxt = keyword;
    Class currentClass = object_getClass(self.poiDelegate);
    if (currentClass == self.originalClass)
    {
        if (self.poiDelegate && [self.poiDelegate respondsToSelector:@selector(voiceSearchResult:)])
        {
            [self.poiDelegate voiceSearchResult:result];
        }
    }
    else
    {
        NSLog(@"delegate dealloc");
    }
    
    [result release];
}
#pragma mark  NetRequestExtDelegate callback
- (void)request:(NetRequestExt *)request didFailWithError:(NSError *)error
{
    [self failedWithError:error withRequestType:request.requestCondition.requestType];
    [self release];
}
- (void)request:(NetRequestExt *)request didFinishLoadingWithData:(NSData *)data{
    
    [self handleResponseData:data withRequestType:request.requestCondition.requestType];
    [self release];
}

#pragma mark  request data handle

- (void)dealXiamenData:(NSData *)data withRequestType:(RequestType)type
{
    if (type == REQ_SYN_DES || type == REQ_SYN_FAV)
    {
        NSString *string = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
        if ([string rangeOfString:@"<Authenticate>False</Authenticate>"].length > 0)
        {
            GDBL_clearAccountInfo();
            [self failedWithError:[self errorWithCode:1 userInfo:nil] withRequestType:type];
            [string release];
            string = nil;
            return;
        }
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        MWFavXMLParser *myparser = [[MWFavXMLParser alloc] init];
        BOOL result = [myparser parser:data];
        NSRange result_range = [string rangeOfString:@"<Result>SUCCESS</Result>"];
        if (result && result_range.length)
        {
            bSynNetData = YES;       //关闭保存至本地文件
            
            MWFavorite *parserFavorite = myparser.favorite;
            
            MWFavorite *favList = nil;
            /*根据唯一标识，删除本地中服务器上没有的点*/
            GFAVORITECATEGORY tempCategory;
            GFAVORITEICON tempIconID;
            if (type == REQ_SYN_FAV)
            {
                tempCategory = GFAVORITE_CATEGORY_DEFAULT;
                tempIconID= GFAVORITE_ICON_DEFAULT;
            }
            else
            {
                tempCategory = GFAVORITE_CATEGORY_HISTORY;
                tempIconID= GFAVORITE_ICON_HISTORY;
            }
            NSString *file_path = nil;
            file_path = [Collect_Directory stringByAppendingFormat:@"/FavoriteList%d.plist",tempCategory];
            GSTATUS res = [MWPoiOperator getPoiListWith:tempCategory poiList:&favList];
            if (res == GD_ERR_OK)
            {
                NSArray *allIdentifyArray = nil;
                if ([myparser.favorite.allIdentify length] > 0)
                {
                    NSString *all_temp = [myparser.favorite.allIdentify substringToIndex:[myparser.favorite.allIdentify length] - 1];
                    allIdentifyArray = [all_temp componentsSeparatedByString:@","];
                }
                
                /***start 删除引擎、本地收藏夹中服务器上没有的poi  ****/
                GFAVORITEPOILIST *ppFavoritePOIList = GNULL;
                GSTATUS res = GDBL_GetFavoriteList(tempCategory, &ppFavoritePOIList);
                int enginePoiCount = 0;
                int *deleteIndexList = NULL;
                int deleteCount = 0;
                if (res == GD_ERR_OK && ppFavoritePOIList)
                {
                    enginePoiCount = ppFavoritePOIList->nNumberOfItem;
                    deleteIndexList = malloc(sizeof(int) * enginePoiCount);
                }
                NSMutableArray *deleteArray = [NSMutableArray array];
                for (int i = 0; i < [favList.pFavoritePOIArray count]; i++)
                {
                    MWFavoritePoi *favPoi = [favList.pFavoritePOIArray objectAtIndex:i];
                    favPoi.actionType = 0;
                    BOOL bExist = NO;
                    for (int j = 0; j < [allIdentifyArray count];j += 2 )
                    {
                        int x = [[allIdentifyArray objectAtIndex:j] intValue];
                        int y = [[allIdentifyArray objectAtIndex:j+1] intValue];
                        if (favPoi.longitude == x && favPoi.latitude == y)   //引擎中的点，在服务器中存在
                        {
                            bExist = YES;
                        }
                    }
                    if (!bExist)        //如果本地中的点，在服务器中不存在，则删除该点
                    {
                        for (int k = 0; k < enginePoiCount; k++)
                        {
                            GFAVORITEPOI gfavePoi = ppFavoritePOIList->pFavoritePOI[k];
                            GPOI gpoi = gfavePoi.Poi;
                            if (gpoi.Coord.x == favPoi.longitude && gpoi.Coord.y == favPoi.latitude)
                            {
                                deleteIndexList[deleteCount] = gfavePoi.nIndex;
//                                NSLog(@"deleteIndex %d",deleteIndex[deleteCount]);
                                deleteCount++;
                                break;
                            }
                        }
                        [deleteArray addObject:favPoi];
                    }
                }
                if (deleteIndexList)
                {
                    res = GDBL_DelFavoriteByIndex(deleteIndexList, deleteCount);
                    free(deleteIndexList);
                }
                [favList.pFavoritePOIArray removeObjectsInArray:deleteArray];
                
                favList.userId = self.userId;        //记录此次与服务器同步的用户名，用于下次同步判断
                favList.Time = parserFavorite.Time;
                favList.Date = parserFavorite.Date;
                if (![NSKeyedArchiver archiveRootObject:favList toFile:file_path])
                {
                    NSLog(@"-------------同步至本地文件失败-----------------");
                }
                else
                {
                    NSLog(@"-------------同步至本地文件成功-----------------");
                }
                
            }
            /***end 删除引擎、本地收藏夹中服务器上没有的poi  ****/
            
            for (int i =0; i < [parserFavorite.pFavoritePOIArray count]; i++)     //操作服务器下发数据
            {
                MWFavoritePoi *tmp = [parserFavorite.pFavoritePOIArray objectAtIndex:i];
                tmp.eCategory = tempCategory;
                tmp.eIconID = tempIconID;
                GSTATUS sign = [MWPoiOperator collectPoiWith:tmp];
                if (sign == GD_ERR_NO_SPACE)
                {
                    break;
                }
                else if (sign == GD_ERR_DUPLICATE_DATA)  //如果重复则使用编辑
                {
                    [MWPoiOperator editeFavoritePoiWith:tmp];
                }
                
            }
            bSynNetData = NO;                               //打开保存至本地文件
            
            Class currentClass = object_getClass(self.poiDelegate);
            if (currentClass == self.originalClass)
            {
                if ([self.poiDelegate respondsToSelector:@selector(synSuccessWith:result:)])
                {
                    MWFavorite *favorite = nil;
                    [MWPoiOperator getPoiListWith:tempCategory poiList:&favorite];
                    [self.poiDelegate synSuccessWith:type result:favorite];
                }
            }
            else
            {
                NSLog(@"delegate dealloc");
            }
        }
        else
        {
            NSString *str = [string CutFromNSString:@"<Message>" Tostring:@"</Message>"];
            NSDictionary *dic = [NSDictionary dictionaryWithObject:str forKey:@"message"];
            [self failedWithError:[self errorWithCode:0 userInfo:dic] withRequestType:type];
        }
        
        [myparser release];
        [string release];
        string = nil;
    }
    else if (type == REQ_SYN_DSP)
    {
        NSString *string = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
        if ([string rangeOfString:@"<Authenticate>False</Authenticate>"].length > 0)
        {
            GDBL_clearAccountInfo();
            [self failedWithError:[self errorWithCode:1 userInfo:nil] withRequestType:type];
            [string release];
            string = nil;
            return;
        }
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableArray *contextArray = [[NSMutableArray alloc] init];
        MWSmartEyesXMLParser *myparser = [[MWSmartEyesXMLParser alloc] init];
        BOOL result = [myparser parser:data];
        NSRange result_range = [string rangeOfString:@"<Result>SUCCESS</Result>"];
        if (result && result_range.length)
        {
            bSynNetData = YES;
            MWSmartEyes *parserSmartEyes = myparser.smartEyes;
            
            MWSmartEyes *safeList = nil;
            NSString *file_path = nil;
            file_path = [Collect_Directory stringByAppendingFormat:@"/SafeList.plist"];
            
            /***start 删除引擎、本地收藏夹中服务器上没有的电子眼  ****/
            GSTATUS res = [MWPoiOperator getSmartEyesListWith:GSAFE_CATEGORY_ALL poiList:&safeList];
            if (res == GD_ERR_OK)
            {
                NSArray *allIdentifyArray = nil;
                if ([parserSmartEyes.allIdentify length] > 0)
                {
                    NSString *all_temp = [parserSmartEyes.allIdentify substringToIndex:[parserSmartEyes.allIdentify length] - 1];
                    allIdentifyArray = [all_temp componentsSeparatedByString:@","];
                }
                
                GUSERSAFEINFOLIST  *ppSafeInfoList = GNULL;
                GSTATUS res = GDBL_GetUserSafeInfoList(GSAFE_CATEGORY_ALL,&ppSafeInfoList);  //获取引擎中的电子眼信息
                int engineSafeCount = 0;
                int *deleteIndexList = NULL;
                int deleteCount = 0;
                if (res == GD_ERR_OK && ppSafeInfoList)
                {
                    engineSafeCount = ppSafeInfoList->nNumberOfItem;
                    deleteIndexList = malloc(sizeof(int) * engineSafeCount);
                }
                
                NSMutableArray *deleteArray = [NSMutableArray array];
                for (int i = 0; i < [safeList.smartEyesArray count]; i++)
                {
                    MWSmartEyesItem *favPoi = [safeList.smartEyesArray objectAtIndex:i];
                    favPoi.actionType = 0;
                    BOOL bExist = NO;
                    for (int j = 0; j < [allIdentifyArray count];j += 2 )
                    {
                        int x = [[allIdentifyArray objectAtIndex:j] intValue];
                        int y = [[allIdentifyArray objectAtIndex:j+1] intValue];
                        if (favPoi.longitude == x && favPoi.latitude == y)   //引擎中的点，在服务器中存在
                        {
                            bExist = YES;
                        }
                    }
                    if (!bExist)        //如果本地中的点，在服务器中不存在，则删除该点
                    {
                        for (int k = 0; k < engineSafeCount; k++)
                        {
                            GUSERSAFEINFO gfavePoi = ppSafeInfoList->pSafeInfo[k];
                            if (gfavePoi.coord.x == favPoi.longitude && gfavePoi.coord.y == favPoi.latitude)
                            {
                                deleteIndexList[deleteCount] = gfavePoi.nIndex;
//                                NSLog(@"deleteIndex %d",deleteIndex[deleteCount]);
                                deleteCount++;
                                break;
                            }
                        }
                        [deleteArray addObject:favPoi];
                    }
                }
                if (deleteIndexList)
                {
                    res = GDBL_DelUserSafeInfo(deleteIndexList, deleteCount);
                    free(deleteIndexList);
                }
                [safeList.smartEyesArray removeObjectsInArray:deleteArray];
                safeList.userId = self.userId;        //记录此次与服务器同步的用户名，用于下次同步判断
                safeList.Time = parserSmartEyes.Time;
                safeList.Date = parserSmartEyes.Date;
                if (![NSKeyedArchiver archiveRootObject:safeList toFile:file_path])
                {
                    NSLog(@"-------------同步至本地文件失败-----------------");
                }
                else
                {
                    NSLog(@"-------------同步至本地文件成功-----------------");
                }
            }
            
            /***end 删除引擎、本地收藏夹中服务器上没有的电子眼  ****/
            
            for (int i =0; i < [parserSmartEyes.smartEyesArray count]; i++)     //重新添加服务器下发的电子眼数据
            {
                MWSmartEyesItem *tmp = [parserSmartEyes.smartEyesArray objectAtIndex:i];
                GSTATUS sign = [MWPoiOperator collectSmartEyesWith:tmp];
                if (sign == GD_ERR_NO_SPACE)
                {
                    break;
                }
                else if (sign == GD_ERR_DUPLICATE_DATA)  //如果重复则使用编辑
                {
                    [MWPoiOperator editeSmartEyesWith:tmp];
                }
                
            }
            GDBL_FlushFileUserSafe();  //保存电子眼数据到文件里
            bSynNetData = NO;                               //打开保存至本地文件
            Class currentClass = object_getClass(self.poiDelegate);
            if (currentClass == self.originalClass)
            {
                if ([self.poiDelegate respondsToSelector:@selector(synSuccessWith:result:)])
                {
                    MWSmartEyes *smartEyes;
                    [MWPoiOperator getSmartEyesListWith:GSAFE_CATEGORY_ALL poiList:&smartEyes];
                    [self.poiDelegate synSuccessWith:type result:smartEyes];
                }
            }
            else
            {
                NSLog(@"delegate dealloc");
            }
            
        }
        else
        {
            NSString *str = [string CutFromNSString:@"<Message>" Tostring:@"</Message>"];
            NSDictionary *dic = [NSDictionary dictionaryWithObject:str forKey:@"message"];
            [self failedWithError:[self errorWithCode:0 userInfo:dic] withRequestType:type];
        }
        
        [myparser release];
        [contextArray release];
        
        [string release];
        string = nil;
    }
}
/*
状态码     说明
0000    请求服务成功,
￼1001       交易超时
1002    报文 XML 格式错误
1003    imei 参数错误或为空
1004    坐标值错误或为空
1005    缺少请求参数 activitycode
1006    系统内部错误,同步不成功
1007    缺少参数 oprtime
1008    用户未登录 或 sessionid 为空或 userid 为空
1011    缺少 x\y 请求参数
1012    缺少 List 节点属性 type
1013    鉴权失败
1014    缺少参数 syscode
1015    Edog 类型报错情况下缺少参数 edogtype
1099    其他错误(待扩展)
 */
- (void)dealBeijingData:(NSData *)data withRequestType:(RequestType)type
{
    bSynNetData = YES;
    NSDictionary *dic = [NSDictionary dictionaryWithXMLData:data];
    if (dic)
    {
        NSDictionary *response = [dic objectForKey:@"response"];
        NSString *rspcode = [response objectForKey:@"rspcode"];
        if ([rspcode isEqualToString:@"0000"])  //成功
        {
            NSDictionary *svccont = [dic objectForKey:@"svccont"];
            if (type == REQ_SYN_DES || type == REQ_SYN_FAV)
            {
                GFAVORITECATEGORY eCategory = type == REQ_SYN_DES ? GFAVORITE_CATEGORY_HISTORY:GFAVORITE_CATEGORY_DEFAULT;
                GFAVORITEICON eIconID = type == REQ_SYN_DES ? GFAVORITE_ICON_HISTORY:GFAVORITE_ICON_DEFAULT;
                [MWPoiOperator clearFavoriteWith:eCategory];
                
                NSDictionary *list = [svccont objectForKey:@"list"];
                NSArray *poiArray = nil;
                id tempPoi = [list objectForKey:@"poi"];
                if ([tempPoi isKindOfClass:[NSDictionary class]])
                {
                    poiArray = [NSArray arrayWithObject:tempPoi];
                }
                else if ([tempPoi isKindOfClass:[NSArray class]])
                {
                    poiArray = tempPoi;
                }
                NSMutableArray *array = [[NSMutableArray alloc] init];
                BOOL isAddHome = NO;
                BOOL isAddCom = NO; //家和公司有多个，只需要添加第一个
                for (int i = 0; i < [poiArray count]; i++)
                {
                    NSDictionary *poiDic = [poiArray objectAtIndex:i];
                    MWFavoritePoi *poi = [[MWFavoritePoi alloc] init];
                    poi.longitude = [[poiDic objectForKey:@"x"] intValue];
                    poi.latitude = [[poiDic objectForKey:@"y"] intValue];
                    poi.lAdminCode = [[poiDic objectForKey:@"adcode"] intValue];
                    poi.netPoiId = [poiDic objectForKey:@"id"];
                    poi.szName = [poiDic objectForKey:@"name"];
                    poi.szAddr = [poiDic objectForKey:@"address"];
                    poi.szTel = [poiDic objectForKey:@"tel"];
                    int subtype = [[poiDic objectForKey:@"subtype"] intValue];
                    if (subtype == 2 && type == REQ_SYN_FAV) {
                        if (isAddHome)
                        {
                            continue;
                        }
                        isAddHome = YES;
                        poi.eCategory = GFAVORITE_CATEGORY_HOME;
                        poi.eIconID = GFAVORITE_ICON_HOME;
                    }
                    else if (subtype == 3 && type == REQ_SYN_FAV) {
                        if (isAddCom)
                        {
                            continue;
                        }
                        isAddCom = YES;
                        poi.eCategory = GFAVORITE_CATEGORY_COMPANY;
                        poi.eIconID = GFAVORITE_ICON_COMPANY;
                    }
                    else
                    {
                        poi.eCategory = eCategory;
                        poi.eIconID = eIconID;
                    }
                    
                    GSTATUS res = [MWPoiOperator collectPoiWith:poi];
                    if ((poi.eCategory == GFAVORITE_CATEGORY_COMPANY || poi.eIconID == GFAVORITE_CATEGORY_HOME))
                    {
                        NSString *file_path = nil;
                        file_path = [Collect_Directory stringByAppendingFormat:@"/FavoriteList%d.plist",poi.eCategory];
                        //家和公司直接替换无需去重，因为家和公司只有一个
                        MWFavorite *favoriteList = nil;
                        favoriteList = [[[MWFavorite alloc] init] autorelease];
                        poi.actionType = 0; //新增
                        [favoriteList.pFavoritePOIArray addObject:poi];
                        favoriteList.nNumberOfItem = [favoriteList.pFavoritePOIArray count];
                        poi.nIndex = 0;
                        [NSKeyedArchiver archiveRootObject:favoriteList toFile:file_path];
                       
                    }
                    else if (res == GD_ERR_OK)
                    {
                        [array addObject:poi];
                    }
                    [poi release];
                }
                MWFavorite *favorite = [[[MWFavorite alloc] init] autorelease];
                favorite.pFavoritePOIArray = array;
                favorite.nNumberOfItem = [array count];
                favorite.userId = self.userId;
                [array release];
                
                NSString *file_path = nil;
                file_path = [Collect_Directory stringByAppendingFormat:@"/FavoriteList%d.plist",eCategory];
                if (![NSKeyedArchiver archiveRootObject:favorite toFile:file_path])
                {
                    NSLog(@"-------------同步至本地文件失败-----------------");
                }
                else
                {
                    NSLog(@"-------------同步至本地文件成功-----------------");
                }

                Class currentClass = object_getClass(self.poiDelegate);
                if (currentClass == self.originalClass)
                {
                    if ([self.poiDelegate respondsToSelector:@selector(synSuccessWith:result:)])
                    {
                        
                        [self.poiDelegate synSuccessWith:type result:favorite];
                    }
                }
                else
                {
                    NSLog(@"delegate dealloc");
                }
            }
            else if (type == REQ_SYN_DSP)
            {
                [MWPoiOperator clearSmartEyesWith:GSAFE_CATEGORY_ALL];
                
                NSDictionary *list = [svccont objectForKey:@"list"];
                NSArray *poiArray = nil;
                id tempPoi = [list objectForKey:@"poi"];
                if ([tempPoi isKindOfClass:[NSDictionary class]])
                {
                    poiArray = [NSArray arrayWithObject:tempPoi];
                }
                else if ([tempPoi isKindOfClass:[NSArray class]])
                {
                    poiArray = tempPoi;
                }
                
                NSMutableArray *array = [NSMutableArray array];
                
                for (int i = 0; i < [poiArray count]; i++)
                {
                    NSDictionary *poiDic = [poiArray objectAtIndex:i];
                    MWSmartEyesItem *poi = [[MWSmartEyesItem alloc] init];
                    poi.longitude = [[poiDic objectForKey:@"x"] intValue];
                    poi.latitude = [[poiDic objectForKey:@"y"] intValue];
                    poi.lAdminCode = [[poiDic objectForKey:@"adcode"] intValue];
                    poi.nSpeed = [[poiDic objectForKey:@"v"] intValue];
                    int edogtype = [[poiDic objectForKey:@"edogtype"] intValue];
                    //1:限速摄像头 2:违章摄像头 3:监控摄像头 4:测速摄像头 5:专用道摄像头
                    if (edogtype == 1)
                    {
                        if (poi.nSpeed == 0)
                        {
                            poi.eCategory = GSAFE_CATEGORY_SURVEILLANCE_CAMERA;
                        }
                        else
                        {
                            poi.eCategory = GSAFE_CATEGORY_SPEEDLIMIT;
                        }
                    }
                    else if (edogtype == 2)
                    {
                        poi.eCategory = GSAFE_CATEGORY_ILLEGAL_CAMERA;
                    }
                    else if (edogtype == 3)
                    {
                        poi.eCategory = GSAFE_CATEGORY_SURVEILLANCE_CAMERA;
                    }
                    else if (edogtype == 4)
                    {
                        poi.eCategory = GSAFE_CATEGORY_RESTRICTION_CAMERA;
                    }
                    else if (edogtype == 5)
                    {
                        poi.eCategory = GSAFE_CATEGORY_LANE_CAMERA;
                    }
                    else
                    {
                        if (poi.nSpeed == 0)
                        {
                            poi.eCategory = GSAFE_CATEGORY_SURVEILLANCE_CAMERA;
                        }
                        else
                        {
                            poi.eCategory = GSAFE_CATEGORY_SPEEDLIMIT;
                        }
                    }
                    poi.netPoiId = [poiDic objectForKey:@"id"];
                    poi.szName = [poiDic objectForKey:@"name"];
                    poi.szAddr = [poiDic objectForKey:@"address"];
                    poi.szTel = [poiDic objectForKey:@"tel"];
                    GSTATUS res = [MWPoiOperator collectSmartEyesWith:poi];
                    if (res == GD_ERR_OK) {
                        [array addObject:poi];
                    }
                    [poi release];
                }
                GDBL_FlushFileUserSafe();  //保存电子眼数据到文件里
                
                MWSmartEyes *smartEyes = [[[MWSmartEyes alloc] init] autorelease];
                smartEyes.nNumberOfItem = [array count];
                smartEyes.smartEyesArray = array;
                smartEyes.userId = self.userId;
                NSString *file_path = nil;
                file_path = [Collect_Directory stringByAppendingFormat:@"/SafeList.plist"];
                if (![NSKeyedArchiver archiveRootObject:smartEyes toFile:file_path])
                {
                    NSLog(@"-------------同步至本地文件失败-----------------");
                }
                else
                {
                    NSLog(@"-------------同步至本地文件成功-----------------");
                }

                
                Class currentClass = object_getClass(self.poiDelegate);
                if (currentClass == self.originalClass)
                {
                    if ([self.poiDelegate respondsToSelector:@selector(synSuccessWith:result:)])
                    {
                        [self.poiDelegate synSuccessWith:type result:smartEyes];
                    }
                }
                else
                {
                    NSLog(@"delegate dealloc");
                }
            }
        }
        else if ([rspcode isEqualToString:@"1008"])  //未登录
        {
            GDBL_clearAccountInfo();
            [self failedWithError:[self errorWithCode:1 userInfo:nil] withRequestType:type];
        }
        else
        {
            NSDictionary *dic = [NSDictionary dictionaryWithObject:rspcode forKey:@"message"];
            [self failedWithError:[self errorWithCode:0 userInfo:dic] withRequestType:type];
        }
    }
    bSynNetData = NO;
}

- (void)handleResponseData:(NSData *)data withRequestType:(RequestType) type
{
    int loginType = [[Plugin_Account getAccountInfoWith:0] intValue];
    if (loginType == 2 || loginType == 1)
    {
        //北京服务器返回的数据
        [self dealBeijingData:data withRequestType:type];
    }
    else
    {
        //厦门服务器返回的数据
        [self dealXiamenData:data withRequestType:type];
    }
}

- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo
{
    return [NSError errorWithDomain:MWFavoritemErrorDomain code:code userInfo:userInfo];
}
- (void)failedWithError:(NSError *)error withRequestType:(RequestType) type
{
    if (type == REQ_SYN_DES || type == REQ_SYN_FAV ||type == REQ_SYN_DSP)
    {
        if ([self.poiDelegate respondsToSelector:@selector(synFailWith:error:)])
        {
            [self.poiDelegate synFailWith:type error:error];
        }
    }
}


@end
