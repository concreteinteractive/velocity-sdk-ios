//
//  VLTHTTPMotionDetectOperation.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 17/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTMotionDataOperation.h"
#import "VLTMotionDetect.h"

@class VLTMotionDetectResult;

@interface VLTHTTPMotionDetectOperation : VLTMotionDataOperation <VLTMotionDetect>

@property (atomic, strong, readonly, nullable) VLTMotionDetectResult *result;
@property (atomic, strong, readonly, nullable) NSError *error;
@property (atomic, copy, nullable) void(^onMotionDetect)(VLTMotionDetectResult * _Nonnull);
@property (atomic, copy, nullable) void(^onError)(NSError * _Nonnull);

@property (nonatomic, assign, readonly) UInt32 sequenceIndex;

- (nonnull instancetype)initWithMotionData:(nonnull NSArray<VLTData *> *)motionData sequenceIndex:(UInt32)sequenceIndex;

@end
