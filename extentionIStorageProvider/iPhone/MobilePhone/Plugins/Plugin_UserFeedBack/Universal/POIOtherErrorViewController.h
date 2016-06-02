//
//  POIOtherErrorViewController.h
//  AutoNavi
//
//  Created by weisheng on 14-6-10.
//
//

#import <UIKit/UIKit.h>
#import "CustomNetWork.h"
#import "HTextVIewPlaceholder.h"
#import "FeedBackTableViewCell.h"
#import "FeedBackImageView.h"
@interface POIOtherErrorViewController : CustomNetWork<feedBackImageViewDelegate>
{
    HTextVIewPlaceholder * _textViewDes;
    UIButton * _btnCommit;
    float      _keyBoardHeight;
}
@property(retain,nonatomic)UITextView  * textViewAdd;
@property(retain,nonatomic)UITextField * textFieldQQ;
@property(retain,nonatomic)FeedBackImageView * feedBackImage;
@property(assign,nonatomic)int type;
@property(retain,nonatomic)MWPoi * poi;
@end
