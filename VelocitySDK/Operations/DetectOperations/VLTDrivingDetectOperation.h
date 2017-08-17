//
//  VLTDrivingDetectOperation.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 16/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLTDetectOperation.h"

@interface VLTDrivingDetectOperation : VLTDetectOperation

@property (atomic, assign, readonly) Float32 speedThreshold;
@property (atomic, assign, readonly) Float32 averageSpeed;
@property (atomic, assign, readonly) BOOL isDriving;

@end
