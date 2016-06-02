//
//  TodayViewController.h
//  test1
//
//  Created by gaozhimin on 14-12-10.
//
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController

@property (retain,nonatomic) IBOutlet UILabel *lable;
@property (nonatomic,copy) id backgroundSessionCompletionHandler;
- (IBAction)openContainingApp:(id)sender;
- (IBAction)downloadAction:(id)sender;
@end
