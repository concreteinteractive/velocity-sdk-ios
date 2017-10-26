//
//  VLTWsMotionDetectOperation.h
//  VelocitySDK iOS
//
//  Created by Vytautas Galaunia on 25/10/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTOperation.h"
#import "VLTMotionDetect.h"
#import "VLTWsApiOperation.h"

@interface VLTWsMotionDetectOperation : VLTWsApiOperation  <VLTMotionDetect>

@property (atomic, strong, readonly, nullable) VLTMotionDetectResult *result;
@property (atomic, strong, readonly, nullable) NSError *error;
@property (atomic, copy, nullable) void(^onMotionDetect)(VLTMotionDetectResult * _Nonnull);
@property (atomic, copy, nullable) void(^onError)(NSError * _Nonnull);

@end
