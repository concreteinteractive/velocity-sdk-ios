//
//  VLTMotionDetectOperation.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 17/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTDetectOperation.h"

@class VLTMotionDetectResult;

@interface VLTMotionDetectOperation : VLTDetectOperation

@property (atomic, strong, readonly) VLTMotionDetectResult *result;
@property (atomic, strong, readonly) NSError *error;

@property (atomic, copy) void(^onMotionDetect)(VLTMotionDetectResult *);
@property (atomic, copy) void(^onError)(NSError *);

@end
