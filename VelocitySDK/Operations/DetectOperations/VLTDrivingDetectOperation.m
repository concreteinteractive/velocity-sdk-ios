//
//  VLTDrivingDetectOperation.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 16/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTDrivingDetectOperation.h"
#import "Velocity.pb.h"
#import "VLTSampleBuilder.h"

static Float32 VLTSpeedThreshold = 20;

@interface VLTDrivingDetectOperation ()

@property (atomic, assign) Float32 speedThreshold;
@property (atomic, assign) Float32 averageSpeed;
@property (atomic, assign) BOOL isDriving;

@end

@implementation VLTDrivingDetectOperation

- (void)processMotionRequest
{
    self.speedThreshold = VLTSpeedThreshold;

    NSArray<VLTPBSensor *> *sensors = [self.motionRequest sensors];

    NSUInteger gpsSensorIndex = [sensors indexOfObjectPassingTest:^BOOL(VLTPBSensor * sensor, NSUInteger idx, BOOL *stop) {
        return sensor.type == VLTPBSensorTypeGps;
    }];

    if (gpsSensorIndex == NSNotFound) {
        return;
    }

    VLTPBSensor *gpsSensor = sensors[gpsSensorIndex];


    Float32 sum = 0;
    for (VLTPBSample *sample in gpsSensor.samples) {
        sum += [self speedFromSample:sample];
    }

    self.averageSpeed = sum/gpsSensor.samples.count;
    self.isDriving = self.averageSpeed >= self.speedThreshold;
}

- (Float32)speedFromSample:(VLTPBSample *)sample
{
    if (sample.values.count > VLTPBSampleSpeedIndex) {
        Float32 speed = [sample valuesAtIndex:VLTPBSampleSpeedIndex];
        if (speed > 0) {
            return speed;
        }
    }
    return 0.0;
}

@end
