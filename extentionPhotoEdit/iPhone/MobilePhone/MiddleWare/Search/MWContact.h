//
//  MWContact.h
//  AutoNavi
//
//  Created by gaozhimin on 13-7-31.
//
//

#import <Foundation/Foundation.h>
#import "NameIndex.h"

/**********************************!
  @brief 用户联系人列表类
  *********************************/
@interface MWContact : NSObject

/*!
  @brief 用户联系人个数
  */
@property (nonatomic,assign) int			nNumberOfItem;

/*!
  @brief 用户联系人   储存 NameIndex 对象
  */
@property (nonatomic,retain) NSArray*			contactArray;

@end

/******************************************!
  @brief 上传，下载兴趣点条件类
  @see GFAVORITECATEGORY
  ******************************************/
@interface MWContactOption : NSObject



/*!
  @brief 高德用户名   必填
  */
@property (nonatomic,copy) NSString			*userName;

/*!
  @brief 高德用户密码   必填
  */
@property (nonatomic,copy) NSString			*password;

@end


/******************************************!
  @brief 联系人数据解析
  ******************************************/
@interface MWContactXMLParser : NSObject <NSXMLParserDelegate>
{
	NSMutableArray *result;
	
	NSMutableString *currentProperty;
	
	NameIndex *itemNode;
    NameIndex *phoneItemNode;
    AddressItem *addressItemNode;
    NameIndex *urlItemNode;
    NameIndex *emailItemNode;
    
    NameIndex *phoneNode;
    NameIndex *addressNode;
    NameIndex *urlNode;
    NameIndex *emailNode;
	
}

- (id)initWitharray:(NSMutableArray *)parray;
- (BOOL)parser:(NSData *)data;

@end