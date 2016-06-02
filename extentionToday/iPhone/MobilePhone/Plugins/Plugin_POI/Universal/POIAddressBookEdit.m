//
//  POIAddressBookEdit.m
//  AutoNavi
//
//  Created by huang on 13-8-20.
//
//

#import "POIAddressBookEdit.h"
#import "MWPoiOperator.h"
#import "POIDefine.h"
@implementation POIAddressBookEdit
@synthesize nameIndex,viewContrller,index;
-(void)dealloc
{
    if (nameIndex) {
        [nameIndex release];
    }
    CLOG_DEALLOC(self);
    [super dealloc];
}
-(void)editAddressBook
{
    
    if (nameIndex==nil||viewContrller==nil) {
        NSLog(@"数据不存在");
        return;
    }
 
    
    NameIndex *tmpnode = nameIndex;
    
    aContact = ABPersonCreate();

    ABRecordSetValue(aContact, kABPersonFirstNameProperty, (CFStringRef)tmpnode._fullName, nil);
    for(int i = 0;i<[tmpnode.addressArray count];i++)
    {
        AddressItem *item = [tmpnode.addressArray objectAtIndex:i];
        [self addAddress:aContact POIAddress:item];
    }
    for(int i = 0;i<[tmpnode.phoneArray count];i++)
    {
        
        [self addPhone:aContact phone:[tmpnode.phoneArray objectAtIndex:i] type:[tmpnode.phoneTypeArray objectAtIndex:i]];
    }
    for (int i = 0; i < [tmpnode.emailArray count]; i++) {
        [self addEmail:aContact email:[tmpnode.emailArray objectAtIndex:i] type:[tmpnode.emailTypeArray objectAtIndex:i]];
    }
    
    for (int i = 0; i < [tmpnode.URLArray count]; i++) {
        [self addURL:aContact url:[tmpnode.URLArray objectAtIndex:i] type:[tmpnode.URLTypeArray objectAtIndex:i]];
    }

	ABAddressBookRef addressBook = nil;
    
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_6_0)
    {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                                 {
                                                     dispatch_semaphore_signal(sema);
                                                 });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else
    {
        addressBook = ABAddressBookCreate();
    }
	CFArrayRef friendList = ABAddressBookCopyArrayOfAllPeople(addressBook);
	
	int friendsCount = CFArrayGetCount(friendList);
	
	
	for (int i = 0; i<friendsCount; i++) {
		BOOL addFlag = NO;
		BOOL URLFlag = NO;
		BOOL emailFlag = NO;
		BOOL PhoneFlag = NO;
		ABRecordRef record = CFArrayGetValueAtIndex(friendList, i);
		
		if ([tmpnode._fullName isEqualToString:(NSString*)ABRecordCopyCompositeName(record)]) {
			
			
			ABMultiValueRef address = ABRecordCopyValue(record, kABPersonAddressProperty);
			int addressCount = ABMultiValueGetCount(address);
			if (addressCount != [tmpnode.addressArray count]) {
				continue;
			}
			else {
				for (int j = 0; j<[tmpnode.addressArray count]; j++) {
					
					AddressItem *item = [tmpnode.addressArray objectAtIndex:j];
					NSString *addressTmp = [NSString stringWithFormat:@"%@%@%@%@%@%@",item.country,item.city,item.state,item.street,item.zip,item.countryCode];
					//NSLog(@"addtmp==%@",addressTmp);
					
					NSDictionary* personaddress =(NSDictionary*) ABMultiValueCopyValueAtIndex(address, j);
					NSString* country = [personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
					NSString* city = [personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
					NSString* state = [personaddress valueForKey:(NSString *)kABPersonAddressStateKey];
					NSString* street = [personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
					NSString* zip = [personaddress valueForKey:(NSString *)kABPersonAddressZIPKey];
					NSString* coutntrycode = [personaddress valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
					NSString* addressAll = [NSString stringWithFormat:@"%@%@%@%@%@%@",country,city,state,street,zip,coutntrycode];
					//NSLog(@"addlabel==%@",addressAll);
					
					if (![addressTmp isEqualToString:addressAll]) {
						addFlag = YES;
						
					}
                    
				}
				if (addFlag == YES) {
					continue;
				}
			}
			
			ABMultiValueRef email = ABRecordCopyValue(record, kABPersonEmailProperty);
			int emailcount = ABMultiValueGetCount(email);
			if (emailcount != [tmpnode.emailArray count]) {
				continue;
			}
			else {
				for (int j = 0; j<[tmpnode.emailArray count]; j++) {
					NSString *emailString = [tmpnode.emailArray objectAtIndex:j];
					//NSLog(@"emailtmp==%@",emailString);
					
					NSString* emailContent = (NSString*)ABMultiValueCopyValueAtIndex(email, j);
					//NSLog(@"emailContent==%@",emailContent);
					if (![emailString isEqualToString:emailContent]) {
						emailFlag = YES;
						
					}
					
				}
				if (emailFlag == YES) {
					continue;
				}
			}
			
			ABMultiValueRef URL = ABRecordCopyValue(record, kABPersonURLProperty);
			int URLcount = ABMultiValueGetCount(URL);
			if (URLcount != [tmpnode.URLArray count]) {
				continue;
			}
			else {
				for (int j = 0; j<[tmpnode.URLArray count]; j++) {
					NSString *URLString = [tmpnode.URLArray objectAtIndex:j];
					//NSLog(@"URLtmp==%@",URLString);
					
					NSString* URLContent = (NSString*)ABMultiValueCopyValueAtIndex(URL, j);
					//NSLog(@"URLContent==%@",URLContent);
					if (![URLString isEqualToString:URLContent]) {
						URLFlag = YES;
						
					}
					
				}
				if (URLFlag == YES) {
					continue;
				}
			}
			
			ABMultiValueRef phone = ABRecordCopyValue(record, kABPersonPhoneProperty);
			int phonecount = ABMultiValueGetCount(phone);
			if (phonecount != [tmpnode.phoneArray count]) {
				continue;
			}
			else {
				for (int j = 0; j<[tmpnode.phoneArray count]; j++) {
					NSString *phoneString = [tmpnode.phoneArray objectAtIndex:j];
					//NSLog(@"phoneArray==%@",phoneString);
					
					NSString* phoneContent = (NSString*)ABMultiValueCopyValueAtIndex(phone, j);
					//NSLog(@"phoneContent==%@",phoneContent);
					if (![phoneString isEqualToString:phoneContent]) {
						PhoneFlag = YES;
						
					}
					
				}
				if (PhoneFlag == YES) {
					continue;
				}
			}
			
			ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
			picker.newPersonViewDelegate = self;
			picker.displayedPerson = record;
			UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
			[viewContrller presentModalViewController:navigation animated:YES];
			
			[picker release];
			[navigation release];
			
			if (addressBook) {
		        CFRelease(addressBook);
		    }
			return;
			
		}
		
	}
	
	
	ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
	picker.newPersonViewDelegate = self;
	picker.displayedPerson = aContact;
	UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
	[viewContrller presentModalViewController:navigation animated:YES];
	
	[picker release];
	[navigation release];
	if (addressBook) {
		CFRelease(addressBook);
	}

}

#pragma mark -
//通讯录添加地址字段
- (BOOL)addAddress:(ABRecordRef)person POIAddress:(AddressItem *)poiaddress
{
    ABMultiValueRef immutableMultiAddress = (ABMultiValueRef) ABRecordCopyValue(person, kABPersonAddressProperty);
	ABMutableMultiValueRef addres;
	if (immutableMultiAddress)
		
    {
		
        addres= ABMultiValueCreateMutableCopy(immutableMultiAddress);
		
    }
    else
		
    {
		
        addres = ABMultiValueCreateMutable(kABDictionaryPropertyType);
    }
	
    
    static int  homeLableValueCount = 6;
    
    // 设置字典的keys和value
    CFStringRef keys[homeLableValueCount];
    CFStringRef values[homeLableValueCount];
    keys[0]      = kABPersonAddressStreetKey;
    keys[1]      = kABPersonAddressCityKey;
    keys[2]      = kABPersonAddressStateKey;
    keys[3]      = kABPersonAddressZIPKey;
    keys[4]      = kABPersonAddressCountryKey;
    keys[5]      = kABPersonAddressCountryCodeKey;
    
    if (poiaddress.street == nil) {
		values[0]    = (CFStringRef)@" ";
	}
	else {
		values[0]    = (CFStringRef)poiaddress.street;
	}
	if (poiaddress.city == nil) {
		values[1]    = (CFStringRef)@" ";
	}
	else {
		values[1]    = (CFStringRef)poiaddress.city;
	}
	if (poiaddress.state == nil) {
		values[2]    = (CFStringRef)@" ";
	}
	else {
		values[2]    = (CFStringRef)poiaddress.state;
	}
	if (poiaddress.zip == nil) {
		values[3]    = (CFStringRef)@" ";
	}
	else {
		values[3]    = (CFStringRef)poiaddress.zip;
	}
	if (poiaddress.country == nil) {
		values[4]    = (CFStringRef)@" ";
	}
	else {
		values[4]    = (CFStringRef)poiaddress.country;
	}
	if (poiaddress.countryCode == nil) {
		values[5]    = (CFStringRef)@" ";
	}
	else {
		values[5]    = (CFStringRef)poiaddress.countryCode;
	}
    
    CFDictionaryRef aDict = CFDictionaryCreate(
                                               kCFAllocatorDefault,
                                               (void *)keys,
                                               (void *)values,
                                               homeLableValueCount,
                                               &kCFCopyStringDictionaryKeyCallBacks,
                                               &kCFTypeDictionaryValueCallBacks
                                               );
    
    // 添加地址到 person 纪录.
    ABMultiValueIdentifier identifier;
    
    BOOL result = ABMultiValueAddValueAndLabel(addres, aDict, (CFStringRef)poiaddress.type, &identifier);
	
    CFErrorRef error = NULL;
    result = ABRecordSetValue(person, kABPersonAddressProperty, addres, &error);
    
    if(aDict)CFRelease(aDict);
    if(addres)CFRelease(addres);
    
    return result;
}
//添加邮件字段
- (BOOL)addEmail:(ABRecordRef)person email:(NSString*)email type:(NSString *)emailtype
{
	ABMultiValueRef immutableMultiAddress = (ABMultiValueRef) ABRecordCopyValue(person, kABPersonEmailProperty);
	ABMutableMultiValueRef multi;
	if (immutableMultiAddress)
    {
		
        multi = ABMultiValueCreateMutableCopy(immutableMultiAddress);
		
    }
    else
    {
		
        multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    }
    
    CFErrorRef anError = NULL;
	
    ABMultiValueIdentifier multivalueIdentifier;
    
    if (!ABMultiValueAddValueAndLabel(multi, (CFStringRef)email, (CFStringRef)emailtype, &multivalueIdentifier)){
        if(multi)CFRelease(multi);
        return NO;
    }
	
    if (!ABRecordSetValue(person, kABPersonEmailProperty, multi, &anError)){
        if(multi)CFRelease(multi);
        return NO;
    }
	
    if(multi)CFRelease(multi);
    return YES;
}
//添加电话字段
- (BOOL)addPhone:(ABRecordRef)person phone:(NSString*)phone type:(NSString *)phonetype
{
	ABMultiValueRef immutableMultiAddress = (ABMultiValueRef) ABRecordCopyValue(person, kABPersonPhoneProperty);
	ABMutableMultiValueRef multi;
	if (immutableMultiAddress)
    {
		
        multi = ABMultiValueCreateMutableCopy(immutableMultiAddress);
		
    }
    else
    {
		
        multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    }
    
    CFErrorRef anError = NULL;
	
    ABMultiValueIdentifier multivalueIdentifier;
    
    if (!ABMultiValueAddValueAndLabel(multi, (CFStringRef)phone, (CFStringRef)phonetype, &multivalueIdentifier)){
        if(multi)CFRelease(multi);
        return NO;
    }
	
    if (!ABRecordSetValue(person, kABPersonPhoneProperty, multi, &anError)){
        if(multi)CFRelease(multi);
        return NO;
    }
	
    if(multi)CFRelease(multi);
    return YES;
}
//添加url字段
- (BOOL)addURL:(ABRecordRef)person url:(NSString*)url type:(NSString*)urltype
{
	ABMultiValueRef immutableMultiURL = (ABMultiValueRef) ABRecordCopyValue(person, kABPersonURLProperty);
	ABMutableMultiValueRef multi;
	CFErrorRef anError = NULL;
    ABMultiValueIdentifier multivalueIdentifier;
	if (immutableMultiURL)
    {
		
        multi= ABMultiValueCreateMutableCopy(immutableMultiURL);
		
    }
    else
    {
		
        multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    }
	if (url == nil) {
		url = @" ";
	}
    //添加url属性值
    if (!ABMultiValueAddValueAndLabel(multi, (CFStringRef)url, (CFStringRef)urltype,
									  &multivalueIdentifier)){
        if(multi)CFRelease(multi);
        return NO;
    }
	//设置url属性值
    if (!ABRecordSetValue(person, kABPersonURLProperty, multi, &anError)){
        if(multi)CFRelease(multi);
        return NO;
    }
	
    if(multi)CFRelease(multi);
    return YES;
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
	if (person != nil) { //添加成功处理
		ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
		ABMultiValueRef url = ABRecordCopyValue(person, kABPersonURLProperty);
        UIAlertView *alertView;
        NSString *message;
      
		if (0 == ABMultiValueGetCount(address) && 0 == ABMultiValueGetCount(url)) {
			[MWPoiOperator deleteContactWithIndex:index];
            message=STR(@"POI_AddressBookEditFail", Localize_POI);
		}
		else {
			[MWPoiOperator editContactWith:person index:index];
			
            message=STR(@"POI_AddressBookEditSuccess", Localize_POI);
		}
        alertView = [[UIAlertView alloc]
                     initWithTitle:message
                     message:nil
                     delegate:self
                     cancelButtonTitle:STR(@"POI_AddressBookEditOK", Localize_POI)
                     otherButtonTitles:nil,nil];
        
		[alertView show];
        [alertView release];
     
		
	}
	
	[viewContrller dismissModalViewControllerAnimated:YES];
	
}



#pragma mark ABUnknownPersonViewControllerDelegate methods
// Dismisses the picker when users are done creating a contact or adding the displayed person properties to an existing contact.
- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person
{
	[viewContrller dismissModalViewControllerAnimated:YES];
}


// Does not allow users to perform default actions such as emailing a contact, when they select a contact property.
- (BOOL)unknownPersonViewController:(ABUnknownPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person
						   property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    
	return NO;
}

@end
