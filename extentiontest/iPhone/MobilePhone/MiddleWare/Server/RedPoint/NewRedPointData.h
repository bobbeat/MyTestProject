//
//  NewRedPointData.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-5-29.
//
//

#import <Foundation/Foundation.h>

typedef void(^RedRequesetSuccess)(void);
typedef void(^RedRequesetFail)(void);

@interface NewRedPointData : NSObject<NetRequestExtDelegate>

//服务器下发的数据结果
#define  RED_POINT_SVCCONT  @"svccont"
#define  RED_POINT_ID       @"servicesid"
#define  RED_POINT_SIGN     @"sign"
#define  RED_POINT_TAG      @"tag"
#define  RED_POINT_TYPE     @"type"
#define  RED_POINT_ISPRESS  @"isPress"
#define  RED_POINT_ISDOWN   @"isDown"   //这次是否有下发数据，0 没又下发，1，下发了数据   ——  没有下发数据将会被删除
//红点类型，推荐和非推荐
#define  RED_TYPE_RECOMMEND    @"0" //推荐
#define  RED_TYPE_NO_RECOMMEND @"1" //非推荐

@property (nonatomic, copy) RedRequesetSuccess redRequestSuccess;
@property (nonatomic, copy) RedRequesetFail redRequestFail;

+ (NewRedPointData *)sharedInstance;

/*!
  @brief 请求红点的信息列表
  */
- (void)RequestRedPointURL;

/*!
  @brief    设置某一项被点击过
  @param
  @author   by bazinga
  */
- (void) setItemPress:(NSString *) type withID:(NSString *)stringID;

/*!
  @brief    根据类型来获取是否需要显示红点信息
  @param    type —— 类型，0-服务推荐插件 1-服务非推荐插件 2-图层
  @author   by bazinga
  */
- (BOOL) getValueByType:(NSString *)type;

/*!
  @brief    根据类型 和 id 信息 来获取是否需要显示红点信息
  @param    type —— 类型，0-服务推荐插件 1-服务非推荐插件 2-图层
  @param    stringID —— 类型下的服务 id
  @author   by bazinga
  */
- (BOOL) getValueByType:(NSString *)type withID:(NSString *) stringID;

/*!
  @brief    根据类型来获取某一个类型的数组
  @param    type —— 类型，0-服务推荐插件 1-服务非推荐插件 2-图层
  @author   by bazinga
  */
- (NSDictionary *) getArrayByType:(NSString *)type;

@end
