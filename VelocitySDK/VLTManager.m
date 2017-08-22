//
//  VLTManager.m
//  Velocity
//
//  Created by Vytautas Galaunia on 24/01/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTManager.h"
#import "VLTApiClient.h"
#import "VLTUserDataStore.h"
#import "VLTClient.h"
#import "VLTMotionDataOperation.h"
#import "VLTCaptureUploadOperation.h"
#import "VLTParkedDetectOperation.h"
#import "VLTMacros.h"

NSString * const VLTMotionWalking = @"walking";
NSString * const VLTMotionDriving = @"driving";

@interface VLTManager ()

@property (atomic, strong) VLTClient *client;
@property (atomic, assign, getter=isTrackingOn) BOOL trackingOn;

@property (atomic, assign, getter=isDetectionOn) BOOL detectionOn;
@property (atomic, copy) void(^detectionHandler)(VLTMotionDetectResult * _Nonnull);

@end

@implementation VLTManager

+ (VLTManager *)shared
{
    static VLTManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _client = [[VLTClient alloc] init];
        vlt_weakify(self);
        _client.operationFatoryHandler = ^NSArray<VLTMotionDataOperation *> *(NSArray<VLTData *> *motionData, UInt32 sequenceIndex) {
            vlt_strongify(self);
            return [self operationWith:motionData sequenceIndex:sequenceIndex];
        };
    }
    return self;
}

+ (void)setApiToken:(NSString *)token
{
    [[VLTApiClient shared] setApiToken:token];
}

+ (void)setUserId:(NSString *)userId
{
    [VLTUserDataStore shared].userId = userId;
}

+ (void)setEnabled:(BOOL)enabled
{
    [VLTManager shared].client.active = enabled;
}

+ (BOOL)isEnabled
{
    return [VLTManager shared].client.active;
}

+ (void)setTrackingEnabled:(BOOL)enabled
{
    [VLTManager shared].trackingOn = NO;
}

+ (BOOL)isTrackingEnabled
{
    return [VLTManager shared].isTrackingOn;
}

+ (void)setDetectionEnabled:(BOOL)enabled handler:(nonnull void(^)(VLTMotionDetectResult * _Nonnull))handler
{
    [VLTManager shared].detectionOn = enabled;
    [VLTManager shared].detectionHandler = handler;
}

+ (BOOL)isDetectionEnabled
{
    return [VLTManager shared].isDetectionOn;
}

+ (void)markGoalAsCompleted:(nonnull NSString *)goalId
                    eventId:(nonnull NSString *)eventId
                    success:(nullable void (^)(void))success
                    failure:(nullable void (^)(NSError *_Nonnull error))failure
{
    [[VLTApiClient shared] markGoalAsCompleted:goalId eventId:eventId success:success failure:failure];
}

- (NSArray<VLTMotionDataOperation *> *)operationWith:(NSArray<VLTData *> *)motionData sequenceIndex:(UInt32)sequenceIndex
{
    NSMutableArray<VLTMotionDataOperation *> *operations = [[NSMutableArray alloc] init];
    if (self.isTrackingOn) {
        VLTCaptureUploadOperation *captureOp = [[VLTCaptureUploadOperation alloc] initWithMotionData:motionData
                                                                                       sequenceIndex:sequenceIndex];
        [operations addObject:captureOp];
    }

    if (self.isDetectionOn) {
        VLTParkedDetectOperation *captureOp = [[VLTParkedDetectOperation alloc] initWithMotionData:motionData
                                                                                     sequenceIndex:sequenceIndex];
        [operations addObject:captureOp];
    }

    return operations;
}

+ (void)labelCurrentMotionWith:(nonnull NSArray<NSString *> *)labels
{
    [[VLTManager shared].client pushMotionDataWithLabels:labels
                                                 success:^{}
                                                 failure:^(NSError * _Nullable error) {
                                                     NSLog(@"[VelocitySDK] error: markCurrentMotionAs %@ failed.", labels);
                                                 }];
}

@end
