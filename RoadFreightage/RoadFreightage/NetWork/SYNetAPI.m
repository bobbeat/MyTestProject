//
//  SYNetAPI.m
//  SuYun
//
//  Created by yu.liao on 15/5/15.
//  Copyright (c) 2015年 yu.liao. All rights reserved.
//

#import "SYNetAPI.h"
#import "NetRequestCondition.h"
#import "Net.h"

NSString *const SYNetErrorDomain = @"SYNetErrorDomain";

NSString *const SYNetErrorParamCodeKey = @"SYNetErrorParamCodeKey";

#define SID       @"sid"
#define UserID    @"userid"
#define UserType  @"usertype"
#define PlatForm  @"platform"

#define VerifyCodeURL          @"http://123.57.44.192:8001/wksy/user/requestVerifyCode"
#define LoginURL               @"http://123.57.44.192:8001/wksy/user/login"
#define LogoutURL              @"http://123.57.44.192:8001/wksy/user/logout"
#define UploadImageURL         @"http://123.57.44.192:8001/wksy/upload/image"

#define DriverReportStatusURL  @"http://123.57.44.192:8001/wksy/user/report/driver/status"
#define DriverAuthURL          @"http://123.57.44.192:8001/wksy/user/driverAuth"

@implementation SYNetAPI

- (void)login:(LoginRequest *)request
{
    NSMutableDictionary *params =[[NSMutableDictionary alloc] init];
    [params setObject:request.sid forKey:SID];
    [params setObject:[NSNumber numberWithInt:request.userid]  forKey:UserID];
    [params setObject:request.usertype forKey:UserType];
    [params setObject:request.platform forKey:PlatForm];
    [params setObject:request.phone forKey:@"phone"];
    [params setObject:request.code forKey:@"code"];
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = LoginURL;
    condition.requestID = request.requestType;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}
- (void)logout:(LogoutRequest *)request;
{
    NSMutableDictionary *params =[[NSMutableDictionary alloc] init];
    [params setObject:request.sid forKey:SID];
    [params setObject:[NSNumber numberWithInt:request.userid]  forKey:UserID];
    [params setObject:request.usertype forKey:UserType];
    [params setObject:request.platform forKey:PlatForm];
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = LogoutURL;
    condition.requestID = request.requestType;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

- (void)getVerifyCode:(VerifyCodeRequest *)request
{
    NSMutableDictionary *params =[[NSMutableDictionary alloc] init];
    [params setObject:request.sid forKey:SID];
    [params setObject:[NSNumber numberWithInt:request.userid] forKey:UserID];
    [params setObject:request.usertype forKey:UserType];
    [params setObject:request.platform forKey:PlatForm];
    [params setObject:request.phone forKey:@"phone"];
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = VerifyCodeURL;
    condition.requestID = request.requestType;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

- (void)uploadImage:(UploadImageRequest *)request
{
    NSMutableDictionary *params =[[NSMutableDictionary alloc] init];
    [params setObject:request.sid forKey:SID];
    [params setObject:[NSNumber numberWithInt:request.userid]  forKey:UserID];
    [params setObject:request.usertype forKey:UserType];
    [params setObject:request.platform forKey:PlatForm];
    [params setObject:request.image forKey:@"file"];
    
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    NSMutableData *data = [NSMutableData postBodyHasRawData:params];
    
    NSMutableDictionary * dicHead = [NSMutableDictionary dictionary];
    [dicHead setObject:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",netRequestStringBoundary] forKey:@"Content-Type"];
    [dicHead setObject:request.imgType forKey:@"IMG_TYPE"];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = UploadImageURL;
    condition.requestID = request.requestType;
    condition.httpHeaderFieldParams = dicHead;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

- (void)driverReportStatus:(DriverReportStatusRequest *)request
{
    NSMutableDictionary *params =[[NSMutableDictionary alloc] init];
    [params setObject:request.sid forKey:SID];
    [params setObject:[NSNumber numberWithInt:request.userid] forKey:UserID];
    [params setObject:request.usertype forKey:UserType];
    [params setObject:request.platform forKey:PlatForm];
    [params setObject:request.driverStatus forKey:@"driverStatus"];
    [params setObject:request.driverStatusLon forKey:@"driverStatusLon"];
    [params setObject:request.driverStatusLat forKey:@"driverStatusLat"];
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = DriverReportStatusURL;
    condition.requestID = request.requestType;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

- (void)driverAuth:(DriverAuthRequest *)request
{
    NSMutableDictionary *params =[[NSMutableDictionary alloc] init];
    [params setObject:request.sid forKey:SID];
    [params setObject:[NSNumber numberWithInt:request.userid] forKey:UserID];
    [params setObject:request.usertype forKey:UserType];
    [params setObject:request.platform forKey:PlatForm];
    [params setObject:request.username forKey:@"username"];
    [params setObject:[NSNumber numberWithInt:request.corpId] forKey:@"corpId"];
    [params setObject:request.carType forKey:@"carType"];
    [params setObject:[NSNumber numberWithDouble:request.carLength] forKey:@"carLength"];
    [params setObject:[NSNumber numberWithDouble:request.carWidth] forKey:@"carWidth"];
    [params setObject:[NSNumber numberWithDouble:request.carHeight] forKey:@"carHeight"];
    [params setObject:[NSNumber numberWithDouble:request.carLoad] forKey:@"carLoad"];
    [params setObject:request.carNum forKey:@"carNum"];
    [params setObject:request.carName forKey:@"carName"];
    [params setObject:request.driverLicenseImg forKey:@"driverLicenseImg"];
    [params setObject:request.drivingLicenseImg forKey:@"drivingLicenseImg"];
    [params setObject:request.carPositiveImg forKey:@"carPositiveImg"];
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = DriverAuthURL;
    condition.requestID = request.requestType;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}


#pragma mark -  Private Methods
#define ErrorCode @"errorcode"

- (id)composeRequestObj:(NetRequest *)request
{
    switch (request.requestCondition.requestID) {
        case SYNetType_VerifyCode:
        {
            NSDictionary * params = [NSJSONSerialization JSONObjectWithData:request.requestCondition.bodyData options:NSJSONReadingMutableContainers error:nil];
            
            VerifyCodeRequest *verifyCode = [[VerifyCodeRequest alloc] init];
            verifyCode.requestType  = request.requestCondition.requestID;
            verifyCode.sid          = [params objectForKey:SID];
            verifyCode.userid       = [[params objectForKey:UserID] intValue];
            verifyCode.usertype     = [params objectForKey:UserType];
            verifyCode.platform     = [params objectForKey:PlatForm];
            verifyCode.phone        = [params objectForKey:@"phone"];
            
            return verifyCode;
        }
            break;
        case SYNetType_Login:
        {
            NSDictionary * params = [NSJSONSerialization JSONObjectWithData:request.requestCondition.bodyData options:NSJSONReadingMutableContainers error:nil];
            
            LoginRequest *loginObj = [[LoginRequest alloc] init];
            loginObj.requestType  = request.requestCondition.requestID;
            loginObj.sid          = [params objectForKey:SID];
            loginObj.userid       = [[params objectForKey:UserID] intValue];
            loginObj.usertype     = [params objectForKey:UserType];
            loginObj.platform     = [params objectForKey:PlatForm];
            loginObj.phone        = [params objectForKey:@"phone"];
            loginObj.code         = [params objectForKey:@"code"];
            
            return loginObj;
        }
            break;
        case SYNetType_Logout:
        {
            NSDictionary * params = [NSJSONSerialization JSONObjectWithData:request.requestCondition.bodyData options:NSJSONReadingMutableContainers error:nil];
            
            LoginRequest *loginObj = [[LoginRequest alloc] init];
            loginObj.requestType  = request.requestCondition.requestID;
            loginObj.sid          = [params objectForKey:SID];
            loginObj.userid       = [[params objectForKey:UserID] intValue];
            loginObj.usertype     = [params objectForKey:UserType];
            loginObj.platform     = [params objectForKey:PlatForm];
            
            return loginObj;
        }
            break;
        case SYNetType_DriverReportStatus:
        {
            NSDictionary * params = [NSJSONSerialization JSONObjectWithData:request.requestCondition.bodyData options:NSJSONReadingMutableContainers error:nil];
            
            DriverReportStatusRequest *status = [[DriverReportStatusRequest alloc] init];
            status.requestType      = request.requestCondition.requestID;
            status.sid              = [params objectForKey:SID];
            status.userid           = [[params objectForKey:UserID] intValue];
            status.usertype         = [params objectForKey:UserType];
            status.platform         = [params objectForKey:PlatForm];
            status.driverStatus     = [params objectForKey:@"driverStatus"];
            status.driverStatusLon  = [params objectForKey:@"driverStatusLon"];
            status.driverStatusLat  = [params objectForKey:@"driverStatusLat"];
            
            return status;

        }
            break;
        case SYNetType_DriverAuth:
        {
            NSDictionary * params = [NSJSONSerialization JSONObjectWithData:request.requestCondition.bodyData options:NSJSONReadingMutableContainers error:nil];
            
            DriverAuthRequest *auth = [[DriverAuthRequest alloc] init];
            auth.requestType        = request.requestCondition.requestID;
            auth.sid                = [params objectForKey:SID];
            auth.userid             = [[params objectForKey:UserID] intValue];
            auth.usertype           = [params objectForKey:UserType];
            auth.platform           = [params objectForKey:PlatForm];
            auth.username           = [params objectForKey:@"username"];
            auth.corpId             = [[params objectForKey:@"corpId"] intValue];
            auth.carType            = [params objectForKey:@"carType"];
            auth.carLength          = [[params objectForKey:@"carLength"] intValue];
            auth.carWidth           = [[params objectForKey:@"carWidth"] intValue];
            auth.carHeight          = [[params objectForKey:@"carHeight"] intValue];
            auth.carLoad            = [[params objectForKey:@"carLoad"] intValue];
            auth.carNum             = [params objectForKey:@"carNum"];
            auth.carName            = [params objectForKey:@"carName"];
            auth.driverLicenseImg   = [params objectForKey:@"driverLicenseImg"];
            auth.drivingLicenseImg  = [params objectForKey:@"drivingLicenseImg"];
            auth.carPositiveImg     = [params objectForKey:@"carPositiveImg"];
            
            return auth;
            
        }
            break;
        default:
            break;
    }
    
    return nil;
}

-(void)handleVerifyCodeWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    int errorCode = [[result objectForKey:ErrorCode] intValue];
    
    VerifyCodeRequest *verifyCode = [self composeRequestObj:request];
    
    if (errorCode == 0)
    {
        [self.delegate onVerifyCodeDone:verifyCode response:nil];
    }
    else
    {
        [self.delegate netRequest:verifyCode didFailWithError:[NSError errorWithDomain:SYNetErrorDomain code:SYNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",SYNetErrorParamCodeKey:[NSNumber numberWithInt:errorCode]}]];
    }
    
}

-(void)handleLoginWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    int errorCode = [[result objectForKey:ErrorCode] intValue];
    
    LoginRequest *loginObj = [self composeRequestObj:request];
    
    if (errorCode == 0)
    {
        LoginResponse *response = [[LoginResponse alloc] init];
        response.sid      = [[result objectForKey:@"result"] objectForKey:SID];
        response.userid   = [[[result objectForKey:@"result"] objectForKey:UserID] intValue];
        response.usertype = [[result objectForKey:@"result"] objectForKey:UserType];
        response.username = [[result objectForKey:@"result"] objectForKey:@"username"];
        response.headIcon = [[result objectForKey:@"result"] objectForKey:@"headicon"];
        
        if ([response.usertype isEqualToString:@"driver"])
        {
            response.authStatus        = [[result objectForKey:@"result"] objectForKey:@"authStatus"];
            response.driverLicenseImg  = [[result objectForKey:@"result"] objectForKey:@"driverLicenseImg"];
            response.carType           = [[result objectForKey:@"result"] objectForKey:@"carType"];
            response.carLength         = [[[result objectForKey:@"result"] objectForKey:@"carLength"] doubleValue];
            response.carWidth          = [[[result objectForKey:@"result"] objectForKey:@"carWidth"] doubleValue];
            response.carHeight         = [[[result objectForKey:@"result"] objectForKey:@"carHeight"] doubleValue];
            response.carLoad           = [[[result objectForKey:@"result"] objectForKey:@"carLoad"] doubleValue];
            response.carNum            = [[result objectForKey:@"result"] objectForKey:@"carNum"];
            response.carName           = [[result objectForKey:@"result"] objectForKey:@"carName"];
            response.carPositiveImg    = [[result objectForKey:@"result"] objectForKey:@"carPositiveImg"];
            response.drivingLicenseImg = [[result objectForKey:@"result"] objectForKey:@"drivingLicenseImg"];
            response.driverStatus      = [[result objectForKey:@"result"] objectForKey:@"driverStatus"];
            response.corpName          = [[result objectForKey:@"result"] objectForKey:@"corpName"];
            response.corpCode          = [[[result objectForKey:@"result"] objectForKey:@"corpCode"] intValue];
            response.corpCity          = [[result objectForKey:@"result"] objectForKey:@"corpCity"];
            response.corpAddress       = [[result objectForKey:@"result"] objectForKey:@"corpAddress"];
            response.corpLicenseImg    = [[result objectForKey:@"result"] objectForKey:@"corpLicenseImg"];
            response.corpRegisterTime  = [[result objectForKey:@"result"] objectForKey:@"corpRegisterTime"];
        }
                
        [self.delegate onLoginDone:loginObj response:response];
    }
    else
    {
        [self.delegate netRequest:loginObj didFailWithError:[NSError errorWithDomain:SYNetErrorDomain code:SYNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",SYNetErrorParamCodeKey:[NSNumber numberWithInt:errorCode]}]];
    }
    
}

-(void)handleLogoutWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    int errorCode = [[result objectForKey:ErrorCode] intValue];
    
    LogoutRequest *logoutObj = [self composeRequestObj:request];
    
    if (errorCode == 0)
    {
        [self.delegate onLogoutDone:logoutObj response:nil];
    }
    else
    {
        [self.delegate netRequest:logoutObj didFailWithError:[NSError errorWithDomain:SYNetErrorDomain code:SYNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",SYNetErrorParamCodeKey:[NSNumber numberWithInt:errorCode]}]];
    }
    
}

-(void)handleUploadImageWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    int errorCode = [[result objectForKey:ErrorCode] intValue];
    
    if (errorCode == 0)
    {
        UploadImageResponse *response = [[UploadImageResponse alloc] init];
        response.imgType  = [[result objectForKey:@"result"] objectForKey:@"imgType"];
        response.imgUrl   = [[result objectForKey:@"result"] objectForKey:@"imgUrl"];
        [self.delegate onUploadImageDone:nil response:response];
    }
    else
    {
        [self.delegate netRequest:nil didFailWithError:[NSError errorWithDomain:SYNetErrorDomain code:SYNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",SYNetErrorParamCodeKey:[NSNumber numberWithInt:errorCode]}]];
    }
    
}

-(void)handleDriverReportStatusWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    int errorCode = [[result objectForKey:ErrorCode] intValue];
    
    DriverReportStatusRequest *status = [self composeRequestObj:request];
    
    if (errorCode == 0)
    {
        [self.delegate onDriverReportStatusDone:status response:nil];
    }
    else
    {
        [self.delegate netRequest:status didFailWithError:[NSError errorWithDomain:SYNetErrorDomain code:SYNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",SYNetErrorParamCodeKey:[NSNumber numberWithInt:errorCode]}]];
    }
    
}

-(void)handleDriverAuthWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    int errorCode = [[result objectForKey:ErrorCode] intValue];
    
    DriverAuthRequest *auth = [self composeRequestObj:request];
    
    if (errorCode == 0)
    {
        DriverAuthResponse *response = [[DriverAuthResponse alloc] init];
        response.authStatus  = [[result objectForKey:@"result"] objectForKey:@"authStatus"];
        
        [self.delegate onDriverAuthDone:auth response:response];
    }
    else
    {
        [self.delegate netRequest:auth didFailWithError:[NSError errorWithDomain:SYNetErrorDomain code:SYNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",SYNetErrorParamCodeKey:[NSNumber numberWithInt:errorCode]}]];
    }
    
}

- (void)request:(NetRequest *)request handleResponseData:(NSData *)data
{
    switch (request.requestCondition.requestID) {
        case SYNetType_VerifyCode:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onVerifyCodeDone:response:)])
            {
                [self handleVerifyCodeWithRequest:request responseData:data];
            }
        }
            break;
        case SYNetType_Login:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onLoginDone:response:)])
            {
                [self handleLoginWithRequest:request responseData:data];
            }
        }
            break;
        case SYNetType_Logout:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onLogoutDone:response:)])
            {
                [self handleLogoutWithRequest:request responseData:data];
            }
        }
            break;
        case SYNetType_UploadImage:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onUploadImageDone:response:)])
            {
                [self handleUploadImageWithRequest:request responseData:data];
            }
        }
            break;
        case SYNetType_DriverReportStatus:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onDriverReportStatusDone:response:)])
            {
                [self handleDriverReportStatusWithRequest:request responseData:data];
            }
        }
            break;
        case SYNetType_DriverAuth:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onDriverAuthDone:response:)])
            {
                [self handleDriverAuthWithRequest:request responseData:data];
            }
        }
            break;
        default:
            break;
    }
}

- (void)request:(NetRequest *)request failedWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(netRequest:didFailWithError:)])
    {
        [self.delegate netRequest:[self composeRequestObj:request] didFailWithError:[self parseError:error]];
    }

}

- (NSError *)parseError:(NSError *) error
{
    NSError *tmpError;
    switch (error.code) {
        case NetErrorUnknown:
            tmpError = [NSError errorWithDomain:SYNetErrorDomain code:SYNetErrorUnknown userInfo:error.userInfo];
            break;
        case NetErrorBadURL:
            tmpError = [NSError errorWithDomain:SYNetErrorDomain code:SYNetErrorBadURL userInfo:error.userInfo];
            break;
        case NetErrorTimeOut:
            tmpError = [NSError errorWithDomain:SYNetErrorDomain code:SYNetErrorTimeOut userInfo:error.userInfo];
            break;
        case NetErrorCannotFindHost:
            tmpError = [NSError errorWithDomain:SYNetErrorDomain code:SYNetErrorCannotFindHost userInfo:error.userInfo];
            break;
        case NetErrorCannotConnectToHost:
            tmpError = [NSError errorWithDomain:SYNetErrorDomain code:SYNetErrorCannotConnectToHost userInfo:error.userInfo];
            break;
        case NetErrorNotConnectedToInternet:
            tmpError = [NSError errorWithDomain:SYNetErrorDomain code:SYNetErrorNotConnectedToInternet userInfo:error.userInfo];
            break;
        case NetErrorInvalidResponse:
            tmpError = [NSError errorWithDomain:SYNetErrorDomain code:SYNetErrorInvalidResponse userInfo:error.userInfo];
            break;
        default:
            tmpError = [NSError errorWithDomain:SYNetErrorDomain code:SYNetErrorUnknown userInfo:error.userInfo];
            break;
    }
    
    return tmpError;
}

#pragma mark - NetRequestDelegate

- (void)request:(id)request didFailWithError:(NSError *)error
{
    [self request:request failedWithError:error];
}


- (void)request:(NetRequest *)request didFinishLoadingWithData:(NSData *)data
{
    [self request:request handleResponseData:data];
}

@end
