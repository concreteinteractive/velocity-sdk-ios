//
//  VLTWsApiOperation.m
//  VelocitySDK iOS
//
//  Created by Vytautas Galaunia on 25/10/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
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
