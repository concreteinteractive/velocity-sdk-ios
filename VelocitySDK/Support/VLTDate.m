//
//  VLTDate.m
//  Velocity
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTDate.h"

@implementation VLTDate

+ (NSDate *)dateWithTimeIntervalFromSystemBoot:(NSTimeInterval)timeInterval
{
    return [NSDate dateWithTimeIntervalSinceNow:timeInterval - [[NSProcessInfo processInfo] systemUptime]];
}

+ (NSTimeInterval)timeIntervalSince1970FromAccelerometerData:(CMAccelerometerData *)data
{
    return [[VLTDate dateWithTimeIntervalFromSystemBoot:data.timestamp] timeIntervalSince1970];
}

+ (NSTimeInterval)timeIntervalSince1970FromGyroData:(CMGyroData *)data
{
    return [[VLTDate dateWithTimeIntervalFromSystemBoot:data.timestamp] timeIntervalSince1970];
}

+ (NSTimeInterval)timeIntervalSince1970FromDeviceMotion:(CMDeviceMotion *)motion
{
    return [[VLTDate dateWithTimeIntervalFromSystemBoot:motion.timestamp] timeIntervalSince1970];
}

@end
