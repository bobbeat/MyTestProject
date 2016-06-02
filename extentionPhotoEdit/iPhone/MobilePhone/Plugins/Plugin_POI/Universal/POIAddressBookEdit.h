//
//  POIAddressBookEdit.h
//  AutoNavi
//
//  Created by huang on 13-8-20.
//
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "NameIndex.h"
@interface POIAddressBookEdit : NSObject<ABUnknownPersonViewControllerDelegate,ABNewPersonViewControllerDelegate>
{
    ABUnknownPersonViewController *unkownpicker;
	ABRecordRef aContact;
}
@property(nonatomic)int index;
@property(nonatomic,retain)NameIndex *nameIndex;
@property(nonatomic,assign)UIViewController *viewContrller;
-(void)editAddressBook;
@end
