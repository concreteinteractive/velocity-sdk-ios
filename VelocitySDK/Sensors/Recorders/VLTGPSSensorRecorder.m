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
#import "VLTData.h"
#import "VLTSample.h"

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

- (nonnull NSArray<VLTData *> *)dataForTimeInterval:(NSTimeInterval)interval
{
    NSArray<VLTData *> *datas = [super dataForTimeInterval:DBL_MAX];

    VLTData *gpsData = datas.firstObject;
    if (!gpsData) {
        return [super dataForTimeInterval:interval];
    }

    NSMutableArray <id<VLTSample>> *newResults = [gpsData.values mutableCopy];

    id<VLTSample> lastSample = newResults.lastObject;
    if (lastSample) {
        NSTimeInterval timestampLimit = lastSample.timestamp - interval;

        id<VLTSample> sample = newResults.firstObject;
        while (newResults.count > 2 && sample.timestamp < timestampLimit ) {
            [newResults removeObjectAtIndex:0];
            sample = newResults.firstObject;
        }
    }

    VLTData *data = [[VLTData alloc] initWithSensorType:gpsData.sensorType
                                                 values:newResults];
    return @[data];
}

- (NSTimeInterval)availableTimeInBuffer
{
    return DBL_MAX;
}

@end
