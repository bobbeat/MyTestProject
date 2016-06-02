//
//  GDTableCellArray.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-5-21.
//
//

#import <Foundation/Foundation.h>

@interface GDTableCellArray : NSObject

//group header 的标题
@property (nonatomic, copy)  NSString *stringHeader;
//group foot 的标题
@property (nonatomic, copy) NSString *stringFoot;
//group 下的 cell 栏数据数组 类型为 —— GDTableCellData
@property (nonatomic, retain) NSMutableArray *arrayCellData;

- (id) initWithHeader:(NSString *) stringHeader;

- (id) initWithHeader:(NSString *)stringHeader withFoot:(NSString *)stringFoot;


@end
