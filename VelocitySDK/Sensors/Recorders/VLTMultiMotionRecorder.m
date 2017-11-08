//
//  VLTMultiSensorRecorder.m
//  Velocity
//
//
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import "VLTMultiMotionRecorder.h"

@interface VLTMultiMotionRecorder ()

@property (nonatomic, strong) NSArray<id<VLTMotionRecorder>> *motionRecorders;

@end

@implementation VLTMultiMotionRecorder

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)init
{
    @throw
        [NSException exceptionWithName:@"NOT_SUPPORTED" reason:@"PLEASE USE: -initWithMotionRecorders:" userInfo:nil];
}
#pragma clang diagnostic pop

- (nonnull instancetype)initWithMotionRecorders:(nonnull NSArray<id<VLTMotionRecorder>> *)motionRecorders
{
    self = [super init];
    if (self) {
        _motionRecorders = motionRecorders;
    }
    return self;
}

- (void)startRecording
{
    for (id<VLTMotionRecorder> recorder in self.motionRecorders) {
        [recorder startRecording];
    }
}

- (void)stopRecording
{
    for (id<VLTMotionRecorder> recorder in self.motionRecorders) {
        [recorder stopRecording];
    }
}

- (NSTimeInterval)availableTimeInBuffer
{
    NSTimeInterval result = DBL_MAX;
    for (id<VLTMotionRecorder> r in self.motionRecorders) {
        result = MIN(result, [r availableTimeInBuffer]);
    }
    return result;
}

- (nonnull NSArray<VLTData *> *)dataForTimeInterval:(NSTimeInterval)interval
{
    NSMutableArray<VLTData *> *results = [[NSMutableArray alloc] init];
    for (id<VLTMotionRecorder> recorder in self.motionRecorders) {
        NSArray<VLTData *> *dataList = [recorder dataForTimeInterval:interval];
        [results addObjectsFromArray:dataList];
    }
    return results;
}

@end
