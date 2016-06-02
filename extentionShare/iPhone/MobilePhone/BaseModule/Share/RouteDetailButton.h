//
//  RouteDetailButton.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-7-18.
//
//

#import <UIKit/UIKit.h>
//button 用来显示的数据
@interface RouteDetailButtonData : NSObject

@property (nonatomic, copy) NSString *stringTime;     //总时间
@property (nonatomic, copy) NSString *stringLength;   //路径长度
@property (nonatomic, copy) NSString *stringTrafficeNum;      //交通信号灯个数
@property (nonatomic, copy) NSString *stringTollNum;          //加油站个数
@property (nonatomic, copy) NSString *stringType;           //路径规划类型
@property (nonatomic, assign) int buttonTag;        //按钮的 tag 标示符
@property (nonatomic, assign) int routeChose;       //路线选择类型
@property (nonatomic, assign) BOOL isTuiJian;       //是否是推荐（233） 默认是非推荐
@property (nonatomic, assign) BOOL isAvoid;         //是否是躲避拥堵
@property (nonatomic, assign) int indexButton;      //是索引中的第几个
@property (nonatomic, assign) int indexTotal;       //总计有多少个索引
/*!
  @brief    设置数据值
  @param
  @author   by bazinga
  */
- (void) setData:(RouteDetailButtonData *)tempData;

@end

typedef void(^RouteListButtonPress)(int);
//点击前一个后一个
typedef void(^PreRouteListButtonPress)();
typedef void(^NextRouteListButtonPress)();

@interface RouteDetailButton : UIImageView

@property (nonatomic, retain) RouteDetailButtonData *dataWithButton;    //button 显示的数据
//@property (nonatomic, copy) RouteListButtonPress buttonPress;           //button 按钮的点击响应
@property (nonatomic, copy) PreRouteListButtonPress PreButtonPress;           //前一个 button 按钮的点击响应
@property (nonatomic, copy) NextRouteListButtonPress NextButtonPress;           //后一个 button 按钮的点击响应


/*!
  @brief    初始化函数
  @param
  @author   by bazinga
  */
- (id) init;
- (id) initWithData:(RouteDetailButtonData *)data ;

@end
