//
//  VLTDetectOperation.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 17/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTDetectOperation.h"

@interface VLTDetectOperation ()

@property (nonatomic, strong) VLTPBDetectMotionRequest *motionRequest;

@end

@implementation VLTDetectOperation

- (instancetype)initWithMotionRequest:(VLTPBDetectMotionRequest *)motionRequest
{
    self = [super init];
    if (self) {
        _motionRequest = motionRequest;
    }
    return self;
}

- (void)start
{
    if ([self isCancelled]) {
        return;
    }

    [self markAsExecuting];
    [self processMotionRequest];
    if (![self isAsynchronous]) {
        [self markAsFinished];
    }
}

- (void)processMotionRequest
{
}

@end
