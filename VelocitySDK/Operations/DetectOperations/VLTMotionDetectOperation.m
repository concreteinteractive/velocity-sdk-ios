//
//  VLTMotionDetectOperation.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 17/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTMotionDetectOperation.h"
#import "VLTApiClient.h"
#import "VLTMacros.h"
#import "VLTMotionDetectResult.h"

@interface VLTMotionDetectOperation ()

@property (atomic, strong) VLTMotionDetectResult *result;
@property (atomic, strong) NSError *error;

@end

@implementation VLTMotionDetectOperation

- (BOOL)isAsynchronous
{
    return YES;
}

- (void)processMotionRequest
{
    vlt_weakify(self);
    [[VLTApiClient shared] detect:self.motionRequest
                          success:^(VLTMotionDetectResult * _Nonnull result) {
                              vlt_strongify(self);
                              self.result = result;
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  vlt_invoke_block(self.onMotionDetect, result);
                              });
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
