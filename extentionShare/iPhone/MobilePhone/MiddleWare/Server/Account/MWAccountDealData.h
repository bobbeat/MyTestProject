//
//  MWAccountDealData.h
//  AutoNavi
//
//  Created by gaozhimin on 13-9-8.
//
//

#import <Foundation/Foundation.h>
#import "MWAccountOperator.h"

@interface MWAccountDealData : NSObject<NetRequestExtDelegate>

+ (id)createDealingWith:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	删除所有监听
 */
+ (void)clearAllDealing;

/**
 *	删除某类请求
 *
 *	@param	type	请求类型
 */
+ (void)deletaDealingWith:(RequestType)type;
@end
