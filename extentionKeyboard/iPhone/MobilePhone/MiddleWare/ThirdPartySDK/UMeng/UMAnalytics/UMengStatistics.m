//
//  UMengStatistics.m
//  AutoNavi
//
//  Created by huang on 14-1-3.
//
//

#import "UMengStatistics.h"
#import "UMengEventDefine.h"

@implementation UMengStatistics

+(void)trafficTimeBucket                                       //获取系统时间段
{
    NSDate *date=[NSDate date];
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    
    [formatter setDateFormat:@"hh"];
    NSString *string = [formatter stringFromDate:date];
    [formatter release];
    [UMengStatistics trafficTimeBucket:[string intValue]];

}
+(void)trafficTimeBucket:(int)bucket                           //手动设置时间段
{
    [MobClick event:UM_EVENTID_TRAFFIC_TIME_BUCKET label:[NSString stringWithFormat:@"%i",bucket]];
}

+(void)recalculationCount:(int)count                           //偏航次数
{
    NSString *string=[NSString stringWithFormat:@"%i",count];
    if (count>5) {
        string=UM_LABEL_RECALCULATION_ABOVE_5;
    }
    [MobClick event:UM_EVENTID_RECALCULATION_COUNT label:string];
}
+(void)naviDistanceCount:(int)dis                              //导航距离
{
    [UMengStatistics naviDistanceCount:dis withNaviType:0];
}
+(void)naviDistanceCount:(int)dis withNaviType:(int)type       //导航距离带类型，类型用于以后拓展用，现阶段暂时不用
{
    switch (type) {
        case 0:
        {
            NSString *string=nil;
            if (dis<5000) {
                string=UM_LABEL_BELOW_5KM;
            }
            else if (dis<100000)
            {
                string=UM_LABEL_5KM_10KM;
            }
            else if (dis<15000)
            {
                string=UM_LABEL_10KM_15KM;
            }
            else if (dis<20000)
            {
                string=UM_LABEL_15KM_20KM;
            }
            else if (dis<25000)
            {
                string=UM_LABEL_20KM_25KM;
            }
            else
            {
                string=UM_LABEL_ABOVE_25KM;
            }
            [MobClick event:UM_EVENTID_NAVI_DISTANCE_COUNT label:string];
        }
            break;
            
        default:
            break;
    }
}
@end
