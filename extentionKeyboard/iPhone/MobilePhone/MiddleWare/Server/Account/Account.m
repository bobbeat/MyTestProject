//
//  Account.m
//  New_GNaviServer
//
//  Created by yang yi on 12-3-26.
//  Copyright 2012 autonavi.com. All rights reserved.
//

#import "Account.h"
#import "AccountXmlParser.h"
#import <CommonCrypto/CommonDigest.h>



@implementation Account
static Account	*shareAccount;

+(id)AccountInstance
{
	@synchronized(self)
	{
		if (nil ==shareAccount) 
		{
			shareAccount =[[Account alloc] init];
		}
	}
	
	return shareAccount;
	
}

- (id)init
{
    if (self = [super init])
    {
       
    }
    return self;
}


- (void)dealloc
{
    [super dealloc];
}

-(NSString *)createPostURL:(NSMutableDictionary *)params
{
    NSString *postString=@"";
	if (params ==nil) {
		return postString;
	}
    for(NSString *key in [params allKeys])
    {
        NSString *value=[params objectForKey:key];
        postString=[postString stringByAppendingFormat:@"%@=%@&",key,value];
    }
    if([postString length]>1)
    {
        postString=[postString substringToIndex:[postString length]-1];
    }
    return [postString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(NSData *)getResultData:(NSMutableDictionary *)params WithHeader:(NSString*)header
{
    NSString *postURL=[self createPostURL:params];
    NSError *error;
    NSURLResponse *theResponse;
	NSMutableURLRequest *theRequest;
    //	NSURL *test =[NSURL URLWithString:postURL];
	
	if (0==NET_METHOD)//POST
	{
		theRequest=[NSMutableURLRequest requestWithURL:
					[NSURL URLWithString:
					 [NSString stringWithFormat:@"%@%@",kNetDomain,header ]
					 ]
					];
		[theRequest setHTTPMethod:@"POST"];
		[theRequest setHTTPBody:[postURL dataUsingEncoding:NSUTF8StringEncoding]];
		
	}else //GET
	{
        
        theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:
                                                            [NSString stringWithFormat:@"%@%@%@",kNetDomain,header,postURL ]
                                                            ]
                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                           timeoutInterval:NET_TIMEOUT_SYN];
		
		[theRequest setHTTPMethod:@"GET"];
		[theRequest setTimeoutInterval:NET_TIMEOUT_SYN];//un support for POST
		
	}
	
    //	NSLog(@"request:%@%@",[NSString stringWithFormat:@"%@%@",ACCOUNT_SERVER_HOST,header ],postURL);//POST
    [theRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	return [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&theResponse error:&error];
	
}

-(BOOL) parseWithParam:(NSMutableDictionary *)params WithHeader:(RequestType ) opType WithBody:(NSString *)body
{
    NSString *urlHead;
    switch (opType)
    {
        case REQ_BUY_95190_SERVICE:
			urlHead = HEAD_BUY_95190_SERVICE;
            break;
        default:
			break;
    }
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,urlHead];
    condition.requestType = opType;
    condition.urlParams = params;
    condition.httpMethod = @"POST";
    condition.bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    
    return YES;
}

-(BOOL) parseWithParam:(NSMutableDictionary *)params WithHeader:(RequestType ) opType  fileKey:(NSString *)fileKey
{
    NSString *urlHead;
    switch (opType)
    {
        case REQ_UPLOAD_HEAD:
			urlHead = HEAD_UPLOAD_HEAD;
            break;
        default:
			break;
    }
   
    
    NSMutableDictionary *url_params = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *content_params = [[NSMutableDictionary alloc] init];
    NSArray *keys= [params allKeys];
    
    //遍历keys
    for(int i=0;i<[keys count];i++)
    {
        NSString *key=[keys objectAtIndex:i];
        if(![key isEqualToString:fileKey])
        {
            [url_params setObject:[params objectForKey:key] forKey:key];
        }
        else
        {
            [content_params setObject:[params objectForKey:key] forKey:key];
        }
    }
    
   
    NSData *body = [[NetExt sharedInstance] postBodyData:content_params];
    
     NSMutableDictionary *dic_head = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kNetRequestStringBoundary],@"Content-Type", nil];
    
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,urlHead];
    condition.requestType = opType;
    condition.urlParams = url_params;
    condition.httpHeaderFieldParams = dic_head;
    condition.httpMethod = @"POST";
    condition.bodyData = body;
    
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    
    
    [url_params release];
    [content_params release];
	return YES;
}

-(BOOL) parseWithParam:(NSMutableDictionary *)params WithHeader:(RequestType ) opType
{
	NSString *urlHead;
	switch (opType) {
		case REQ_REGIST:
			urlHead = [NSString stringWithFormat:@"%@",HEAD_REGIST];
			break;
		case REQ_LOGIN:
			urlHead = [NSString stringWithFormat:@"%@",HEAD_LOGIN];
			break;
        case REQ_THIRD_LOGIN:
			urlHead = [NSString stringWithFormat:@"%@",HEAD_THIRD_LOGIN];
			break;
		case REQ_SEND_PWD_EMAIL:
			urlHead = HEAD_SEND_PWD_EMAIL;
			break;
		case REQ_GET_AUTH_IMG:
			urlHead = HEAD_GET_AUTH_IMG;
			break;
		case REQ_LOGOUT:
			urlHead = HEAD_LOGOUT;
			break;
		case REQ_UNBIND_TOKEN:
			urlHead = HEAD_UNBIND_TOKEN;
			break;
		case REQ_GET_PROFILE:
			urlHead = HEAD_GET_PROFILE;
			break;
		case REQ_UPDATE_PROFILE:
			urlHead = HEAD_UPDATE_PROFILE;
			break;
		case REQ_RESET_PWD:
			urlHead = HEAD_RESET_PWD;
            break;
        case REQ_UPDATE_PWD:
			urlHead = HEAD_UPDATE_PWD;
            break;
        case REQ_GET_CHECK_NUMBER:
			urlHead = HEAD_GET_CHECK_NUMBER;
            break;
        case REQ_GET_95190CHECK:
			urlHead = HEAD_GET_95190CHECK;
            break;
        case REQ_BIND_95190PHONE_NUMBER:
			urlHead = HEAD_BIND_95190PHONE_NUMBER;
            break;
        case REQ_OLD_USER_BIND_PHONE_NUMBER:
			urlHead = HEAD_OLD_USER_BIND_PHONE_NUMBER;
            break;
        case REQ_GET_95190PHONE_NUMBER:
			urlHead = HEAD_GET_95190PHONE_NUMBER;
            break;
        case REQ_GET_95190_DESTINATION:
			urlHead = HEAD_GET_95190_DESTINATION;
            break;
        case REQ_GET_95190_STATUS:
			urlHead = HEAD_GET_95190_STATUS;
            break;
        case REQ_MODIFY_95190PHONE_NUMBER:
			urlHead = HEAD_MODIFY_95190PHONE_NUMBER;
            break;
        case REQ_FREE_95190:
			urlHead = HEAD_FREE_95190;
            break;
        case REQ_ORDER_EN_CHECK:
			urlHead = HEAD_ORDER_EN_CHECK;
            break;
        case REQ_PRE_CALL_95190:
			urlHead = HEAD_PRE_CALL_95190;
            break;
        case REQ_GET_CURRENT95190_DES:
			urlHead = HEAD_GET_CURRENT95190_DES;
            break;
        case REQ_GET_EN_TEXT:
			urlHead = HEAD_GET_EN_TEXT;
            break;
        case REQ_GET_95190_TEXT:
			urlHead = HEAD_GET_95190_TEXT;
            break;
        case REQ_CHECK_CODE:
			urlHead = HEAD_CHECK_COEDE;
            break;
        case REQ_CLEAR_95190PHONE_NUMBER:
			urlHead = HEAD_CLEAR_95190PHONE_NUMBER;
            break;
		default:
			break;
	}
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,urlHead];
    condition.requestType = opType;
    condition.urlParams = params;
    condition.httpMethod = @"GET";
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
     return YES;
}

-(void)CancelAllREQ
{
    [[NetExt sharedInstance] cancelAllRequests];
}
#pragma mark public methods

//删除UGC同步时间截
- (BOOL)deleteUgcServerTime
{
    char tmpChar[1024];
    NSString *ugcServerTimeFile = [NSString stringWithUTF8String:tmpChar];
    
    NSError *error = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:ugcServerTimeFile])
    {
        [[NSFileManager defaultManager] removeItemAtPath:ugcServerTimeFile error:&error];
        return YES;
    }
    if (error)
    {
        return NO;
    }
    return NO;
}

-(int)setLoginStatus:(int) status
{
    
    NSMutableArray *array=[[NSMutableArray alloc] initWithContentsOfFile:account_path];
	
	if (array==nil)
    {
        array = [[NSMutableArray alloc] init];
		[array  addObject:[[[NSNumber alloc] initWithInt:0] autorelease]]; //登陆状态
        [array  addObject:@""];		//账户名
        [array  addObject:@""];      //密码
        [array  addObject:@""];        //昵称
        [array  addObject:UIImagePNGRepresentation(IMAGE(@"non_head.png", IMAGEPATH_TYPE_1))]; //图片
        [array  addObject:@""];        //uuid
        [array  addObject:@""];        //tpusername
       
	}
	
	[array replaceObjectAtIndex:0 withObject:[[[NSNumber alloc]initWithInt:status] autorelease]];
	
	[array writeToFile:account_path  atomically:YES];
    [array release]; 
	return 1;
}

-(int)setAccountName:(NSString*) name Password:(NSString*)pwd
{
	
    
    NSMutableArray *array=[[NSMutableArray alloc] initWithContentsOfFile:account_path];
	
	if (array==nil) {
        array = [[NSMutableArray alloc] init];
		[array  addObject:[[[NSNumber alloc] initWithInt:0] autorelease]]; //登陆状态
        [array  addObject:@""];		//账户名
        [array  addObject:@""];      //密码
        [array  addObject:@""];        //昵称
        [array  addObject:UIImagePNGRepresentation( IMAGE(@"non_head.png", IMAGEPATH_TYPE_1))]; //图片
        [array  addObject:@""];        //uuid
        [array  addObject:@""];        //tpusername
	}
	
//	[array replaceObjectAtIndex:0 withObject:[[NSNumber alloc]initWithInt:1]];//default set login
	if (name) {
		[array replaceObjectAtIndex:1 withObject:name];
	}
	if (pwd) {
		[array replaceObjectAtIndex:2 withObject:pwd];
	}
	[array writeToFile:account_path  atomically:YES];
    [array release]; 
	return 1;
}

-(NSArray *)getAccountInfo
{
    
    NSMutableArray *array=[[[NSMutableArray alloc] initWithContentsOfFile:account_path] autorelease];
	
	if ([array count] < 7)
    {
        array = [[[NSMutableArray alloc] init] autorelease];
		[array  addObject:[[[NSNumber alloc] initWithInt:0] autorelease]]; //登陆状态 0未登录，1老用户登录，2新用户登录，3新浪微博帐号登录，4腾讯微博帐号登录，5 新浪帐号绑定高德帐号 6 腾讯帐号绑定高德帐号
        [array  addObject:@""];		//账户名
        [array  addObject:@""];      //密码
        [array  addObject:@""];        //昵称
        [array  addObject:UIImagePNGRepresentation( IMAGE(@"non_head.png", IMAGEPATH_TYPE_1))]; //图片
        [array  addObject:@""];        //第三方uuid，若登陆状态为3或5，则是新浪UUID；若是4或6，则为腾讯UUID
        [array  addObject:@""];        //tpusername
        [array  addObject:@""];        //userid
        [array  addObject:@""];        //usersid
        [self setAccountInfo:array];
	}
    else if ([array count] == 7)
    {
        [array  addObject:@""];        //userid
        [array  addObject:@""];        //usersid登陆令牌
        [self setAccountInfo:array];
    }
    else if ([array count] == 8)
    {
        [array  addObject:@""];        //usersid登陆令牌
        [self setAccountInfo:array];
    }
    return array;
}

-(int)setAccountInfo:(NSArray *)array
{
    if (array == nil)
    {
        return 0;
    }
    
    BOOL sign = [array writeToFile:account_path  atomically:YES];
	return sign;
}


//-(void)accountRequestSucceeded:(NSData *)data WithOperation:(id)op
- (void)request:(NetRequestExt *)request didFinishLoadingWithData:(NSData *)data

{
    NSNumber *op = [NSNumber numberWithInt:request.requestCondition.requestType];
	NSDictionary *result =[[AccountXmlParser instance] GetOperationResultByData:data WithOperation:op];
    AccountInfo *userInfo = [result objectForKey:KEY_FOR_PROFILE];
	if (result) 
	{
		GSTATUS gRet;
		NSString *authenticate =[result objectForKey:KEY_FOR_AUTH];
        if ([authenticate isEqual:@"False"] && ([op intValue] == REQ_GET_PROFILE))
        {
            [[AccountXmlParser instance] ClearAccountInfo]; //清除信息
            [[Account AccountInstance] setLoginStatus:0];
            [[MWPreference sharedInstance] setValue:PREF_SET95190 Value:0];
            [[MWPreference sharedInstance] savePreference];
        }
		
        NSString *isOk =[result objectForKey: KEY_FOR_RESULT];
        int requestType = [op intValue];
		switch (requestType) 
		{
			case REQ_LOGIN:
                
				if ([isOk isEqual:PARSE_CHECK_SUCCESS])
				{
                    [[Account AccountInstance] deleteUgcServerTime];
					gRet = GD_ERR_OK;
				}
				else if([isOk isEqual: PARSE_ALREADY_LOGIN])
                {
					gRet = GD_ERR_ALREADY_LOGIN;
				}
				else
				{
                    if ([[result objectForKey: KEY_FOR_Error] isEqualToString:PARSE_USER_NOT_EXISTS])
                    {
                        gRet = GD_ERR_USER_NOT_EXISTS;
                    }
                    else
                    {
                        gRet = GD_ERR_UNKNOWN_ERROR;
                    }
				}
				break;
				
			case REQ_SEND_PWD_EMAIL:
				if ([isOk isEqual:PARSE_CHECK_SUCCESS]) {
					gRet = GD_ERR_OK;
				}
                else if ([isOk isEqual:ERROR_NO_THISUSER])
				{
					gRet = GD_ERR_USER_NOT_EXISTS;
				}
				else if ([isOk isEqual:PARSE_SEND_MAIL_ERROR])
				{
					gRet = GD_ERR_SEND_MAIL_ERROR;
				}else 
				{
					gRet = GD_ERR_PARSE_ERROR;
				}
				
				break;
				
			case REQ_REGIST:
				if ([isOk isEqual:PARSE_CHECK_SUCCESS]) {
					gRet = GD_ERR_OK;
				}
				else if([isOk isEqual: PARSE_USER_EXISTS] ) 
				{
					gRet = GD_ERR_USER_EXISTS;
				}
				else if([isOk isEqual: PARSE_EMAIL_EXISTS] ) 
				{
					gRet = GD_ERR_EMAIL_EXISTS;
				}
				else if([isOk isEqual: PARSE_TEL_EXISTS] ) 
				{
					gRet = GD_ERR_TEL_EXISTS;
				}
				else if ([isOk isEqual: PARSE_PARAMS_ERROR]) 
				{		
					gRet = GD_ERR_PARSE_ERROR;
				}else {
					
					gRet = GD_ERR_UNKNOWN_ERROR;
				}
				
				break;
			case REQ_GET_AUTH_IMG:

				break;
			case REQ_LOGOUT:
				if ([ isOk isEqual:PARSE_CHECK_SUCCESS]) 
				{
                    gRet = GD_ERR_OK;
                    [[AccountXmlParser instance] ClearAccountInfo]; //清除信息
					[[Account AccountInstance] setLoginStatus:0];
                    [[MWPreference sharedInstance] setValue:PREF_SET95190 Value:0];
                    [[MWPreference sharedInstance] savePreference];
				}
				else {
					gRet = GD_ERR_PARSE_ERROR;
				}	
	
				break;
			case REQ_UNBIND_TOKEN:

				if ([ isOk isEqual:PARSE_OK]) 
				{
					gRet = GD_ERR_OK;
				}
				else {
					gRet = GD_ERR_PARSE_ERROR;
				}
				break;
				
			case REQ_GET_PROFILE:
				if ([ isOk isEqual:PARSE_CHECK_SUCCESS]) {
					gRet= GD_ERR_OK;
				}
				else {
					gRet= GD_ERR_PARSE_ERROR;
				}
				break;
			case REQ_UPDATE_PROFILE:
				

				if ([ isOk isEqual:PARSE_CHECK_SUCCESS]) 
				{
					gRet = GD_ERR_OK;
				}
				else if([isOk isEqual: PARSE_USER_EXISTS] ) 
				{
					gRet = GD_ERR_USER_EXISTS;
				}
				else if([isOk isEqual: PARSE_EMAIL_EXISTS] ) 
				{
					gRet = GD_ERR_EMAIL_EXISTS;
				}
				else if([isOk isEqual: PARSE_TEL_EXISTS] ) 
				{
					gRet = GD_ERR_TEL_EXISTS;
				}
				else 
				{
					gRet = GD_ERR_UNKNOWN_ERROR;
				}
					
				break;
				
			case REQ_RESET_PWD:
				if ([ isOk isEqual:PARSE_CHECK_SUCCESS]) {
					gRet =  GD_ERR_OK;
				}else if ([isOk isEqual:PARSE_UNKNOWN_ERROR])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else 
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
				
				break;
            case REQ_UPDATE_PWD:
				if ([ isOk isEqual:PARSE_CHECK_SUCCESS])
                {
					gRet =  GD_ERR_OK;
				}else if ([isOk isEqual:PARSE_UNKNOWN_ERROR])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
				
				break;
            case REQ_GET_CHECK_NUMBER:
				if ([ isOk isEqual:PARSE_CHECK_SUCCESS]) {
					gRet =  GD_ERR_OK;
				}else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
				
				break;
            case REQ_GET_95190CHECK:
				if ([ isOk isEqual:PARSE_CHECK_SUCCESS]) {
					gRet =  GD_ERR_OK;
				}else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
				
				break;
            case REQ_BIND_PHONE_NUMBER:
				if ([ isOk isEqual:PARSE_CHECK_SUCCESS]) {
					gRet =  GD_ERR_OK;
				}else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
                    userInfo.m_tel_95190 = @"";
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
				
				break;
            case REQ_OLD_USER_BIND_PHONE_NUMBER:
				if ([ isOk isEqual:PARSE_CHECK_SUCCESS]) {
					gRet =  GD_ERR_OK;
				}else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
				
				break;
            case REQ_GET_95190PHONE_NUMBER:
				if ([ isOk isEqual:PARSE_CHECK_SUCCESS])
                {
					gRet =  GD_ERR_OK;
				}
                else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
				
				break;
            case REQ_GET_95190_DESTINATION:
                if ([ isOk isEqual:PARSE_CHECK_SUCCESS])
                {
					gRet =  GD_ERR_OK;
				}
                else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
                break;
            case REQ_GET_95190_STATUS:
                if ([ isOk isEqual:PARSE_CHECK_SUCCESS])
                {
                    [[MWPreference sharedInstance] setValue:PREF_SET95190 Value:1]; //设置能够拨打95190
                    [[MWPreference sharedInstance] savePreference];
					gRet =  GD_ERR_OK;
				}
                else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
                    [[AccountXmlParser instance] Clear95190Info]; //清除信息
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
                break;
            case REQ_BUY_95190_SERVICE:
                if ([ isOk isEqual:PARSE_CHECK_SUCCESS])
                {
					gRet =  GD_ERR_OK;
				}
                else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
                break;
            case REQ_BIND_95190PHONE_NUMBER:
                if ([ isOk isEqual:PARSE_CHECK_SUCCESS])
                {
					gRet =  GD_ERR_OK;
				}
                else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
                break;
            case REQ_FREE_95190:
                if ([ isOk isEqual:PARSE_CHECK_SUCCESS])
                {
                    [[MWPreference sharedInstance] setValue:PREF_SET95190 Value:1]; //设置能够拨打95190
                    [[MWPreference sharedInstance] savePreference];
					gRet =  GD_ERR_OK;
				}
                else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
                break;
            case REQ_ORDER_EN_CHECK:
                if ([ isOk isEqual:PARSE_CHECK_SUCCESS])
                {
					gRet =  GD_ERR_OK;
				}
                else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
                break;
            case REQ_PRE_CALL_95190:
                if ([ isOk isEqual:PARSE_CHECK_SUCCESS])
                {
                
					gRet =  GD_ERR_OK;
				}
                else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
                break;
            case REQ_GET_CURRENT95190_DES:
                if ([ isOk isEqual:PARSE_CHECK_SUCCESS])
                {
					gRet =  GD_ERR_OK;
				}
                else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
                break;
            case REQ_GET_95190_TEXT:
                if ([ isOk isEqual:PARSE_CHECK_SUCCESS])
                {
					gRet =  GD_ERR_OK;
				}
                else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
                break;
            case REQ_GET_EN_TEXT:
                if ([ isOk isEqual:PARSE_CHECK_SUCCESS])
                {
					gRet =  GD_ERR_OK;
				}
                else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
                break;
            case REQ_CHECK_CODE:
                if ([ isOk isEqual:PARSE_CHECK_SUCCESS])
                {
					gRet =  GD_ERR_OK;
				}
                else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
                break;
            case REQ_THIRD_LOGIN:
            {
                if ([ isOk isEqual:PARSE_CHECK_SUCCESS])
                {
					gRet =  GD_ERR_OK;
				}
                else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
            }
                break;
            case REQ_UPLOAD_HEAD:
            {
                if ([ isOk isEqual:PARSE_CHECK_SUCCESS])
                {
					gRet =  GD_ERR_OK;
				}
                else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
            }
                break;
            case REQ_CLEAR_95190PHONE_NUMBER:
            {
                if ([ isOk isEqual:PARSE_CHECK_SUCCESS])
                {
                    userInfo.m_tel_95190 = @"";
					gRet =  GD_ERR_OK;
				}
                else if ([isOk isEqual:PARSE_CHECK_FAIL])
				{
					gRet =  GD_ERR_UNKNOWN_ERROR;
				}else
				{
					gRet =  GD_ERR_PARSE_ERROR;
				}
            }
                break;
			default:
                gRet =  GD_ERR_PARSE_ERROR;
				break;
		}
        
        
		
		NSArray* param=[[NSArray alloc] initWithObjects:PARSE_OK,op,[NSNumber numberWithInt:gRet],result,nil];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ACCOUNT object:param];
        [param release];
		
	}else {
		//parse fail;
		NSArray* param=[[NSArray alloc] initWithObjects:PARSE_ERROR,op,nil];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ACCOUNT object:param];
        [param release];

	}

}

//-(void)accountRequestFailured:(NSError *)error withOperation:(id)op
-(void)request:(NetRequestExt *)request didFailWithError:(NSError *)error
{
    NSNumber *op = [NSNumber numberWithInt:request.requestCondition.requestType];
    NSArray* param;
    if ([error code] == NSURLErrorTimedOut)
    {
        param =[[NSArray alloc] initWithObjects:NET_CON_TIMEOUT,op,nil];
    }
	else
    {
        param =[[NSArray alloc] initWithObjects:PARSE_DATA_NIL,op,nil];
    }
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ACCOUNT object:param];
    [param release];
}

@end
@implementation AccountInfo

@synthesize userId,userName,nickName,firstName,lastName,telNumber,email,deviceId,phoneDevice,sex,age,country,province,city,m_Destination,m_end_timer,m_order,m_retaiDay,m_tel_95190,birthday,loginType,gdusername,headimage,signature,tpusername,Gd_User_Name,tptype;

- (id)init
{
    if (self = [super init])
    {
        self.userName = @"";
        self.firstName = @"";
        self.lastName = @"";
        self.nickName = @"";
        self.telNumber = @"";
        self.email = @"";
        self.province = @"";
        self.country = @"";
        self.city = @"";
        self.deviceId = @"";
        self.phoneDevice = @"";
        self.m_order = @"";
        self.m_end_timer = @"";
        self.m_Destination = @"";
        self.m_tel_95190 = @"";
        self.birthday = @"";
        self.loginType = @"";
        self.headimage = @"";
        self.gdusername = @"";
        self.signature = @"";
        self.tpusername = @"";
        self.Gd_User_Name = @"";
        
        self.userId = 0;
        self.sex = 0;
        self.age = 0;
        self.m_retaiDay = 0;
        self.tptype = 0;
        
    }
    return self;
}

-(void)dealloc
{
    if (birthday)
    {
        [birthday release];
        birthday = nil;
    }
    if (m_tel_95190)
    {
        [m_tel_95190 release];
    }
    if (m_Destination)
    {
        [m_Destination release];
    }
    if (m_end_timer)
    {
        [m_end_timer release];
    }
    if (m_order)
    {
        [m_order release];
    }
    if (userName)
    {
        [userName release];
    }
    if (firstName)
    {
        [firstName release];
    }
    if (lastName)
    {
        [lastName release];
    }
    if (nickName)
    {
        [nickName release];
    }
    if (telNumber)
    {
        [telNumber release];
    }
    if (email)
    {
        [email release];
    }
    if (province)
    {
        [province release];
    }
    if (country)
    {
        [country release];
    }
    if (city)
    {
        [city release];
    }
    if (deviceId)
    {
        [deviceId release];
    }
    if (phoneDevice)
    {
        [phoneDevice release];
    }
    [super dealloc];
}

@end
