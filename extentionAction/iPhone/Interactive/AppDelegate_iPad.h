//
//  AppDelegate_iPad.h
//  AutoNavi
//
//  Created by GHY on 12-3-26.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class MainViewController_iPad;


@interface AppDelegate_iPad : NSObject <UIApplicationDelegate> 
{
    UIWindow *window;
	MainViewController_iPad *rootViewController;
	UINavigationController *navigationController;
    
}
@property (nonatomic, retain) IBOutlet MainViewController_iPad *rootViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UIWindow *window;


@end

