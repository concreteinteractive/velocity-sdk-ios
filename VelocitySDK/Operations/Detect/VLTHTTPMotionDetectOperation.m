//
//  VLTHTTPMotionDetectOperation.m
//  VelocitySDK
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTHTTPMotionDetectOperation.h"
#import "VLTApiClient.h"
#import "VLTConfig.h"
#import "VLTMacros.h"
#import "VLTMotionDetectResult.h"
#import "VLTProtobufHelper.h"
#import "VLTUserDataStore.h"

@interface VLTHTTPMotionDetectOperation ()

@property (atomic, strong) VLTMotionDetectResult *result;
@property (atomic, strong) NSError *error;

@end

@implementation VLTHTTPMotionDetectOperation

- (BOOL)isAsynchronous
{
    return YES;
}

- (void)processMotionData
{
    VLTPBDetectMotionRequest *motionRequest = nil;
    motionRequest                           = [VLTProtobufHelper detectMotionRequestFromDatas:self.motionData
                                                       impressionId:[VLTUserDataStore shared].sessionId
                                                         modelNames:@[]
                                                                ifa:[VLTUserDataStore shared].IFA
                                                             userId:[VLTUserDataStore shared].userId];
    vlt_weakify(self);
    [[VLTApiClient shared] detect:motionRequest
        success:^(VLTMotionDetectResult *_Nonnull result) {
            vlt_strongify(self);
            self.result = result;
            dispatch_async(dispatch_get_main_queue(), ^{
                vlt_invoke_block(self.onMotionDetect, result);
            });
            [self markAsFinished];
        }
        failure:^(NSError *_Nonnull error) {
            vlt_strongify(self);
            self.error = error;
            dispatch_async(dispatch_get_main_queue(), ^{
                vlt_invoke_block(self.onError, error);
            });
            [self markAsFinished];
        }];
}

@end
