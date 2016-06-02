//
//  MWAccountParseData.h
//  AutoNavi
//
//  Created by gaozhimin on 13-9-8.
//
//

#import <Foundation/Foundation.h>

@interface MWAccountParseData : NSObject<NSXMLParserDelegate>

+ (NSDictionary *)GetOperationResultByData:(NSData *)data;

@end
