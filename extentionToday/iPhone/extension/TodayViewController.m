//
//  TodayViewController.m
//  test1
//
//  Created by gaozhimin on 14-12-10.
//
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "AppDelegate_iPhone.h"

static UILabel *g_lable =nil;

@interface TodayViewController () <NCWidgetProviding,NSURLSessionDelegate,UIApplicationDelegate>
{
    NSURLSession *_mySession;
}

@end

@implementation TodayViewController

@synthesize backgroundSessionCompletionHandler;

@synthesize lable;

- (void)dealloc
{
    self.lable.text = @"20000";
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.lable.numberOfLines = 5;
    g_lable = self.lable;
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.autonavi.appgrouptestextension"];
    
    NSLog(@"app group:\n%@",containerURL.path);
    
    
    
    //打印可执行文件路径
    
    NSLog(@"bundle:\n%@",[[NSBundle mainBundle] bundlePath]);
    
    
    //打印documents
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *path = [paths objectAtIndex:0];
    NSLog(@"documents:\n%@",path);
    
//    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.autonavi.appgrouptestextension"];
//    BOOL isload = [userDefault boolForKey:@"isLoading"];
//    if (isload) {
//        NSInteger loadID = [userDefault integerForKey:@"isLoadingid"];
//        NSURLSessionConfiguration* config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"com.autonavi.appgrouptest.extension%ld",loadID]];
//        config.sharedContainerIdentifier = @"group.com.autonavi.appgrouptestextension";
//        _mySession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//    }
//    [userDefault release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    completionHandler(NCUpdateResultNewData);
}

- (IBAction)openContainingApp:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"Autonavi://"];
    
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        
    }];
    
    
   
}

- (IBAction)downloadAction:(id)sender
{
    NSURLSession *mySession = [self configureMySession];
    if (mySession)
    {
        NSURL *url = [NSURL URLWithString:@"http://mlbsdown.autonavi.com/mobilenavi/70/14Q10005/42tmc/c0508.zip"];
        NSURLSessionTask *myTask = [mySession downloadTaskWithURL:url];
        [myTask resume];
        if (myTask)
        {
            self.lable.text = @"start load";
        }
    }
}


- (NSURLSession *) configureMySession
{
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.autonavi.appgrouptestextension"];
    NSInteger loadID = [userDefault integerForKey:@"isLoadingid"];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"com.autonavi.appgrouptest.extension%ld",loadID]];
    config.sharedContainerIdentifier = @"group.com.autonavi.appgrouptestextension";
    _mySession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    loadID++;
    [userDefault setInteger:loadID forKey:@"isLoadingid"];
    [userDefault setBool:YES forKey:@"isLoading"];
    [userDefault release];
    return _mySession;
}

/* The last message a session receives.  A session will only become
 * invalid because of a systemic error or when it has been
 * explicitly invalidated, in which case the error parameter will be nil.
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.autonavi.appgrouptestextension"];
    [userDefault setBool:NO forKey:@"isLoading"];
    [userDefault release];
    self.lable.text = [NSString stringWithFormat:@"%@,%ld,%@",error.domain,error.code,error.localizedDescription];
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
    self.lable.text = [self.lable.text stringByAppendingString:@"11 "];
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
    self.lable.text = [self.lable.text stringByAppendingString:@"12 "];
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
    self.lable.text = [self.lable.text stringByAppendingString:@"13 "];
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
    self.lable.text = [self.lable.text stringByAppendingString:@"14 "];
}

/* Sent if a task requires a new, unopened body stream.  This may be
 * necessary when authentication has failed for any request that
 * involves a body stream.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
    self.lable.text = [self.lable.text stringByAppendingString:@"15 "];
}

/* Sent periodically to notify the delegate of upload progress.  This
 * information is also available as properties of the task.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
   self.lable.text = [self.lable.text stringByAppendingString:@"16 "];
}

/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    self.lable.text = [self.lable.text stringByAppendingString:@"17 "];
}

/* Sent when a download task that has completed a download.  The delegate should
 * copy or move the file at the given location to a new location as it will be
 * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
 * still be called.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    self.lable.text = [self.lable.text stringByAppendingString:@"18 "];
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
    NSLog(@"%@",error);
//    NSString *str = [containerURL.path stringByAppendingString:@"/c0508.zip"];
//    NSData *data = [NSData dataWithContentsOfURL:location];
//    BOOL sign = [data writeToFile:str atomically:YES];
}

/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    g_lable.text = [NSString stringWithFormat:@"%lld",(totalBytesExpectedToWrite == 0)?100:totalBytesWritten*100/totalBytesExpectedToWrite];
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
    self.lable.text = [self.lable.text stringByAppendingString:@"19 "];
}
@end
