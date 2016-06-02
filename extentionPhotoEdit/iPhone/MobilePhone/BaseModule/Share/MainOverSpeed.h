//
//  MainOverSpeed.h
//  AutoNavi
//
//  Created by bazinga on 14-10-16.
//
//

#import <Foundation/Foundation.h>

typedef void (^ChangeSpeed)(int);   //超速速度
typedef void (^ChangeHidden)(BOOL); //是否显示

@interface MainOverSpeed : NSObject


@property (nonatomic, assign) int speed;
@property (nonatomic, assign) int hidden;
@property (nonatomic, assign) int roadID;
@property (nonatomic, copy) ChangeSpeed changeSpeed;
@property (nonatomic, copy) ChangeHidden changeHidden;

+ (instancetype)SharedInstance;

@end
