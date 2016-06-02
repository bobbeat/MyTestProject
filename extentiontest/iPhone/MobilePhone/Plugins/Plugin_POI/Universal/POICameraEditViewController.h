//
//  POICameraEditViewController.h
//  AutoNavi
//
//  Created by huang on 13-8-20.
//
//

#import "ANViewController.h"
#import "MWSmartEyes.h"
@interface POICameraEditViewController : ANTableViewController
{

    UITextField *_textField;
}
@property(nonatomic,retain)MWSmartEyesItem *smartEyesItem;
@property(nonatomic)BOOL isAdd;                             //用于判断是添加还是编辑0表示编辑，1表示添加
@end
