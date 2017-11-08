//
//  VLTWsApiOperation.h
//  VelocitySDK iOS
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTMotionDataOperation.h"
#import "VLTWsApiClient.h"

@interface VLTWsApiOperation : VLTMotionDataOperation

@property (nonnull, strong, readonly) VLTWsApiClient *wsApiClient;

- (nonnull instancetype)initWithMotionData:(nonnull NSArray<VLTData *> *)motionData
                               wsApiClient:(nonnull VLTWsApiClient *)wsApiClient;

@end
