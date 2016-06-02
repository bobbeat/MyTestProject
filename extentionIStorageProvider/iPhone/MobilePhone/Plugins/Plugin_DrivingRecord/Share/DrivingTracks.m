//
//  DrivingTracks.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-3.
//
//

#import "DrivingTracks.h"

@implementation DCoordinate

 - (void) encodeWithCoder: (NSCoder *)coder
 {
     [coder encodeInt:self.lon forKey:@"lon"];
     [coder encodeInt:self.lat forKey:@"lat"];
     [coder encodeInt:self.Altitude forKey:@"altitude"];
     [coder encodeInt:self.nSpeed forKey:@"speed"];
     [coder encodeInt:self.arrayNum forKey:@"arrayNum"];
     [coder encodeInt:self.coordType forKey:@"coordType"];
 }
 
 - (id) initWithCoder: (NSCoder *)coder
 {
     if (self = [super init])
 {
     self.lon = [coder decodeIntForKey:@"lon"];
     self.lat = [coder decodeIntForKey:@"lat"];
     self.Altitude = [coder decodeIntForKey:@"altitude"];
     self.nSpeed = [coder decodeIntForKey:@"speed"];
     self.arrayNum = [coder decodeIntForKey:@"arrayNum"];
     self.coordType = [coder decodeIntForKey:@"coordType"];
 }
 return self;
 }
 

@end
@implementation DTrace

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:self.gdCoordType forKey:@"gdCoordType"];
    [coder encodeObject:self.mDescription forKey:@"description"];
    [coder encodeObject:self.altitudeMode forKey:@"altitudeMode"];
    [coder encodeObject:self.coordinates forKey:@"coordinates"];
}

- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.gdCoordType = [coder decodeObjectForKey:@"gdCoordType"];
        self.mDescription = [coder decodeObjectForKey:@"description"];
        self.altitudeMode = [coder decodeObjectForKey:@"altitudeMode"];
        self.coordinates = [coder decodeObjectForKey:@"coordinates"];
    }
    return self;
}

- (id)init
{
    if (self = [super init])
    {
        _coordinates = [[NSMutableArray alloc] init];
       
    }
    return self;
}

- (void)dealloc
{
    [_gdCoordType release];
    [_mDescription release];
    [_altitudeMode release];
    [_coordinates release];
    [super dealloc];
}
@end



@implementation DTTS

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:self.gdCoordType forKey:@"gdCoordType"];
    [coder encodeInt:self.lon forKey:@"lon"];
    [coder encodeInt:self.lat forKey:@"lat"];
    [coder encodeObject:self.gdVoiceText forKey:@"gdVoiceText"];
}
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.gdCoordType = [coder decodeObjectForKey:@"gdCoordType"];
        self.gdVoiceText = [coder decodeObjectForKey:@"gdVoiceText"];
        self.lon = [coder decodeIntForKey:@"lon"];
        self.lat = [coder decodeIntForKey:@"lat"];
    }
    return self;
}

- (void)dealloc
{
    [_gdCoordType release];
    [_gdVoiceText release];
    [super dealloc];
}
@end


@implementation DTurnInfo

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:self.gdCoordType forKey:@"gdCoordType"];
    [coder encodeInt:self.lon forKey:@"lon"];
    [coder encodeInt:self.lat forKey:@"lat"];
    [coder encodeInt:self.gdTurn forKey:@"gdTurn"];
}
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.gdCoordType = [coder decodeObjectForKey:@"gdCoordType"];
        self.gdTurn = [coder decodeIntForKey:@"gdTurn"];
        self.lon = [coder decodeIntForKey:@"lon"];
        self.lat = [coder decodeIntForKey:@"lat"];
    }
    return self;
}

- (void)dealloc
{
    [_gdCoordType release];
    
    [super dealloc];
}

@end



@implementation DrivingTracks


- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.trace forKey:@"trace"];
    [coder encodeObject:self.ttsArray forKey:@"ttsArray"];
    [coder encodeObject:self.turnInfoArray forKey:@"turnInfoArray"];
    [coder encodeObject:self.yawArray forKey:@"yawArray"];
    [coder encodeObject:self.haccelerationArray forKey:@"haccelerationArray"];
    [coder encodeObject:self.brakesArray forKey:@"brakesArray"];
    [coder encodeObject:self.uturnArray forKey:@"uturnArray"];
    [coder encodeObject:self.hypervelocityArray forKey:@"hypervelocityArray"];
}
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.name = [coder decodeObjectForKey:@"name"];
        self.trace = [coder decodeObjectForKey:@"trace"];
        self.ttsArray = [coder decodeObjectForKey:@"ttsArray"];
        self.turnInfoArray = [coder decodeObjectForKey:@"turnInfoArray"];
        self.yawArray = [coder decodeObjectForKey:@"yawArray"];
        self.haccelerationArray = [coder decodeObjectForKey:@"haccelerationArray"];
        self.brakesArray = [coder decodeObjectForKey:@"brakesArray"];
        self.uturnArray = [coder decodeObjectForKey:@"uturnArray"];
        self.hypervelocityArray = [coder decodeObjectForKey:@"hypervelocityArray"];
    }
    return self;
}

- (id)init
{
    if (self = [super init])
    {
        _trace = [[DTrace alloc] init];
        _yawArray = [[NSMutableArray alloc] init];
        _ttsArray = [[NSMutableArray alloc] init];
        _turnInfoArray = [[NSMutableArray alloc] init];
        _haccelerationArray = [[NSMutableArray alloc] init];
        _brakesArray = [[NSMutableArray alloc] init];
        _uturnArray = [[NSMutableArray alloc] init];
        _hypervelocityArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_name release];
    [_trace release];
    [_ttsArray release];
    [_turnInfoArray release];
    [_yawArray release];
    [_haccelerationArray release];
    [_brakesArray release];
    [_uturnArray release];
    [_hypervelocityArray release];
    
    [super dealloc];
}
@end
