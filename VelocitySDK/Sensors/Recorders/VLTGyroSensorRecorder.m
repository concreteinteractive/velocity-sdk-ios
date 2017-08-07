//
//  VLTGyroSensorRecorder.m
//  Velocity
//
//  Created by Vytautas Galaunia on 21/10/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import "VLTGyroSensorRecorder.h"
#import <CoreMotion/CoreMotion.h>
#import "VLTSampleBuilder.h"
#import "VLTCore.h"

@interface VLTGyroSensorRecorder ()

@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation VLTGyroSensorRecorder

- (instancetype)initWithUpdateInterval:(NSTimeInterval)interval timeInBuffer:(NSTimeInterval)timeInBuffer
{
    self = [super initWithUpdateInterval:interval timeInBuffer:timeInBuffer sensorType:VLTSensorTypeGyro];
    if (self) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return self;
}

- (void)startRecording
{
    __weak VLTGyroSensorRecorder *weakSelf = self;
    self.motionManager.gyroUpdateInterval = self.updateInterval;
    [self.motionManager startGyroUpdatesToQueue:[VLTCore queue]
                                    withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
                                        if (gyroData) {
                                            id <VLTSample> sample = [VLTSampleBuilder sampleFrom:gyroData];
                                            [weakSelf addSample:sample];
                                        }
                                    }];
}

- (void)stopRecording
{
    [_motionManager stopGyroUpdates];
}

@end
