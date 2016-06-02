//
//  SettingSettingViewControllerTempViewController.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-5-21.
//
//

#import "ANTableViewController.h"
#import "BottomButton.h"
@interface SwitchInfoData : NSObject

@property (nonatomic, copy) NSString *stringTitle;
@property (nonatomic, copy) BottomButoonPress buttonPress;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) CGFloat fontSize;     //-1 : 使用默认


- (id) initInfoData:(NSString*)title withPress:(BottomButoonPress) buttonPress;


- (id) initInfoData:(NSString*)title
          withPress:(BottomButoonPress) buttonPress
       withSelected:(BOOL) select;


- (id) initInfoData:(NSString*)title
          withPress:(BottomButoonPress) buttonPress
       withSelected:(BOOL) select
       withFontSize:(CGFloat) fontSize;
@end


@interface SettingSettingViewControllerTempViewController : ANTableViewController<NetReqToViewCtrDelegate,GDActionSheetDelegate>


@end
