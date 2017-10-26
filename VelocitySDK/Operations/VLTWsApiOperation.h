//
//  VLTWsApiOperation.h
//  VelocitySDK iOS
//
//  Created by Vytautas Galaunia on 25/10/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTMotionDataOperation.h"
#import "VLTWsApiClient.h"

@interface VLTWsApiOperation : VLTMotionDataOperation

@property (nonnull, strong, readonly) VLTWsApiClient *wsApiClient;

- (nonnull instancetype)initWithMotionData:(nonnull NSArray<VLTData *> *)motionData
                               wsApiClient:(nonnull VLTWsApiClient *)wsApiClient;

@end
