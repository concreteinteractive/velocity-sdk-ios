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
#import "VLTUserDataStore.h"
#import "VLTCore.h"

static const NSTimeInterval VLTDetectUploaderTimerInterval = 1.0;

@interface VLTDetectUploader ()

@property (nonatomic, strong) dispatch_source_t timer;
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


- (void)startUploading {
    [self createTimer];
}

- (void)stopUploading {
    [self invalidateTimer];
}

- (void)invalidateTimer
{
    if (self.timer != nil) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}

- (void)createTimer
{
    [self invalidateTimer];
    vlt_weakify(self);
    self.timer = [VLTCore timer:VLTDetectUploaderTimerInterval handler:^{
        vlt_strongify(self);
        [self upload];
    }];
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

            VLTPBDetectMotionRequest *motionReq = nil;
            motionReq = [VLTProtobufHelper detectMotionRequestFromDatas:[self.recorder dataForTimeInterval:self.sampleSize]
                                                           impressionId:self.impressionId
                                                             modelNames:@[]
                                                                    ifa:[VLTConfig IFA]
                                                                 userId:[VLTUserDataStore shared].userId
                                                          sequenceIndex:seqIndex];
            self.isInProgress = YES;
            [[VLTApiClient shared] detect:motionReq
                                  success:^(VLTDetectResult * _Nonnull result) {
                                      DLog(@"DetectMotionRequest done.");
                                      self.isInProgress = NO;
                                      vlt_invoke_block(self.onSuccess, result);
                                  }
                                  failure:^(NSError * _Nonnull error) {
                                      DLog(@"DetectMotionRequest faile. Error: %@", error);
                                      self.isInProgress = NO;
                                      vlt_invoke_block(self.onError, error);
                                  }];
        }];
        [queue addOperation:operation];
    }
}


@end
