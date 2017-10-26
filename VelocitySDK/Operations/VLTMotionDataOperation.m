//
//  VLTMotionDataOperation.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 21/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTMotionDataOperation.h"
#import "VLTData.h"

@interface VLTMotionDataOperation ()

@property (nonatomic, strong, nonnull) NSArray<VLTData *> *motionData;

@end

@implementation VLTMotionDataOperation

- (nonnull instancetype)initWithMotionData:(nonnull NSArray<VLTData *> *)motionData
{
    self = [super init];
    if (self) {
        _motionData = motionData;
    }
    return self;
}

- (void)start
{
    if ([self isCancelled]) {
        return;
    }

    [self markAsExecuting];
    [self processMotionData];
    if (![self isAsynchronous]) {
        [self markAsFinished];
    }
}

- (void)processMotionData
{
    
}

@end
