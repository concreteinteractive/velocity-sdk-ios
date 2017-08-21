//
//  VLTMotionDataOperation.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 21/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTOperation.h"

@class VLTData;

@interface VLTMotionDataOperation : VLTOperation

@property (nonatomic, strong, readonly, nonnull) NSArray<VLTData *> *motionData;

- (nonnull instancetype)initWithMotionData:(nonnull NSArray<VLTData *> *)motionData;

- (void)processMotionData;

@end
