//
//  VLTSensorBuilder.m
//  Velocity
//
//  Created by Vytautas Galaunia on 21/10/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import "VLTSensorBuilder.h"
#import "VLTMultiMotionRecorder.h"
#import "VLTAccSensorRecorder.h"
#import "VLTGyroSensorRecorder.h"
#import "VLTConfig.h"
#import "VLTSimulatorSensorRecorder.h"
#import "VLTSensorTypes.h"
#import "VLTGPSSensorRecorder.h"
#import "VLTGPS.h"

static NSTimeInterval MinGPSBufferSizeInSec = 300;

@implementation VLTSensorBuilder

+ (BOOL)isSimulator
{
#if TARGET_OS_SIMULATOR
    return YES;
#else 
    return NO;
#endif
}

+ (nonnull id<VLTMotionRecorder>)buildSimulatorRecorder
{
    NSTimeInterval updateInterval = [VLTConfig sensorsUpdateInterval];
    NSTimeInterval bufferSize = [VLTConfig sensorsBufferSize];
    VLTSimulatorSensorRecorder *accRecorder;
    accRecorder = [[VLTSimulatorSensorRecorder alloc] initWithUpdateInterval:updateInterval
                                                                timeInBuffer:bufferSize
                                                                  sensorType:VLTSensorTypeAcc];
    VLTSimulatorSensorRecorder *gyroRecorder;
    gyroRecorder = [[VLTSimulatorSensorRecorder alloc] initWithUpdateInterval:updateInterval
                                                                 timeInBuffer:bufferSize
                                                                   sensorType:VLTSensorTypeGyro];
    NSMutableArray<VLTSensorRecorder *> *recorders = [[NSMutableArray alloc] init];
    [recorders addObject:accRecorder];
    [recorders addObject:gyroRecorder];

    if ([VLTGPS isEnabled]) {
        VLTGPSSensorRecorder *gpsRecorder = [[VLTGPSSensorRecorder alloc] initWithUpdateInterval:updateInterval
                                                                                    timeInBuffer:MAX(bufferSize, MinGPSBufferSizeInSec)];
        [recorders addObject:gpsRecorder];
    }

    return [[VLTMultiMotionRecorder alloc] initWithMotionRecorders:recorders];
}

+ (nonnull id<VLTMotionRecorder>)buildRealDeviceRecorder
{
    NSTimeInterval updateInterval = [VLTConfig sensorsUpdateInterval];
    NSTimeInterval bufferSize = [VLTConfig sensorsBufferSize];
    VLTAccSensorRecorder *accRecorder = [[VLTAccSensorRecorder alloc] initWithUpdateInterval:updateInterval
                                                                                timeInBuffer:bufferSize];
    VLTGyroSensorRecorder *gyroRecorder = [[VLTGyroSensorRecorder alloc] initWithUpdateInterval:updateInterval
                                                                                   timeInBuffer:bufferSize];

    NSMutableArray<VLTSensorRecorder *> *recorders = [[NSMutableArray alloc] init];
    [recorders addObject:accRecorder];
    [recorders addObject:gyroRecorder];

    if ([VLTGPS isEnabled]) {
        VLTGPSSensorRecorder *gpsRecorder = [[VLTGPSSensorRecorder alloc] initWithUpdateInterval:updateInterval
                                                                                    timeInBuffer:MAX(bufferSize, MinGPSBufferSizeInSec)];
        [recorders addObject:gpsRecorder];
    }
    return [[VLTMultiMotionRecorder alloc] initWithMotionRecorders:recorders];
}

+ (nonnull id<VLTMotionRecorder>)buildRecorder
{
    if ([VLTSensorBuilder isSimulator]) {
        return [VLTSensorBuilder buildSimulatorRecorder];
    } else {
        return [VLTSensorBuilder buildRealDeviceRecorder];
    }

}

@end
