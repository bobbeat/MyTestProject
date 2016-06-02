//
//  AppDelegate_iPhone.m
//  AutoNavi
//
//  Created by GHY on 12-3-26.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate_iPhone.h"
#import "MPApp.h"
#import "MainViewController.h"
#import "WarningViewController.h"
#import "AppLaunchManager.h"

static NSURLSession *g_mySession = nil;
@implementation AppDelegate_iPhone

@synthesize window;
@synthesize navigationController;
@synthesize rootViewController;
@synthesize  backgroundSessionCompletionHandler;
#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    [[MPApp sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    [[MPApp sharedInstance] launchImage:self.window];//modi by hlf for iPhone6 Plus横屏无闪屏，需要将此函数提到launchAppWith函数之前执行，避免interface获取不准确，进而导致不能控制iphone6plus横屏的闪屏状态
    
    [[AppLaunchManager SharedInstance] launchAppWith:self.window navigation:self.navigationController];
    [self.window makeKeyAndVisible];
   
    return YES;
}

- (IBAction)downloadAction:(id)sender
{
    NSURLSession *mySession = [self configureMySession];
    
    NSURL *url = [NSURL URLWithString:@"http://mlbsdown.autonavi.com/mobilenavi/70/14Q10005/42tmc/c0508.zip"];
    
    NSURLSessionTask *myTask = [mySession downloadTaskWithURL:url];
    
    [myTask resume];
}


- (NSURLSession *) configureMySession
{
    
    if (!g_mySession) {
        
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.autonavi.appgrouptest"];
        
        config.sharedContainerIdentifier = @"group.com.autonavi.appgrouptestextension";
        
        g_mySession = [[NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil] retain];
        
    }
    
    return g_mySession;
    
}

/* The last message a session receives.  A session will only become
 * invalid because of a systemic error or when it has been
 * explicitly invalidated, in which case the error parameter will be nil.
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    printf("URLSession didBecomeInvalidWithError\n");
}

/* If implemented, when a connection level authentication challenge
 * has occurred, this delegate will be given the opportunity to
 * provide authentication credentials to the underlying
 * connection. Some types of authentication will apply to more than
 * one request on a given connection to a server (SSL Server Trust
 * challenges).  If this delegate message is not implemented, the
 * behavior will be to use the default handling, which may involve user
 * interaction.
 */
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    printf("URLSession didReceiveChallenge\n");
}
/* If an application has received an
 * -application:handleEventsForBackgroundURLSession:completionHandler:
 * message, the session delegate will receive this message to indicate
 * that all messages previously enqueued for this session have been
 * delivered.  At this time it is safe to invoke the previously stored
 * completion handler, or to begin any internal updates that will
 * result in invoking the completion handler.
 */
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session NS_AVAILABLE_IOS(7_0)
{
    AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.backgroundSessionCompletionHandler) {
        
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        
        completionHandler();
        
        appDelegate.backgroundSessionCompletionHandler = nil;
        
        
        
    }
    printf("URLSessionDidFinishEventsForBackgroundURLSession\n");
}

/* An HTTP request is attempting to perform a redirection to a different
 * URL. You must invoke the completion routine to allow the
 * redirection, allow the redirection with a modified request, or
 * pass nil to the completionHandler to cause the body of the redirection
 * response to be delivered as the payload of this request. The default
 * is to follow redirections.
 *
 * For tasks in background sessions, redirections will always be followed and this method will not be called.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    printf("URLSessionDidFinishEventsForBackgroundURLSession\n");
}

/* The task has received a request specific authentication challenge.
 * If this delegate is not implemented, the session specific authentication challenge
 * will *NOT* be called and the behavior will be the same as using the default handling
 * disposition.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    printf("URLSessionDidFinishEventsForBackgroundURLSession\n");
}

/* Sent if a task requires a new, unopened body stream.  This may be
 * necessary when authentication has failed for any request that
 * involves a body stream.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
   printf("URLSessionDidFinishEventsForBackgroundURLSession\n");
}

/* Sent periodically to notify the delegate of upload progress.  This
 * information is also available as properties of the task.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    printf("totalBytesExpectedToSend\n");
}

/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.autonavi.appgrouptestextension"];
    [userDefault setBool:NO forKey:@"isLoading"];
    [userDefault release];
    printf("didCompleteWithError,%lld,%lld,%lld,%lld\n",task.countOfBytesReceived,task.countOfBytesSent,task.countOfBytesExpectedToSend,task.countOfBytesExpectedToReceive);
}

/* Sent when a download task that has completed a download.  The delegate should
 * copy or move the file at the given location to a new location as it will be
 * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
 * still be called.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.autonavi.appgrouptestextension"];
    NSString *str = [containerURL.path stringByAppendingString:@"/gddownload"];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:str])
    {
        NSDictionary *DirectoryAttrib = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLong:0777UL] forKey:NSFilePosixPermissions];
        [[NSFileManager defaultManager] createDirectoryAtPath:str withIntermediateDirectories:YES attributes:DirectoryAttrib error:&error];
    }
    NSString *zipPath = [str stringByAppendingString:@"/c0508.zip"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:zipPath error:&error];
    }
    [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:zipPath error:&error];
}

/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
     printf("totalBytesExpectedToSend\n");
}

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
     printf("totalBytesExpectedToSend\n");
}

- (void)test
{
    self.window.rootViewController = navigationController;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    [[MPApp sharedInstance] applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
   
    [[MPApp sharedInstance] applicationDidEnterBackground:application];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    self.backgroundSessionCompletionHandler = completionHandler;
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
    config.sharedContainerIdentifier = @"group.com.autonavi.appgrouptestextension";
    g_mySession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//    NSURL *url = [NSURL URLWithString:@"http://mlbsdown.autonavi.com/mobilenavi/70/14Q10005/42tmc/c0508.zip"];
//    NSURLSessionTask *myTask = [g_mySession downloadTaskWithURL:url];
//    [myTask resume];
    
    NSLog(@"identifier %@",identifier);
    NSString *temp = identifier;
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    
     [[MPApp sharedInstance] applicationWillEnterForeground:application];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
        
     [[MPApp sharedInstance] applicationDidBecomeActive:application];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken 
{
    [[MPApp sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken ];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error 
{
     [[MPApp sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error  ];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo 
{
    [[MPApp sharedInstance] application:application didReceiveRemoteNotification:userInfo];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
      [[MPApp sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[MPApp sharedInstance] applicationDidReceiveMemoryWarning:application];
}

- (void)dealloc {
	
    [window release];
	[rootViewController release];
	[navigationController release];
	
    [super dealloc];
}

- (UIViewController *)mainViewController {
	
	return navigationController;
}
@end
