//
//  NameIndex.h
//  autonavi
//
//  Created by huang longfeng on 12-2-3.
//  Copyright 2012 autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressItem : NSObject <NSCoding>{
    NSString *city;
    NSString *country;
    NSString *countryCode;
    NSString *state;
    NSString *street;
    NSString *zip;
    NSString *type;
}
@property(nonatomic,retain) NSString *city;
@property(nonatomic,retain) NSString *country;
@property(nonatomic,retain) NSString *countryCode;
@property(nonatomic,retain) NSString *state;
@property(nonatomic,retain) NSString *street;
@property(nonatomic,retain) NSString *zip;
@property(nonatomic,retain) NSString *type;
@end


@interface NameIndex : NSObject <NSCoding>{  
    NSString *_fullName;  
    NSDate *lastEditTime;

    NSMutableArray *addressArray;
    
     
	NSMutableArray *phoneArray;
    NSMutableArray *emailArray;
    NSMutableArray *URLArray;
    
    NSMutableArray *phoneTypeArray;
    NSMutableArray *emailTypeArray;
    NSMutableArray *URLTypeArray;

    //AddressItem *addressItem;
}  
//@property (nonatomic, retain) NSString *_lastName;  
@property (nonatomic, retain) NSString *_fullName;   
@property (nonatomic, retain) NSDate *lastEditTime;  
@property (nonatomic, retain) NSMutableArray *phoneArray; 
@property (nonatomic, retain) NSMutableArray *emailArray; 
@property (nonatomic, retain) NSMutableArray *URLArray;
@property (nonatomic, retain) NSMutableArray *addressArray;
@property (nonatomic, retain) NSMutableArray *phoneTypeArray; 
@property (nonatomic, retain) NSMutableArray *emailTypeArray; 
@property (nonatomic, retain) NSMutableArray *URLTypeArray;

//- (NSString *) getFullName;  
//- (NSString *) getLastName;  
@end  
