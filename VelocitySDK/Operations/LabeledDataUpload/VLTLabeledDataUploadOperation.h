//
//  VLTLabeledDataUploadOperation.h
//  VelocitySDK
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTMotionDataOperation.h"

@interface VLTLabeledDataUploadOperation : VLTMotionDataOperation

@property (atomic, strong, readonly, nonnull) NSArray<NSString *> *labels;

@property (atomic, assign, readonly) BOOL success;
@property (atomic, copy, nullable) void (^onSuccess)(void);

@property (atomic, strong, readonly, nullable) NSError *error;
@property (atomic, copy, nullable) void (^onError)(NSError *_Nonnull);

- (nonnull instancetype)initWithMotionData:(nonnull NSArray<VLTData *> *)motionData
                                    labels:(nonnull NSArray<NSString *> *)labels;

@end
