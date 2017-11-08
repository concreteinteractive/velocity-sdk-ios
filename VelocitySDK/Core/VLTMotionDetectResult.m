//
//  VLTMotionDetectResult.m
//  VelocitySDK
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTMotionDetectResult.h"

NSString *const VLTMotionDetectResultWalkingKey = @"walking";
NSString *const VLTMotionDetectResultDrivingKey = @"driving";
NSString *const VLTMotionDetectResultParkedKey  = @"parked";

@interface VLTMotionDetectResult ()

@property (nonatomic) NSDate *timestamp;
@property (nonatomic, getter=isWalking) BOOL walking;
@property (nonatomic, getter=isDriving) BOOL driving;
@property (nonatomic, getter=isParked) BOOL parked;

@end

@implementation VLTMotionDetectResult

- (nonnull instancetype)initWithWalking:(BOOL)walking driving:(BOOL)driving parked:(BOOL)parked;
{
    self = [super init];
    if (self) {
        _timestamp = [NSDate date];
        _walking   = walking;
        _driving   = driving;
        _parked    = parked;
    }
    return self;
}

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict
{
    BOOL walking = [dict[VLTMotionDetectResultWalkingKey] boolValue] ?: false;
    BOOL driving = [dict[VLTMotionDetectResultDrivingKey] boolValue] ?: false;
    BOOL parked  = [dict[VLTMotionDetectResultParkedKey] boolValue] ?: false;
    return [self initWithWalking:walking driving:driving parked:parked];
}

- (nonnull NSDictionary *)toDictionary
{
    return @{
        VLTMotionDetectResultWalkingKey: @(self.isWalking),
        VLTMotionDetectResultDrivingKey: @(self.isDriving),
        VLTMotionDetectResultParkedKey: @(self.isParked),
    };
}

@end
