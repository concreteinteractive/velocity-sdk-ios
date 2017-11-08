//
//  VLTMultiSensorRecorder.h
//  Velocity
//
//  
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import "VLTSensorRecorder.h"
#import "VLTMotionRecorder.h"

@interface VLTMultiMotionRecorder : NSObject<VLTMotionRecorder>

@property (nonatomic, readonly, nonnull) NSArray<id<VLTMotionRecorder>> * motionRecorders;

- (nonnull instancetype)initWithMotionRecorders:(nonnull NSArray<id<VLTMotionRecorder>> *)motionRecorders NS_DESIGNATED_INITIALIZER;

@end
