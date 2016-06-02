//
//  VCTranslucentBarButtonItem.h
//  Custom NavBar
//
//  Created by ljj on 12-7-16.
//  Copyright (c) 2012年 autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    VCTranslucentBarButtonItemTypeForward = 0,
    VCTranslucentBarButtonItemTypeNormal,
    VCTranslucentBarButtonItemTypeBackward,
    VCTranslucentBarButtonItemTypeRedColor,
    VCTranslucentBarButtonItemTypeLeftCancel        //左边取消按钮
} VCTranslucentBarButtonItemType;

@interface VCTranslucentBarButtonItem : UIBarButtonItem
@property (nonatomic, assign) VCTranslucentBarButtonItemType type;

- (id)initWithType:(VCTranslucentBarButtonItemType)theType title:(NSString *)title target:(id)target action:(SEL)action;

- (void)setNewHidden:(BOOL)hidden;
@end
