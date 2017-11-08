//
//  VLTAccSensorRecorder.m
//  Velocity
//
//
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import "VLTAccSensorRecorder.h"
#import <CoreMotion/CoreMotion.h>
#import "VLTCore.h"
#import "VLTSampleBuilder.h"

@interface VLTAccSensorRecorder ()

@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation VLTAccSensorRecorder

- (instancetype)initWithUpdateInterval:(NSTimeInterval)interval timeInBuffer:(NSTimeInterval)timeInBuffer
{
    self = [super initWithUpdateInterval:interval timeInBuffer:timeInBuffer sensorType:VLTSensorTypeAcc];
    if (self) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return self;
}

- (void)startRecording
{
    self.motionManager.accelerometerUpdateInterval = self.updateInterval;
    __weak VLTAccSensorRecorder *weakSelf          = self;
    [self.motionManager
        startAccelerometerUpdatesToQueue:[VLTCore queue]
                             withHandler:^(CMAccelerometerData *_Nullable accelerometerData, NSError *_Nullable error) {
                                 if (accelerometerData) {
                                     id<VLTSample> sample = [VLTSampleBuilder sampleFrom:accelerometerData];
                                     [weakSelf addSample:sample];
                                 }
                             }];
}

- (void)stopRecording
{
    [_motionManager stopAccelerometerUpdates];
}

@end
