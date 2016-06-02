//	应用程序入口
//  AppDelegate_iPhone.h
//  AutoNavi
//
//  Created by GHY on 12-3-26.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>

@class MainViewController;

@interface AppDelegate_iPhone : NSObject <UIApplicationDelegate,NSURLSessionDelegate,NSURLSessionTaskDelegate,NSURLSessionDownloadDelegate>
{
    UIWindow *window;
	MainViewController *rootViewController;
	UINavigationController *navigationController;
    
}
@property (nonatomic,retain) IBOutlet MainViewController *rootViewController;
@property (nonatomic,retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic,copy) id backgroundSessionCompletionHandler;

- (UIViewController *)mainViewController;
@end

