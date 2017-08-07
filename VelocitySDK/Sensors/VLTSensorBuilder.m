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

@implementation VLTSensorBuilder

+ (nonnull id<VLTMotionRecorder>)buildRecorder
{
    NSTimeInterval updateInterval = [VLTConfig sensorsUpdateInterval];
    NSTimeInterval bufferSize = [VLTConfig sensorsBufferSize];
    VLTAccSensorRecorder *accRecorder = [[VLTAccSensorRecorder alloc] initWithUpdateInterval:updateInterval
                                                                                timeInBuffer:bufferSize];
    VLTGyroSensorRecorder *gyroRecorder = [[VLTGyroSensorRecorder alloc] initWithUpdateInterval:updateInterval
                                                                                   timeInBuffer:bufferSize];
    return [[VLTMultiMotionRecorder alloc] initWithMotionRecorders:@[accRecorder, gyroRecorder]];
}

@end
