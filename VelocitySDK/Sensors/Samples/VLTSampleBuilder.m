//
//  VLTSampleBuilder.m
//  Velocity
//
//  Created by Vytautas Galaunia on 21/10/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import "VLTSampleBuilder.h"
#import <CoreMotion/CoreMotion.h>
#import "VLTSimpleSample.h"
#import "VLTDate.h"

@implementation VLTSampleBuilder

+ (nonnull id<VLTSample>)sampleFrom:(id)sourceData
{
    if ([sourceData isKindOfClass:[CMAccelerometerData class]]) {
        return [VLTSampleBuilder fromAccelerometerData:(CMAccelerometerData *)sourceData];
    } else if ([sourceData isKindOfClass:[CMGyroData class]]) {
        return [VLTSampleBuilder fromGyroData:(CMGyroData *)sourceData];
    } else if ([sourceData isKindOfClass:[CMDeviceMotion class]]) {
        return [VLTSampleBuilder fromDeviceMotion:(CMDeviceMotion *)sourceData];
    } else {
        NSLog(@"VLTSampleBuilder RETURNING EMPTY SAMPLE AS TYPE IS NOT SUPPORTED.");
        return [VLTSampleBuilder emptySample];
    }
}

+ (nonnull id<VLTSample>)emptySample
{
    return [[VLTSimpleSample alloc] init];
}

+ (nonnull id<VLTSample>)fromAccelerometerData:(CMAccelerometerData *)data
{
    return [[VLTSimpleSample alloc] initWithTimestamp:[VLTDate timeIntervalSince1970FromAccelerometerData:data]
                                                    x:data.acceleration.x
                                                    y:data.acceleration.y
                                                    z:data.acceleration.z];
}

+ (nonnull id<VLTSample>)fromGyroData:(CMGyroData *)data
{
    return [[VLTSimpleSample alloc] initWithTimestamp:[VLTDate timeIntervalSince1970FromGyroData:data]
                                                    x:data.rotationRate.x
                                                    y:data.rotationRate.y
                                                    z:data.rotationRate.z];
}

+ (nonnull id<VLTSample>)fromDeviceMotion:(CMDeviceMotion *)data
{
    return [[VLTSimpleSample alloc] initWithTimestamp:[VLTDate timeIntervalSince1970FromDeviceMotion:data]
                                                    x:data.userAcceleration.x
                                                    y:data.userAcceleration.y
                                                    z:data.userAcceleration.z];
}

@end
