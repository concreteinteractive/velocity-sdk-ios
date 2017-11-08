//
//  VLTMotionDataOperation.h
//  VelocitySDK
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTOperation.h"

@class VLTData;

@interface VLTMotionDataOperation : VLTOperation

@property (nonatomic, strong, readonly, nonnull) NSArray<VLTData *> *motionData;

- (nonnull instancetype)initWithMotionData:(nonnull NSArray<VLTData *> *)motionData;
- (void)processMotionData;

@end
