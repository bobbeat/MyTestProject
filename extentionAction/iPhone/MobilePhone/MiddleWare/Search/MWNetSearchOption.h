//
//  MWNetSearchOption.h
//  AutoNavi
//
//  Created by gaozhimin on 14-2-25.
//
//

#import <Foundation/Foundation.h>

/*
 网络搜索条件基类
 */
@interface MWNetSearchOption : NSObject

@property (nonatomic,copy) NSString *search;          //查询关键词
@property (nonatomic,copy) NSString *adcode;          //搜索区域代码
@property (nonatomic,assign) int size;          //每页返回结果数,最多返回的结果条数
@property (nonatomic,assign) int page;          //页码 默认为 1,起始为 1
@property (nonatomic,assign) int language;          //搜索语言

@end

/** POI 搜索、语音搜索、交叉路口搜索请求参数
 
 sign鉴权说明:本接口参与计算签名的参数为: syscode、search 由于不同模式下查询, 可
 能不会传递所有参数,而是 syscode、search 中的一个或几个, 缺失的参数不参与计算,
 但仍然需要注意保持顺序.
 
 父元素名称	元素名称    是否必须 (1是0否)     类型      描述                  取值说明
 og          servcode       1           String[4]	交易代码                0005
 og          search         1           String[100]	查询关键词               查询关键字
 og          adcode         1           String[6]   搜索区域代码             可为空,默认为 010, 全国为 0000
 og          adcodesrc      0               int     Adcode 来源             0:本地搜索引擎定义 adcode 1:母库 adcode   默认为 adcodesrc=0
 og          mapv           0           String      本地数据版本号           当 adcodesrc=0 时,根据 mapv 对应 adcode 母库映射表进行搜索
 og          size           1           int         每页返回结果数           最多返回的结果条数
 og          page           1           int         页码                   页码,默认为 1,起始为 1
 og          searchtype     0           int         搜索类型                0:普通关键字搜索 1:语音输入模式搜索 2:交叉路口搜索 可空,默认值=0
 og          language       0           int         搜索语言                0:中文搜索 1:英文搜索(返回结果为英文) 可空,默认值=0
 og          imei           1           String      机器唯一码              非空
 og          syscode        1           String      业务系统账号             非空,参与鉴权计算
 og          sign           1           String      签名串                  接口访问鉴权使用,非空
 og          model          0           int         搜索模式                 默认为 0,大陆搜索 1,台湾搜索
 
 */

/*
 POI 搜索、语音搜索、交叉路口搜索请求参数
 */

@interface MWNetKeyWordSearchOption : MWNetSearchOption

@property (nonatomic,assign) int searchtype;          //搜索类型     0:普通关键字搜索 1:语音输入模式搜索 2:交叉路口搜索 可空,默认值=0
@property (nonatomic,copy)NSString * suggestion;//默认为 false, true : 通过城市建议请求 false:不是通过城市建议请求
/*
 获取对象的所有属性和属性内容
 */
- (NSData *)getAllPropertiesAndVaulesData;

@end

/* 周边查询参数
 sign鉴权说明:本接口参与计算签名的参数为: syscode、cx、cy、category、keywords 由 于不同模式下查询, 可能不会传递所有参数,而是 syscode、cx、cy、category、keywords 中的一个或几个, 缺失的参数不参与计算, 但仍然需要注意保持顺序.
 父元素名称	元素名称      是否必须(1是0否)    类型        描述                  取值说明
 og      servcode            1           String[4]   交易代码             0006
 og      search              0           String      查询关键字           查询关键字
 og      cx                  0           String      经度               查询中心点经度坐标
 og      cy                  0           String      纬度               查询中心点纬度坐标
 og      center              0           String      中心点名称           中心点名称
 og      category            0           String[100]	查询类别            查询类别,一级分类|二级分类 如:商务休闲|茶艺馆 停车场 停车场|全部
 og      adcode              0           String[6]	区域编码            区域编码,默认全国 000000
 og      adcodesrc           0           int         Adcode 来源        0:本地搜索引擎定义 adcode 1:母库 adcode 默认为 adcodesrc=0
 og      mapv                0           String      本地数据版本号      当 adcodesrc=0 时,根据 mapv 对应 adcode 母库映射表进行搜索
 og      size                1           String[2]   每页条数            最多返回的结果条数
 og      page                1           String[2]   页码              页码,默认为 1,起始为 1
 og      range               1           String[4]   查询范围,单位为米
 og      language            0           int         搜索语言            0:中文搜索 1:英文搜索 可空,默认值=0
 og      syscode             1           String      业务系统账号          非空
 og      sign                1           String      签名串             非空
 og      model               0           int         搜索模式            默认为 0,大陆搜索 1,台湾搜索
 */

/*
 周边查询参数
 */
@interface MWNetAroundSearchOption : MWNetSearchOption

@property (nonatomic,copy) NSString *cx;          //经度
@property (nonatomic,copy) NSString *cy;          //纬度
@property (nonatomic,copy) NSString *center;          //中心点名称
@property (nonatomic,copy) NSString *category;          //查询类别,一级分类|二级分类 如:商务休闲|茶艺馆 停车场 停车场|全部
@property (nonatomic,assign) int range;          //查询范围,单位为米

/*
 搜索条件转换成NSData
 */
- (NSData *)getAllPropertiesAndVaulesData;

@end
/*
 */

@interface MWNetLineSearchOption : NSObject
@property (nonatomic,copy) NSString *cx;          //目的地经度
@property (nonatomic,copy) NSString *cy;          //目的地纬度
@property (nonatomic,copy) NSString *category;    //查询类别
@property (nonatomic,assign) int range;           //查询范围,单位为米
- (NSData *)getAllPropertiesAndVaulesData;
- (NSDictionary *)getHttpHeader;

@end


@interface MWNetParkStopSearchOption : NSObject
{
    
}
@property (nonatomic,copy) NSString *cx;          //经度
@property (nonatomic,copy) NSString *cy;          //纬度
@property (nonatomic,copy) NSString * search;     //查询,停车场
@property (nonatomic,assign)int range;            //查询范围,单位为米
@property(assign,nonatomic)int size;              //返回的停车场个数
@property(assign,nonatomic)int language;          //查询的语言
- (NSData *)getAllPropertiesAndVaulesData;//bogyData
- (NSDictionary *)getHttpHeader;

@end


