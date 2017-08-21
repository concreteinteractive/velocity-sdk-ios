//
//  VLTCaptureUploadOperation.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 17/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTCaptureUploadOperation.h"
#import "VLTApiClient.h"
#import "VLTMacros.h"
#import "VLTProtobufHelper.h"
#import "VLTConfig.h"
#import "VLTUserDataStore.h"

@interface VLTCaptureUploadOperation ()

@property (atomic, strong) NSError *error;

@end

@implementation VLTCaptureUploadOperation

- (BOOL)isAsynchronous
{
    return YES;
}

- (void)processMotionData
{
    VLTPBCapture *captureRequest = [VLTProtobufHelper captureFromDatas:self.motionData
                                                                   ifa:[VLTConfig IFA]
                                                         sequenceIndex:self.sequenceIndex
                                                          impressionId:[VLTUserDataStore shared].impressionId];
    vlt_weakify(self);
    [[VLTApiClient shared] uploadForTracking:captureRequest
                                     success:^{
                                         vlt_strongify(self);
                                         [self markAsFinished];
                                     }
                                     failure:^(NSError * _Nonnull error) {
                                         vlt_strongify(self);
                                         self.error = error;
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             vlt_invoke_block(self.onError, error);
                                         });
                                         [self markAsFinished];
                                     }];
}

@end
