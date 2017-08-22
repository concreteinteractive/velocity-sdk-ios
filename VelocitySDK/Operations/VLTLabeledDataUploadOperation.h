//
//  VLTLabeledDataUploadOperation.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 21/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTMotionDataOperation.h"

@interface VLTLabeledDataUploadOperation : VLTMotionDataOperation

@property (atomic, strong, readonly, nonnull) NSArray<NSString *> *labels;

@property (atomic, assign, readonly) BOOL success;
@property (atomic, copy, nullable) void(^onSuccess)();

@property (atomic, strong, readonly, nullable) NSError *error;
@property (atomic, copy, nullable) void(^onError)(NSError * _Nonnull);

- (nonnull instancetype)initWithMotionData:(nonnull NSArray<VLTData *> *)motionData
                             sequenceIndex:(UInt32)sequenceIndex
                                    labels:(nonnull NSArray<NSString *> *)labels;

@end
