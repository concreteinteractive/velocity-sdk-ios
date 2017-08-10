//
//  VLTGPSSensorRecorder.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 10/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTGPSSensorRecorder.h"
#import <CoreLocation/CoreLocation.h>
#import "VLTGPS.h"
#import "VLTSampleBuilder.h"

@implementation VLTGPSSensorRecorder

- (instancetype)initWithUpdateInterval:(NSTimeInterval)interval
                          timeInBuffer:(NSTimeInterval)timeInBuffer
{
    self = [super initWithUpdateInterval:interval timeInBuffer:timeInBuffer sensorType:VLTSensorTypeGPS];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didUpdateLocations:)
                                                     name:VLTGPSLocationUpdateNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didUpdateLocations:(NSNotification *)notification
{
    NSArray<CLLocation *> *locations = notification.userInfo[VLTGPSLocationsKey];
    for (CLLocation *location in locations) {
        id <VLTSample> sample = [VLTSampleBuilder sampleFrom:location];
        [self addSample:sample];
    }
}

- (void)startRecording
{
}

- (void)stopRecording
{
}

- (NSTimeInterval)availableTimeInBuffer
{
    return DBL_MAX;
}

@end
