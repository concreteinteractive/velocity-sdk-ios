//
//  VLTLabeledDataUploadOperation.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 21/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTMotionDataOperation.h"

@interface VLTLabeledDataUploadOperation : VLTMotionDataOperation

@property (atomic, strong, readonly) NSArray<NSString *> *labels;

@property (atomic, assign, readonly) BOOL success;
@property (atomic, copy) void(^onSuccess)();

@property (atomic, strong, readonly) NSError *error;
@property (atomic, copy) void(^onError)(NSError *);

- (nonnull instancetype)initWithMotionData:(nonnull NSArray<VLTData *> *)motionData
                                    labels:(nonnull NSArray<NSString *> *)labels;

@end
