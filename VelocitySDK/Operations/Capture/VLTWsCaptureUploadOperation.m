//
//  VLTWsCaptureUploadOperation.m
//  VelocitySDK iOS
//
//  Created by Vytautas Galaunia on 25/10/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTWsCaptureUploadOperation.h"
#import "Velocity.pbobjc.h"
#import "VLTProtobufHelper.h"
#import "VLTUserDataStore.h"
#import "VLTMacros.h"

@interface VLTWsCaptureUploadOperation ()

@property (atomic, strong) NSError *error;

@end

@implementation VLTWsCaptureUploadOperation

- (BOOL)isAsynchronous
{
    return YES;
}

- (void)processMotionData
{
    VLTPBRequest *req = [[VLTPBRequest alloc] init];
    req.sensorsArray = [[VLTProtobufHelper sensorsFromMotionData:self.motionData] mutableCopy];
    req.modelNamesArray = [NSMutableArray new];
    req.sessionId = [[VLTUserDataStore shared] sessionId];

    vlt_weakify(self);
    __block NSUInteger bytesSent;
    bytesSent = [self.wsApiClient captureUpload:req
                                        success:^(VLTPBResponse * _Nonnull response) {
                                                       vlt_strongify(self);
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           vlt_invoke_block(self.onSuccess, bytesSent);
                                                       });
                                                       [self markAsFinished];
                                                   }
                                                   failure:^(NSError * _Nonnull error) {
                                                       vlt_strongify(self);
                                                       self.error = error;
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           vlt_invoke_block(self.onError, bytesSent, error);
                                                       });
                                                       [self markAsFinished];
                                                   }];
}



@end
