//
//  ViewPOIController.h
//  AutoNavi
//
//  Created by huang longfeng on 12-5-3.
//  Copyright (c) 2012年 autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANViewController.h"
#import "PaintingView.h"
#import "plugin_PoiNode.h"


@interface ViewPOIController : ANViewController<PaintingViewDelegate>
{
    PaintingView *_mapView;
   	UIButton *buttonSwitchMapMode;//地图模式切换(4)
    UIButton *buttonINC,*buttonDEC;//放大，缩小
	UIButton *label_meter;

    BOOL _firstIn;

    int viewFlag; //查图类别标志
    int viewIndex; //索引

	GCOORD poiPoint;
	GPOI curPOI;
	BOOL noAnimating;
    NSMutableArray *poiList;
  
    id<PaintingViewDelegate> delegate;
    NSTimer *inc_timer, *dec_timer;
    NSTimer *m_delayShowButton;
    BOOL isTmcLoading;
    BOOL bLongPressed; //是否长按放大，缩小
    
}
@property(assign) id<PaintingViewDelegate> delegate;
@property (nonatomic) BOOL noAnimating;
@property (nonatomic,assign) int aroundFlag;
@property (nonatomic,copy) NSString *titleString;

- (id)initWithIndex:(int)index ViewFlag:(int)flag POI:(NSArray *)viewPOI;
- (id)initWithIndex:(int)index ViewFlag:(int)flag POI:(NSArray *)viewPOI withTitle:(NSString*)title;
- (UIButton *)buttonInCondition:(NSInteger)condition;
- (void)ChangePOI;
- (void)initControl;
- (void)viewInfoInCondition:(NSInteger)condition;
- (UILabel *)labelInCondition:(NSInteger)condition;
@end
