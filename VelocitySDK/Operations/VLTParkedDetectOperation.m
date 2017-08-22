//
//  VLTParkedDetectOperation.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 21/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTParkedDetectOperation.h"
#import "VLTDrivingDetectOperation.h"
#import "VLTMotionDetectResult.h"
#import "VLTMacros.h"
#import "VLTMotionDetectOperation.h"
#import "VLTCoreMotionActivityTracker.h"
#import <CoreMotion/CoreMotion.h>

static const NSTimeInterval PreviousResultRelevanceTimeInterval = 300;

static NSString * const VLTParkedDetectOperationLastResultDefaultsKey = @"VLTParkedDetectOperationLastResultDefaultsKey";

@interface VLTParkedDetectOperation ()

@property (atomic, strong) VLTMotionDetectResult *result;
@property (atomic, strong) NSError *error;

@end

@implementation VLTParkedDetectOperation

- (BOOL)isAsynchronous
{
    return YES;
}

- (VLTDrivingDetectOperation *)drivingDetectOperation
{
    return [[VLTDrivingDetectOperation alloc] initWithMotionData:self.motionData
                                                   sequenceIndex:self.sequenceIndex];
}

- (VLTMotionDetectOperation *)motionDetectOperation
{
    return [[VLTMotionDetectOperation alloc] initWithMotionData:self.motionData
                                                  sequenceIndex:self.sequenceIndex];
}


- (void)processMotionData
{
    VLTDrivingDetectOperation *drivingOp = [self drivingDetectOperation];
    [drivingOp start];
    [drivingOp waitUntilFinished];

    VLTMotionDetectResult *result;

    CMMotionActivity *recentMotionActivity = [VLTCoreMotionActivityTracker shared].recentActivity;
    if (drivingOp.isDriving || recentMotionActivity.automotive) {
        result = [[VLTMotionDetectResult alloc] initWithDictionary:@{
                                                                     VLTMotionDetectResultDrivingKey: @YES,
                                                                     VLTMotionDetectResultParkedKey: @NO,
                                                                     VLTMotionDetectResultWalkingKey: @NO,
                                                                     }];
    } else {
        VLTMotionDetectOperation *detectOp = [self motionDetectOperation];
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
