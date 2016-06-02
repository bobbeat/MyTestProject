//
//  FeedbackRequestCondition.h
//  AutoNavi
//
//  Created by gaozhimin on 13-7-25.
//
//

#import <Foundation/Foundation.h>
#import "NetKit.h"

/******************************************************************************************!
  @brief 提交用户反馈信息的条件基类
  ******************************************************************************************/
@interface MWFeedbackBaseCondition : NSObject

/*!
  @brief 问题描述 varchar(400) 必须
  */
@property (nonatomic,copy) NSString  *errorDesc;

/*!
  @brief QQ号 varchar(20) 不必须
  */
@property (nonatomic,copy) NSString  *qq;

/*!
  @brief 电话 varchar(20) 不必须
  */
@property (nonatomic,copy) NSString  *tel;


@end


/******************************************************************************************!
  @brief 数据报错接口的请求条件
  ******************************************************************************************/
@interface MWFeedbackDataCondition : MWFeedbackBaseCondition

/*!
  @brief 错误种类 必须 1 poi问题 2 道路问题
  */
@property (nonatomic,assign) int  dataType;

/*!
  @brief 错误类型 char(2) 必须
  */
@property (nonatomic,copy) NSString  *errorType;

/*!
  @brief 城市名称 varchar(100) 必须
  */
@property (nonatomic,copy) NSString  *cityName;

/*!
  @brief 城市代码 varchar(20)) 必须
  */
@property (nonatomic,copy) NSString  *cityCode;

/*!
  @brief 报错名称 varchar(100) 必须
  */
@property (nonatomic,copy) NSString  *name;


@end

/******************************************************************************************!
  @brief 功能反馈接口的请求条件
  ******************************************************************************************/
@interface MWFeedbackFunctionCondition : MWFeedbackBaseCondition

/*!
  @brief 问题类型 必须 
 1	 闪退问题
 2	 定位问题
 3	导航没有声音
 4	路线规划问题
 5	其它问题
  */
@property (nonatomic,assign) int  questionType;

/*!
  @brief 上传图片 Base64编码串  不必须
  */
@property (nonatomic,retain) UIImage  *pic;

@end


/******************************************************************************************!
  @brief 建议反馈接口的请求条件
  ****************************************************************************************/
@interface MWFeedbackAdviceCondition : MWFeedbackBaseCondition

/*!
  @brief 上传图片 Base64编码串  不必须
  */
@property (nonatomic,retain) UIImage  *pic;

@end

/******************************************************************************************!
  @brief 查询回复列表信息的条件
  ****************************************************************************************/
@interface MWFeedbackQueryListCondition : NSObject



@end

/******************************************************************************************!
  @brief 查询详细回复信息的条件
  ****************************************************************************************/
@interface MWFeedbackQueryDetailCondition : NSObject

/*!
  @brief 反馈的唯一标识 必须
  */
@property (nonatomic,copy) NSString  *answerId;

/*!
  @brief 错误种类 不必须 缺省值 0
  */
@property (nonatomic,assign) int  funcType;

@end

/******************************************************************************************!
  @brief 删除回复信息
  ****************************************************************************************/
@interface MWFeedbackDeleteOneCondition : NSObject

/*!
  @brief 反馈的唯一标识 必须
  */
@property (nonatomic,copy) NSString  *answerId;

@end
