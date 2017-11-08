//
//  VLTData.m
//  Velocity
//
//
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import "VLTData.h"
#import "VLTSensorRecorder.h"

@interface VLTData ()

@property (nonatomic, assign) VLTSensorType sensorType;
@property (nonatomic, strong, nonnull) NSArray<id<VLTSample>> *values;

@end

@implementation VLTData

- (nonnull instancetype)initWithSensorType:(VLTSensorType)sensorType values:(nonnull NSArray<id<VLTSample>> *)values
{
    self = [super init];
    if (self) {
        _sensorType = sensorType;
        _values     = values;
    }
    return self;
}

@end
