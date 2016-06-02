//
//  GDProgressObject.h
//  AutoNavi
//
//  Created by gaozhimin on 14-7-25.
//
//

#import <Foundation/Foundation.h>

/*
 * 用于交互时转圈，目前只用于路径计算中，这个view是显示在window上的，可以覆盖整个屏幕。
 */
@interface GDProgressObject : NSObject

+ (void)ShowProgressWith:(NSString *)tip;

+ (void)HideenProgress;

@end
