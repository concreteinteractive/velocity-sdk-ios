//
//  VLTWsApiOperation.m
//  VelocitySDK iOS
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTWsApiOperation.h"

@implementation VLTWsApiOperation

- (nonnull instancetype)initWithMotionData:(nonnull NSArray<VLTData *> *)motionData
                               wsApiClient:(VLTWsApiClient *)wsApiClient
{
    self = [super initWithMotionData:motionData];
    if (self) {
        _wsApiClient = wsApiClient;
    }
    return self;
}

@end
