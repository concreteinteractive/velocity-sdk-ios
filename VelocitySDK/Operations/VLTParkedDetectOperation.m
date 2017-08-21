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
    if (drivingOp.isDriving) {
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
            vlt_invoke_block(self.onError, self.error);
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
            result = previousResult;
        }
    }

    self.result = result;
    [self saveMotionDetectResult:result];
    vlt_invoke_block(self.onMotionDetect, result);
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

    return [[VLTMotionDetectResult alloc] initWithDictionary:dict];
}

@end
