//
//  POIDesParkObj.h
//  AutoNavi
//
//  Created by weisheng on 14-4-8.
//
//

#import "MWSearchResult.h"

@interface POIDesParkObj : MWPoi
/*
 @brief 是否存在详细信息
 */
@property(nonatomic)BOOL bParkDetail;

/*
  -1->表示暂无信息 其他有信息
 */
/*
 @brief 收费 不收费 无法判断
 */
@property(copy,nonatomic)NSString* charge;
/*
 @brief 大车白天每小时价格
 */
@property(assign,nonatomic)int prc_t_d_e;
/*
 @brief 小车白天首小时价格
 */
@property(assign,nonatomic)int prc_c_d_f;
/*
 @brief 小车白天每小时价格
 */
@property(assign,nonatomic)int prc_c_d_e;
/*
 @brief 小车夜间每小时价格
 */
@property(assign,nonatomic)int prc_c_n_e;
/*
 @brief 大车夜间每小时价格
 */
@property(assign,nonatomic)int prc_t_n_e;
/*
 @brief 小车包天价格
 */
@property(assign,nonatomic)int prc_c_wd;
/*
 @brief 总车位数
 */
@property(assign,nonatomic)int num_space;
/*
 @brief 停车场营业时间
 */
@property(copy,nonatomic)NSString* time;
@end
