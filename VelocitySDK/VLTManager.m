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

NSString * const VLTMotionWalking = @"walking";
NSString * const VLTMotionDriving = @"driving";

@interface VLTManager ()

@property (atomic, strong) VLTClient *client;

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

+ (void)activateTracking
{
    [VLTManager shared].client.trackingOn = YES;
    [VLTManager shared].client.active = YES;
}

+ (void)deactivateTracking
{
    [VLTManager shared].client.trackingOn = NO;
    [VLTManager shared].client.active = NO;
}

+ (BOOL)isTrackingActive
{
    return ([VLTManager shared].client.trackingOn && [VLTManager shared].client.active);
}

+ (void)activateDetectionWithHandler:(nonnull void(^)(VLTMotionDetectResult * _Nonnull))handler
{
    [VLTManager shared].client.active = YES;
    [VLTManager shared].client.detectionOn = YES;
    [VLTManager shared].client.detectHandler = handler;
    [VLTManager shared].client.errorHandler = ^(NSError *error) {
        NSLog(@"Detect error: %@", error);
    };
}

+ (void)deactivateDetection
{
    [VLTManager shared].client.active = NO;
    [VLTManager shared].client.detectionOn = NO;
}

+ (void)markGoalAsCompleted:(nonnull NSString *)goalId
                    eventId:(nonnull NSString *)eventId
                    success:(nullable void (^)(void))success
                    failure:(nullable void (^)(NSError *_Nonnull error))failure
{
    [[VLTApiClient shared] markGoalAsCompleted:goalId eventId:eventId success:success failure:failure];
}

@end
