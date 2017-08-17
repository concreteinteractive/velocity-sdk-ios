//
//  VLTDetectOperation.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 17/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTOperation.h"

@class VLTPBDetectMotionRequest;

@interface VLTDetectOperation : VLTOperation

@property (nonatomic, strong, readonly, nonnull) VLTPBDetectMotionRequest *motionRequest;

- (nonnull instancetype)initWithMotionRequest:(nonnull VLTPBDetectMotionRequest *)motionRequest;

- (void)processMotionRequest;

@end
