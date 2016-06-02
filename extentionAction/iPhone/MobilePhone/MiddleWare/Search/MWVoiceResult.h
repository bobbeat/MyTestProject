//
//  MWVoice.h
//  AutoNavi
//
//  Created by gaozhimin on 13-7-31.
//
//

#import <Foundation/Foundation.h>

typedef enum MWVoiceDataTyoe
{
    MWVOICE_DATA_CMDERR = 0,  //语音搜索，数据以数组形式返回。
    MWVOICE_DATA_CMDID = 1,   //语音搜索，数据以类别形式返回。
}MWVoiceTyoe;

@interface MWVoiceOption : NSObject

/*!
  @brief 结果类型  默认 RESULT_TYPE_KEYWORD_CONTENT
 enum{
 RESULT_TYPE_KEYWORD_CONTENT = 0,    // 返回识别字符串和内容数据
 RESULT_TYPE_KEYWORD_ONLY = 1,       // 仅返回转换后的识别字符串
 };
  */
@property (nonatomic,assign) int			resultType;

/*!
  @brief 经度坐标
  */
@property (nonatomic,assign) long longitude;

/*!
  @brief 纬度坐标
  */
@property (nonatomic,assign) long latitude;

/*!
  @brief 行政编码，参见行政区域编码表
  */
@property (nonatomic,assign) int lAdminCode;


@end

@interface MWVoiceResult : NSObject

/*!
  @brief 语音搜索，返回数据的形式
  */
@property (nonatomic,assign) MWVoiceTyoe		voiceDataType;
/*!
  @brief 语音结果的个数
  */
@property (nonatomic,assign) int			nNumberOfItem;    

/*!
  @brief  语音结果列表   储存 MWPoi 对象
  */
@property (nonatomic,retain) NSArray*			contentArray;

/*!
  @brief  语音结果列表   
  */
@property (nonatomic,retain) NSArray*			keyArray;

/*!
  @brief 语音结果的类别   如：300 （对应住宿）
  */
@property (nonatomic,assign) int			cmdid;

/*!
  @brief 语音结果的类别名称   如：住宿  （对应300）
  */
@property (nonatomic,copy) NSString*      cmdtxt;

@end
