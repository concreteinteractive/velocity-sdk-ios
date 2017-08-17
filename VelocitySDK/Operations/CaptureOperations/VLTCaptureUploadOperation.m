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

@interface VLTCaptureUploadOperation ()

@property (atomic, strong) NSError *error;

@end

@implementation VLTCaptureUploadOperation

- (BOOL)isAsynchronous
{
    return YES;
}

- (void)processCaptureRequest
{
    vlt_weakify(self);
    [[VLTApiClient shared] uploadForTracking:self.captureRequest
                                     success:^{
                                         vlt_strongify(self);
                                         [self markAsFinished];
                                     }
                                     failure:^(NSError * _Nonnull error) {
                                         vlt_strongify(self);
                                         self.error = error;
                                         vlt_invoke_block(self.onError, error);
                                         [self markAsFinished];
                                     }];
}

@end
