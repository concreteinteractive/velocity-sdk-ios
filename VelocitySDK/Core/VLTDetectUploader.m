//
//  VLTPredictUploader.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 04/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTDetectUploader.h"
#import "VLTCore.h"
#import "VLTProtobufHelper.h"
#import "VLTApiClient.h"
#import "VLTConfig.h"
#import "VLTMacros.h"

@interface VLTDetectUploader ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval sampleSize;
@property (nonatomic, strong) id <VLTMotionRecorder> recorder;
@property (nonatomic, copy) NSString *impressionId;
@property (atomic, assign) BOOL isUploading;
@property (atomic, assign) BOOL isInProgress;
@property (atomic, assign) UInt32 sequenceIndex;

@end

@implementation VLTDetectUploader

- (nonnull instancetype)initWithRecorder:(nonnull id<VLTMotionRecorder>)recorder
                            impressionId:(nonnull NSString *)impressionId
                              sampleSize:(NSTimeInterval)sampleSize
{
    self = [super init];
    if (self) {
        _recorder = recorder;
        _impressionId = impressionId;
        _sampleSize = sampleSize;
    }
    return self;
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)startUploading {
    [self createTimer];
}

- (void)createTimer
{
    [self.timer invalidate];
    NSDate *afterSecond = [NSDate dateWithTimeInterval:1.0 sinceDate:[NSDate date]];

    self.timer = [[NSTimer alloc] initWithFireDate:afterSecond
                                          interval:self.sampleSize
                                            target:self
                                          selector:@selector(upload)
                                          userInfo:nil
                                           repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.timer fire];
}

- (void)stopUploading {
    if (self.timer.isValid) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)upload
{
    if ([self.recorder availableTimeInBuffer] > self.sampleSize && !self.isInProgress) {
        NSOperationQueue *queue = [VLTCore queue];
        vlt_weakify(self);
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            vlt_strongify(self);
            UInt32 seqIndex = self.sequenceIndex;
            self.sequenceIndex = self.sequenceIndex + 1;
            VLTPBCapture *capture = [VLTProtobufHelper captureFromDatas:[self.recorder dataForTimeInterval:self.sampleSize]
                                                                    ifa:[VLTConfig IFA]
                                                          sequenceIndex:seqIndex
                                                           impressionId:self.impressionId];

            self.isInProgress = YES;
            [[VLTApiClient shared] uploadForTracking:capture
                                             success:^{
                                                 DLog(@"VLTTrackingPredictionUploader uploaded.");
                                                 self.isInProgress = NO;
                                                 vlt_invoke_block(self.onUpload);
                                             }
                                             failure:^(NSError * _Nonnull error) {
                                                 DLog(@"VLTTrackingPredictionUploader error: %@", error);
                                                 self.isInProgress = NO;
                                                 vlt_invoke_block(self.onError, error);
                                             }];
        }];
        [queue addOperation:operation];
    }
}


@end
