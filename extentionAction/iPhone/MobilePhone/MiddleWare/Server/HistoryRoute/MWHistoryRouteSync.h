//
//  MWHistoryRouteSync.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-6.
//
//

#import <Foundation/Foundation.h>

@interface MWHistoryRouteSync : NSObject <NetRequestExtDelegate>

@property (nonatomic, assign) id<NetReqToViewCtrDelegate> delegate;

- (void)historyRouteSync;

@end
