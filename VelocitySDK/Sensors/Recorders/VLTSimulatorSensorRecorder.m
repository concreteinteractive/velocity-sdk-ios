//
//  VLTSimulatorSensorRecorder.m
//  VelocitySDK
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTSimulatorSensorRecorder.h"
#import "VLTSensorTypes.h"
#import "VLTCore.h"
#import "VLTMacros.h"
#import "VLTSampleBuilder.h"

@interface VLTSimulatorSensorRecorder ()

@property (nonatomic, strong) dispatch_source_t timer;


@end

@implementation VLTSimulatorSensorRecorder

- (instancetype)initWithUpdateInterval:(NSTimeInterval)interval
                          timeInBuffer:(NSTimeInterval)timeInBuffer
                            sensorType:(VLTSensorType)type
{
    return [super initWithUpdateInterval:interval timeInBuffer:timeInBuffer sensorType:type];
}

- (void)startRecording
{
    vlt_weakify(self);
    self.timer = [VLTCore timer:0.01 handler:^{
        vlt_strongify(self);
        [self addSample:[VLTSampleBuilder simulatorSample]];
    }];
}

- (void)stopRecording
{
    dispatch_source_cancel(self.timer);
    self.timer = nil;
}

@end
