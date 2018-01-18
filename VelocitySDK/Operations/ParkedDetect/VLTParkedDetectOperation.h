//
//  VLTParkedDetectOperation.h
//  VelocitySDK
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTMotionDataOperation.h"

@class VLTMotionDetectResult;

@interface VLTParkedDetectOperation : VLTMotionDataOperation

@property (atomic, strong, readonly, nullable) VLTMotionDetectResult *result;
@property (atomic, strong, readonly, nullable) NSError *error;

@property (atomic, copy, nullable) void (^onMotionDetect)(VLTMotionDetectResult *_Nonnull);
@property (atomic, copy, nullable) void (^onError)(NSError *_Nonnull);

@end
