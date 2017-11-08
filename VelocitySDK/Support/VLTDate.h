//
//  VLTDate.h
//  Velocity
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <Foundation/Foundation.h>

@interface VLTDate : NSObject

+ (nonnull NSDate *)dateWithTimeIntervalFromSystemBoot:(NSTimeInterval)timeInterval;

+ (NSTimeInterval)timeIntervalSince1970FromAccelerometerData:(nonnull CMAccelerometerData *)data;
+ (NSTimeInterval)timeIntervalSince1970FromGyroData:(nonnull CMGyroData *)data;
+ (NSTimeInterval)timeIntervalSince1970FromDeviceMotion:(nonnull CMDeviceMotion *)motion;

@end
