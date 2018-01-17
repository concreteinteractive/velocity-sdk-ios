//
//  VLTHTTPCaptureUploadOperation.m
//  VelocitySDK
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTHTTPCaptureUploadOperation.h"
#import "VLTApiClient.h"
#import "VLTConfig.h"
#import "VLTMacros.h"
#import "VLTProtobufHelper.h"
#import "VLTUserDataStore.h"

@interface VLTHTTPCaptureUploadOperation ()

@property (atomic, strong) NSError *error;

@end

@implementation VLTHTTPCaptureUploadOperation

- (BOOL)isAsynchronous
{
    return YES;
}

- (void)processMotionData
{
    VLTPBCapture *captureRequest = [VLTProtobufHelper captureFromDatas:self.motionData
                                                                   ifa:[VLTUserDataStore shared].IFA
                                                          impressionId:[VLTUserDataStore shared].sessionId];
    vlt_weakify(self);
    [[VLTApiClient shared] uploadForTracking:captureRequest
        success:^(NSUInteger bytesSent) {
            vlt_strongify(self);
            [self markAsFinished];
            dispatch_async(dispatch_get_main_queue(), ^{
                vlt_invoke_block(self.onSuccess, bytesSent);
            });
        }
        failure:^(NSUInteger bytesSent, NSError *_Nonnull error) {
            vlt_strongify(self);
            self.error = error;
            dispatch_async(dispatch_get_main_queue(), ^{
                vlt_invoke_block(self.onError, bytesSent, error);
            });
            [self markAsFinished];
        }];
}

@end
