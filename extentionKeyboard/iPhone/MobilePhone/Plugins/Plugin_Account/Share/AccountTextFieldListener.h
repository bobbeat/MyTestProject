//
//  AccountTextFieldListener.h
//  AutoNavi
//
//  Created by gaozhimin on 13-9-22.
//
//

#import <Foundation/Foundation.h>

typedef enum ListenerType
{
    ListenerType_changeBounds = 0,      //改变table高度，也就是减去键盘高度
    ListenerType_changeOffset,          //仅仅只做table的content偏移
}ListenerType;

@interface AccountTextFieldListener : NSObject

+ (id)startAccountTextFieldListner;

+ (id)startAccountTextFieldListner:(ListenerType)Type;

+ (void)StopAccountTextFieldListner;

@end
