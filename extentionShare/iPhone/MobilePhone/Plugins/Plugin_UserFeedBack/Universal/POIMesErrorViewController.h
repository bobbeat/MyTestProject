//
//  POIMesErrorViewController.h
//  AutoNavi
//
//  Created by weisheng on 14-6-10.
//
//

#import <UIKit/UIKit.h>
#import "CustomNetWork.h"
#import "POIInputCell.h"
#import "MWSearchResult.h"
#import "MWFeedbackRequestCondition.h"
#import "FeedBackImageView.h"
#import "FeedBackTableViewCell.h"

@interface POIMesErrorViewController : CustomNetWork<feedBackImageViewDelegate>
{

}
@property(retain,nonatomic)UITextField * textFieldName1;
@property(retain,nonatomic)UITextField * textFieldAdd1;
@property(retain,nonatomic)UITextField * textFieldTel1;
@property(retain,nonatomic)UITextField * textFieldOther;
@property(retain,nonatomic)UITextField * textFieldPhone;;
@property(retain,nonatomic)FeedBackImageView * feedBackImage;
@property(retain,nonatomic)MWPoi * poi;
@end
