//
//  VLTDeviceMotionRecorder.m
//  Velocity
//
//  Created by Antanas Majus on 10/25/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import "VLTAccDMSensorRecorder.h"
#import <CoreMotion/CMMotionManager.h>
#import "VLTCore.h"
#import "VLTSampleBuilder.h"

@interface VLTAccDMSensorRecorder ()

@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation VLTAccDMSensorRecorder

- (instancetype)initWithUpdateInterval:(NSTimeInterval)interval timeInBuffer:(NSTimeInterval)timeInBuffer
{
    self = [super initWithUpdateInterval:interval timeInBuffer:timeInBuffer sensorType:VLTSensorTypeDmAcc];
    if (self) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return self;
}

- (void)startRecording
{
    __weak VLTAccDMSensorRecorder *weakSelf = self;
    self.motionManager.deviceMotionUpdateInterval = self.updateInterval;
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical
                                                            toQueue:[VLTCore queue]
                                                        withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
                                                            if (motion) {
                                                                id <VLTSample> sample = [VLTSampleBuilder sampleFrom:motion];
                                                                [weakSelf addSample:sample];
                                                            }
                                                        }];
}

- (void)stopRecording
{
    [self.motionManager stopDeviceMotionUpdates];
}

@end
