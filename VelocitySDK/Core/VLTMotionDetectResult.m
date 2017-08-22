//
//  VLTMotionDetectResult.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 17/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTMotionDetectResult.h"

NSString * const VLTMotionDetectResultWalkingKey = @"walking";
NSString * const VLTMotionDetectResultDrivingKey = @"driving";
NSString * const VLTMotionDetectResultParkedKey = @"parked";

@interface VLTMotionDetectResult ()

@property (nonatomic) NSDate *timestamp;
@property (nonatomic, getter=isWalking) BOOL walking;
@property (nonatomic, getter=isDriving) BOOL driving;
@property (nonatomic, getter=isParked) BOOL parked;

@end

@implementation VLTMotionDetectResult

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _timestamp = [NSDate date];
        _walking = [dict[VLTMotionDetectResultWalkingKey] boolValue] ?: false;
        _driving = [dict[VLTMotionDetectResultDrivingKey] boolValue] ?: false;
        _parked = [dict[VLTMotionDetectResultParkedKey] boolValue] ?: false;
    }
    return self;
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
