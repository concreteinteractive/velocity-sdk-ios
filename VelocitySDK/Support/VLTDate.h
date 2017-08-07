//
//  VLTDate.h
//  Velocity
//
//  Created by Vytautas Galaunia on 24/01/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface VLTDate : NSObject

+ (nonnull NSDate *)dateWithTimeIntervalFromSystemBoot:(NSTimeInterval)timeInterval;

+ (NSTimeInterval)timeIntervalSince1970FromAccelerometerData:(nonnull CMAccelerometerData *)data;
+ (NSTimeInterval)timeIntervalSince1970FromGyroData:(nonnull CMGyroData *)data;
+ (NSTimeInterval)timeIntervalSince1970FromDeviceMotion:(nonnull CMDeviceMotion *)motion;

@end
