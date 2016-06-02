//
//  MWNetSearchListener.h
//  AutoNavi
//
//  Created by gaozhimin on 14-2-25.
//
//

#import <Foundation/Foundation.h>
#import "NetKit.h"

@interface MWNetSearchListener : NSObject<NetRequestExtDelegate>

+ (id)createListenerWith:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	删除所有监听
 */
+ (void)clearAllListener;

/**
 *	删除某类请求
 *
 *	@param	type	请求类型
 */
+ (void)deleteListenerWith:(RequestType)type;

@end
