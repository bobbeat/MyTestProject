//
//  MWAccountRequest.h
//  AutoNavi
//
//  Created by yaying.xiao on 14-10-20.
//
//

#import <Foundation/Foundation.h>

@interface MWAccountRequest : NSObject<NetRequestExtDelegate>
{
    

}
@property (nonatomic, assign) id<NetReqToViewCtrDelegate> delegate;
@property (nonatomic, copy) NSString* strcheckcode;
@property (nonatomic, copy) NSString* struserid;
@property (nonatomic, copy) NSString* strsid;
@property (nonatomic, copy) NSString* strnickname;
@property (nonatomic, copy) NSString* strusername;
@property (nonatomic, copy) NSString* strphone;
@property (nonatomic, copy) NSString* strimageurl;

- (void)accountRegistRequest:(RequestType)type  username:(NSString*)username password:(NSString*)pwd;
- (void)accountLoginRequest:(RequestType)type  username:(NSString*)username password:(NSString*)pwd;
- (void)accountLoginStatusRequest:(RequestType)type;
- (void)accountLogoutRequest:(RequestType)type;
- (void)accountCheckCodeRequest:(RequestType)type phone:(NSString*)phone actiontype:(NSString*)actiontype;
- (void) accountpwdResetRequest:(RequestType)type username:(NSString*)username password:(NSString*)pwd checkcode:(NSString*)checkcode;
- (void) accountbindphoneRequest:(RequestType)type newphone:(NSString*)newphone  checkcode:(NSString*)checkcode;
- (void)accountHeaderImgRequest:(RequestType)type image:(UIImage*)image ;
- (void) accountChangeNickNameRequest:(RequestType)type nickname:(NSString*)nickname;
- (void)accountGetImageRequest:(RequestType)type imageUrl:(NSString*)imageurl;
@end
