//
//  VLTCoreMotionActivityTracker.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 23/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface VLTCoreMotionActivityTracker : NSObject

@property (atomic, assign, getter=isEnabled) BOOL enabled;
@property (atomic, strong, readonly) CMMotionActivity *recentActivity;

+ (instancetype)shared;

@end
