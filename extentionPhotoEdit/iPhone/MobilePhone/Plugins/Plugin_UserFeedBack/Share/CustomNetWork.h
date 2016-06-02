//
//  CustomNetWork.h
//  AutoNavi
//
//  Created by liyuhang on 13-5-6.
//
//

#import <UIKit/UIKit.h>
#import "ANViewController.h"
#import "CustomImagePickerCtr.h"
#import "VCTranslucentBarButtonItem.h"
#import "ANParamValue.h"

/*
 1 只处理单一网络请求
 2 开启网络请求时，暂停按钮响应
 */

@protocol SubClassProcessConnectResult

- (void)CtNetWorkConnectionDidFinishWithData:(NSData *)netData;//通知客户，网络连接完毕
- (void)CtNetWorkConnectiondidFailWithError:(NSError *)error;//通知客户网络连接失败

@end
enum _CST_NETWORK_STATUS_{
    CST_NETWORK_NO_REACHABLE_0 = 100,
    CST_NETWORK_FAILED_1,
    CST_NETWORK_TIMEOUT_2,
    CST_NETWORK_SUCCESS_3,
    CST_NETWORK_REQUEST_FAILED_4,
};
@interface CustomNetWork : CustomImagePickerCtr<SubClassProcessConnectResult> {
@private
	NSMutableData           *m_mutableDataForNet;
	NSURL                   *m_urlForNet;
	NSMutableURLRequest     *m_mutableRequestForNet;
	NSURLConnection         *m_connectionForNet;
    //
    NSTimer                 *m_timerForTimeout;
    id<SubClassProcessConnectResult> m_delegateForNet;
     UIActivityIndicatorView *m_actIndicatorViewForNet;
@public
    BOOL                    m_bNetWorking;                      // There is a connection
    BOOL                    m_bShowTipForNet;                   // Pop the alert view tip
}
/*
 1 check net status
 */
- (BOOL)CtNetWorkPreviousCheckStatus:(BOOL)bShowAlert;
/*
 2 generate request
 */
- (BOOL)CtNetWorkFirstInitWithString:(NSString *)urlString;
- (BOOL)CtNetWorkFirstInitWithUrl:(NSURL *)url;
/*
 3 establish the network
 */
- (void)CtNetWorkSecondSetConnection;
- (void)CtNetWorkSecondSetGetConnection;
- (void)CtNetWorkSecondSetPostConnectionWithBody:(NSData *)bodydata;
/*
 4 callback for network
 */
- (void)CtNetWorkConnectionDidFinishWithData:(NSData *)netData;//通知客户，网络连接完毕
- (void)CtNetWorkConnectiondidFailWithError:(NSError *)error;//通知客户网络连接失败
/*
 5 the tips for different net status
 */
-(void)CtNetWorkTipsForNetStatus:(int)nStatus;
@end