//
//  VLTClient.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 17/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTClient.h"
#import "VLTMotionRecorder.h"
#import "VLTErrors.h"
#import "VLTSensorBuilder.h"
#import "VLTUserDataStore.h"
#import "VLTCore.h"
#import "VLTRecordingConfig.h"
#import "VLTMacros.h"
#import "VLTProtobufHelper.h"
#import "VLTConfig.h"
#import "VLTOperation.h"
#import "VLTMotionDetectOperation.h"
#import "VLTCaptureUploadOperation.h"
#import "VLTLabeledDataUploadOperation.h"
#import "VLTMotionDataOperation.h"

static void * VLTIsActiveKVOContext = &VLTIsActiveKVOContext;

static const NSTimeInterval LabeledDataMaxTimeInterval = 300;

@interface VLTClient ()

@property (atomic, strong) VLTRecordingConfig *recordingConfig;
@property (atomic, strong) id <VLTMotionRecorder> recorder;
@property (atomic, strong) dispatch_source_t hitTimer;
@property (atomic, assign, getter=isInProgress) BOOL inProgress;
@property (atomic, assign) UInt32 sequenceIndex;
@property (atomic, assign) UInt32 labeledSequenceIndex;

@property (nonatomic, strong) NSOperationQueue *processingQueue;

@end

@implementation VLTClient

@synthesize active = _active;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _processingQueue = [[NSOperationQueue alloc] init];
        _processingQueue.suspended = NO;
    }
    return self;
}


- (void)setActive:(BOOL)active
{
    @synchronized (self) {
        _active = active;
    }

    [self handleIsActiveChange];
}

- (BOOL)isActive
{
    @synchronized (self) {
        return _active;
    }
}

- (void)handleIsActiveChange
{
    if (self.isActive) {
        [self startMotionSensing];
    } else {
        [self stopMotionSensing];
    }
}

- (void)startMotionSensing
{
    vlt_weakify(self);
    [[VLTUserDataStore shared] updateConfigWithSuccess:^(VLTRecordingConfig * _Nonnull config) {
        vlt_strongify(self);
        self.recordingConfig = config;
        [self startRecording];
    } failure:^(NSError * _Nonnull error) {
        vlt_strongify(self);
        [self handleError:error];
    }];
}

- (void)stopMotionSensing
{
    [self stopRecording];
}

- (void)startRecording
{
    if (!self.recordingConfig) {
        [self handleError:[NSError errorWithDomain:VLTErrorDomain code:VLTClientError userInfo:nil]];
        return;
    }

    self.recorder = [VLTSensorBuilder buildRecorder];
    [self.recorder startRecording];
    [self startHitTimer];
}

- (void)stopRecording
{
    [self invalidateHitTimer];
    [self.recorder stopRecording];
    self.recorder = nil;
}

- (void)startHitTimer
{
    [self invalidateHitTimer];
    [self.processingQueue addOperationWithBlock:^{
        vlt_weakify(self);
        self.hitTimer = [VLTCore timer:5 //self.recordingConfig.captureInterval
                               handler:^{
                                   vlt_strongify(self);
                                   [self capture];
                               }];
    }];
}

- (void)invalidateHitTimer
{
    [self.processingQueue addOperationWithBlock:^{
        if (self.hitTimer != nil) {
            dispatch_source_cancel(self.hitTimer);
            self.hitTimer = nil;
        }
    }];
}

- (void)handleError:(NSError *)error
{
    if (error && [error.domain isEqualToString:VLTErrorDomain]) {
        switch (error.code) {
            case VLTApiFatalError:
            case VLTApiTokenNotRecognized:
            case VLTApiTokenNoAccess:
                self.active = NO;
                break;
            default:
                break;
        }
    }
}

- (void)capture
{
    if (self.isInProgress) {
        return;
    }

    MotionDataOperationsFactory factoryHandler = self.operationFatoryHandler;
    if (!factoryHandler) {
        return;
    }


    self.inProgress = YES;
    vlt_weakify(self);
    [self.processingQueue addOperationWithBlock:^{
        vlt_strongify(self);

        NSTimeInterval sampleSize = self.recordingConfig.sampleSize;
        if ([self.recorder availableTimeInBuffer] > sampleSize) {
            UInt32 seqIndex = self.sequenceIndex;
            self.sequenceIndex = self.sequenceIndex + 1;

            NSArray<VLTData *> *datas = [self.recorder dataForTimeInterval:sampleSize];
            NSArray<VLTMotionDataOperation *> * operations = factoryHandler(datas, seqIndex);
            [self.processingQueue addOperations:operations waitUntilFinished:YES];
        }
        self.inProgress = NO;
    }];
}

- (void)pushMotionDataWithLabels:(nonnull NSArray<NSString *> *)labels
                         success:(void(^)())success
                         failure:(void(^)(NSError *error))failure
{
    if (!self.recordingConfig.pushLabeledDataOn) {
        NSDictionary *uInfo = @{
                                NSLocalizedDescriptionKey: @"Labeled data push is off on this client.",
                                };
        NSError *error = [NSError errorWithDomain:VLTErrorDomain code:VLTClientError userInfo:uInfo];
        vlt_invoke_block(failure, error);
        return;
    }

    [self.processingQueue addOperationWithBlock:^{
        UInt32 seqIndex = self.labeledSequenceIndex;
        self.labeledSequenceIndex = self.labeledSequenceIndex + 1;
        
        NSArray<VLTData *> *motionData = [self.recorder dataForTimeInterval:LabeledDataMaxTimeInterval];
        VLTLabeledDataUploadOperation *op = [[VLTLabeledDataUploadOperation alloc] initWithMotionData:motionData
                                                                                        sequenceIndex:seqIndex
                                                                                               labels:labels];
        op.onSuccess = success;
        op.onError = failure;
        [self.processingQueue addOperations:@[op] waitUntilFinished:YES];
    }];
}


@end
