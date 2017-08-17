//
//  VLTCaptureOperation.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 17/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTCaptureOperation.h"

@interface VLTCaptureOperation ()

@property (nonatomic, strong) VLTPBCapture *captureRequest;

@end

@implementation VLTCaptureOperation

- (instancetype)initWithCaptureRequest:(VLTPBCapture *)captureRequest
{
    self = [super init];
    if (self) {
        _captureRequest = captureRequest;
    }
    return self;
}

- (void)start
{
    if ([self isCancelled]) {
        return;
    }

    [self markAsExecuting];
    [self processCaptureRequest];
    if (![self isAsynchronous]) {
        [self markAsFinished];
    }
}

- (void)processCaptureRequest
{
}


@end
