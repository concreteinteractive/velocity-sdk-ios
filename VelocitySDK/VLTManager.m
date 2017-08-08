//
//  VLTManager.m
//  Velocity
//
//  Created by Vytautas Galaunia on 24/01/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTManager.h"
#import "VLTApiClient.h"
#import "VLTTracker.h"
#import "VLTUserDataStore.h"
#import "VLTDetector.h"

NSString * const VLTMotionWalking = @"walking";
NSString * const VLTMotionDriving = @"driving";

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
    [VLTTracker activate];
}

+ (void)deactivateTracking
{
    [VLTTracker deactivate];
}

+ (BOOL)isTrackingActive
{
    return [VLTTracker isActive];
}

+ (void)setOnTrackingStatusHandler:(nonnull void(^)(BOOL active))handler
{
    [VLTTracker setOnStatusHandler:handler];
}

+ (void)activateDetectionWithHandler:(nonnull void(^)(VLTDetectResult * _Nonnull))handler
{
    [VLTDetector setOnDetectReceivedHandler:handler];
    [VLTDetector activate];
}

+ (void)deactivateDetection
{
    [VLTDetector deactivate];
}

+ (void)markGoalAsCompleted:(nonnull NSString *)goalId
                    eventId:(nonnull NSString *)eventId
                    success:(nullable void (^)(void))success
                    failure:(nullable void (^)(NSError *_Nonnull error))failure
{
    [[VLTApiClient shared] markGoalAsCompleted:goalId eventId:eventId success:success failure:failure];
}

@end
