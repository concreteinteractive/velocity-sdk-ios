//
//  VLTClient.m
//  VelocitySDK
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTClient.h"
#import "VLTConfig.h"
#import "VLTCore.h"
#import "VLTErrors.h"
#import "VLTHTTPCaptureUploadOperation.h"
#import "VLTHTTPMotionDetectOperation.h"
#import "VLTLabeledDataUploadOperation.h"
#import "VLTMacros.h"
#import "VLTMotionDataOperation.h"
#import "VLTMotionRecorder.h"
#import "VLTOperation.h"
#import "VLTProtobufHelper.h"
#import "VLTRecordingConfig.h"
#import "VLTSensorBuilder.h"
#import "VLTUserDataStore.h"
#import "VLTWsApiClient.h"

@import SocketRocket;
@import AFNetworking;

static void *VLTIsActiveKVOContext = &VLTIsActiveKVOContext;

static const NSTimeInterval LabeledDataMaxTimeInterval = 300;
static const NSUInteger VLTWsApiQueueSize              = 10;

@interface VLTClient ()

@property (atomic, strong) VLTRecordingConfig *recordingConfig;
@property (atomic, strong) id<VLTMotionRecorder> recorder;
@property (atomic, strong) dispatch_source_t hitTimer;
@property (atomic, assign, getter=isInProgress) BOOL inProgress;
@property (atomic, strong) VLTWsApiClient *wsApiClient;

@property (nonatomic, strong) NSOperationQueue *processingQueue;
@property (nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;

@end

@implementation VLTClient

@synthesize authToken = _authToken;
@synthesize active    = _active;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _processingQueue           = [[NSOperationQueue alloc] init];
        _processingQueue.suspended = NO;

        _reachabilityManager = [AFNetworkReachabilityManager manager];
        [_reachabilityManager startMonitoring];
        vlt_weakify(self);
        [_reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            vlt_strongify(self);
            [self handleReachabilityChange];
        }];
        [self initializeWsApiClient];
    }
    return self;
}

- (void)setActive:(BOOL)active
{
    @synchronized(self) { _active = active; }

    [self handleIsActiveChange];
}

- (BOOL)isActive
{
    @synchronized(self) { return _active; }
}

- (void)handleReachabilityChange
{
    if (!self.isActive) {
        return;
    }

    if ([self.reachabilityManager isReachable] && !self.wsApiClient.isOpen) {
        [self reinitializeWsApiClient];
    }
}

- (void)handleIsActiveChange
{
    if (self.isActive) {
        [self reinitializeWsApiClient];
    } else {
        [self stopMotionSensing];
        [self closeWsApiClientIfNeeded];
    }
}

- (BOOL)shouldReconnectAfterError:(NSError *)error
{
    if ([error.domain isEqualToString:VLTErrorDomain] && error.code == VLTWsApiClientDisconnectedError) {
        BOOL wasClean = [error.userInfo[VLTWsCloseWasCleanKey] boolValue];
        if (wasClean) {
            return NO;
        }
    }

    if ([error.domain isEqualToString:NSPOSIXErrorDomain]) {
        switch (error.code) {
            case ECONNREFUSED:
                return NO;
            default:
                break;
        }
    }

    if ([error.domain isEqualToString:SRWebSocketErrorDomain]) {
        NSInteger code = [error.userInfo[SRHTTPResponseErrorKey] integerValue];
        if (code >= 400) {
            return NO;
        }
    }

    return YES;
}

- (void)initializeWsApiClient
{
    [self closeWsApiClientIfNeeded];
    vlt_weakify(self);
    self.wsApiClient = [[VLTWsApiClient alloc] initWithQueueSize:VLTWsApiQueueSize];
    [self.wsApiClient setOnError:^(NSError *_Nonnull error) {
        DLog(@"WS error: %@", error);

        vlt_strongify(self);
        BOOL shouldReconnect = [self shouldReconnectAfterError:error];
        if (shouldReconnect) {
            [self reinitializeWsApiClient];
        } else {
            self.active = NO;
        }
    }];
    [self.wsApiClient setOnPong:^(NSData *_Nullable pongPayload) {
        DLog(@"WS API Client PONG: %@", [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding]);
    }];
}

- (void)reinitializeWsApiClient
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initializeWsApiClient];
        [self startMotionSensing];
    });
}

- (void)closeWsApiClientIfNeeded
{
    if (self.wsApiClient.isOpen) {
        [self.wsApiClient close];
    }
}

- (void)startMotionSensing
{
    if (!self.reachabilityManager.isReachable) {
        return;
    }

    vlt_weakify(self);
    [self.wsApiClient setOnOpen:^{
        vlt_strongify(self);
        [self.wsApiClient handshakeWithSuccess:^(VLTPBHandshakeResponse *_Nonnull response) {
            vlt_strongify(self);
            self.recordingConfig = [[VLTRecordingConfig alloc] initWithHandshakeResponse:response];
            [self startRecording];
        }
            failure:^(NSError *_Nonnull error) {
                DLog(@"Handshake error: %@", error);
            }];
    }];
    [self.wsApiClient openWithAuthToken:self.authToken];
}

- (void)stopMotionSensing
{
    [self stopRecording];
}

- (void)startRecording
{
    if (!self.recordingConfig) {
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
        self.hitTimer = [VLTCore timer:5 // self.recordingConfig.captureInterval
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

- (void)capture
{
    if (self.isInProgress || !self.wsApiClient.isOpen) {
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
            NSArray<VLTData *> *datas                     = [self.recorder dataForTimeInterval:sampleSize];
            NSArray<VLTMotionDataOperation *> *operations = factoryHandler(self.wsApiClient, datas);
            [self.processingQueue addOperations:operations waitUntilFinished:YES];
        }
        self.inProgress = NO;
    }];
}

- (void)pushMotionDataWithLabels:(nonnull NSArray<NSString *> *)labels
                         success:(void (^)(void))success
                         failure:(void (^)(NSError *error))failure
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
        NSArray<VLTData *> *motionData = [self.recorder dataForTimeInterval:LabeledDataMaxTimeInterval];
        VLTLabeledDataUploadOperation *op =
            [[VLTLabeledDataUploadOperation alloc] initWithMotionData:motionData labels:labels];
        op.onSuccess = success;
        op.onError   = failure;
        [self.processingQueue addOperations:@[op] waitUntilFinished:YES];
    }];
}

@end
