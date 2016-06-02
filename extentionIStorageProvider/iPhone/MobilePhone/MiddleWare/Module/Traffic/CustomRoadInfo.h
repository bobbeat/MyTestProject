//
//  RoadInfo.h
//  AutoNavi
//
//  Created by liyuhang on 13-1-16.
//
//

#import <Foundation/Foundation.h>
#import "CustomClassForRoadList.h"
// 主要道路
@interface MainRoadInfo : NSObject
{
    NSString *m_szDistance;
    NSString *m_szRoadName;
    NSString *m_szNextRoadName;
    int       m_nDirectID;
    int       m_nCountOfSubRoadInfo;
    int       m_nTrafficStatus;
    int       m_nEventState;
    NSMutableArray*  m_arraySubRoadInfo;
    BOOL      m_bCarOnTheRoad;
    BOOL      m_bShowSubRoadInfo;
    //
    CustomHeaderForRoadList* m_imgView;
    //
    int       m_nIndexInRoadList;
    BOOL      m_bSetDetour;
    BOOL      m_bEvent;
    NSString *m_szEventDetail;
    NSString *m_szEventName;
    
}
@property (nonatomic, copy) NSString *psszDistance;
@property (nonatomic, copy) NSString *psszRoadName;
@property (nonatomic, copy) NSString *psszNextRoadName;
@property (nonatomic, assign) int psnDirectID;
@property (nonatomic, assign) int psnCountOfSubRoadInfo;
@property (nonatomic, assign) int psnTrafficStatus;
@property (nonatomic, assign) int psnEventState;
@property (nonatomic, retain) NSMutableArray* psarraySubRoadInfo;
@property (nonatomic, assign) BOOL psbCarOnTheRoad;
@property (nonatomic, assign) BOOL psbShowSubRoadInfo;
@property (nonatomic, retain) CustomHeaderForRoadList* psimgView;
@property (nonatomic, assign) int  psnIndexInRoadList;
@property (nonatomic, assign) BOOL psbSetDetour;
@property (nonatomic, assign) BOOL psbEvent;
@property (nonatomic, copy)   NSString *psszEventDetail;
@property (nonatomic, copy)   NSString *psszEventName;


@end


// 详细道路
@interface SubRoadInfo : NSObject
{
    NSString* m_szDistance;
    NSString* m_szRoadName;
    int       m_nDirectID;
    int       m_nTrafficStatus;
    BOOL      m_bCarOnTheRoad;
    int       m_nIndexInRoadList;
    BOOL      m_bSetDetour;
}
@property (nonatomic, copy) NSString* psszDistance;
@property (nonatomic, copy) NSString* psszRoadName;
@property (nonatomic, assign) int psnDirectID;
@property (nonatomic, assign) int psnTrafficStatus;
@property (nonatomic, assign) BOOL psbCarOnTheRoad;
@property (nonatomic, assign) int  psnIndexInRoadList;
@property (nonatomic, assign) BOOL psbSetDetour;
@end

/*
 *机动文本信息列表
 */

@interface ManeuverInfoList : NSObject

@property (nonatomic, assign) Guint32 nNumberOfManeuver;    /**< 个数*/
@property (nonatomic, retain) NSArray *pManeuverText;  /**<机动信息数组 */

@end

// 机动文本信息
@interface ManeuverInfo : NSObject

@property (nonatomic, copy) NSString* szDescription;    /**< 机动信息描述 */
@property (nonatomic, assign) GOBJECTID stObjectId;     /**< 对象ID信息 */
@property (nonatomic, assign) Guint32 nID;              /**< ID */
@property (nonatomic, assign) Guint32 unTurnID;         /**< 转向ID */
@property (nonatomic, assign) Gint32  nNextDis;         /**< 路口距离（单位：米） */
@property (nonatomic, assign) Gint32 nNextArrivalTime;  /**< 到达路口预计耗时（单位：分） */
@property (nonatomic, assign) Gint32 nTotalRemainDis;   /**< 到达目的地距离（单位：米） */
@property (nonatomic, assign) Gint32      nTrafficLightNum;       /**< 交通灯数目 */
@property (nonatomic, assign) GTRAFFICSTREAM	eTrafficStream;		/**< 实时交通状态 */
@property (nonatomic, assign) Guint32		nTrafficEventID;		/**< 实时交通事件ID */
@property (nonatomic, assign) GGUIDEROADFLAG		eFlag;			/**< 道路属性标志位 */
@property (nonatomic, assign) Gint32		nDisFromCar;			/**< 车位到该路口距离 */
@property (nonatomic, copy)   NSString* currentLoadName;        /**< 当前道路名 */
@property (nonatomic, copy)   NSString* nextLoadName;        /**< 下一道路名 */
@property (nonatomic, assign) Guint32		  nNumberOfSubManeuver;		/**< 个数 */
@property (nonatomic, assign) GCOORD		Coord;					/**< 经纬度信息 */
@property (nonatomic, assign) BOOL isExtension;         //是否有展开
@property (nonatomic, assign) BOOL isSonPoint;          //是否是子节点

@property (nonatomic, retain) NSArray *pstSubManeuverText;  /**<机动信息数组 */

@property (nonatomic,assign) int nNumberOfEvents;           /*事件个数*/
@property (nonatomic,assign) GEVENTINFO *pstGeventInfo;     /*事件信息*/
@property (nonatomic,assign) GDETOURROADINFO *detourRoadInfo; /*避让道路信息*/

- (NSString *) getNextDisString;

@end