//
//  VLTSensorRecorder.m
//  Velocity
//
//
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import "VLTSensorRecorder.h"
#import "VLTData.h"

@interface VLTSensorRecorder ()

@property (nonatomic, assign) NSTimeInterval updateInterval;
@property (nonatomic, assign) NSTimeInterval keepTimeInBuffer;
@property (nonatomic, assign) NSTimeInterval availableTimeInBuffer;
@property (nonatomic, strong) NSMutableArray<id<VLTSample>> *buffer;
@property (nonatomic) dispatch_queue_t concurrent_queue;

@end

@implementation VLTSensorRecorder

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"NOT_SUPPORTED"
                                   reason:@"PLEASE USE: -initWithUpdateInterval:timeInBuffer:"
                                 userInfo:nil];
}
#pragma clang diagnostic pop

- (instancetype)initWithUpdateInterval:(NSTimeInterval)interval timeInBuffer:(NSTimeInterval)timeInBuffer
{
    return [self initWithUpdateInterval:interval timeInBuffer:timeInBuffer sensorType:VLTSensorTypeNotSpecified];
}

- (instancetype)initWithUpdateInterval:(NSTimeInterval)interval
                          timeInBuffer:(NSTimeInterval)timeInBuffer
                            sensorType:(VLTSensorType)type
{
    self = [super init];
    if (self) {
        _sensorType       = type;
        _updateInterval   = interval;
        _keepTimeInBuffer = timeInBuffer;
        _buffer           = [[NSMutableArray alloc] init];
        _concurrent_queue = dispatch_queue_create("net.vlcty.recorder", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)startRecording {}

- (void)stopRecording {}

- (void)addSample:(nonnull id<VLTSample>)sample
{
    dispatch_barrier_async(self.concurrent_queue, ^{
        id<VLTSample> firstSample = self.buffer.firstObject;

        [self.buffer addObject:sample];

        if (firstSample) {
            while (sample.timestamp - firstSample.timestamp > self.keepTimeInBuffer && self.buffer.count > 0) {
                [self.buffer removeObjectAtIndex:0];
                firstSample = self.buffer.firstObject;
            }
        }

        if (firstSample) {
            self.availableTimeInBuffer = sample.timestamp - firstSample.timestamp;
        } else {
            self.availableTimeInBuffer = 0.0;
        }
    });
}

- (NSArray<id<VLTSample>> *)copiedSamples
{
    __block NSArray<id<VLTSample>> *samples = nil;
    dispatch_sync(self.concurrent_queue, ^{
        samples = [self.buffer copy];
    });
    return samples;
}

- (nonnull NSArray<VLTData *> *)dataForTimeInterval:(NSTimeInterval)interval
{
    NSArray<id<VLTSample>> *samples = [self copiedSamples];
    NSArray<id<VLTSample>> *results = @[];
    id<VLTSample> lastObject        = [samples lastObject];
    if (lastObject) {
        NSTimeInterval timestampLimit = lastObject.timestamp - interval;
        for (NSInteger i = (samples.count - 1); i >= 0; i--) {
            id<VLTSample> sample = samples[i];
            if (sample.timestamp < timestampLimit) {
                results = [samples subarrayWithRange:NSMakeRange(i, samples.count - i)];
                break;
            }
        }
    }

    VLTData *data = [[VLTData alloc] initWithSensorType:self.sensorType values:results];

    return @[data];
}

@end
