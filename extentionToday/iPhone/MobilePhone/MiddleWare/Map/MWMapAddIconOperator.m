//
//  MWMapAddIcon.m
//  AutoNavi
//
//  Created by gaozhimin on 13-9-4.
//
//

#import "MWMapAddIconOperator.h"
#import "GDBL_typedef.h"
#import "MapViewManager.h"
#import "MWPoiOperator.h"


#define CUSTOMELEMENT_NUM 1000

static MWMapAddIconOperator *g_mapAddIconView = nil;
static NSMutableDictionary *g_pictureIdDic = nil;        //对应的图片是否已成生成的纹理，key 图片名称 value 纹理id
static GBITMAP g_bitMap[10] = {0};
static int  g_bitCount = 0;                 //当前的bit总数

@interface MWMapPoiTapView : UIView
{
    id<MWMapPoiAddIconDelegate> _delegate;
}

@property (nonatomic,retain) MWMapPoi *mapPoi;
@end

@implementation MWMapPoiTapView

@synthesize mapPoi;
- (void)dealloc
{
    self.mapPoi = nil;
    [super dealloc];
}

- (void)setDelegateWith:(id<MWMapPoiAddIconDelegate>)delegate
{
    _delegate = delegate;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        UITapGestureRecognizer *singalClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(poiTapRecongnizer:)];
        [singalClick setNumberOfTouchesRequired:1];//触摸点个数
        [singalClick setNumberOfTapsRequired:1];//点击次数
        [self addGestureRecognizer:singalClick];
        [singalClick release];
    }
    return self;
}

#pragma mark - UITapGestureRecognizer method

- (void)poiTapRecongnizer:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.numberOfTapsRequired == 1 && recognizer.numberOfTouchesRequired == 1)
    {
        MWMapPoiTapView *tapView =  (MWMapPoiTapView *)recognizer.view;
        if (_delegate && [_delegate respondsToSelector:@selector(tapMapPoiIconnWith:)])
        {
            [_delegate tapMapPoiIconnWith:tapView.mapPoi];
        }
        NSLog(@"tap success : %ld,%ld",tapView.mapPoi.longitude,tapView.mapPoi.latitude);
    }
}

@end

@interface MWMapAddIconOperator()
{
    GCUSTOMELEMENT  pCustomElement[CUSTOMELEMENT_NUM];
    id<MWMapPoiAddIconDelegate> _delegate;  //响应委托
    UIView *_superView;                     //添加button的View
    NSMutableArray          *_subViewArray; //子视图数组
    float mapScale;                         //缩放比例，高清为2，标清为1
    IconPosition _iconPosition;             //图片位置
    NSDictionary *_lastScreenDic;           //保存上一次显示的poi屏幕坐标，用于下一次作对比，防止重复添加响应区域
}

@property (nonatomic,retain) NSDictionary *mapDataDic;              //传进的地图数据
/**
 *	将数据转换成引擎数据
 *
 *	@param	ppElements	传入引擎的元素数据
 *	@param	count       传入引擎的元素个数
 */
- (void)getElementData:(GCUSTOMELEMENT **)ppElements count:(Gint32 *)count;

@end

#pragma mark - show map icon callback
static void MWMapGetElement(GCUSTOMELEMENT **ppElements, Gint32 *pNumberOfElement)
{
    [g_mapAddIconView getElementData:ppElements count:pNumberOfElement];
}


#pragma mark - MWMapAddIconOperator
@implementation MWMapAddIconOperator

@synthesize mapDataDic;

/**
 *	判断是否在图面上有绘制图标
 *  @parm sender 当前的MWMapAddIconOperator对象
 *	@return	有图标为yes 无图标为no
 */
+ (BOOL)ExistIconInMap:(MWMapAddIconOperator *)sender
{
    if (sender == nil || sender != g_mapAddIconView)
    {
        return NO;
    }
    if (g_mapAddIconView)
    {
        if ([g_mapAddIconView.mapDataDic  count] > 0)
        {
            return YES;
        }
    }
    return NO;
}

/**
 *	清除地图图标
 */
+(void)ClearMapIcon
{
    if (g_mapAddIconView)
    {
        if ([g_mapAddIconView.mapDataDic  count] > 0)
        {
            g_mapAddIconView.mapDataDic = [NSDictionary dictionary];
        }
    }
    
}

- (id)init
{
    return [self initWith:nil inView:nil delegate:nil];
}

- (void)dealloc
{
    if (_lastScreenDic)
    {
        [_lastScreenDic release];
        _lastScreenDic = nil;
    }
    for (UIView *view in _subViewArray)
    {
        [view removeFromSuperview];
    }
    [_subViewArray release];
    GDBL_SetGetUserElementCB(NULL);
    g_mapAddIconView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.mapDataDic = nil;
    [super dealloc];
}

/**
 *	初始化方法
 *
 *	@param	dic	绘制信息，key为图片名称，如***.png。value为数组，存储对象为MWMapPoi
 *	@param	view	添加地图的父视图    目前此参数废弃，内部赋值
 *
 */
- (id)initWith:(NSDictionary *)dic inView:(UIView *)view  delegate:(id<MWMapPoiAddIconDelegate>)delegate
{
    if (self = [super init])
    {
        if (g_pictureIdDic == nil)
        {
            g_pictureIdDic = [[NSMutableDictionary alloc] init];
        }
        self.mapDataDic = dic;
        [self CreateSubView];
        for (NSString *key in [self.mapDataDic allKeys])
        {
            NSNumber *numberID = [g_pictureIdDic objectForKey:key];
            if (!numberID)
            {
                [g_pictureIdDic setObject:[NSNumber numberWithInt:g_bitCount] forKey:key];
                [self setRGBABitMapWith:&g_bitMap[g_bitCount] imageName:key];
                g_bitCount++;
            }
        }
        
        if (g_mapAddIconView)
        {
            [g_mapAddIconView freshPoiDic:dic];
        }
        
        g_mapAddIconView = self;
        _delegate = delegate;
        _superView = view;
        
        NSLog(@"%f,%f",view.bounds.size.width,view.bounds.size.height);
        
        GETELEMENT pFun = GNULL;
        pFun = MWMapGetElement;
        GDBL_SetGetUserElementCB(pFun);
        
        
        mapScale = 1;
        if ([UIScreen instancesRespondToSelector:@selector(scale)])
        {
            mapScale = [[UIScreen mainScreen] scale];
        }
        _iconPosition = Position_Center;
    }
    return self;
}

/**
 *	重新刷新poi数组
 *
 *	@param	dic	新的poi数据
 */
- (void)freshPoiDic:(NSDictionary *)dic
{
    if ([dic count] > 0)
    {
        self.mapDataDic = dic;
        [self CreateSubView];
        for (NSString *key in [self.mapDataDic allKeys])
        {
            NSNumber *numberID = [g_pictureIdDic objectForKey:key];
            if (!numberID)
            {
                [g_pictureIdDic setObject:[NSNumber numberWithInt:g_bitCount] forKey:key];
                [self setRGBABitMapWith:&g_bitMap[g_bitCount] imageName:key];
                g_bitCount++;
            }
        }
        g_mapAddIconView = self;
        GETELEMENT pFun = GNULL;
        pFun = MWMapGetElement;
        GDBL_SetGetUserElementCB(pFun);
    }
    else
    {
        for (UIView *view in _subViewArray)
        {
            [view removeFromSuperview];
        }
        [_subViewArray removeAllObjects];
        g_mapAddIconView = nil;
        GDBL_SetGetUserElementCB(GNULL);
    }
}

- (void)CreateSubView
{
    if (_subViewArray == nil)
    {
         _subViewArray = [[NSMutableArray alloc] init];
    }
    for (UIView *view in _subViewArray)
    {
        [view removeFromSuperview];
    }
    [_subViewArray removeAllObjects];
    for (NSString *key in [self.mapDataDic allKeys])
    {
        NSArray *array = [self.mapDataDic objectForKey:key];
        _superView = (UIView *)[MapViewManager ShowMapViewInController:nil];  //获取当前显示的主地图
        for (int i = 0; i < [array count]; i++)
        {
            MWMapPoi *mapPoi = [array objectAtIndex:i];
            MWMapPoiTapView *tapView = [[MWMapPoiTapView alloc] init];
            [tapView setDelegateWith:_delegate];
            tapView.backgroundColor = [UIColor clearColor];
            tapView.center = mapPoi.scPoint;
            tapView.mapPoi = mapPoi;
            [_superView addSubview:tapView];
            [tapView release];
            [_subViewArray addObject:tapView];
            
        }
        
    }
}



#pragma mark - UITapGestureRecognizer method

- (void)poiTapRecongnizer:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.numberOfTapsRequired == 1 && recognizer.numberOfTouchesRequired == 1)
    {
        MWMapPoiTapView *tapView =  (MWMapPoiTapView *)recognizer.view;
        if (_delegate && [_delegate respondsToSelector:@selector(tapMapPoiIconnWith:)])
        {
            [_delegate tapMapPoiIconnWith:tapView.mapPoi];
        }
        NSLog(@"tap success : %ld,%ld",tapView.mapPoi.longitude,tapView.mapPoi.latitude);
    }
}

#pragma mark - public method

/**
 *	设置图标相对于点的位置
 *
 *	@param	position	设置的位置类型
 */
- (void)SetIconPosition:(IconPosition)position
{
    _iconPosition = position;
}

#pragma mark -
#pragma mark notification
-(void)notificationReceived:(NSNotification*) notification
{
    
}


#pragma mark - private method

/**
 *	将数据转换成引擎数据
 *
 *	@param	ppElements	传入引擎的元素数据
 *	@param	count       传入引擎的元素个数
 */
- (void)getElementData:(GCUSTOMELEMENT **)ppElements count:(Gint32 *)count;
{
    if ([self.mapDataDic count] > 0)
    {
        NSDictionary *currentScreenDic = [self getScreenPoiDic];
        if (![self judgeTwoDicEqual:_lastScreenDic dicTwo:currentScreenDic])
        {
            if (_lastScreenDic)
            {
                [_lastScreenDic release];
                _lastScreenDic = nil;
            }
            _lastScreenDic = [[self saveScreenPoiDic:currentScreenDic] retain];
            for (NSString *key in [currentScreenDic allKeys])
            {
                NSArray *array = [currentScreenDic objectForKey:key];
                int pictureid = [[g_pictureIdDic objectForKey:key] intValue];
                [self addTapGesture:array bit:&g_bitMap[pictureid]];
            }
        }
        
        int poiNumber = 0;
        for (NSString *key in [currentScreenDic allKeys])
        {
            NSArray *array = [currentScreenDic objectForKey:key];
            poiNumber += [array count];
        }
        *count = poiNumber;
        GCUSTOMELEMENT *temp = [self getElementDataWithDic:currentScreenDic];
        *ppElements = temp;
    }
    else
    {
        for (UIView *view in _subViewArray)
        {
            [view removeFromSuperview];
        }
        [_subViewArray removeAllObjects];
    }
}

- (BOOL)judgeTwoDicEqual:(NSDictionary *)dicOne dicTwo:(NSDictionary *)dicTwo
{
    NSArray *dicOne_allKeys = [dicOne allKeys];
    NSArray *dicTwo_allKeys = [dicTwo allKeys];
    if ([dicOne_allKeys count] == [dicTwo_allKeys count])
    {
        for (int i = 0; i < [dicOne_allKeys count]; i++)
        {
            NSArray *dicOne_value = [dicOne objectForKey:[dicOne_allKeys objectAtIndex:i]];
            NSArray *dicTwo_value = [dicTwo objectForKey:[dicTwo_allKeys objectAtIndex:i]];
            if ([dicOne_value count] == [dicTwo_value count])
            {
                for (int j = 0; j < [dicOne_value count]; j++)
                {
                    MWMapPoi *dicOne_mapPoi = [dicOne_value objectAtIndex:j];
                    MWMapPoi *dicTwo_mapPoi = [dicTwo_value objectAtIndex:j];
                    if (abs(dicOne_mapPoi.scPoint.x - dicTwo_mapPoi.scPoint.x) > 3 || abs(dicOne_mapPoi.scPoint.y - dicTwo_mapPoi.scPoint.y) > 3)
                    {
                        return NO;
                    }
                }
            }
            else
            {
                return NO;
            }
        }
    }
    else
    {
        return NO;
    }
    return YES;
}

/**
 *	根据屏幕上的点添加手势响应区域
 */
- (void)addTapGesture:(NSArray *)screenArray bit:(GBITMAP *)bit
{
    int currentArray = [screenArray count];
    for (int i = 0; i < [_subViewArray count]; i++)
    {
        MWMapPoiTapView *tapView = [_subViewArray objectAtIndex:i];
        if (i < currentArray)
        {
            MWMapPoi *mapPoi = [screenArray objectAtIndex:i];
            [tapView setDelegateWith:_delegate];
            tapView.hidden = NO;
            tapView.frame = CGRectMake(0, 0, bit->nWidth, bit->nHeight);
            CGPoint point = mapPoi.scPoint;
            point.y =  point.y - bit->nHeight/2;
            tapView.center = point;
            tapView.mapPoi = mapPoi;
        }
        else
        {
            tapView.hidden = YES;
        }
    }
}

/**
 *	获取poi数据中屏幕中的点
 *
 *	@return	屏幕中poi的数据
 */
- (NSMutableDictionary *)getScreenPoiDic
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSString *key in [self.mapDataDic allKeys])
    {
        NSArray *array = [self.mapDataDic objectForKey:key];
        NSMutableArray *screenArray = [NSMutableArray array];
        CGRect mapRect = _superView.bounds;
        for (int i = 0; i < [array count]; i++)
        {
            MWMapPoi *mapPoi = [array objectAtIndex:i];
            GCOORD geoCoord = {0};
            geoCoord.x = mapPoi.longitude;
            geoCoord.y = mapPoi.latitude;
            
            CGPoint point = [self transCoordConvertWith:geoCoord HMapView:GMAP_VIEW_TYPE_MAIN];
            mapPoi.scPoint = point;
            //        NSLog(@"%f,%f",point.x,point.y);
            if(YES==CGRectContainsPoint(mapRect, mapPoi.scPoint))
            {
                [screenArray addObject:mapPoi];
            }
        }
        
        [dic setObject:screenArray forKey:key];
    }
    return dic;
}

/**
 *	保存字典里上次poi的屏幕坐标
 *
 *	@return	保存后poi的数据
 */
- (NSMutableDictionary *)saveScreenPoiDic:(NSDictionary *)savePoiDic
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSString *key in [savePoiDic allKeys])
    {
        NSArray *array = [savePoiDic objectForKey:key];
        NSMutableArray *screenArray = [NSMutableArray array];
        for (int i = 0; i < [array count]; i++)
        {
            MWMapPoi *mapPoi = [array objectAtIndex:i];
            MWMapPoi *savePoi = [[MWMapPoi alloc] init];
            savePoi.scPoint = mapPoi.scPoint;
            [screenArray addObject:savePoi];
            [savePoi release];
        }
        
        [dic setObject:screenArray forKey:key];
    }
    return dic;
}

//经纬坐标转换屏幕坐标
-(CGPoint)transCoordConvertWith:(GCOORD)layerCoord HMapView:(GMAPVIEWTYPE)mapView
{
	GFCOORD scrCoord;
	GCOORD pgdCoord;
	CGPoint layerPoint;
	pgdCoord.x = layerCoord.x;
	pgdCoord.y = layerCoord.y;
	GSTATUS gRet;
    GHMAPVIEW mapHandle;
    GDBL_GetMapViewHandle(mapView,&mapHandle);
    
	gRet=GDBL_CoordConvert(mapHandle,GCC_GEO_TO_SCR, &scrCoord, &pgdCoord);
    
    if (GD_ERR_OK==gRet) {
        layerPoint = CGPointMake(scrCoord.x/mapScale, scrCoord.y/mapScale);
    }else
    {
        layerPoint = CGPointMake(-1, -1);//转换失败或3D模式下的天空区域内
    }
	return layerPoint;
}

/**
 *	获取传入引擎的数据
 *
 *	@param	screenDIC	屏幕中poi的数据
 *
 *	@return 传入引擎的数据
 */
- (GCUSTOMELEMENT *)getElementDataWithDic:(NSDictionary *)screenDIC
{
    int currentCount = 0;
    memset(pCustomElement, 0, sizeof(GCUSTOMELEMENT) * CUSTOMELEMENT_NUM);
    for (NSString *key in [screenDIC allKeys])
    {
        NSNumber *pictureid = [g_pictureIdDic objectForKey:key];
        NSArray *array = [screenDIC objectForKey:key];
        float offset_x = 0;
        float offset_y = 0;
        
        for (int i = 0; i < [array count]; i++)
        {
            MWMapPoi *poi = [array objectAtIndex:i];
            GBITMAP *bitmap = &g_bitMap[[pictureid intValue]];
            if (_iconPosition == Position_Bottom)
            {
                offset_y = -bitmap->nHeight/2;
            }
            pCustomElement[currentCount].pImage = bitmap;
            pCustomElement[currentCount].x = poi.scPoint.x * mapScale + offset_x;
            pCustomElement[currentCount].y = poi.scPoint.y * mapScale + offset_y;
            currentCount++;
        }
    }
    
    return pCustomElement;
}

/**
 *	将图片数据转换引擎数据
 *
 *	@param	bitMap	引擎图片结构
 *	@param	img	需要显示的图片
 */
- (void)setBitMapWith:(GBITMAP*)bitMap imageName:(NSString *)img
{
    CGImageRef inImage = IMAGE(img, IMAGEPATH_TYPE_1).CGImage;
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL)
    {
        return ; /* error */
    }
    NSNumber *number = [g_pictureIdDic objectForKey:img];
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{(float)w,(float)h}};
    static int i = 0x40000006;
    bitMap->nID=i + [number intValue];                                   // ID标识
    bitMap->nWidth =(int)w;
    bitMap->nHeight =(int)h;
    bitMap->cbxPitch =2;
    bitMap->cbyPitch =2*((int)w);
    
    int nDataCount=w*h*2;
    Guint8 *tmpRGBData= (Guint8*)malloc(nDataCount*sizeof(Guint8));
    Guint8 *rgbData = tmpRGBData;
    
    int nAlphaLen= nDataCount/2;
    Guint8 *tmpAlpha = (Guint8*)malloc(nAlphaLen);
    Guint8 *alpha=tmpAlpha;
    
    CGContextClearRect(cgctx,rect);
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = (unsigned char*)CGBitmapContextGetData (cgctx);
    if (data != NULL)
    {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        @try {
            unsigned short int write_data;
            
            for (int offset=0; offset<nDataCount*2;) {
                *tmpAlpha = (data[offset]*32/256);
                tmpAlpha++;
                write_data = (data[offset+3] >> 3)  | (( data[offset+2] & 0xFC) << 3) |(( data[offset+1] & 0xF8) << 8);
                //                write_data = (data[offset+1] >> 3)  | (((data[offset+2]<<8)& 0xFC) << 3) |((( data[offset+3]<<16) & 0xF8) << 8);
                *tmpRGBData = (write_data&0xffffffff);
                tmpRGBData++;
                *tmpRGBData = (write_data>>8);
                tmpRGBData++;
                offset+=4;
            }
            
            bitMap->pData = (Guint8*)malloc(nDataCount*sizeof(Guint8));
            memcpy(bitMap->pData, rgbData, nDataCount);
            //            currentBitmap->pData =rgbData;
            
            bitMap->pAlpha= (Guint8*)malloc(nAlphaLen*sizeof(Guint8));
            memcpy(bitMap->pAlpha, alpha, nAlphaLen);
            //            currentBitmap->pAlpha =alpha;
            free(rgbData);
            tmpRGBData = NULL;
            free(alpha);
            tmpAlpha = NULL;
        }
        @catch (NSException * e) {
            NSLog(@"exception %s\n",[[e reason] UTF8String]);
        }
        @finally
        {
            
        }
    }
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data)
    {
        free(data);
    }
    
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

/**
 *	将图片数据转换引擎数据
 *
 *	@param	bitMap	引擎图片结构 (RGBA)
 *	@param	img	需要显示的图片
 */
- (void)setRGBABitMapWith:(GBITMAP*)bitMap  imageName:(NSString *)img
{
    CGImageRef inImage = IMAGE(img, IMAGEPATH_TYPE_1).CGImage;
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL)
    {
        return ; /* error */
    }
    NSNumber *number = [g_pictureIdDic objectForKey:img];
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{(float)w,(float)h}};
    static int i = 0x40000006;
    bitMap->nID=i + [number intValue];                                   // ID标识
    bitMap->nWidth =(int)w;
    bitMap->nHeight =(int)h;
    bitMap->cbxPitch =4;
    bitMap->cbyPitch =4*((int)w);
    bitMap->euFormat = COLOR_FORMAT_RGBA8888;
    int nDataCount=w*h*4;
    Guint8 *tmpRGBData= (Guint8*)malloc(nDataCount*sizeof(Guint8));
    Guint8 *rgbaData = tmpRGBData;
    memset(rgbaData, 0, nDataCount);
    bitMap->nPixelSize = nDataCount;
    
    //    int nAlphaLen= nDataCount/2;
    //    Guint8 *tmpAlpha = (Guint8*)malloc(nAlphaLen);
    //    Guint8 *alpha=tmpAlpha;
    //    bitMap->nAlphaSize = nAlphaLen;
    
    CGContextClearRect(cgctx,rect);
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = (unsigned char*)CGBitmapContextGetData (cgctx);
    if (data != NULL)
    {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        @try {
            for (int offset = 0; offset < nDataCount/4; offset++)
            {
                
                rgbaData[offset*4 + 0] = data[offset*4 + 1];
                rgbaData[offset*4 + 1] = data[offset*4 + 2];
                rgbaData[offset*4 + 2] = data[offset*4 + 3];
                rgbaData[offset*4 + 3] = data[offset*4 + 0];
            }
            
            
            bitMap->pData = (Guint8*)malloc(nDataCount*sizeof(Guint8));
            memcpy(bitMap->pData, rgbaData, nDataCount);
            
            bitMap->pAlpha= NULL;
            free(rgbaData);
            tmpRGBData = NULL;
            
        }
        @catch (NSException * e) {
            NSLog(@"exception %s\n",[[e reason] UTF8String]);
        }
        @finally
        {
            
        }
    }
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data)
    {
        free(data);
    }
    
}


@end

@implementation MWMapPoi

@synthesize scPoint;

@end