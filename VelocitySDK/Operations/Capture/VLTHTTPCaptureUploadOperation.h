//
//  VLTHTTPCaptureUploadOperation.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 17/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTMotionDataOperation.h"
#import "VLTCaptureUpload.h"

@interface VLTHTTPCaptureUploadOperation : VLTMotionDataOperation <VLTCaptureUpload>

@property (atomic, strong, readonly, nullable) NSError *error;
@property (atomic, copy, nullable) void(^onError)(NSUInteger bytesSent, NSError * _Nonnull);
@property (atomic, copy, nullable) void(^onSuccess)(NSUInteger bytesSent);

@property (nonatomic, assign, readonly) UInt32 sequenceIndex;

- (nonnull instancetype)initWithMotionData:(nonnull NSArray<VLTData *> *)motionData sequenceIndex:(UInt32)sequenceIndex;


@end
