//
//  SettingNewVersionIntroduceViewController.h
//  AutoNavi
//
//  Created by huang on 13-8-13.
//
//

#import "ANViewController.h"
//新版本功能介绍
@class MyScrollView;
@interface SettingNewVersionIntroduceViewController : ANViewController
{
    UIImageView *_imageView;
    MyScrollView *_scrollView;
    UINavigationBar *_navigationBar;

}

- (id)initWithTarget:(id)target selector:(SEL)sel ;
@end
