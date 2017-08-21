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

static void * VLTIsActiveKVOContext = &VLTIsActiveKVOContext;

static const NSTimeInterval LabeledDataMaxTimeInterval = 300;

@interface VLTClient ()

@property (atomic, strong) VLTRecordingConfig *recordingConfig;
@property (atomic, strong) id <VLTMotionRecorder> recorder;
@property (atomic, strong) dispatch_source_t hitTimer;
@property (atomic, assign, getter=isInProgress) BOOL inProgress;
@property (atomic, assign) UInt32 sequenceIndex;

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
    [[VLTCore queue] addOperationWithBlock:^{
        vlt_weakify(self);
        self.hitTimer = [VLTCore timer:self.recordingConfig.captureInterval
                               handler:^{
                                   vlt_strongify(self);
                                   [self capture];
                               }];
    }];
}

- (void)invalidateHitTimer
{
    [[VLTCore queue] addOperationWithBlock:^{
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

    self.inProgress = YES;
    vlt_weakify(self);
    [[VLTCore queue] addOperationWithBlock:^{
        vlt_strongify(self);

        NSTimeInterval sampleSize = self.recordingConfig.sampleSize;
        if ([self.recorder availableTimeInBuffer] > sampleSize) {
            UInt32 seqIndex = self.sequenceIndex;
            self.sequenceIndex = self.sequenceIndex + 1;

            NSArray<VLTData *> *datas = [self.recorder dataForTimeInterval:sampleSize];
            VLTPBDetectMotionRequest *motionReq = nil;

            if (self.isDetectionOn) {
                motionReq = [VLTProtobufHelper detectMotionRequestFromDatas:datas
                                                               impressionId:[VLTUserDataStore shared].impressionId
                                                                 modelNames:@[]
                                                                        ifa:[VLTConfig IFA]
                                                                     userId:[VLTUserDataStore shared].userId
                                                              sequenceIndex:seqIndex];
                [self runDetectionWithMotionRequest:motionReq];
            }

            if (self.isTrackingOn) {
                VLTPBCapture *capture = [VLTProtobufHelper captureFromDatas:datas
                                                                        ifa:[VLTConfig IFA]
                                                              sequenceIndex:seqIndex
                                                               impressionId:[VLTUserDataStore shared].impressionId];
                [self runOperationWithCaptureRequest:capture];
            }
        }
        self.inProgress = NO;
    }];
}

- (void)runDetectionWithMotionRequest:(VLTPBDetectMotionRequest *)motionRequest
{
    VLTMotionDetectOperation *motionDetectOperation = [[VLTMotionDetectOperation alloc] initWithMotionRequest:motionRequest];
    motionDetectOperation.onMotionDetect = self.detectHandler;
    motionDetectOperation.onError = self.errorHandler;

    [self.processingQueue addOperations:@[motionDetectOperation] waitUntilFinished:YES];
}

- (void)runOperationWithCaptureRequest:(VLTPBCapture *)captureRequest
{
    VLTCaptureUploadOperation *op = [[VLTCaptureUploadOperation alloc] initWithCaptureRequest:captureRequest];
    op.onError = self.errorHandler;
    [self.processingQueue addOperations:@[op] waitUntilFinished:YES];
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

    [[VLTCore queue] addOperationWithBlock:^{
        NSArray<VLTData *> *motionData = [self.recorder dataForTimeInterval:LabeledDataMaxTimeInterval];
        VLTLabeledDataUploadOperation *op = [[VLTLabeledDataUploadOperation alloc] initWithMotionData:motionData
                                                                                               labels:labels];
        op.onSuccess = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                vlt_invoke_block(success);
            });
        };
        op.onError = ^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                vlt_invoke_block(failure, error);
            });
        };
        [op start];
    }];
}


@end
