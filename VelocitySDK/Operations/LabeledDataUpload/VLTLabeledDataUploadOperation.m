//
//  VLTLabeledDataUploadOperation.m
//  VelocitySDK
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTLabeledDataUploadOperation.h"
#import "VLTApiClient.h"
#import "VLTConfig.h"
#import "VLTMacros.h"
#import "VLTProtobufHelper.h"
#import "VLTUserDataStore.h"

@interface VLTLabeledDataUploadOperation ()

@property (atomic, strong) NSArray<NSString *> *labels;
@property (atomic, assign) BOOL success;
@property (atomic, strong) NSError *error;

@end

@implementation VLTLabeledDataUploadOperation

- (nonnull instancetype)initWithMotionData:(nonnull NSArray<VLTData *> *)motionData
                                    labels:(nonnull NSArray<NSString *> *)labels;
{
    self = [super initWithMotionData:motionData];
    if (self) {
        _labels = labels;
    }
    return self;
}

- (BOOL)isAsynchronous
{
    return YES;
}

- (void)processMotionData
{
    VLTPBCapture *capture = [VLTProtobufHelper captureFromDatas:self.motionData
                                                            ifa:[VLTConfig IFA]
                                                  sequenceIndex:1
                                                   impressionId:[[VLTUserDataStore shared] sessionId]];
    vlt_weakify(self);
    [[VLTApiClient shared] uploadMotionData:capture
        labels:self.labels
        success:^{
            vlt_strongify(self);
            self.success = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                vlt_invoke_block(self.onSuccess);
            });
            [self markAsFinished];
        }
        failure:^(NSError *_Nonnull error) {
            vlt_strongify(self);
            self.success = NO;
            self.error   = error;
            dispatch_async(dispatch_get_main_queue(), ^{
                vlt_invoke_block(self.onError, error);
            });
            [self markAsFinished];
        }];
}

@end
