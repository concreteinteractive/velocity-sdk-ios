//
//  VLTWsMotionDetectOperation.m
//  VelocitySDK iOS
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTWsMotionDetectOperation.h"
#import "Velocity.pbobjc.h"
#import "VLTProtobufHelper.h"
#import "VLTUserDataStore.h"
#import "VLTMacros.h"
#import "VLTMotionDetectResult.h"

static NSString * const WalkingModel = @"Parking Walking Temporal";
static NSString * const PredictionWalking = @"Walking";
static NSString * const PredictionNotWalking = @"Not walking";

@interface VLTWsMotionDetectOperation()

@property (atomic, strong, nullable) VLTMotionDetectResult *result;
@property (atomic, strong, nullable) NSError *error;

@end

@implementation VLTWsMotionDetectOperation

- (BOOL)isAsynchronous
{
    return YES;
}


- (VLTMotionDetectResult *)responseToDetectResult:(VLTPBResponse *)response
{
    NSUInteger walkingWeight = 0;
    NSUInteger notWalkingWeight = 0;

    for (VLTPBModelPrediction *mp in response.modelPredictionsArray) {
        if ([mp.modelName isEqualToString:WalkingModel]) {
            for (VLTPBPrediction *p in mp.predictionsArray) {
                if ([p.name isEqualToString:PredictionWalking]) {
                    walkingWeight++;
                } else if (([p.name isEqualToString:PredictionNotWalking])) {
                    notWalkingWeight++;
                }
            }
        }
    }

    BOOL walking = NO;
    if (walkingWeight > notWalkingWeight) {
        walking = YES;
    }

    VLTMotionDetectResult *result = [[VLTMotionDetectResult alloc] initWithWalking:walking driving:NO parked:NO];
    return result;
}

- (void)processMotionData
{
    VLTPBRequest *req = [[VLTPBRequest alloc] init];
    req.sensorsArray = [[VLTProtobufHelper sensorsFromMotionData:self.motionData] mutableCopy];
    req.modelNamesArray = [@[WalkingModel] mutableCopy];
    req.sessionId = [[VLTUserDataStore shared] sessionId];

    vlt_weakify(self);
    [self.wsApiClient motionDetect:req
                           success:^(VLTPBResponse * _Nonnull response) {
                               vlt_strongify(self);
                               self.result = [self responseToDetectResult:response];
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   vlt_invoke_block(self.onMotionDetect, self.result);
                               });
                               [self markAsFinished];
                           } failure:^(NSError * _Nonnull error) {
                               vlt_strongify(self);
                               self.error = error;
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   vlt_invoke_block(self.onError, error);
                               });
                               [self markAsFinished];
                           }];
}

@end
