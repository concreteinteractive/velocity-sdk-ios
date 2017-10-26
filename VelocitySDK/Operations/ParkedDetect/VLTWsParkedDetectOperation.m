//
//  VLTWsParkedDetectOperation.m
//  VelocitySDK iOS
//
//  Created by Vytautas Galaunia on 25/10/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTWsParkedDetectOperation.h"
#import "VLTMotionDetectResult.h"
#import "VLTMotionDetect.h"
#import "VLTWsMotionDetectOperation.h"
#import "VLTDrivingDetectOperation.h"
#import "VLTCoreMotionActivityTracker.h"
#import "VLTMacros.h"

static const NSTimeInterval PreviousResultRelevanceTimeInterval = 300;
static NSString * const VLTParkedDetectOperationLastResultDefaultsKey = @"VLTParkedDetectOperationLastResultDefaultsKey";


@interface VLTWsParkedDetectOperation ()

@property (atomic, strong, nullable) VLTMotionDetectResult *result;
@property (atomic, strong, nullable) NSError *error;

@end

@implementation VLTWsParkedDetectOperation

- (BOOL)isAsynchronous
{
    return YES;
}

- (VLTDrivingDetectOperation *)drivingDetectOperation
{
    return [[VLTDrivingDetectOperation alloc] initWithMotionData:self.motionData];
}

- (id<VLTMotionDetect>)motionDetectOperation
{
    return [[VLTWsMotionDetectOperation alloc] initWithMotionData:self.motionData wsApiClient:self.wsApiClient];
}

- (VLTCoreMotionActivityTracker *)activityTracker
{
    return [VLTCoreMotionActivityTracker shared];
}


- (void)processMotionData
{
    VLTDrivingDetectOperation *drivingOp = [self drivingDetectOperation];
    [drivingOp start];
    [drivingOp waitUntilFinished];

    VLTMotionDetectResult *result;

    CMMotionActivity *recentMotionActivity = [self activityTracker].recentActivity;
    if (drivingOp.isDriving || recentMotionActivity.automotive) {
        result = [[VLTMotionDetectResult alloc] initWithDictionary:@{
                                                                     VLTMotionDetectResultDrivingKey: @YES,
                                                                     VLTMotionDetectResultParkedKey: @NO,
                                                                     VLTMotionDetectResultWalkingKey: @NO,
                                                                     }];
    } else {
        VLTWsMotionDetectOperation *detectOp = [self motionDetectOperation];
        [detectOp start];
        [detectOp waitUntilFinished];

        if (!detectOp.result) {
            self.error = detectOp.error;
            dispatch_async(dispatch_get_main_queue(), ^{
                vlt_invoke_block(self.onError, self.error);
            });
            [self markAsFinished];
            return;
        }

        VLTMotionDetectResult *detectResult = detectOp.result;
        VLTMotionDetectResult *previousResult = [self getPreviousMotionDetectResult];

        if (detectResult.isWalking) {
            result = [[VLTMotionDetectResult alloc] initWithDictionary:@{
                                                                         VLTMotionDetectResultDrivingKey: @NO,
                                                                         VLTMotionDetectResultParkedKey: @YES,
                                                                         VLTMotionDetectResultWalkingKey: @YES,
                                                                         }];
        } else {
            result = [[VLTMotionDetectResult alloc] initWithDictionary:@{
                                                                         VLTMotionDetectResultDrivingKey: @NO,
                                                                         VLTMotionDetectResultParkedKey: @(previousResult.isParked),
                                                                         VLTMotionDetectResultWalkingKey: @NO,
                                                                         }];
        }
    }

    self.result = result;
    [self saveMotionDetectResult:result];
    dispatch_async(dispatch_get_main_queue(), ^{
        vlt_invoke_block(self.onMotionDetect, result);
    });
    [self markAsFinished];
}

- (void)saveMotionDetectResult:(VLTMotionDetectResult *)result
{
    NSDictionary *dict = [result toDictionary];
    [[NSUserDefaults standardUserDefaults] setValue:dict forKey:VLTParkedDetectOperationLastResultDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (VLTMotionDetectResult *)getPreviousMotionDetectResult
{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults]
                          dictionaryForKey:VLTParkedDetectOperationLastResultDefaultsKey];
    if (!dict) {
        return nil;
    }

    VLTMotionDetectResult *result = [[VLTMotionDetectResult alloc] initWithDictionary:dict];
    if (fabs([result.timestamp timeIntervalSinceNow]) < PreviousResultRelevanceTimeInterval) {
        return result;
    }

    return nil;
}


@end
