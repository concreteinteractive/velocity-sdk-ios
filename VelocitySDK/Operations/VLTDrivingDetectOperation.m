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
#import "VLTData.h"
#import "VLTSample.h"
#import <CoreLocation/CoreLocation.h>

static Float32 VLTSpeedThreshold = 4;

@interface VLTDrivingDetectOperation ()

@property (atomic, assign) float speedThreshold;
@property (atomic, assign) float averageSpeed;
@property (atomic, assign) BOOL isDriving;

@end

@implementation VLTDrivingDetectOperation

- (void)processMotionData
{
    self.speedThreshold = VLTSpeedThreshold;

    NSUInteger gpsDataIndex = [self.motionData indexOfObjectPassingTest:^BOOL(VLTData *data, NSUInteger idx, BOOL *stop) {
        return data.sensorType == VLTPBSensorTypeGps;
    }];

    if (gpsDataIndex == NSNotFound) {
        return;
    }

    VLTData *gpsData = self.motionData[gpsDataIndex];

    CLLocation *prevLocation = nil;
    double totalDistance = 0;
    NSTimeInterval totalTimeInSec = 0;
    for (id<VLTSample> sample in gpsData.values) {
        CLLocation *location = [self locationFromSample:sample];

        if (location.horizontalAccuracy < 0) {
            continue;
        }
        
        if (prevLocation) {
            totalDistance += [location distanceFromLocation:prevLocation];
            totalTimeInSec += fabs([location.timestamp timeIntervalSinceDate:prevLocation.timestamp]);
        }
        prevLocation = location;
    }
    self.averageSpeed = totalDistance / totalTimeInSec;
    self.isDriving = self.averageSpeed >= self.speedThreshold;
}

- (CLLocation *)locationFromSample:(id<VLTSample>)sample
{
    if (sample.values.count < VLTLocationSampleValuesCount) {
        return nil;
    }

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:sample.timestamp];
    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake([sample.values[VLTSampleLatitudeIndex] doubleValue],
                                                               [sample.values[VLTSampleLongitudeIndex] doubleValue]);
    CLLocationDistance altitude = [sample.values[VLTSampleAltitudeIndex] doubleValue];
    CLLocationAccuracy hAccuracy = [sample.values[VLTSampleHorizontalAccuracyIndex] doubleValue];
    CLLocationSpeed speed = [sample.values[VLTSampleSpeedIndex] doubleValue];
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:coords
                                                         altitude:altitude
                                               horizontalAccuracy:hAccuracy
                                                 verticalAccuracy:kCLLocationAccuracyThreeKilometers
                                                           course:-1.0
                                                            speed:speed
                                                        timestamp:date];
    return location;
}

- (float)speedFromSample:(id<VLTSample>)sample
{
    if (sample.values.count > VLTSampleSpeedIndex) {
        return [sample.values[VLTSampleSpeedIndex] floatValue];
    }
    return -1.0;
}

@end
