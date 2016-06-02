//
//  FeedBackImageView.h
//  AutoNavi
//
//  Created by weisheng on 14-6-10.
//
//

#import <UIKit/UIKit.h>
@protocol feedBackImageViewDelegate
@optional
-(void)selectImageView;
@end
@interface FeedBackImageView : UIView
{
     UIButton *_selectButton;
}
@property (nonatomic,copy)      UIImage *selectImage;
@property (nonatomic,assign)    id<feedBackImageViewDelegate> delegate;
@end
