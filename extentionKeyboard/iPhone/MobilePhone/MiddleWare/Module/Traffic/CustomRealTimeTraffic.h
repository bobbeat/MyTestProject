//
//  CustomRealTimeTraffic.h
//  AutoNavi
//
//  Created by liyuhang on 12-12-18.
//
//

#import <Foundation/Foundation.h>
#define LOG_DEBUG
/*
 1 路径比例尺9格，每格10个小图片
 2 比例尺具体值 1, 2, 3, 4, 5, 15, 25, 50, 100
 3 起点在第一格， 终点计算得到，同时也是可以移动的最大距离，车位为移动的起始点
 4 根据引擎传入的各个信息点，计算相应的刻度值，以便贴相应的图片
 5 所有信息一次获取后，保存用于显示，手动调用接口进行更新
 */
typedef enum _RealTimeTrafficStatus{
    UI_RTC_STREAM_FREE = 1,             /* 畅通 */
    UI_RTC_STREAM_SLOW,                 /* 缓行 */
    UI_RTC_STREAM_CROWDED,              /* 拥堵 */
    UI_RTC_STREAM_NONE                  /* 无交通流状态数据 */
}RealTimeTrafficStatus;

@interface CustomRealTimeTraffic : NSObject
{
    NSMutableArray* m_mArrayForHalfWay;
    NSMutableArray* m_mArrayRtcInfo;
    float   m_fTotalDistance;
    float   m_fCarPosition;         // Distance from startpoint
    int     m_nCarScale;            // The scale for car position
    int     m_nDestScale;           // The scale for dest postion
    //
    int     m_nCurrentIndex;        // 当前索引值，用于按钮返回
    int     m_nCurrentIndexForMove; // 当前索引值，用于控制上下按钮选择
    //
    float         m_fFreeStatus;          /*交通情况比例*/
    float         m_fSlowStatus;
    float         m_fHeavyStatus;
    float         m_fNoDataStatus;
}
@property (nonatomic, assign) int psCurrentIndexForMove;
//
@property (nonatomic, assign) float       psfFreeStatus;
@property (nonatomic, assign) float       psfSlowStatus;
@property (nonatomic, assign) float       psfHeavyStatus;
@property (nonatomic, assign) float       psfNoDataStatus;
#pragma mark sharedInstance
+(CustomRealTimeTraffic*)sharedInstance;

// 路径是否有信息
-(BOOL) getHaveTrafficInfo;


// 更新实时交通的信息，也就是更改类中保存的相应信息
-(void) updateCurrentTrafficInfo;
/*
    添加配合CustomSlider使用的函数
 1 获取包含交通信息的数组的个数；
 2 根据“数组索引值”获取具体的交通信息-刻度值
 3 根据“数组索引值”获取具体的交通信息－长度
 4 根据“数组索引值”获取具体的交通信息－状态
 5 根据“数组索引值”获取具体的交通信息－延迟时间
 6 根据“数组索引值”获取具体的交通信息－道路名字
 
 7 根据“刻度值”查询详细信息，如有，返回数组索引值，否则返回－1；

*/
-(int) RtcInfoArrayCount;
- (NSString *)RtcSpecificInfo:(int)nArrayIndex;
-(int) RtcSpecificInfoStatus:(int) nArrayIndex;
-(NSString*) RtcSpecificInfoName:(int) nArrayIndex;
-(int) RtcSpecificInfoDistanceFromCar:(int)nArrayIndex;
-(int) RtcSpecificInfoDistanceFromStart:(int)nArrayIndex;//到起点的距离

/*
 1 根据索引值获得当前路径得时间＋延迟得时间
 */
-(NSString*)RtcTotalTimeOfRoute:(int)nArrayIndex;


@end
/*
 /////////////////////////////////////////////////////////////////////////////////////////
 ////////////////////定义一个类型对应引导道路TMC信息结构体，以交通流状态为依据合并相关道路//////////////
 /////////////////////////////////////////////////////////////////////////////////////////
 */
@interface UIGuideRoadTmc:NSObject
{
	int         m_nStartIndex;          /* 起始索引号			*/
	int         m_nEndIndex;            /* 结束索引号			*/
	int         m_nDisFromStart;        /* 距离路径起点的距离	*/
	int         m_nDis;                 /* 此段长度				*/
	NSString*   m_szRoadNames;          /* 道路名称以逗号隔开，不包含未命名道路 */
	int         m_nNumberOfEvent;       /* 事件个数				*/
	int         m_pTrafficEvents;       /* 事件ID和距起点的距离	*/
	int         m_nTrafficStream;       /* 流状态				*/
	int         m_nDelayTime;           /* 延迟时间				*/
    // UI自定义
    int         m_nScaleFromStart;      /*距离起点的刻度值*/
    int         m_nTrafficStatus;       /*交通情况,UI层定义4个*/
    int         m_nIndexInOrigianArray; /*在原有数组的索引值*/
    int         m_nDisFromCar;          // 到车位的距离
}
@property (nonatomic, assign) int       psnStartIndex;
@property (nonatomic, assign) int       psnEndIndex;
@property (nonatomic, assign) int       psnDisFromStart;
@property (nonatomic, assign) int       psnDis;
@property (nonatomic, copy)   NSString* psszRoadNames;
@property (nonatomic, assign) int       psnNumberOfEvent;
@property (nonatomic, assign) int       pspTrafficEvents;
@property (nonatomic, assign) int       psnTrafficStream ;
@property (nonatomic, assign) int       psnDelayTime;
@property (nonatomic, assign) int       psnScaleFromStart;
@property (nonatomic, assign) int       psnTrafficStatus;
@property (nonatomic, assign) int       psnIndexInOriginalArray;
@property (nonatomic, assign) int       psnDisFromCar;
//

@end






