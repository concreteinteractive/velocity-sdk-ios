//
//  VLTDrivingDetectOperation.h
//  VelocitySDK
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLTHTTPMotionDetectOperation.h"

@interface VLTDrivingDetectOperation : VLTMotionDataOperation

@property (atomic, assign, readonly) float speedThreshold;
@property (atomic, assign, readonly) float averageSpeed;
@property (atomic, assign, readonly) BOOL isDriving;

@end
