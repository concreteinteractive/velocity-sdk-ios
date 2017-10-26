//
//  VLTDrivingDetectOperation.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 16/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLTHTTPMotionDetectOperation.h"

@interface VLTDrivingDetectOperation : VLTMotionDataOperation

@property (atomic, assign, readonly) float speedThreshold;
@property (atomic, assign, readonly) float averageSpeed;
@property (atomic, assign, readonly) BOOL isDriving;

@end
