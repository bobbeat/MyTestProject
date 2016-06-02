
//
//  play.h
//  AutoNavi
//
//  Created by huang longfeng on 11-12-14.
//  Copyright 2011 autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Play : NSObject {

}
//基础资源和一级城市列表的公共属性
//@property (nonatomic, retain) NSString *name;
//@property (nonatomic, retain) NSString *url;
//@property (nonatomic,assign) long long totalsize;
//@property (nonatomic,assign) int admincode;
@property (nonatomic, retain) NSArray *quotations;

@property (nonatomic, copy) NSString *zhname;
@property (nonatomic, copy) NSString *twname;
@property (nonatomic, copy) NSString *enname;
@property (nonatomic, assign) int status;
@property (nonatomic, retain) NSDictionary *updatedes;
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

@property (nonatomic,assign) long long size;
@property (nonatomic,assign) long long unzipsize;

@property (nonatomic,assign) int admincode;
@end
