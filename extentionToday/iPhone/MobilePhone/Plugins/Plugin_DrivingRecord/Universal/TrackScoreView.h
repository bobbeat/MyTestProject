//
//  TrackScoreView.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-13.
//
//

#import <UIKit/UIKit.h>

@interface TrackScoreView : UIView

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *scoreLabel;
@property (nonatomic, retain) UILabel *symbolLabel;

- (void)drawImageName:(NSString *)imageName precent:(float)precent width:(float)width;

@end
