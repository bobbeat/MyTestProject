//
//  Map_Upgrade.h
//  AutoNavi
//
//  Created by huang longfeng on 11-8-17.
//  Copyright 2011 autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANParamValue.h"
#import "ColorLable.h"

@interface Map_Download : ANViewController {

	
	UIButton *Button_continue;
    
    UILabel *_labelGreenTip;            //提示语句绿色
    ColorLable *_labelTip;                 //提示语句黑色
    
    UIImageView *_imageViewWarningBack; //警告语句背景
    UIImageView *_imageViewWarning;     //警告语句图片
    ColorLable *_labelWarning;             //警告语句文字
}

@end
