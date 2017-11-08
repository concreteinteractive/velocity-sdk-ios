//
//  VLTCoreMotionActivityTracker.h
//  VelocitySDK
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <Foundation/Foundation.h>

@interface VLTCoreMotionActivityTracker : NSObject

@property (atomic, assign, getter=isEnabled) BOOL enabled;
@property (atomic, strong, readonly) CMMotionActivity *recentActivity;

+ (instancetype)shared;

@end
