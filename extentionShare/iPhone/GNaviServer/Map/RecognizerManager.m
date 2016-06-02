//
//  RecognizerManager.m
//  RecognizerTest
//
//  Created by Autonavi on 12-5-10.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RecognizerManager.h"
#import "PaintingView.h"


@implementation RecognizerManager

static RecognizerManager	*instance = nil;		//单例对象

@synthesize delegate;

- (id)init{    
	self = [super init];
	if (self) 
	{
		mapScale =1.0f;
		memset(&stMoveMap, 0, sizeof(GMOVEMAP));
       // [self getDataInfoFromFile];
	}
	return self;
}	

/**********************************************************************
 * 函数名称: recognizerInstance
 * 功能描述: 单例,回调函数中使用   
 * 输入参数: 
 * 输出参数: 
 * 返 回 值：成功返回recognizerManager对象
 * 其它说明: 
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 **********************************************************************/
+(id)recognizerInstance
{
	@synchronized(self)
	{
		if (nil==instance)
		{
			instance = [[RecognizerManager alloc] init];
		}
	}
	return instance;
}

-(void)dealloc
{
    GDBL_StopAllRecognizeEvent();
	[super dealloc];
}

-(BOOL) isRecognizeInFrame:(CGPoint) point WithStatus:(BOOL) singleStatus
{
	if (iAcitveTypes !=0&&singleStatus==NO) 
	{
		return NO;
	}
	if (point.x>myRecognizeFrame.origin.x
		&&point.x<(myRecognizeFrame.origin.x+myRecognizeFrame.size.width)
		&&point.y>myRecognizeFrame.origin.y
		&&point.y<(myRecognizeFrame.origin.y+myRecognizeFrame.size.height)) {
		return YES;
	}
	return NO;
}
/**********************************************************************
 * 函数名称: setDelegate
 * 功能描述: 设置手势委托   
 * 输入参数: (id)recognizerDelegate
 * 输出参数: 
 * 返 回 值：
 * 其它说明: 
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 **********************************************************************/
-(void)setDelegateExt:(id)recognizerDelegate
{
     delegate = recognizerDelegate;
	if ([recognizerDelegate isKindOfClass:[PaintingView class]]==NO) {
//		NSLog(@"recognize support paintingview only");
		return;
	}
	
	UIView *delegateView = (UIView*)recognizerDelegate;
	
	delegateView.exclusiveTouch = YES;

	if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)])
	{
		mapScale = [[UIScreen mainScreen] scale];
	}
	//两点触控,二指往內或往外拨动
	UIPinchGestureRecognizer *pinchRecognizer;
	pinchRecognizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchRecognizer:)] autorelease];
	lastScale = 1.0f;
	[pinchRecognizer setDelegate:recognizerDelegate];
	[delegateView addGestureRecognizer:pinchRecognizer];
	
	//旋转
	UIRotationGestureRecognizer *twoFingersRotate =
	[[[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingersRotate:)] autorelease];
	twoFingersRotate.delegate = recognizerDelegate;
	[delegateView addGestureRecognizer:twoFingersRotate];
	
	//滑动、移图
	UIPanGestureRecognizer *panRecongnizer;
	panRecongnizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecongnizer:)] autorelease];
	panRecongnizer.delegate = recognizerDelegate;
	[panRecongnizer setMaximumNumberOfTouches:2];
	[delegateView addGestureRecognizer:panRecongnizer];
	
	//单击，点击移图
	UITapGestureRecognizer *singleFingerOne = [[[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(handleSingleFingerEvent:)] autorelease];  
    singleFingerOne.numberOfTouchesRequired = 1; //手指数  
    singleFingerOne.numberOfTapsRequired = 1; //tap次数  
    singleFingerOne.delegate = recognizerDelegate;  
    [delegateView addGestureRecognizer:singleFingerOne]; 
	
	[singleFingerOne requireGestureRecognizerToFail:pinchRecognizer];

	
	//单指双击，放大一个比例尺并移图到双击的点
	UITapGestureRecognizer *singleFingerTwo = [[[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(handleSingleFingerEvent:)] autorelease];  
    singleFingerTwo.numberOfTouchesRequired = 1;
    singleFingerTwo.numberOfTapsRequired = 2;
    singleFingerTwo.delegate = recognizerDelegate;
    [delegateView addGestureRecognizer:singleFingerTwo];  
	
	[singleFingerOne requireGestureRecognizerToFail:singleFingerTwo];
	
	
	//双指双击，缩小一个比例尺
    UITapGestureRecognizer *doubleFingerTwo = [[[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(handleDoubleFingerEvent:)] autorelease];  
    doubleFingerTwo.numberOfTouchesRequired = 2;  
    doubleFingerTwo.numberOfTapsRequired = 1;  
    doubleFingerTwo.delegate = recognizerDelegate;  
    [delegateView addGestureRecognizer:doubleFingerTwo]; 
	
	[doubleFingerTwo requireGestureRecognizerToFail:panRecongnizer];
	[doubleFingerTwo requireGestureRecognizerToFail:pinchRecognizer];
	
//	[panRecongnizer requireGestureRecognizerToFail:twoFingersRotate];//若设置此项，panRecognizer 则无法识别2指事件
	
	UILongPressGestureRecognizer *longPress =[[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressEvent:)]autorelease];
	longPress.delegate=recognizerDelegate;
	longPress.minimumPressDuration =0.2;
	[delegateView addGestureRecognizer:longPress];
	
	[self setRecognizeActive:EVENT_NONE];//default active recognize when set delegate
	
	[self setRecognizeFrame:delegateView.frame];
}

/**********************************************************************
 * 函数名称: setRecognizeFrame
 * 功能描述: 设置手势响应区域   
 * 输入参数: (CGRect)recognizedFrame
 * 输出参数: 
 * 返 回 值：
 * 其它说明: 
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 **********************************************************************/
-(void)setRecognizeFrame:(CGRect)recognizedFrame
{
	myRecognizeFrame = CGRectMake(recognizedFrame.origin.x, recognizedFrame.origin.y, recognizedFrame.size.width, recognizedFrame.size.height);
}

/**********************************************************************
 * 函数名称: setRecognizeActive
 * 功能描述: 设置手势响应开关   
 * 输入参数: (BOOL) activeType
 * 输出参数: 
 * 返 回 值：
 * 其它说明: 
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 **********************************************************************/
-(void)setRecognizeActive:(int) activeTypes
{

	iAcitveTypes = activeTypes;
	if (iAcitveTypes<0)
	{
		bPinchActive = NO;
		bRotateActive = NO;
		bPanActive = NO;
		bPanMoveActive = NO;
		bSwipActive = NO;
		bTapSingleActive = NO;
		bTapDoubleActive = NO;
		bDoubleFingerActive = NO;
        bLongPressActive = NO;
	}
	else if (activeTypes ==EVENT_NONE) 
	{
		bPinchActive = YES;
		bRotateActive = YES;
		bPanActive = YES;
		bPanMoveActive = YES;
		bSwipActive = YES;
		bTapSingleActive = YES;
		bTapDoubleActive = YES;
		bDoubleFingerActive = YES;
        bLongPressActive = YES;
	}
	else 
	{
		bPinchActive =((activeTypes&EVENT_PINCH)==EVENT_PINCH)?YES:NO;
		bRotateActive = ((activeTypes&EVENT_ROTATE)==EVENT_ROTATE)?YES:NO;
		bPanActive = ((activeTypes&EVENT_PAN)==EVENT_PAN)?YES:NO;
		bPanMoveActive = ((activeTypes&EVENT_PAN_MOVE)==EVENT_PAN_MOVE)?YES:NO;
		bSwipActive = ((activeTypes&EVENT_SWIP)==EVENT_SWIP)?YES:NO;
		bTapSingleActive = ((activeTypes&EVENT_TAP_SINGLE)==EVENT_TAP_SINGLE)?YES:NO;
		bTapDoubleActive = ((activeTypes&EVENT_TAP_DOUBLE)==EVENT_TAP_DOUBLE)?YES:NO;
		bDoubleFingerActive = ((activeTypes&EVENT_DOUBLE_FINGER_TAP)==EVENT_DOUBLE_FINGER_TAP)?YES:NO;
        bLongPressActive = ((activeTypes&EVENT_LONGPRESS)==EVENT_LONGPRESS)?YES:NO;
	}
}
#pragma mark recognizer handle start

- (void)pinchRecognizer:(UIPinchGestureRecognizer *)recognizer 
{
	if ([self isRecognizeInFrame:[recognizer locationInView:recognizer.view] WithStatus:bPinchActive]==NO)
    {
		return;
	}
	if([recognizer state] == UIGestureRecognizerStateBegan)  
    {   
		if (GDBL_CheckRecognizeType(EVENT_SWIP)==Gtrue)
		{
			return;
		}
		
		GDBL_SetRecognizeEvent(EVENT_PINCH,Gfalse);
		lastScale = 1.0f;

		return;
    }
	
	if([recognizer state] == UIGestureRecognizerStateChanged)  
    {    			
		if (abs(lastScale*100-recognizer.scale*100)>10
			&&GDBL_CheckRecognizeType(EVENT_PINCH)==Gfalse
			&&GDBL_CheckRecognizeType(EVENT_NONE)==Gfalse) 
		{
			GDBL_SetRecognizeEvent(EVENT_PINCH,Gtrue);

			lastScale = recognizer.scale;
			return;				
		}
		if (abs(lastScale*100-recognizer.scale*100)>25)
		{

			GDBL_SetRecognizeEvent(EVENT_PINCH, Gfalse);

			if (lastScale<recognizer.scale)//双指分开
			{
                GMAPVIEW pMapview = {0};
                GDBL_GetMapView(&pMapview);
                GHMAPVIEW hMapView = NULL;
                GDBL_GetMapViewHandle(pMapview.eViewType, &hMapView);
                GDBL_ZoomMapView(hMapView, GSETMAPVIEW_LEVEL_IN, 0);
                if (delegate && [delegate respondsToSelector:@selector(mapView:GestureRecognizer:gestureType:withParam:)]) {
                    [delegate mapView:nil GestureRecognizer:recognizer gestureType:EVENT_PINCH  withParam:0];
                }
               
                
			}else //双指捏合
			{
                GMAPVIEW pMapview = {0};
                GDBL_GetMapView(&pMapview);
                GHMAPVIEW hMapView = NULL;
                GDBL_GetMapViewHandle(pMapview.eViewType, &hMapView);
                GDBL_ZoomMapView(hMapView, GSETMAPVIEW_LEVEL_OUT, 0);
                if (delegate && [delegate respondsToSelector:@selector(mapView:GestureRecognizer:gestureType:withParam:)]) {
                    [delegate mapView:nil GestureRecognizer:recognizer gestureType:EVENT_PINCH  withParam:1];
                }
                
                
			}
			lastScale = recognizer.scale;
		}

    }
	if([recognizer state] == UIGestureRecognizerStateEnded)
	{
		if(1!=((int)lastScale))
		{
			GDBL_StopAllRecognizeEvent();
		}
		lastScale = 1.0;
		
	}
	else if([recognizer state] == UIGestureRecognizerStateFailed)  
	{

	}
	
}

- (void)twoFingersRotate:(UIRotationGestureRecognizer *)recognizer 
{
    
	if ([self isRecognizeInFrame:[recognizer locationInView:recognizer.view] WithStatus:bRotateActive]==NO)
    {
		
        return;
	}
	if([recognizer state] == UIGestureRecognizerStateBegan) 
	{
		if (GDBL_CheckRecognizeType(EVENT_SWIP)==Gtrue)
		{
			return;
		}
		GDBL_SetRecognizeEvent(EVENT_ROTATE,Gtrue);

		firstRotation = recognizer.rotation;
		
		return;
	}
	if([recognizer state] == UIGestureRecognizerStateChanged)
	{
        
		CGFloat lastRotation;
		lastRotation = firstRotation- recognizer.rotation;
		if(abs(lastRotation*180/M_PI)>4)//10度
		{
			if (abs(lastRotation*180/M_PI)<3
				&&GDBL_CheckRecognizeType(EVENT_ROTATE)==Gfalse
				&&GDBL_CheckRecognizeType(EVENT_NONE)==Gfalse) 
			{
                
				GDBL_SetRecognizeEvent(EVENT_ROTATE,Gtrue);
				firstRotation = recognizer.rotation;
				return;				
			}
			GDBL_SetRecognizeEvent(EVENT_ROTATE,Gfalse);

//			int deltaVelocity =(int)(recognizer.velocity);
            GMAPVIEW pMapview = {0};
            GDBL_GetMapView(&pMapview);
            
            GHMAPVIEW hMapView = NULL;
            GDBL_GetMapViewHandle(pMapview.eViewType, &hMapView);
//            GDBL_RotateMapViewEx(mapHandle,NO,0,0,lastRotation*180/M_PI,deltaVelocity);
            GDBL_RotateMapView(hMapView, lastRotation*180/M_PI);
            if (delegate && [delegate respondsToSelector:@selector(mapView:GestureRecognizer:gestureType:withParam:)]) {
                [delegate mapView:nil GestureRecognizer:recognizer gestureType:EVENT_ROTATE  withParam:0];
            }
            
			//GDBL_RotateMapEx(lastRotation*180/M_PI, (int)velocity);
			GDBL_SetRecognizeEvent(EVENT_ROTATE, Gfalse);
			firstRotation = recognizer.rotation;
		}

		
	}
	if([recognizer state] == UIGestureRecognizerStateEnded)
	{
//		if (GDBL_CheckRecognizeType(EVENT_ROTATE)==Gtrue) 
//		{
//			GDBL_StopRotate(Gtrue);
//			firstRotation =0.0f;
//		}
	}
}

- (void)panRecongnizer:(UIPanGestureRecognizer *)recognizer 
{
	if ([self isRecognizeInFrame:[recognizer locationInView:recognizer.view] WithStatus:(bPanActive||bPanMoveActive||bSwipActive)]==NO) {
        
		return;
	}
	if (MUT_RECOGNIZE_SUPPORT==0) {
		if (!((GDBL_CheckRecognizeType(EVENT_PAN)==Gfalse)
			  ||(GDBL_CheckRecognizeType(EVENT_PAN_MOVE)==Gfalse))
			&&(GDBL_CheckRecognizeType(EVENT_NONE)==Gfalse)) 
		{
            
			return;
		}
	}

	if (recognizer.state == UIGestureRecognizerStateBegan) 
	{
		startLocation = [recognizer locationInView:recognizer.view];
		if ((GDBL_CheckRecognizeType(EVENT_PAN)==Gfalse)
			&&(GDBL_CheckRecognizeType(EVENT_PAN_MOVE)==Gfalse)
			&&(GDBL_CheckRecognizeType(EVENT_PINCH)==Gfalse)
			&&(GDBL_CheckRecognizeType(EVENT_ROTATE)==Gfalse)
			&&(GDBL_CheckRecognizeType(EVENT_SWIP)==Gfalse)
			&&(GDBL_CheckRecognizeType(EVENT_NONE)==Gfalse)
			)
		{
			NSLog(@"exception! fail status");
			if ([recognizer numberOfTouches]==1) 
			{
				GDBL_SetRecognizeEvent(EVENT_PAN, Gtrue);
			}
			return;
		}

		if ([recognizer numberOfTouches]==2)
		{
            
			GDBL_SetRecognizeEvent(EVENT_SWIP, Gtrue);
			return;

		}else 
		{
            
			if (bPanActive||bPanMoveActive) 
			{
			GDBL_SetRecognizeEvent(EVENT_PAN, Gtrue);

			}
		}

    }
	if (recognizer.state == UIGestureRecognizerStateChanged)
	{
        
		if ([recognizer numberOfTouches]==2&&bSwipActive)//&&recognizeHandleID==EVENT_SWIP) 
		{
			CGPoint changeLocation = [recognizer locationInView:recognizer.view];
			
            int tmpValue;
            UIInterfaceOrientation ori = [[UIApplication sharedApplication] statusBarOrientation];
            if (ori == UIInterfaceOrientationPortrait || ori == UIInterfaceOrientationPortraitUpsideDown)
            {
                tmpValue = 0;
            }
            else  if (ori == UIInterfaceOrientationLandscapeLeft || ori == UIInterfaceOrientationLandscapeRight)
            {
                 tmpValue = 1;
            }

			if(abs((startLocation.y-changeLocation.y)*90/(tmpValue==1?SCREENHEIGHT/2:SCREENWIDTH/2))>4&&
			   abs(changeLocation.y-startLocation.y)>abs(changeLocation.x-startLocation.x)*2)
			{
				//swipe in Y,incY>incX*2&&incY >4

				if (GDBL_CheckRecognizeType(EVENT_SWIP)==Gfalse&&GDBL_CheckRecognizeType(EVENT_NONE)==Gfalse) 
				{				
                    
					GDBL_SetRecognizeEvent(EVENT_SWIP, Gfalse);
					startLocation = changeLocation;
					return;
				}
				GDBL_SetRecognizeEvent(EVENT_SWIP, Gfalse);
                
                GMAPVIEW pMapview = {0};
                GDBL_GetMapView(&pMapview);
                GHMAPVIEW mapHandle = NULL;
                GDBL_GetMapViewHandle(pMapview.eViewType, &mapHandle);
                GMAPVIEWINFO pMapViewInfo;
                GDBL_GetMapViewInfo(mapHandle, &pMapViewInfo);
                GDBL_AdjustMapViewElevation(mapHandle ,(startLocation.y- changeLocation.y)*90/(tmpValue==1?SCREENHEIGHT/2:SCREENWIDTH/2));
                
                startLocation = changeLocation;
                
                if (delegate && [delegate respondsToSelector:@selector(mapView:GestureRecognizer:gestureType:withParam:)]) {
                    [delegate mapView:nil GestureRecognizer:recognizer gestureType:EVENT_SWIP  withParam:0];
                }
                
                
				startLocation = changeLocation;

			}else 
			{
                
				if (GDBL_CheckRecognizeType(EVENT_SWIP)==Gfalse)
				{
					startLocation = changeLocation;
				}
			}

		}
        else if ([recognizer numberOfTouches]==1&&(GDBL_CheckRecognizeType(EVENT_PAN)==Gtrue))
		{		
			CGPoint changeLocation = [recognizer locationInView:recognizer.view];
							
			stMoveMap.eOP =MOVEMAP_OP_DRAG;
			stMoveMap.deltaCoord.x = (startLocation.x-changeLocation.x)*mapScale;
			stMoveMap.deltaCoord.y = (startLocation.y-changeLocation.y)*mapScale;
            
            GMAPVIEW pMapview = {0};
            GDBL_GetMapView(&pMapview);
            [[MWMapOperator sharedInstance] MW_MoveMapView:pMapview.eViewType TypeAndCoord:&stMoveMap]; //modify by gzm for 移图时，post消息改变ANParamValue中的isMove标识 at 2014-7-26
            if (delegate && [delegate respondsToSelector:@selector(mapView:GestureRecognizer:gestureType:withParam:)]) {
                [delegate mapView:nil GestureRecognizer:recognizer gestureType:EVENT_PAN  withParam:0];
            }
           
            
			GDBL_SetRecognizeEvent(EVENT_PAN, Gfalse);

			startLocation = changeLocation;

		}
		
	}
    else if (recognizer.state == UIGestureRecognizerStateEnded)
	{
        
//		GDBL_StopAdjustElevation(Gtrue);

		CGPoint volite = [recognizer velocityInView:recognizer.view];
		
		if ((abs(volite.x)>1000||abs(volite.y)>1000)&&GDBL_CheckRecognizeType(EVENT_PAN)==Gtrue) 
		{	
			GDBL_SetRecognizeEvent(EVENT_PAN_MOVE, Gfalse);
			GDBL_FlingMap(volite.x*mapScale, volite.y*mapScale);
            
            if (delegate && [delegate respondsToSelector:@selector(mapView:GestureRecognizer:gestureType:withParam:)]) {
                [delegate mapView:nil GestureRecognizer:recognizer gestureType:EVENT_PAN_MOVE  withParam:0];
            }
             
		}
		else
		{
			GDBL_StopAllRecognizeEvent();
		}
		
    }
}

- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)recognizer 
{
	if ([self isRecognizeInFrame:[recognizer locationInView:recognizer.view] WithStatus:(bTapSingleActive||bTapDoubleActive)]==NO)
	{
		return;
	}

    GDBL_StopAllRecognizeEvent();

	if (recognizer.numberOfTapsRequired == 1) 
	{
        //单指单击
        if (delegate && [delegate respondsToSelector:@selector(mapView:GestureRecognizer:gestureType:withParam:)]) {
           [delegate mapView:nil GestureRecognizer:recognizer gestureType:EVENT_TAP_SINGLE  withParam:0];
        }
    }else
		if(recognizer.numberOfTapsRequired == 2&&GDBL_CheckRecognizeType(EVENT_NONE)==Gtrue)
		{  
            GMAPVIEWMODE mapMode;
            GMAPVIEW pMapview;
            GDBL_GetMapView(&pMapview);
            GHMAPVIEW mapHandle;
            GDBL_GetMapViewHandle(pMapview.eViewType,&mapHandle);
            GMAPVIEWINFO pMapViewInfo;
            GDBL_GetMapViewInfo(mapHandle, &pMapViewInfo);
            mapMode = pMapViewInfo.eMapMode;
           
//			if (GMAPVIEW_MODE_3D==mapMode&& (GMAPVIEWTYPE)pMapview.eViewType == GMAP_VIEW_TYPE_MAIN)
//			{
//				//zoomIn not support in 3D
//			}else
            {
                GHMAPVIEW hMapView = NULL;
                GDBL_GetMapViewHandle(pMapview.eViewType, &hMapView);
                GDBL_ZoomMapView(hMapView, GSETMAPVIEW_LEVEL_IN, 0);
                
                if (delegate && [delegate respondsToSelector:@selector(mapView:GestureRecognizer:gestureType:withParam:)]) {
                    [delegate mapView:nil GestureRecognizer:recognizer gestureType:EVENT_TAP_DOUBLE  withParam:0];
                    
				}

			}
		
	}
   GDBL_StopAllRecognizeEvent();
}


- (void)handleDoubleFingerEvent:(UITapGestureRecognizer *)recognizer 
{
    if ([self isRecognizeInFrame:[recognizer locationInView:recognizer.view] WithStatus:bDoubleFingerActive]==NO) {
		return;
	}

	GDBL_StopAllRecognizeEvent();
	GMAPVIEWMODE value;
    GMAPVIEW pMapview;
    GDBL_GetMapView(&pMapview);
    GHMAPVIEW mapHandle;
    GDBL_GetMapViewHandle(pMapview.eViewType,&mapHandle);
    GMAPVIEWINFO pMapViewInfo;
    GDBL_GetMapViewInfo(mapHandle, &pMapViewInfo);
    value = pMapViewInfo.eMapMode;
	if (GMAPVIEW_MODE_3D==value&& (GMAPVIEWTYPE)pMapview.eViewType == GMAP_VIEW_TYPE_MAIN)
	{
		//return;
	}
    GHMAPVIEW hMapView = NULL;
    GDBL_GetMapViewHandle(pMapview.eViewType, &hMapView);
    GDBL_ZoomMapView(hMapView, GSETMAPVIEW_LEVEL_OUT, 0);
    
    if (delegate && [delegate respondsToSelector:@selector(mapView:GestureRecognizer:gestureType:withParam:)]) {
        [delegate mapView:nil GestureRecognizer:recognizer gestureType:EVENT_DOUBLE_FINGER_TAP  withParam:0];
    }
}

-(void)handleLongPressEvent:(UILongPressGestureRecognizer *)recognizer
{
    if ([self isRecognizeInFrame:[recognizer locationInView:recognizer.view] WithStatus:bLongPressActive] == NO)
    {
		return;
	}
    if (delegate && [delegate respondsToSelector:@selector(mapView:GestureRecognizer:gestureType:withParam:)]) {
        [delegate mapView:nil GestureRecognizer:recognizer gestureType:EVENT_LONGPRESS  withParam:0];
    }
    
    
	if (recognizer.state == UIGestureRecognizerStateBegan) 
	{
		GDBL_StopAllRecognizeEvent();
	}
	else if (recognizer.state == UIGestureRecognizerStateChanged) 
	{
         
	}
    else if (recognizer.state == UIGestureRecognizerStateEnded)
	{

	}

}

#pragma mark recognizer handle end

@end
