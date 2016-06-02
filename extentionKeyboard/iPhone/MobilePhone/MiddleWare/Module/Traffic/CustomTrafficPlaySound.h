//
//  CustomTrafficPlaySound.h
//  AutoNavi
//
//  Created by gaozhimin on 13-5-25.
//
//

#import <Foundation/Foundation.h>

@interface CustomTrafficPlaySound : NSObject

+ (CustomTrafficPlaySound *)SharedInstance;
- (void)StartPlaySound;
- (void)StopPlaySound;

@end
