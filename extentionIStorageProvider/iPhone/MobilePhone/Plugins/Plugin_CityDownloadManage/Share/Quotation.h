//
//  Quotation.h
//  AutoNavi－sj
//
//  Created by huang longfeng on 11-12-14.
//  Copyright 2011 autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Quotation : NSObject {

}
//二级城市列表属性

@property (nonatomic, assign)	BOOL			checked;
@property (nonatomic, copy) NSString *zhname;
@property (nonatomic, copy) NSString *twname;
@property (nonatomic, copy) NSString *enname;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, assign) int updatetype;
@property (nonatomic, copy) NSString *all_suburl;
@property (nonatomic,assign) long long all_size;
@property (nonatomic,assign) long long all_unzipsize;
@property (nonatomic,copy) NSString *all_md5;
@property (nonatomic, copy) NSString *add_suburl;
@property (nonatomic,assign) long long add_size;
@property (nonatomic,assign) long long add_unzipsize;
@property (nonatomic,copy) NSString *add_md5;
@property (nonatomic, assign) int      admincode;


+ (Quotation*) quotation;
@end
