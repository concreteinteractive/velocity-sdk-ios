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

NSString * const VLTMotionWalking = @"walking";
NSString * const VLTMotionDriving = @"driving";

@interface VLTManager ()

@property (atomic, strong) VLTClient *client;
@property (atomic, assign, getter=isTrackingIsOn) BOOL trackingIsOn;

@property (atomic, assign, getter=isDetectionIsOn) BOOL detectionIsOn;
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
    [VLTManager shared].trackingIsOn = NO;
}

+ (BOOL)isTrackingEnabled
{
    return [VLTManager shared].trackingIsOn;
}

+ (void)setDetectionEnabled:(BOOL)enabled handler:(nonnull void(^)(VLTMotionDetectResult * _Nonnull))handler
{
    [VLTManager shared].detectionIsOn = enabled;
    [VLTManager shared].detectionHandler = handler;
}

+ (BOOL)isDetectionEnabled
{
    return [VLTManager shared].isDetectionIsOn;
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
    if (self.isTrackingIsOn) {
        VLTCaptureUploadOperation *captureOp = [[VLTCaptureUploadOperation alloc] initWithMotionData:motionData
                                                                                       sequenceIndex:sequenceIndex];
        [operations addObject:captureOp];
    }

    if (self.isDetectionIsOn) {
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
