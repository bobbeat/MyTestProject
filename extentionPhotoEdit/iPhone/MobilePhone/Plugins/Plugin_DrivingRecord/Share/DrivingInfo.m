//
//  DrivingInfo.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-3.
//
//

#import "DrivingInfo.h"

@implementation DrivingInfo

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:self.drivingID forKey:@"tId"];
    [coder encodeObject:self.userID forKey:@"userid"];
    [coder encodeInt:self.optype forKey:@"optype"];
    [coder encodeInt:self.postType forKey:@"postType"];
    [coder encodeObject:self.name forKey:@"tname"];
    [coder encodeInt:self.trackLength forKey:@"trackLength"];
    [coder encodeDouble:self.trackScore forKey:@"trackScore"];
    [coder encodeInt:self.trackTimeConsuming forKey:@"trackTimeConsuming"];
    [coder encodeDouble:self.averageSpeed forKey:@"averageSpeed"];
    [coder encodeDouble:self.fuelConsumption forKey:@"fuelConsumption"];
    [coder encodeDouble:self.safetyScore forKey:@"safetyScore"];

    [coder encodeInt:self.brakesCount forKey:@"brakesCount"];
    [coder encodeInt:self.uturnCount forKey:@"uturnCount"];
    [coder encodeInt:self.haccelerationCount forKey:@"haccelerationCount"];
    [coder encodeInt:self.hypervelocityCount forKey:@"hypervelocityCount"];
    [coder encodeInt:self.yawCount forKey:@"yawCount"];
    
    [coder encodeObject:self.dataType forKey:@"dataType"];
    [coder encodeObject:self.creatTime forKey:@"creatTime"];
    [coder encodeObject:self.updateTime forKey:@"updateTime"];
    [coder encodeObject:self.startPOI forKey:@"startPOI"];
    [coder encodeObject:self.desPOI forKey:@"desPOI"];
    [coder encodeObject:self.dataURL forKey:@"dataURL"];
    [coder encodeInt:self.isComprass forKey:@"isComprass"];
    [coder encodeInt:self.resultType forKey:@"resultType"];
    [coder encodeDouble:self.higherSpeed forKey:@"higherSpeed"];
}
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.drivingID = [coder decodeObjectForKey:@"tId"];
        self.userID = [coder decodeObjectForKey:@"userid"];
        self.optype = [coder decodeIntForKey:@"optype"];
        self.postType = [coder decodeIntForKey:@"postType"];
        self.name = [coder decodeObjectForKey:@"tname"];
        self.trackLength = [coder decodeIntForKey:@"trackLength"];
        self.trackScore = [coder decodeDoubleForKey:@"trackScore"];
        self.trackTimeConsuming = [coder decodeIntForKey:@"trackTimeConsuming"];
        self.averageSpeed = [coder decodeDoubleForKey:@"averageSpeed"];
        self.fuelConsumption = [coder decodeDoubleForKey:@"fuelConsumption"];
        self.safetyScore = [coder decodeDoubleForKey:@"safetyScore"];
        self.brakesCount = [coder decodeIntForKey:@"brakesCount"];
        self.uturnCount = [coder decodeIntForKey:@"uturnCount"];
        self.haccelerationCount = [coder decodeIntForKey:@"haccelerationCount"];
        self.hypervelocityCount = [coder decodeIntForKey:@"hypervelocityCount"];
        self.yawCount = [coder decodeIntForKey:@"yawCount"];
        
        self.dataType = [coder decodeObjectForKey:@"dataType"];
        self.creatTime = [coder decodeObjectForKey:@"creatTime"];
        self.updateTime = [coder decodeObjectForKey:@"updateTime"];
        self.startPOI = [coder decodeObjectForKey:@"startPOI"];
        self.desPOI = [coder decodeObjectForKey:@"desPOI"];
        self.dataURL = [coder decodeObjectForKey:@"dataURL"];
        self.isComprass = [coder decodeIntForKey:@"isComprass"];
        self.resultType = [coder decodeIntForKey:@"resultType"];
        self.higherSpeed = [coder decodeDoubleForKey:@"higherSpeed"];
    }
    return self;
}

- (id)init
{
    if (self = [super init])
    {
        _startPOI = [[MWPoi alloc] init];
        _desPOI = [[MWPoi alloc] init];
        
    }
    return self;
}

- (void)dealloc
{
    CRELEASE(_drivingID);
    CRELEASE(_userID);
    CRELEASE(_name);
    CRELEASE(_dataType);
    CRELEASE(_creatTime);
    CRELEASE(_updateTime);
    CRELEASE(_startPOI);
    CRELEASE(_desPOI);
    CRELEASE(_dataURL);
    
    [super dealloc];
}
@end
